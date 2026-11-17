import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:material_ui/material_ui.dart';
import '../models/system_telemetry.dart';

class PidTuningSheet extends StatefulWidget {
  final PumpTelemetry pump;
  final Future<void> Function({
    required double pressureSv,
    required String mode,
    required double kp,
    required double ki,
    required double kd,
  }) onSave;

  const PidTuningSheet({
    super.key,
    required this.pump,
    required this.onSave,
  });

  @override
  State<PidTuningSheet> createState() => _PidTuningSheetState();
}

class _PidTuningSheetState extends State<PidTuningSheet> {
  late String _selectedMode;
  late TextEditingController _svController;
  late TextEditingController _kpController;
  late TextEditingController _kiController;
  late TextEditingController _kdController;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _selectedMode = widget.pump.pid.mode;
    _svController = TextEditingController(
      text: widget.pump.pressureSv.toStringAsFixed(2),
    );
    _kpController = TextEditingController(
      text: widget.pump.pid.kp.toStringAsFixed(2),
    );
    _kiController = TextEditingController(
      text: widget.pump.pid.ki.toStringAsFixed(2),
    );
    _kdController = TextEditingController(
      text: widget.pump.pid.kd.toStringAsFixed(3),
    );
  }

  @override
  void dispose() {
    _svController.dispose();
    _kpController.dispose();
    _kiController.dispose();
    _kdController.dispose();
    super.dispose();
  }

  void _applyPreset({
    required double kp,
    required double ki,
    required double kd,
  }) {
    setState(() {
      _kpController.text = kp.toStringAsFixed(2);
      _kiController.text = ki.toStringAsFixed(2);
      _kdController.text = kd.toStringAsFixed(3);
      _errorMessage = null;
    });
  }

  Future<void> _submit() async {
    final sv = double.tryParse(_svController.text.replaceAll(',', '.'));
    final kp = double.tryParse(_kpController.text.replaceAll(',', '.'));
    final ki = double.tryParse(_kiController.text.replaceAll(',', '.'));
    final kd = double.tryParse(_kdController.text.replaceAll(',', '.'));

    if (sv == null || sv < 0.5 || sv > 10.0) {
      setState(() {
        _errorMessage = 'Pressure SV harus bernilai antara 0.50 hingga 10.00 Bar.';
      });
      return;
    }

    if (kp == null || ki == null || kd == null || kp < 0 || ki < 0 || kd < 0) {
      setState(() {
        _errorMessage = 'Parameter Kp, Ki, dan Kd harus berupa angka positif.';
      });
      return;
    }

    await widget.onSave(
      pressureSv: sv,
      mode: _selectedMode,
      kp: kp,
      ki: ki,
      kd: kd,
    );
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(20, 16, 20, 24 + bottomInset),
      decoration: const BoxDecoration(
        color: Color(0xFF1E293B),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar iOS
            Center(
              child: Container(
                width: 42,
                height: 5,
                decoration: BoxDecoration(
                  color: const Color(0xFF475569),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Konfigurasi PID & Setpoint (SV)',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Icon(
                    CupertinoIcons.xmark_circle_fill,
                    color: Color(0xFF94A3B8),
                    size: 24,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Mode PID (AUTO / MANUAL)
            const Text(
              'Mode Kontrol PID',
              style: TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: CupertinoSlidingSegmentedControl<String>(
                backgroundColor: const Color(0xFF0F172A),
                thumbColor: const Color(0xFF0284C7),
                groupValue: _selectedMode,
                children: const {
                  'AUTO': Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      'AUTO (Closed-Loop)',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  'MANUAL': Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      'MANUAL (Open-Loop)',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                },
                onValueChanged: (val) {
                  if (val != null) {
                    setState(() => _selectedMode = val);
                  }
                },
              ),
            ),
            const SizedBox(height: 18),

            // Input Pressure SV
            _InputField(
              label: 'Target Tekanan / Pressure SV (Bar)',
              controller: _svController,
              suffix: 'Bar',
              helper: 'Rentang aman: 0.50 – 10.00 Bar',
            ),
            const SizedBox(height: 14),

            // Input Kp, Ki, Kd dalam 3 kolom
            Row(
              children: [
                Expanded(
                  child: _InputField(
                    label: 'Kp (Prop.)',
                    controller: _kpController,
                    suffix: '',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _InputField(
                    label: 'Ki (Integral)',
                    controller: _kiController,
                    suffix: '1/s',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _InputField(
                    label: 'Kd (Deriv.)',
                    controller: _kdController,
                    suffix: 's',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Tombol Preset Tuning Cepat
            const Text(
              'Preset Tuning Cepat:',
              style: TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _PresetChip(
                  title: 'Halus (Smooth)',
                  onTap: () => _applyPreset(kp: 1.10, ki: 0.30, kd: 0.04),
                ),
                _PresetChip(
                  title: 'Standar Pabrik',
                  onTap: () => _applyPreset(kp: 1.50, ki: 0.45, kd: 0.08),
                ),
                _PresetChip(
                  title: 'Respons Cepat',
                  onTap: () => _applyPreset(kp: 2.40, ki: 0.80, kd: 0.12),
                ),
              ],
            ),

            if (_errorMessage != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xFFEF4444).withValues(alpha: 0.5),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      CupertinoIcons.exclamationmark_triangle_fill,
                      color: Color(0xFFEF4444),
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(
                          color: Color(0xFFFCA5A5),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 20),

            // Tombol Simpan ke Firebase
            SizedBox(
              width: double.infinity,
              child: CupertinoButton(
                color: const Color(0xFF0284C7),
                borderRadius: BorderRadius.circular(14),
                onPressed: _submit,
                child: const Text(
                  'Kirim Parameter ke Firebase',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String suffix;
  final String? helper;

  const _InputField({
    required this.label,
    required this.controller,
    required this.suffix,
    this.helper,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFFCBD5E1),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        CupertinoTextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFF334155)),
          ),
          suffix: suffix.isNotEmpty
              ? Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Text(
                    suffix,
                    style: const TextStyle(
                      color: Color(0xFF38BDF8),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              : null,
        ),
        if (helper != null) ...[
          const SizedBox(height: 4),
          Text(
            helper!,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 11,
            ),
          ),
        ],
      ],
    );
  }
}

class _PresetChip extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const _PresetChip({
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.4)),
        ),
        child: Text(
          title,
          style: const TextStyle(
            color: Color(0xFF38BDF8),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
