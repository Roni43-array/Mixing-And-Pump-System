import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/system_telemetry.dart';

class MixerCard extends StatelessWidget {
  final MixerTelemetry mixer;
  final ValueChanged<bool> onCommandChanged;
  final ValueChanged<double> onFrequencyChanged;

  const MixerCard({
    super.key,
    required this.mixer,
    required this.onCommandChanged,
    required this.onFrequencyChanged,
  });

  @override
  Widget build(BuildContext context) {
    final bool isRunning = mixer.isRunning;
    final Color statusColor =
        isRunning ? const Color(0xFF10B981) : const Color(0xFF64748B);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isRunning
              ? const Color(0xFF10B981).withValues(alpha: 0.45)
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
          // Header Mixer
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
                  CupertinoIcons.slowmo,
                  color: statusColor,
                  size: 26,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'UNIT MIXER AGITATOR',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.4,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Monitoring Arus & Frekuensi Inverter',
                      style: TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              _StatusBadge(isRunning: isRunning),
            ],
          ),
          const SizedBox(height: 18),

          // Baris Data Monitoring Arus (Ampere) & Monitoring Frequency (Hz)
          Row(
            children: [
              Expanded(
                child: _MetricTile(
                  label: 'Arus (Current)',
                  value: mixer.currentAmpere.toStringAsFixed(2),
                  unit: 'A',
                  icon: CupertinoIcons.bolt_fill,
                  accentColor: const Color(0xFFF59E0B),
                  progress: (mixer.currentAmpere / 20.0).clamp(0.0, 1.0),
                  maxLabel: 'Maks 20.0 A',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MetricTile(
                  label: 'Frequency',
                  value: mixer.frequencyHz.toStringAsFixed(1),
                  unit: 'Hz',
                  icon: CupertinoIcons.waveform_path_ecg,
                  accentColor: const Color(0xFF38BDF8),
                  progress: (mixer.frequencyHz / 50.0).clamp(0.0, 1.0),
                  maxLabel: 'Rated 50.0 Hz',
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Panel Frequency Control (VFD)
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
                          CupertinoIcons.slider_horizontal_3,
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
                            onFrequencyChanged(mixer.setFrequencyHz - 1.0);
                          },
                        ),
                        const SizedBox(width: 10),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              mixer.setFrequencyHz.toStringAsFixed(1),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
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
                            onFrequencyChanged(mixer.setFrequencyHz + 1.0);
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
                    value: mixer.setFrequencyHz.clamp(0.0, 50.0),
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
          const SizedBox(height: 18),

          // Tombol Kontrol START & STOP Mixer
          Row(
            children: [
              Expanded(
                child: _ControlButton(
                  label: 'START MIXER',
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
                child: _ControlButton(
                  label: 'STOP MIXER',
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

class _StatusBadge extends StatelessWidget {
  final bool isRunning;

  const _StatusBadge({required this.isRunning});

  @override
  Widget build(BuildContext context) {
    final Color color =
        isRunning ? const Color(0xFF10B981) : const Color(0xFF94A3B8);

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

class _MetricTile extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final IconData icon;
  final Color accentColor;
  final double progress;
  final String maxLabel;

  const _MetricTile({
    required this.label,
    required this.value,
    required this.unit,
    required this.icon,
    required this.accentColor,
    required this.progress,
    required this.maxLabel,
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
              Icon(icon, size: 15, color: accentColor),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(width: 4),
              Text(
                unit,
                style: TextStyle(
                  color: accentColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: const Color(0xFF1E293B),
              valueColor: AlwaysStoppedAnimation<Color>(accentColor),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            maxLabel,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 10,
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

class _ControlButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color backgroundColor;
  final bool isEnabled;
  final VoidCallback onPressed;

  const _ControlButton({
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
