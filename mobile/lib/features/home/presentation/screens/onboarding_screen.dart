import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_turakurgan/core/auth/auth_notifier.dart';
import 'package:smart_turakurgan/core/theme/colors.dart';
import 'package:smart_turakurgan/l10n/app_localizations.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _addressCtrl = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _addressCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    try {
      final dio = ref.read(dioProvider);
      await dio.put('/update-profile', data: {
        'address': _addressCtrl.text.trim(),
      });
      // Refresh auth state — isNewUser will become false
      ref.invalidate(authProvider);
    } catch (_) {
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.errorOccurred)),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: kColorCream,
      appBar: AppBar(
        title: Text(l10n.onboardingTitle),
        automaticallyImplyLeading: false,
        actions: [
          TextButton(
            onPressed: () => ref.invalidate(authProvider),
            child: Text(l10n.onboardingSkip),
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
              // Info banner — name & phone already collected via Telegram bot
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: kColorPrimary.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: kColorPrimary.withValues(alpha: 0.18), width: 0.5),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_outline, color: kColorPrimary, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        l10n.onboardingTelegramDone,
                        style: const TextStyle(fontSize: 13, color: kColorPrimary, height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                l10n.onboardingSubtitle,
                style: const TextStyle(fontSize: 14, color: kColorTextMuted, height: 1.5),
              ),
              const SizedBox(height: 24),
              _buildField(
                controller: _addressCtrl,
                label: l10n.address,
                hint: 'Turakurgan tumani, Yangi hayot MFY',
                validator: (v) => v == null || v.trim().isEmpty ? l10n.address : null,
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
                      : Text(l10n.save),
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
