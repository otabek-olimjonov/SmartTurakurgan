import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:smart_turakurgan/core/auth/auth_notifier.dart';
import 'package:smart_turakurgan/core/auth/secure_storage.dart';
import 'package:smart_turakurgan/core/theme/colors.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    try {
      final dio = ref.read(dioProvider);
      await dio.put('/update-profile', data: {
        'full_name': _nameCtrl.text.trim(),
        'phone_number': _phoneCtrl.text.trim(),
        'address': _addressCtrl.text.trim(),
      });
      // Refresh auth state — isNewUser will become false
      ref.invalidate(authProvider);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Xatolik yuz berdi. Qayta urinib ko\'ring.')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kColorCream,
      appBar: AppBar(
        title: const Text("Ma'lumotlaringizni kiriting"),
        automaticallyImplyLeading: false,
        actions: [
          TextButton(
            onPressed: () => ref.invalidate(authProvider),
            child: const Text('O\'tkazib yuborish'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Xizmatlardan to\'liq foydalanish uchun quyidagi ma\'lumotlarni kiriting.',
                style: TextStyle(fontSize: 14, color: kColorTextMuted, height: 1.5),
              ),
              const SizedBox(height: 24),
              _buildField(
                controller: _nameCtrl,
                label: "To'liq ism",
                hint: 'Karimov Ali Vohidovich',
                validator: (v) => v == null || v.trim().isEmpty ? 'Ismni kiriting' : null,
              ),
              const SizedBox(height: 14),
              _buildField(
                controller: _phoneCtrl,
                label: 'Telefon raqami',
                hint: '+998 90 123 45 67',
                keyboardType: TextInputType.phone,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Telefon raqamini kiriting';
                  if (!RegExp(r'^\+998\d{9}$').hasMatch(v.replaceAll(' ', ''))) {
                    return 'Format: +998901234567';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              _buildField(
                controller: _addressCtrl,
                label: 'Manzil',
                hint: 'Turakurgan tumani, Yangi hayot MFY',
                validator: (v) => v == null || v.trim().isEmpty ? 'Manzilni kiriting' : null,
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: kColorWhite),
                        )
                      : const Text('Saqlash'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    String? hint,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: kColorInk)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(hintText: hint),
          validator: validator,
        ),
      ],
    );
  }
}
