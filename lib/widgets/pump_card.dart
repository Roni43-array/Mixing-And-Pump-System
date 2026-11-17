import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import '../models/system_telemetry.dart';

class PumpCard extends StatelessWidget {
  final PumpTelemetry pump;
  final ValueChanged<bool> onCommandChanged;
  final ValueChanged<double> onPressureSvChanged;
  final ValueChanged<String> onPidModeChanged;
  final ValueChanged<double> onManualOutputChanged;
  final VoidCallback onOpenTuningSheet;

  const PumpCard({
    super.key,
    required this.pump,
    required this.onCommandChanged,
    required this.onPressureSvChanged,
    required this.onPidModeChanged,
    required this.onManualOutputChanged,
    required this.onOpenTuningSheet,
  });

  @override
  Widget build(BuildContext context) {
    final bool isRunning = pump.isRunning;
    final Color statusColor =
        isRunning ? const Color(0xFF38BDF8) : const Color(0xFF64748B);
    final double pressureError = pump.pressureSv - pump.pressurePv;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isRunning
              ? const Color(0xFF38BDF8).withValues(alpha: 0.45)
              : const Color(0xFF334155),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header Unit Pompa
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  CupertinoIcons.drop_fill,
                  color: statusColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'UNIT TRANSFER PUMP & PID',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.4,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Ampere, Frekuensi, Pressure PV/SV & PID Loop',
                      style: TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              _PumpStatusBadge(isRunning: isRunning),
            ],
          ),
          const SizedBox(height: 18),

          // 2. Baris Elektrikal: Ampere & Frequency
          Row(
            children: [
              Expanded(
                child: _SmallMetricBox(
                  title: 'Ampere',
                  value: pump.currentAmpere.toStringAsFixed(2),
                  unit: 'A',
                  icon: CupertinoIcons.bolt_fill,
                  color: const Color(0xFFF59E0B),
                  progress: (pump.currentAmpere / 25.0).clamp(0.0, 1.0),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SmallMetricBox(
                  title: 'Frequency',
                  value: pump.frequencyHz.toStringAsFixed(1),
                  unit: 'Hz',
                  icon: CupertinoIcons.waveform_path,
                  color: const Color(0xFF38BDF8),
                  progress: (pump.frequencyHz / 50.0).clamp(0.0, 1.0),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 3. Panel Tekanan: Pressure PV & Pressure SV
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF334155)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          CupertinoIcons.gauge,
                          color: Color(0xFF22D3EE),
                          size: 17,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'PRESSURE MONITOR (PV vs SV)',
                          style: TextStyle(
                            color: Color(0xFFCBD5E1),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Error Δ: ${pressureError >= 0 ? '+' : ''}${pressureError.toStringAsFixed(2)} Bar',
                        style: const TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Baris PV dan SV berdampingan
                Row(
                  children: [
                    // Pressure PV (Aktual)
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B).withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFF22D3EE).withValues(alpha: 0.35),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Pressure PV (Aktual)',
                              style: TextStyle(
                                color: Color(0xFF94A3B8),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  pump.pressurePv.toStringAsFixed(2),
                                  style: const TextStyle(
                                    color: Color(0xFF22D3EE),
                                    fontSize: 26,
                                    fontWeight: FontWeight.w800,
                                    fontFeatures: [FontFeature.tabularFigures()],
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Text(
                                  'Bar',
                                  style: TextStyle(
                                    color: Color(0xFF22D3EE),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Pressure SV (Target + Tombol +/-)
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B).withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFFA855F7).withValues(alpha: 0.35),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Pressure SV (Target)',
                              style: TextStyle(
                                color: Color(0xFF94A3B8),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.baseline,
                                  textBaseline: TextBaseline.alphabetic,
                                  children: [
                                    Text(
                                      pump.pressureSv.toStringAsFixed(2),
                                      style: const TextStyle(
                                        color: Color(0xFFC084FC),
                                        fontSize: 24,
                                        fontWeight: FontWeight.w800,
                                        fontFeatures: [
                                          FontFeature.tabularFigures()
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 3),
                                    const Text(
                                      'Bar',
                                      style: TextStyle(
                                        color: Color(0xFFC084FC),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    _MiniStepBtn(
                                      icon: CupertinoIcons.minus,
                                      onTap: () {
                                        HapticFeedback.selectionClick();
                                        onPressureSvChanged(
                                          pump.pressureSv - 0.25,
                                        );
                                      },
                                    ),
                                    const SizedBox(width: 4),
                                    _MiniStepBtn(
                                      icon: CupertinoIcons.plus,
                                      onTap: () {
                                        HapticFeedback.selectionClick();
                                        onPressureSvChanged(
                                          pump.pressureSv + 0.25,
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Visual Bar Perbandingan PV terhadap skala 10 Bar
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Aktual PV: ${(pump.pressurePv / 10.0 * 100).clamp(0, 100).toStringAsFixed(0)}% dari 10 Bar',
                          style: const TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 11,
                          ),
                        ),
                        Text(
                          'Target SV: ${pump.pressureSv.toStringAsFixed(2)} Bar',
                          style: const TextStyle(
                            color: Color(0xFFC084FC),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: (pump.pressurePv / 10.0).clamp(0.0, 1.0),
                        minHeight: 8,
                        backgroundColor: const Color(0xFF1E293B),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF22D3EE),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // 4. Panel PID Control
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF334155)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          CupertinoIcons.slider_horizontal_3,
                          color: Color(0xFF38BDF8),
                          size: 17,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'PID CONTROLLER',
                          style: TextStyle(
                            color: Color(0xFFCBD5E1),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ],
                    ),
                    CupertinoSlidingSegmentedControl<String>(
                      backgroundColor: const Color(0xFF1E293B),
                      thumbColor: const Color(0xFF0284C7),
                      groupValue: pump.pid.mode,
                      children: const {
                        'AUTO': Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          child: Text(
                            'AUTO',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        'MANUAL': Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          child: Text(
                            'MANUAL',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      },
                      onValueChanged: (mode) {
                        if (mode != null) {
                          HapticFeedback.selectionClick();
                          onPidModeChanged(mode);
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Tiga Kotak Parameter Kp, Ki, Kd + Output %
                Row(
                  children: [
                    Expanded(
                      child: _PidParamChip(
                        label: 'Kp',
                        value: pump.pid.kp.toStringAsFixed(2),
                        color: const Color(0xFF38BDF8),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _PidParamChip(
                        label: 'Ki',
                        value: pump.pid.ki.toStringAsFixed(2),
                        color: const Color(0xFF10B981),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _PidParamChip(
                        label: 'Kd',
                        value: pump.pid.kd.toStringAsFixed(3),
                        color: const Color(0xFFF59E0B),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _PidParamChip(
                        label: 'Out (MV)',
                        value: '${pump.pid.outputPercent.toStringAsFixed(0)}%',
                        color: const Color(0xFFC084FC),
                      ),
                    ),
                  ],
                ),

                // Jika mode MANUAL, tampilkan slider pengatur Output MV secara langsung
                if (pump.pid.mode == 'MANUAL') ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Text(
                        'Manual Output:',
                        style: TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 12,
                        ),
                      ),
                      Expanded(
                        child: CupertinoSlider(
                          value: pump.pid.outputPercent.clamp(0.0, 100.0),
                          min: 0.0,
                          max: 100.0,
                          activeColor: const Color(0xFFC084FC),
                          onChanged: onManualOutputChanged,
                        ),
                      ),
                      Text(
                        '${pump.pid.outputPercent.toStringAsFixed(0)}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 12),

                // Tombol Tune PID & SV
                SizedBox(
                  width: double.infinity,
                  child: CupertinoButton(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(10),
                    onPressed: onOpenTuningSheet,
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          CupertinoIcons.tuningfork,
                          color: Color(0xFF38BDF8),
                          size: 16,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Tune Parameter PID & Setpoint SV',
                          style: TextStyle(
                            color: Color(0xFF38BDF8),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // 5. Tombol Kontrol Utama START & STOP Pump
          Row(
            children: [
              Expanded(
                child: _PumpActionButton(
                  label: 'START PUMP',
                  icon: CupertinoIcons.play_fill,
                  backgroundColor: const Color(0xFF10B981),
                  isEnabled: !isRunning,
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    onCommandChanged(true);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _PumpActionButton(
                  label: 'STOP PUMP',
                  icon: CupertinoIcons.stop_fill,
                  backgroundColor: const Color(0xFFEF4444),
                  isEnabled: isRunning,
                  onPressed: () {
                    HapticFeedback.heavyImpact();
                    onCommandChanged(false);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PumpStatusBadge extends StatelessWidget {
  final bool isRunning;

  const _PumpStatusBadge({required this.isRunning});

  @override
  Widget build(BuildContext context) {
    final Color color =
        isRunning ? const Color(0xFF38BDF8) : const Color(0xFF94A3B8);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            isRunning ? 'RUNNING' : 'STOPPED',
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
            ),
          ),
        ],
      ),
    );
  }
}

class _SmallMetricBox extends StatelessWidget {
  final String title;
  final String value;
  final String unit;
  final IconData icon;
  final Color color;
  final double progress;

  const _SmallMetricBox({
    required this.title,
    required this.value,
    required this.unit,
    required this.icon,
    required this.color,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 15, color: color),
              const SizedBox(width: 6),
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(width: 4),
              Text(
                unit,
                style: TextStyle(
                  color: color,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 5,
              backgroundColor: const Color(0xFF1E293B),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStepBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _MiniStepBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(7),
          border: Border.all(color: const Color(0xFF475569)),
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 14,
        ),
      ),
    );
  }
}

class _PidParamChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _PidParamChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.w800,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

class _PumpActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color backgroundColor;
  final bool isEnabled;
  final VoidCallback onPressed;

  const _PumpActionButton({
    required this.label,
    required this.icon,
    required this.backgroundColor,
    required this.isEnabled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isEnabled ? 1.0 : 0.38,
      child: CupertinoButton(
        padding: const EdgeInsets.symmetric(vertical: 14),
        color: backgroundColor,
        disabledColor: backgroundColor.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
        onPressed: isEnabled ? onPressed : null,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
