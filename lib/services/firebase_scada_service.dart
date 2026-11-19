import 'dart:async';
import 'dart:math' as math;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/system_telemetry.dart';

/// Service untuk menghubungkan aplikasi iOS dengan Firebase Realtime Database
/// sekaligus menyediakan Simulator Fisika VFD + PID secara real-time.
class FirebaseScadaService {
  static const String rootPath = 'mixing_pump_system';
  static const String databaseUrl =
      'https://mixing-and-pump-system-default-rtdb.asia-southeast1.firebasedatabase.app';

  static const FirebaseOptions _firebaseOptions = FirebaseOptions(
    apiKey: 'AIzaSyBrxZoMMi5snKq983FHICH4KCX_pWFA8Bk',
    appId: '1:81304669213:ios:55d9f11d2693e6fbe1caf4',
    messagingSenderId: '81304669213',
    projectId: 'mixing-and-pump-system',
    storageBucket: 'mixing-and-pump-system.firebasestorage.app',
    iosBundleId: 'com.antigravity.mixingPumpIosScada',
    databaseURL: databaseUrl,
  );

  final StreamController<SystemTelemetry> _controller =
      StreamController<SystemTelemetry>.broadcast();

  SystemTelemetry _state = SystemTelemetry.initial();
  DatabaseReference? _dbRef;
  StreamSubscription<DatabaseEvent>? _dbSubscription;
  Timer? _simulationTimer;

  // Variabel internal simulator PID
  double _integralError = 0.0;
  double _prevError = 0.0;
  final math.Random _rng = math.Random();

  Stream<SystemTelemetry> get telemetryStream => _controller.stream;
  SystemTelemetry get currentState => _state;

  /// Inisialisasi koneksi Firebase Realtime Database dan jalankan simulator jika diperlukan.
  Future<void> initialize() async {
    bool firebaseReady = false;
    try {
      FirebaseApp app;
      if (Firebase.apps.isEmpty) {
        app = await Firebase.initializeApp(options: _firebaseOptions);
      } else {
        app = Firebase.app();
      }
      _dbRef = FirebaseDatabase.instanceFor(
        app: app,
        databaseURL: databaseUrl,
      ).ref(rootPath);
      firebaseReady = true;
    } catch (_) {
      firebaseReady = false;
    }

    _state = _state.copyWith(
      isFirebaseConnected: firebaseReady,
      isSimulationActive: true,
    );
    _emit(_state);

    if (firebaseReady && _dbRef != null) {
      _listenToFirebase();
    }

    _startSimulationLoop();
  }

  void _listenToFirebase() {
    _dbSubscription?.cancel();
    _dbSubscription = _dbRef!.onValue.listen(
      (DatabaseEvent event) {
        final data = event.snapshot.value;
        if (data is Map) {
          _state = SystemTelemetry.fromFirebaseMap(
            data,
            isFirebaseConnected: true,
            isSimulationActive: _state.isSimulationActive,
          );
          _emit(_state);
        } else {
          _state = _state.copyWith(isFirebaseConnected: true);
          _emit(_state);
        }
      },
      onError: (_) {
        _state = _state.copyWith(isFirebaseConnected: false);
        _emit(_state);
      },
    );
  }

  /// Loop simulasi fisika motor VFD & kontrol PID setiap 400ms
  void _startSimulationLoop() {
    _simulationTimer?.cancel();
    _simulationTimer = Timer.periodic(const Duration(milliseconds: 400), (_) {
      if (!_state.isSimulationActive) return;

      const double dt = 0.4; // 400 ms dalam detik
      final now = DateTime.now().millisecondsSinceEpoch;

      // 1. Simulasi Dinamika MIXER (Arus & Frequency)
      final mixer = _state.mixer;
      double targetMixerFreq = mixer.isRunning ? 50.0 : 0.0;
      double newMixerFreq = _approach(mixer.frequencyHz, targetMixerFreq, 6.5);
      double newMixerAmp = 0.0;
      if (newMixerFreq > 0.5) {
        final jitter = (_rng.nextDouble() - 0.5) * 0.25;
        newMixerAmp = (newMixerFreq / 50.0) * 11.8 + jitter;
      }

      final updatedMixer = mixer.copyWith(
        frequencyHz: _round1(newMixerFreq),
        currentAmpere: _round2(math.max(0.0, newMixerAmp)),
        updatedAt: now,
      );

      // 2. Simulasi Dinamika PUMP + Kontrol PID Tekanan
      final pump = _state.pump;
      final pid = pump.pid;

      double newPidOutput = pid.outputPercent;
      double newPumpFreq = pump.frequencyHz;
      double newPressurePv = pump.pressurePv;
      double newPumpAmp = pump.currentAmpere;

      if (pump.isRunning) {
        if (pid.mode == 'AUTO') {
          // Perhitungan algoritma PID: e(t) = SV - PV
          final double error = pump.pressureSv - pump.pressurePv;
          _integralError = (_integralError + error * dt).clamp(-15.0, 15.0);
          final double derivative = (error - _prevError) / dt;
          _prevError = error;

          // Sinyal kendali PID (0 - 100%)
          final double rawPid =
              (pid.kp * error + pid.ki * _integralError + pid.kd * derivative) *
                  18.0 +
              (pump.pressureSv / 10.0) * 65.0;
          newPidOutput = rawPid.clamp(0.0, 100.0);
        } else {
          // Mode MANUAL mempertahankan output saat ini (default 70% jika baru nyala)
          if (newPidOutput < 5.0) newPidOutput = 70.0;
        }

        // Frekuensi VFD Pompa proporsional dengan PID Output (0 - 50 Hz)
        final double targetPumpFreq = (newPidOutput / 100.0) * 50.0;
        newPumpFreq = _approach(pump.frequencyHz, targetPumpFreq, 5.0);

        // Tekanan aktual (PV) merespon frekuensi pompa (50 Hz -> ~8.0 Bar)
        final double naturalPressure = (newPumpFreq / 50.0) * 8.0;
        final double noise = (_rng.nextDouble() - 0.5) * 0.06;
        newPressurePv = _approach(
          pump.pressurePv,
          naturalPressure + noise,
          0.45,
        ).clamp(0.0, 12.0);

        // Ampere pompa proporsional terhadap frekuensi dan tekanan beban
        final double ampNoise = (_rng.nextDouble() - 0.5) * 0.2;
        newPumpAmp = ((newPumpFreq / 50.0) * 14.5 +
                (newPressurePv / 10.0) * 2.2 +
                ampNoise)
            .clamp(0.0, 25.0);
      } else {
        // Saat pompa STOP: nilai turun bertahap ke 0
        _integralError = 0.0;
        _prevError = 0.0;
        newPidOutput = _approach(pid.outputPercent, 0.0, 12.0);
        newPumpFreq = _approach(pump.frequencyHz, 0.0, 8.0);
        newPressurePv = _approach(pump.pressurePv, 0.0, 0.6);
        newPumpAmp = _approach(pump.currentAmpere, 0.0, 4.0);
      }

      final updatedPump = pump.copyWith(
        frequencyHz: _round1(newPumpFreq),
        currentAmpere: _round2(newPumpAmp),
        pressurePv: _round2(newPressurePv),
        pid: pid.copyWith(outputPercent: _round1(newPidOutput)),
        updatedAt: now,
      );

      _state = _state.copyWith(
        mixer: updatedMixer,
        pump: updatedPump,
      );
      _emit(_state);

      // Jika terhubung ke Firebase dan simulator aktif, sinkronkan ke Firebase
      _syncToFirebaseIfConnected();
    });
  }

  /// Mengaktifkan atau mematikan simulator fisika internal
  void toggleSimulation(bool enabled) {
    _state = _state.copyWith(isSimulationActive: enabled);
    _emit(_state);
  }

  /// Perintah START / STOP untuk Mixer 1
  Future<void> setMixerRunning(bool start) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final updatedMixer = _state.mixer.copyWith(
      isRunning: start,
      command: start ? 'START' : 'STOP',
      updatedAt: now,
    );
    _state = _state.copyWith(mixer: updatedMixer);
    _emit(_state);

    if (_state.isFirebaseConnected && _dbRef != null) {
      await _dbRef!.child('mixer').update({
        'is_running': start,
        'command': start ? 'START' : 'STOP',
        'updated_at': now,
      });
    }
  }

  /// Perintah START / STOP untuk Mixer 2
  Future<void> setMixer2Running(bool start) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final double freq = start && _state.mixer2.frequencyHz == 0.0
        ? 50.0
        : (!start ? 0.0 : _state.mixer2.frequencyHz);
    final updatedMixer2 = _state.mixer2.copyWith(
      isRunning: start,
      command: start ? 'START' : 'STOP',
      frequencyHz: freq,
      updatedAt: now,
    );
    _state = _state.copyWith(mixer2: updatedMixer2);
    _emit(_state);

    if (_state.isFirebaseConnected && _dbRef != null) {
      await _dbRef!.child('mixer_2').update(updatedMixer2.toMap());
    }
  }

  /// Mengatur Frequency (Hz) untuk Mixer 2
  Future<void> updateMixer2Frequency(double newFreqHz) async {
    final clampedFreq = _round1(newFreqHz.clamp(0.0, 50.0));
    final now = DateTime.now().millisecondsSinceEpoch;
    final updatedMixer2 = _state.mixer2.copyWith(
      frequencyHz: clampedFreq,
      updatedAt: now,
    );
    _state = _state.copyWith(mixer2: updatedMixer2);
    _emit(_state);

    if (_state.isFirebaseConnected && _dbRef != null) {
      await _dbRef!.child('mixer_2').update({
        'frequency_hz': clampedFreq,
        'updated_at': now,
      });
    }
  }

  /// Perintah START / STOP untuk Pump 1
  Future<void> setPumpRunning(bool start) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final updatedPump = _state.pump.copyWith(
      isRunning: start,
      command: start ? 'START' : 'STOP',
      updatedAt: now,
    );
    _state = _state.copyWith(pump: updatedPump);
    _emit(_state);

    if (_state.isFirebaseConnected && _dbRef != null) {
      await _dbRef!.child('pump').update({
        'is_running': start,
        'command': start ? 'START' : 'STOP',
        'updated_at': now,
      });
    }
  }

  /// Perintah START / STOP untuk Pump 2
  Future<void> setPump2Running(bool start) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final double freq = start && _state.pump2.frequencyHz == 0.0
        ? 50.0
        : (!start ? 0.0 : _state.pump2.frequencyHz);
    final updatedPump2 = _state.pump2.copyWith(
      isRunning: start,
      command: start ? 'START' : 'STOP',
      frequencyHz: freq,
      updatedAt: now,
    );
    _state = _state.copyWith(pump2: updatedPump2);
    _emit(_state);

    if (_state.isFirebaseConnected && _dbRef != null) {
      await _dbRef!.child('pump_2').update(updatedPump2.toMap());
    }
  }

  /// Mengatur Frequency (Hz) untuk Pump 2
  Future<void> updatePump2Frequency(double newFreqHz) async {
    final clampedFreq = _round1(newFreqHz.clamp(0.0, 50.0));
    final now = DateTime.now().millisecondsSinceEpoch;
    final updatedPump2 = _state.pump2.copyWith(
      frequencyHz: clampedFreq,
      updatedAt: now,
    );
    _state = _state.copyWith(pump2: updatedPump2);
    _emit(_state);

    if (_state.isFirebaseConnected && _dbRef != null) {
      await _dbRef!.child('pump_2').update({
        'frequency_hz': clampedFreq,
        'updated_at': now,
      });
    }
  }

  /// Mengubah nilai Setpoint Tekanan (Pressure SV)
  Future<void> updatePressureSv(double newSv) async {
    final clampedSv = _round2(newSv.clamp(0.5, 10.0));
    final now = DateTime.now().millisecondsSinceEpoch;
    final updatedPump = _state.pump.copyWith(
      pressureSv: clampedSv,
      updatedAt: now,
    );
    _state = _state.copyWith(pump: updatedPump);
    _emit(_state);

    if (_state.isFirebaseConnected && _dbRef != null) {
      await _dbRef!.child('pump').update({
        'pressure_sv': clampedSv,
        'updated_at': now,
      });
    }
  }

  /// Mengubah konfigurasi PID Control (Mode AUTO/MANUAL, Kp, Ki, Kd, atau Manual Output)
  Future<void> updatePidConfig({
    String? mode,
    double? kp,
    double? ki,
    double? kd,
    double? manualOutputPercent,
  }) async {
    final currentPid = _state.pump.pid;
    final updatedPid = currentPid.copyWith(
      mode: mode ?? currentPid.mode,
      kp: kp != null ? double.parse(kp.toStringAsFixed(3)) : currentPid.kp,
      ki: ki != null ? double.parse(ki.toStringAsFixed(3)) : currentPid.ki,
      kd: kd != null ? double.parse(kd.toStringAsFixed(3)) : currentPid.kd,
      outputPercent: manualOutputPercent != null
          ? _round1(manualOutputPercent.clamp(0.0, 100.0))
          : currentPid.outputPercent,
    );

    final now = DateTime.now().millisecondsSinceEpoch;
    final updatedPump = _state.pump.copyWith(
      pid: updatedPid,
      updatedAt: now,
    );
    _state = _state.copyWith(pump: updatedPump);
    _emit(_state);

    if (_state.isFirebaseConnected && _dbRef != null) {
      await _dbRef!.child('pump/pid').update(updatedPid.toMap());
    }
  }

  /// Emergency Stop: Mematikan seluruh Mixer dan Pump secara bersamaan
  Future<void> emergencyStopAll() async {
    await setMixerRunning(false);
    await setMixer2Running(false);
    await setPumpRunning(false);
    await setPump2Running(false);
  }

  Future<void> _syncToFirebaseIfConnected() async {
    if (!_state.isFirebaseConnected || _dbRef == null) return;
    try {
      await _dbRef!.update({
        'mixer': _state.mixer.toMap(),
        'mixer_2': _state.mixer2.toMap(),
        'pump': _state.pump.toMap(),
        'pump_2': _state.pump2.toMap(),
      });
    } catch (_) {
      // Abaikan error tulis sesaat pada loop simulasi
    }
  }

  void _emit(SystemTelemetry telemetry) {
    if (!_controller.isClosed) {
      _controller.add(telemetry);
    }
  }

  double _approach(double current, double target, double maxDelta) {
    final diff = target - current;
    if (diff.abs() <= maxDelta) return target;
    return current + diff.sign * maxDelta;
  }

  double _round1(double val) => (val * 10).roundToDouble() / 10;
  double _round2(double val) => (val * 100).roundToDouble() / 100;

  void dispose() {
    _simulationTimer?.cancel();
    _dbSubscription?.cancel();
    _controller.close();
  }
}
