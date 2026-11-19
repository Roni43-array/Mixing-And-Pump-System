import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/system_telemetry.dart';

/// Kartu kontrol untuk Mixer 2 dan Pump 2:
/// Hanya berisi tombol Start, Stop, serta tampilan & pengatur Frequency (Hz).
class SimpleVfdCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String startLabel;
  final String stopLabel;
  final IconData icon;
  final Color activeColor;
  final SimpleVfdUnitTelemetry unit;
  final ValueChanged<bool> onCommandChanged;
  final ValueChanged<double> onFrequencyChanged;

  const SimpleVfdCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.startLabel,
    required this.stopLabel,
    required this.icon,
    required this.activeColor,
    required this.unit,
    required this.onCommandChanged,
    required this.onFrequencyChanged,
  });

  @override
  Widget build(BuildContext context) {
    final bool isRunning = unit.isRunning;
    final Color statusColor = isRunning ? activeColor : const Color(0xFF64748B);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isRunning
              ? activeColor.withValues(alpha: 0.45)
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
          // Header Unit
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
                  icon,
                  color: statusColor,
                  size: 25,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.4,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              _SimpleStatusBadge(
                isRunning: isRunning,
                activeColor: activeColor,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Panel Tampilan & Pengatur Frequency (Hz)
          Container(
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          CupertinoIcons.waveform_path_ecg,
                          size: 16,
                          color: Color(0xFF38BDF8),
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Frequency Control (VFD)',
                          style: TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        _FreqStepButton(
                          icon: CupertinoIcons.minus,
                          onTap: () {
                            HapticFeedback.selectionClick();
                            onFrequencyChanged(unit.frequencyHz - 1.0);
                          },
                        ),
                        const SizedBox(width: 10),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              unit.frequencyHz.toStringAsFixed(1),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                fontFeatures: [FontFeature.tabularFigures()],
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Text(
                              'Hz',
                              style: TextStyle(
                                color: Color(0xFF38BDF8),
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 10),
                        _FreqStepButton(
                          icon: CupertinoIcons.plus,
                          onTap: () {
                            HapticFeedback.selectionClick();
                            onFrequencyChanged(unit.frequencyHz + 1.0);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: CupertinoSlider(
                    value: unit.frequencyHz.clamp(0.0, 50.0),
                    min: 0.0,
                    max: 50.0,
                    activeColor: const Color(0xFF38BDF8),
                    onChanged: onFrequencyChanged,
                  ),
                ),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '0.0 Hz',
                      style: TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 10,
                      ),
                    ),
                    Text(
                      '25.0 Hz',
                      style: TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 10,
                      ),
                    ),
                    Text(
                      'Rated 50.0 Hz',
                      style: TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Tombol Kontrol START & STOP
          Row(
            children: [
              Expanded(
                child: _SimpleActionButton(
                  label: startLabel,
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
                child: _SimpleActionButton(
                  label: stopLabel,
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

class _SimpleStatusBadge extends StatelessWidget {
  final bool isRunning;
  final Color activeColor;

  const _SimpleStatusBadge({
    required this.isRunning,
    required this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    final Color color = isRunning ? activeColor : const Color(0xFF94A3B8);

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

class _FreqStepButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _FreqStepButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(8),
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

class _SimpleActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color backgroundColor;
  final bool isEnabled;
  final VoidCallback onPressed;

  const _SimpleActionButton({
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
