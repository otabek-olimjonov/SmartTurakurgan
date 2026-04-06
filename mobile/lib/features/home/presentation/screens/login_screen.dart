import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:smart_turakurgan/core/auth/auth_notifier.dart';
import 'package:smart_turakurgan/core/theme/colors.dart';
import 'package:smart_turakurgan/l10n/app_localizations.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  bool _loading = false;
  bool _polling = false;
  String? _error;

  Future<void> _startAuth() async {
    setState(() { _loading = true; _error = null; });

    try {
      final deviceId = _deviceId();
      final auth = ref.read(authProvider.notifier);
      final result = await auth.initTelegramAuth(deviceId);

      final uri = Uri.parse(result.telegramUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }

      setState(() { _loading = false; _polling = true; });

      final confirmed = await auth.pollVerify(result.token);
      if (!confirmed && mounted) {
        setState(() { _polling = false; _error = 'Vaqt tugadi. Qayta urinib ko\'ring.'; });
      }
    } catch (e, st) {
      debugPrint('LOGIN ERROR: $e');
      debugPrint('STACK: $st');
      if (mounted) {
        setState(() {
          _loading = false;
          _polling = false;
          _error = 'Xatolik: $e';
        });
      }
    }
  }

  String _deviceId() {
    // Unique enough for dev purposes; production uses device_info_plus
    return 'device_${Platform.operatingSystem}_${DateTime.now().millisecondsSinceEpoch ~/ 10000}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kColorCream,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(flex: 2),
              // Logo / Brand
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: kColorPrimary,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(Icons.location_city, color: kColorWhite, size: 36),
              ),
              const SizedBox(height: 20),
              const Text('Smart Turakurgan',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500, color: kColorInk)),
              const SizedBox(height: 6),
              Text(AppLocalizations.of(context).appSlogan,
                  style: const TextStyle(fontSize: 14, color: kColorTextMuted)),
              const Spacer(flex: 3),
              if (_polling) ...[
                const CircularProgressIndicator(color: kColorPrimary),
                const SizedBox(height: 16),
                Text(AppLocalizations.of(context).loginWaiting,
                    style: const TextStyle(fontSize: 15, color: kColorTextMuted)),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => setState(() { _polling = false; }),
                  child: const Text('Bekor qilish'),
                ),
              ] else ...[
                if (_error != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: kColorDanger.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(_error!,
                        style: const TextStyle(color: kColorDanger, fontSize: 13)),
                  ),
                  const SizedBox(height: 16),
                ],
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _loading ? null : _startAuth,
                    icon: _loading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: kColorWhite),
                          )
                        : const Icon(Icons.send, size: 18),
                    label: Text(AppLocalizations.of(context).loginButton),
                  ),
                ),
              ],
              const Spacer(),
              const Text(
                'Kirishingiz bilan foydalanish shartlariga rozilik bildirasiz',
                style: TextStyle(fontSize: 11, color: kColorTextMuted),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
