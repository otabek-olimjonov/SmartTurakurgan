import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dio/dio.dart';
import 'package:smart_turakurgan/core/auth/auth_notifier.dart';
import 'package:smart_turakurgan/core/theme/colors.dart';
import 'package:smart_turakurgan/l10n/app_localizations.dart';

class BoglanishScreen extends StatelessWidget {
  const BoglanishScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.boglanish),
          bottom: TabBar(
            tabs: [Tab(text: l10n.kontaktlar), Tab(text: l10n.murojaat)],
          ),
        ),
        body: const TabBarView(
          children: [_KontaktlarTab(), _MurojaatTab()],
        ),
      ),
    );
  }
}

class _Contact {
  final IconData icon;
  final String label;
  final String value;
  const _Contact(this.icon, this.label, this.value);
}

class _KontaktlarTab extends StatelessWidget {
  const _KontaktlarTab();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final contacts = [
      _Contact(Icons.phone, l10n.receptionOffice, '+998 73 394 00 00'),
      _Contact(Icons.phone, l10n.duty, '+998 73 394 00 01'),
      _Contact(Icons.email, l10n.emailLabel, 'hokimiyat@turakurgan.uz'),
      _Contact(Icons.location_on, l10n.address, "Turakurgan tumani, Mustaqillik ko'chasi 1"),
      _Contact(Icons.access_time, l10n.workHours, ''),
    ];
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ...contacts.map((c) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                decoration: BoxDecoration(
                  color: kColorWhite,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: kColorStone, width: 0.5),
                ),
                child: ListTile(
                  leading: Icon(c.icon, color: kColorPrimary, size: 20),
                  title: c.value.isNotEmpty
                      ? Text(c.label,
                          style: const TextStyle(fontSize: 12, color: kColorTextMuted))
                      : null,
                  subtitle: c.value.isNotEmpty
                      ? Text(c.value,
                          style: const TextStyle(
                              fontSize: 14,
                              color: kColorInk,
                              fontWeight: FontWeight.w500))
                      : Text(c.label,
                          style: const TextStyle(
                              fontSize: 14,
                              color: kColorInk,
                              fontWeight: FontWeight.w500)),
                  onTap: c.icon == Icons.phone
                      ? () => launchUrl(
                          Uri.parse('tel:${c.value.replaceAll(' ', '')}'))
                      : c.icon == Icons.email
                          ? () => launchUrl(Uri.parse('mailto:${c.value}'))
                          : null,
                ),
              ),
            )),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: () =>
              launchUrl(Uri.parse('https://t.me/SmartTurakurganBot')),
          icon: const Icon(Icons.send, size: 16),
          label: Text(l10n.telegramChannel),
        ),
      ],
    );
  }
}

class _MurojaatTab extends ConsumerStatefulWidget {
  const _MurojaatTab();

  @override
  ConsumerState<_MurojaatTab> createState() => _MurojaatTabState();
}

class _MurojaatTabState extends ConsumerState<_MurojaatTab> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _messageCtrl = TextEditingController();
  bool _sending = false;
  bool _sent = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _messageCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _sending = true);

    try {
      final dio = ref.read(dioProvider);
      await dio.post('/submit-murojaat', data: {
        'full_name': _nameCtrl.text.trim(),
        'phone': _phoneCtrl.text.trim(),
        'address': _addressCtrl.text.trim(),
        'message': _messageCtrl.text.trim(),
      });
      if (mounted) setState(() { _sending = false; _sent = true; });
    } on DioException catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        final msg = e.response?.statusCode == 429
            ? l10n.murojaatRateLimit
            : l10n.errorOccurred;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
        setState(() => _sending = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (_sent) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: kColorSuccess.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(32),
                ),
                child: const Icon(Icons.check, color: kColorSuccess, size: 32),
              ),
              const SizedBox(height: 16),
              Text(l10n.murojaatSuccess,
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: kColorInk),
                  textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text(l10n.murojaatConnectingSoon,
                  style: const TextStyle(fontSize: 14, color: kColorTextMuted)),
              const SizedBox(height: 24),
              OutlinedButton(
                onPressed: () =>
                    setState(() { _sent = false; _messageCtrl.clear(); }),
                child: Text(l10n.newMurojaat),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildField(_nameCtrl, l10n.fullName, l10n.enterName,
                validator: (v) => v == null || v.trim().isEmpty
                    ? l10n.enterName
                    : null),
            const SizedBox(height: 12),
            _buildField(_phoneCtrl, l10n.phoneNumber, '+998901234567',
                type: TextInputType.phone,
                validator: (v) => v == null || v.trim().isEmpty
                    ? l10n.enterPhone
                    : null),
            const SizedBox(height: 12),
            _buildField(_addressCtrl, l10n.address, l10n.enterAddress,
                validator: (v) => v == null || v.trim().isEmpty
                    ? l10n.enterAddress
                    : null),
            const SizedBox(height: 12),
            _buildField(
                _messageCtrl, l10n.murojaatMessage, l10n.enterMessage,
                maxLines: 5,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return l10n.enterMessage;
                  if (v.trim().length < 10) return l10n.minChars;
                  return null;
                }),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _sending ? null : _submit,
                child: _sending
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: kColorWhite))
                    : Text(l10n.murojaatSubmit),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(
    TextEditingController ctrl,
    String label,
    String hint, {
    TextInputType? type,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: kColorInk)),
        const SizedBox(height: 6),
        TextFormField(
          controller: ctrl,
          keyboardType: type,
          maxLines: maxLines,
          decoration: InputDecoration(hintText: hint),
          validator: validator,
        ),
      ],
    );
  }
}
