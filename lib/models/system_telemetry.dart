/// Model data untuk sistem Mixing & Pump dari Firebase Realtime Database.
library;

class MixerTelemetry {
  final bool isRunning;
  final String command; // "START" atau "STOP"
  final double currentAmpere; // Arus (A)
  final double frequencyHz; // Frekuensi VFD (Hz)
  final int updatedAt;

  const MixerTelemetry({
    required this.isRunning,
    required this.command,
    required this.currentAmpere,
    required this.frequencyHz,
    required this.updatedAt,
  });

  factory MixerTelemetry.initial() {
    return MixerTelemetry(
      isRunning: false,
      command: 'STOP',
      currentAmpere: 0.0,
      frequencyHz: 0.0,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );
  }

  factory MixerTelemetry.fromMap(Map<dynamic, dynamic>? map) {
    if (map == null) return MixerTelemetry.initial();
    return MixerTelemetry(
      isRunning: map['is_running'] == true,
      command: (map['command'] ?? 'STOP').toString(),
      currentAmpere: _toDouble(map['current_ampere'], 0.0),
      frequencyHz: _toDouble(map['frequency_hz'], 0.0),
      updatedAt: _toInt(map['updated_at'], DateTime.now().millisecondsSinceEpoch),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'is_running': isRunning,
      'command': command,
      'current_ampere': double.parse(currentAmpere.toStringAsFixed(2)),
      'frequency_hz': double.parse(frequencyHz.toStringAsFixed(1)),
      'updated_at': updatedAt,
    };
  }

  MixerTelemetry copyWith({
    bool? isRunning,
    String? command,
    double? currentAmpere,
    double? frequencyHz,
    int? updatedAt,
  }) {
    return MixerTelemetry(
      isRunning: isRunning ?? this.isRunning,
      command: command ?? this.command,
      currentAmpere: currentAmpere ?? this.currentAmpere,
      frequencyHz: frequencyHz ?? this.frequencyHz,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Model untuk unit tambahan (Mixer 2 & Pump 2) yang hanya berisi Start, Stop, dan atur Frequency.
class SimpleVfdUnitTelemetry {
  final bool isRunning;
  final String command; // "START" atau "STOP"
  final double frequencyHz; // Frekuensi yang diatur (0.0 - 50.0 Hz)
  final int updatedAt;

  const SimpleVfdUnitTelemetry({
    required this.isRunning,
    required this.command,
    required this.frequencyHz,
    required this.updatedAt,
  });

  factory SimpleVfdUnitTelemetry.initial() {
    return SimpleVfdUnitTelemetry(
      isRunning: false,
      command: 'STOP',
      frequencyHz: 0.0,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );
  }

  factory SimpleVfdUnitTelemetry.fromMap(Map<dynamic, dynamic>? map) {
    if (map == null) return SimpleVfdUnitTelemetry.initial();
    return SimpleVfdUnitTelemetry(
      isRunning: map['is_running'] == true,
      command: (map['command'] ?? 'STOP').toString(),
      frequencyHz: _toDouble(map['frequency_hz'], 0.0),
      updatedAt: _toInt(map['updated_at'], DateTime.now().millisecondsSinceEpoch),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'is_running': isRunning,
      'command': command,
      'frequency_hz': double.parse(frequencyHz.toStringAsFixed(1)),
      'updated_at': updatedAt,
    };
  }

  SimpleVfdUnitTelemetry copyWith({
    bool? isRunning,
    String? command,
    double? frequencyHz,
    int? updatedAt,
  }) {
    return SimpleVfdUnitTelemetry(
      isRunning: isRunning ?? this.isRunning,
      command: command ?? this.command,
      frequencyHz: frequencyHz ?? this.frequencyHz,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class PidControlData {
  final String mode; // "AUTO" atau "MANUAL"
  final double kp; // Proportional Gain
  final double ki; // Integral Gain
  final double kd; // Derivative Gain
  final double outputPercent; // Output PID (0 - 100 %)

  const PidControlData({
    required this.mode,
    required this.kp,
    required this.ki,
    required this.kd,
    required this.outputPercent,
  });

  factory PidControlData.initial() {
    return const PidControlData(
      mode: 'AUTO',
      kp: 1.50,
      ki: 0.45,
      kd: 0.08,
      outputPercent: 0.0,
    );
  }

  factory PidControlData.fromMap(Map<dynamic, dynamic>? map) {
    if (map == null) return PidControlData.initial();
    return PidControlData(
      mode: (map['mode'] ?? 'AUTO').toString().toUpperCase(),
      kp: _toDouble(map['kp'], 1.50),
      ki: _toDouble(map['ki'], 0.45),
      kd: _toDouble(map['kd'], 0.08),
      outputPercent: _toDouble(map['output_percent'], 0.0),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'mode': mode,
      'kp': double.parse(kp.toStringAsFixed(3)),
      'ki': double.parse(ki.toStringAsFixed(3)),
      'kd': double.parse(kd.toStringAsFixed(3)),
      'output_percent': double.parse(outputPercent.toStringAsFixed(1)),
    };
  }

  PidControlData copyWith({
    String? mode,
    double? kp,
    double? ki,
    double? kd,
    double? outputPercent,
  }) {
    return PidControlData(
      mode: mode ?? this.mode,
      kp: kp ?? this.kp,
      ki: ki ?? this.ki,
      kd: kd ?? this.kd,
      outputPercent: outputPercent ?? this.outputPercent,
    );
  }
}

class PumpTelemetry {
  final bool isRunning;
  final String command; // "START" atau "STOP"
  final double currentAmpere; // Arus Pompa (A)
  final double frequencyHz; // Frekuensi Pompa (Hz)
  final double pressurePv; // Process Value Tekanan (Bar)
  final double pressureSv; // Setpoint Value Tekanan (Bar)
  final PidControlData pid;
  final int updatedAt;

  const PumpTelemetry({
    required this.isRunning,
    required this.command,
    required this.currentAmpere,
    required this.frequencyHz,
    required this.pressurePv,
    required this.pressureSv,
    required this.pid,
    required this.updatedAt,
  });

  factory PumpTelemetry.initial() {
    return PumpTelemetry(
      isRunning: false,
      command: 'STOP',
      currentAmpere: 0.0,
      frequencyHz: 0.0,
      pressurePv: 0.0,
      pressureSv: 4.5,
      pid: PidControlData.initial(),
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );
  }

  factory PumpTelemetry.fromMap(Map<dynamic, dynamic>? map) {
    if (map == null) return PumpTelemetry.initial();
    return PumpTelemetry(
      isRunning: map['is_running'] == true,
      command: (map['command'] ?? 'STOP').toString(),
      currentAmpere: _toDouble(map['current_ampere'], 0.0),
      frequencyHz: _toDouble(map['frequency_hz'], 0.0),
      pressurePv: _toDouble(map['pressure_pv'], 0.0),
      pressureSv: _toDouble(map['pressure_sv'], 4.5),
      pid: PidControlData.fromMap(
        map['pid'] is Map ? map['pid'] as Map<dynamic, dynamic> : null,
      ),
      updatedAt: _toInt(map['updated_at'], DateTime.now().millisecondsSinceEpoch),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'is_running': isRunning,
      'command': command,
      'current_ampere': double.parse(currentAmpere.toStringAsFixed(2)),
      'frequency_hz': double.parse(frequencyHz.toStringAsFixed(1)),
      'pressure_pv': double.parse(pressurePv.toStringAsFixed(2)),
      'pressure_sv': double.parse(pressureSv.toStringAsFixed(2)),
      'pid': pid.toMap(),
      'updated_at': updatedAt,
    };
  }

  PumpTelemetry copyWith({
    bool? isRunning,
    String? command,
    double? currentAmpere,
    double? frequencyHz,
    double? pressurePv,
    double? pressureSv,
    PidControlData? pid,
    int? updatedAt,
  }) {
    return PumpTelemetry(
      isRunning: isRunning ?? this.isRunning,
      command: command ?? this.command,
      currentAmpere: currentAmpere ?? this.currentAmpere,
      frequencyHz: frequencyHz ?? this.frequencyHz,
      pressurePv: pressurePv ?? this.pressurePv,
      pressureSv: pressureSv ?? this.pressureSv,
      pid: pid ?? this.pid,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class SystemTelemetry {
  final MixerTelemetry mixer;
  final SimpleVfdUnitTelemetry mixer2;
  final PumpTelemetry pump;
  final SimpleVfdUnitTelemetry pump2;
  final bool isFirebaseConnected;
  final bool isSimulationActive;

  const SystemTelemetry({
    required this.mixer,
    required this.mixer2,
    required this.pump,
    required this.pump2,
    required this.isFirebaseConnected,
    required this.isSimulationActive,
  });

  factory SystemTelemetry.initial() {
    return SystemTelemetry(
      mixer: MixerTelemetry.initial(),
      mixer2: SimpleVfdUnitTelemetry.initial(),
      pump: PumpTelemetry.initial(),
      pump2: SimpleVfdUnitTelemetry.initial(),
      isFirebaseConnected: false,
      isSimulationActive: true,
    );
  }

  factory SystemTelemetry.fromFirebaseMap(
    Map<dynamic, dynamic>? rootMap, {
    required bool isFirebaseConnected,
    required bool isSimulationActive,
  }) {
    if (rootMap == null) {
      return SystemTelemetry.initial().copyWith(
        isFirebaseConnected: isFirebaseConnected,
        isSimulationActive: isSimulationActive,
      );
    }
    return SystemTelemetry(
      mixer: MixerTelemetry.fromMap(
        rootMap['mixer'] is Map ? rootMap['mixer'] as Map<dynamic, dynamic> : null,
      ),
      mixer2: SimpleVfdUnitTelemetry.fromMap(
        rootMap['mixer_2'] is Map
            ? rootMap['mixer_2'] as Map<dynamic, dynamic>
            : null,
      ),
      pump: PumpTelemetry.fromMap(
        rootMap['pump'] is Map ? rootMap['pump'] as Map<dynamic, dynamic> : null,
      ),
      pump2: SimpleVfdUnitTelemetry.fromMap(
        rootMap['pump_2'] is Map
            ? rootMap['pump_2'] as Map<dynamic, dynamic>
            : null,
      ),
      isFirebaseConnected: isFirebaseConnected,
      isSimulationActive: isSimulationActive,
    );
  }

  SystemTelemetry copyWith({
    MixerTelemetry? mixer,
    SimpleVfdUnitTelemetry? mixer2,
    PumpTelemetry? pump,
    SimpleVfdUnitTelemetry? pump2,
    bool? isFirebaseConnected,
    bool? isSimulationActive,
  }) {
    return SystemTelemetry(
      mixer: mixer ?? this.mixer,
      mixer2: mixer2 ?? this.mixer2,
      pump: pump ?? this.pump,
      pump2: pump2 ?? this.pump2,
      isFirebaseConnected: isFirebaseConnected ?? this.isFirebaseConnected,
      isSimulationActive: isSimulationActive ?? this.isSimulationActive,
    );
  }
}

double _toDouble(dynamic value, double fallback) {
  if (value == null) return fallback;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString()) ?? fallback;
}

int _toInt(dynamic value, int fallback) {
  if (value == null) return fallback;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString()) ?? fallback;
}
