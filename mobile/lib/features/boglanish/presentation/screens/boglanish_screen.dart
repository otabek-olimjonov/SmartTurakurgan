import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dio/dio.dart';
import 'package:smart_turakurgan/core/auth/auth_notifier.dart';
import 'package:smart_turakurgan/core/theme/colors.dart';

class BoglanishScreen extends StatelessWidget {
  const BoglanishScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Bog'lanish"),
          bottom: const TabBar(
            tabs: [Tab(text: 'Kontaktlar'), Tab(text: 'Murojaat')],
          ),
        ),
        body: const TabBarView(
          children: [_KontaktlarTab(), _MurojaatTab()],
        ),
      ),
    );
  }
}

class _KontaktlarTab extends StatelessWidget {
  const _KontaktlarTab();

  static const _contacts = [
    _Contact(Icons.phone, 'Qabul xonasi', '+998 73 394 00 00'),
    _Contact(Icons.phone, 'Navbatchi', '+998 73 394 00 01'),
    _Contact(Icons.email, 'E-mail', 'hokimiyat@turakurgan.uz'),
    _Contact(Icons.location_on, 'Manzil', 'Turakurgan tumani, Mustaqillik ko\'chasi 1'),
    _Contact(Icons.access_time, 'Ish vaqti', 'Dushanba–Juma: 09:00–18:00'),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ..._contacts.map((c) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                decoration: BoxDecoration(
                  color: kColorWhite,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: kColorStone, width: 0.5),
                ),
                child: ListTile(
                  leading: Icon(c.icon, color: kColorPrimary, size: 20),
                  title: Text(c.label,
                      style: const TextStyle(fontSize: 12, color: kColorTextMuted)),
                  subtitle: Text(c.value,
                      style: const TextStyle(fontSize: 14, color: kColorInk, fontWeight: FontWeight.w500)),
                  onTap: c.icon == Icons.phone
                      ? () => launchUrl(Uri.parse('tel:${c.value.replaceAll(' ', '')}'))
                      : c.icon == Icons.email
                          ? () => launchUrl(Uri.parse('mailto:${c.value}'))
                          : null,
                ),
              ),
            )),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: () => launchUrl(Uri.parse('https://t.me/SmartTurakurganBot')),
          icon: const Icon(Icons.send, size: 16),
          label: const Text('Telegram kanalimiz'),
        ),
      ],
    );
  }
}

class _Contact {
  final IconData icon;
  final String label;
  final String value;
  const _Contact(this.icon, this.label, this.value);
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
        final msg = e.response?.statusCode == 429
            ? 'Kunlik limit (5) oshib ketdi'
            : 'Xatolik yuz berdi. Qayta urinib ko\'ring.';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
        setState(() => _sending = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
              const Text('Murojaatingiz qabul qilindi!',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: kColorInk),
                  textAlign: TextAlign.center),
              const SizedBox(height: 8),
              const Text('Tez orada siz bilan bog\'lanamiz.',
                  style: TextStyle(fontSize: 14, color: kColorTextMuted)),
              const SizedBox(height: 24),
              OutlinedButton(
                onPressed: () => setState(() { _sent = false; _messageCtrl.clear(); }),
                child: const Text('Yangi murojaat'),
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
            _buildField(_nameCtrl, "To'liq ism", "Ali Karimov",
                validator: (v) => v == null || v.trim().isEmpty ? 'Ismni kiriting' : null),
            const SizedBox(height: 12),
            _buildField(_phoneCtrl, 'Telefon', '+998901234567',
                type: TextInputType.phone,
                validator: (v) => v == null || v.trim().isEmpty ? 'Telefon kiriting' : null),
            const SizedBox(height: 12),
            _buildField(_addressCtrl, 'Manzil', 'Turakurgan, Yangi hayot MFY',
                validator: (v) => v == null || v.trim().isEmpty ? 'Manzil kiriting' : null),
            const SizedBox(height: 12),
            _buildField(_messageCtrl, 'Murojaat matni', 'Muammo yoki savolingizni kiriting...',
                maxLines: 5,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Murojaat matnini kiriting';
                  if (v.trim().length < 10) return 'Kamida 10 belgi';
                  return null;
                }),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _sending ? null : _submit,
                child: _sending
                    ? const SizedBox(height: 20, width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: kColorWhite))
                    : const Text('Yuborish'),
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
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: kColorInk)),
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
