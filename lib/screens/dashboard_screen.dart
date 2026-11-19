import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/system_telemetry.dart';
import '../services/firebase_scada_service.dart';
import '../widgets/mixer_card.dart';
import '../widgets/pid_tuning_sheet.dart';
import '../widgets/pump_card.dart';
import '../widgets/simple_vfd_card.dart';

class DashboardScreen extends StatefulWidget {
  final FirebaseScadaService scadaService;

  const DashboardScreen({
    super.key,
    required this.scadaService,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  void _openPidTuningModal(PumpTelemetry pump) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (ctx) => Material(
        color: Colors.transparent,
        child: PidTuningSheet(
          pump: pump,
          onSave: ({
            required double pressureSv,
            required String mode,
            required double kp,
            required double ki,
            required double kd,
          }) async {
            await widget.scadaService.updatePressureSv(pressureSv);
            await widget.scadaService.updatePidConfig(
              mode: mode,
              kp: kp,
              ki: ki,
              kd: kd,
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<SystemTelemetry>(
      stream: widget.scadaService.telemetryStream,
      initialData: widget.scadaService.currentState,
      builder: (context, snapshot) {
        final telemetry = snapshot.data ?? SystemTelemetry.initial();
        final mixer = telemetry.mixer;
        final mixer2 = telemetry.mixer2;
        final pump = telemetry.pump;
        final pump2 = telemetry.pump2;

        return CupertinoPageScaffold(
          backgroundColor: const Color(0xFF0F172A),
          navigationBar: CupertinoNavigationBar(
            backgroundColor: const Color(0xFF0F172A).withValues(alpha: 0.92),
            border: const Border(
              bottom: BorderSide(color: Color(0xFF1E293B), width: 1),
            ),
            middle: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipOval(
                  child: Image.asset(
                    'assets/icon/app_icon.png',
                    width: 28,
                    height: 28,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 8),
                const Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'MIXING & PUMP SCADA',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      'iOS Industrial Control Panel',
                      style: TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            trailing: CupertinoButton(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              color: const Color(0xFFEF4444).withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(8),
              onPressed: () {
                HapticFeedback.heavyImpact();
                widget.scadaService.emergencyStopAll();
              },
              child: const Text(
                'E-STOP',
                style: TextStyle(
                  color: Color(0xFFEF4444),
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          child: SafeArea(
            child: DefaultTextStyle(
              style: const TextStyle(
                fontFamily: '.SF Pro Text',
                color: Colors.white,
              ),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 32),
                children: [
                  // Banner Status Koneksi Firebase & Mode Simulasi
                  _ConnectionAndSimulationBar(
                    isFirebaseConnected: telemetry.isFirebaseConnected,
                    isSimulationActive: telemetry.isSimulationActive,
                    onToggleSimulation: (val) {
                      widget.scadaService.toggleSimulation(val);
                    },
                  ),
                  const SizedBox(height: 16),

                  // Bagian 1: MIXER 1 Card (Start, Stop, Arus, Frequency & Frequency Control)
                  MixerCard(
                    mixer: mixer,
                    onCommandChanged: (start) {
                      widget.scadaService.setMixerRunning(start);
                    },
                    onFrequencyChanged: (freq) {
                      widget.scadaService.updateMixerFrequency(freq);
                    },
                  ),
                  const SizedBox(height: 18),

                  // Bagian 2: MIXER 2 Card (Start, Stop, Monitoring Arus & Frequency, Frequency Control)
                  SimpleVfdCard(
                    title: 'UNIT MIXER 2',
                    subtitle: 'Monitoring Arus, Frekuensi & Kontrol VFD',
                    startLabel: 'START MIXER 2',
                    stopLabel: 'STOP MIXER 2',
                    icon: CupertinoIcons.slowmo,
                    activeColor: const Color(0xFF10B981),
                    unit: mixer2,
                    onCommandChanged: (start) {
                      widget.scadaService.setMixer2Running(start);
                    },
                    onFrequencyChanged: (freq) {
                      widget.scadaService.updateMixer2Frequency(freq);
                    },
                  ),
                  const SizedBox(height: 18),

                  // Bagian 3: PUMP 1 Card (Start, Stop, Ampere, Frequency, Pressure PV/SV, PID Control)
                  PumpCard(
                    pump: pump,
                    onCommandChanged: (start) {
                      widget.scadaService.setPumpRunning(start);
                    },
                    onPressureSvChanged: (newSv) {
                      widget.scadaService.updatePressureSv(newSv);
                    },
                    onPidModeChanged: (newMode) {
                      widget.scadaService.updatePidConfig(mode: newMode);
                    },
                    onManualOutputChanged: (newManualOut) {
                      widget.scadaService.updatePidConfig(
                        manualOutputPercent: newManualOut,
                      );
                    },
                    onOpenTuningSheet: () => _openPidTuningModal(pump),
                  ),
                  const SizedBox(height: 18),

                  // Bagian 4: PUMP 2 Card (Start, Stop, Monitoring Arus & Frequency, Frequency Control)
                  SimpleVfdCard(
                    title: 'UNIT PUMP 2',
                    subtitle: 'Monitoring Arus, Frekuensi & Kontrol VFD',
                    startLabel: 'START PUMP 2',
                    stopLabel: 'STOP PUMP 2',
                    icon: CupertinoIcons.drop_fill,
                    activeColor: const Color(0xFF38BDF8),
                    unit: pump2,
                    onCommandChanged: (start) {
                      widget.scadaService.setPump2Running(start);
                    },
                    onFrequencyChanged: (freq) {
                      widget.scadaService.updatePump2Frequency(freq);
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ConnectionAndSimulationBar extends StatelessWidget {
  final bool isFirebaseConnected;
  final bool isSimulationActive;
  final ValueChanged<bool> onToggleSimulation;

  const _ConnectionAndSimulationBar({
    required this.isFirebaseConnected,
    required this.isSimulationActive,
    required this.onToggleSimulation,
  });

  @override
  Widget build(BuildContext context) {
    final Color dbColor = isFirebaseConnected
        ? const Color(0xFF10B981)
        : const Color(0xFFF59E0B);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Row(
        children: [
          Container(
            width: 9,
            height: 9,
            decoration: BoxDecoration(
              color: dbColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isFirebaseConnected
                      ? 'Firebase Realtime DB: Connected'
                      : 'Firebase Realtime DB: Demo / Lokal',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  isSimulationActive
                      ? 'Simulator Fisika VFD & Loop PID Aktif'
                      : 'Membaca data murni dari node Firebase',
                  style: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const Text(
            'Simulasi',
            style: TextStyle(
              color: Color(0xFFCBD5E1),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 6),
          Transform.scale(
            scale: 0.82,
            child: CupertinoSwitch(
              value: isSimulationActive,
              activeTrackColor: const Color(0xFF0284C7),
              onChanged: onToggleSimulation,
            ),
          ),
        ],
      ),
    );
  }
}
