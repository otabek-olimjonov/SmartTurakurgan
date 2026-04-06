import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smart_turakurgan/core/auth/auth_notifier.dart';
import 'package:smart_turakurgan/core/locale/locale_provider.dart';
import 'package:smart_turakurgan/core/theme/colors.dart';
import 'package:smart_turakurgan/l10n/app_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _uploading = false;

  String _localeName(Locale locale) {
    for (final entry in localeNames) {
      if (entry.$1 == locale) return entry.$2;
    }
    return locale.toLanguageTag();
  }

  Future<void> _pickLanguage(BuildContext context) async {
    final current = ref.read(localeProvider);
    final l10n = AppLocalizations.of(context);
    final picked = await showModalBottomSheet<Locale>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Text(l10n.selectLanguage,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: kColorInk)),
            ),
            const Divider(height: 1),
            ...localeNames.map((entry) {
              final isSelected = entry.$1 == current;
              return ListTile(
                title: Text(entry.$2,
                    style: TextStyle(
                        fontSize: 14,
                        color: isSelected ? kColorPrimary : kColorInk,
                        fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal)),
                trailing: isSelected ? const Icon(Icons.check, color: kColorPrimary, size: 18) : null,
                onTap: () => Navigator.pop(ctx, entry.$1),
              );
            }),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (picked != null) {
      ref.read(localeProvider.notifier).setLocale(picked);
    }
  }

  Future<void> _pickAndUploadAvatar(String userId) async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 80,
    );
    if (file == null) return;

    setState(() => _uploading = true);
    try {
      final bytes = await file.readAsBytes();
      final path = 'avatars/$userId-${DateTime.now().millisecondsSinceEpoch}.jpg';
      await Supabase.instance.client.storage
          .from('images')
          .uploadBinary(path, bytes,
              fileOptions: const FileOptions(upsert: true, contentType: 'image/jpeg'));
      final url = Supabase.instance.client.storage.from('images').getPublicUrl(path);
      await ref.read(authProvider.notifier).updateProfile(photoUrl: url);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Xato: $e'), backgroundColor: kColorDanger),
        );
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  void _showEditModal(BuildContext context, AuthState auth) {
    final nameCtrl = TextEditingController(text: auth.fullName ?? '');
    final phoneCtrl = TextEditingController(text: auth.phoneNumber ?? '');
    final l10n = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        bool saving = false;
        return StatefulBuilder(
          builder: (ctx, setModalState) => Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(l10n.editProfile,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: kColorInk)),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20, color: kColorTextMuted),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nameCtrl,
                  decoration: InputDecoration(
                    labelText: l10n.fullName,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: phoneCtrl,
                  decoration: InputDecoration(
                    labelText: l10n.phoneNumber,
                    hintText: '+998901234567',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: saving
                        ? null
                        : () async {
                            final name = nameCtrl.text.trim();
                            final phone = phoneCtrl.text.trim();
                            if (name.isEmpty) return;
                            setModalState(() => saving = true);
                            try {
                              await ref.read(authProvider.notifier).updateProfile(
                                    fullName: name,
                                    phoneNumber: phone.isNotEmpty ? phone : null,
                                  );
                              if (ctx.mounted) Navigator.pop(ctx);
                            } catch (e) {
                              setModalState(() => saving = false);
                              if (ctx.mounted) {
                                ScaffoldMessenger.of(ctx).showSnackBar(
                                  SnackBar(content: Text('Xato: $e'), backgroundColor: kColorDanger),
                                );
                              }
                            }
                          },
                    style: FilledButton.styleFrom(
                      backgroundColor: kColorPrimary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: saving
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : Text(l10n.save),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAvatar(AuthState auth) {
    final initials = (auth.fullName ?? 'U')
        .trim()
        .split(' ')
        .where((s) => s.isNotEmpty)
        .take(2)
        .map((s) => s[0].toUpperCase())
        .join();

    Widget avatar;
    if (auth.photoUrl != null && auth.photoUrl!.isNotEmpty) {
      avatar = CachedNetworkImage(
        imageUrl: auth.photoUrl!,
        fit: BoxFit.cover,
        placeholder: (_, __) => _initialsCircle(initials),
        errorWidget: (_, __, ___) => _initialsCircle(initials),
      );
    } else {
      avatar = _initialsCircle(initials);
    }

    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        GestureDetector(
          onTap: _uploading ? null : () => _pickAndUploadAvatar(auth.userId ?? ''),
          child: Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: kColorStone, width: 0.5),
            ),
            clipBehavior: Clip.antiAlias,
            child: _uploading
                ? const Center(child: CircularProgressIndicator(color: kColorPrimary, strokeWidth: 2))
                : avatar,
          ),
        ),
        Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: kColorPrimary,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: const Icon(Icons.camera_alt, size: 13, color: Colors.white),
        ),
      ],
    );
  }

  Widget _initialsCircle(String initials) {
    return Container(
      color: kColorPrimary.withValues(alpha: 0.1),
      child: Center(
        child: Text(initials,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w500, color: kColorPrimary)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authAsync = ref.watch(authProvider);
    final locale = ref.watch(localeProvider);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.navProfile),
        actions: [
          authAsync.maybeWhen(
            data: (auth) => IconButton(
              icon: const Icon(Icons.edit_outlined, size: 20),
              tooltip: l10n.editProfile,
              onPressed: () => _showEditModal(context, auth),
            ),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      backgroundColor: kColorCream,
      body: authAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: kColorPrimary)),
        error: (_, __) => Center(child: Text(l10n.errorGeneric)),
        data: (auth) => ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Avatar + name card
            Container(
              decoration: BoxDecoration(
                color: kColorWhite,
                borderRadius: BorderRadius.circular(14),
                boxShadow: const [
                  BoxShadow(color: Color(0x0C000000), blurRadius: 10, offset: Offset(0, 3)),
                ],
              ),
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
              child: Column(
                children: [
                  _buildAvatar(auth),
                  const SizedBox(height: 14),
                  Text(
                    auth.fullName?.isNotEmpty == true
                        ? auth.fullName!
                        : auth.userId ?? l10n.notLoggedIn,
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500, color: kColorInk),
                    textAlign: TextAlign.center,
                  ),
                  if (auth.phoneNumber != null && auth.phoneNumber!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(auth.phoneNumber!,
                        style: const TextStyle(fontSize: 13, color: kColorTextMuted)),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            _SettingsTile(
              icon: Icons.language,
              title: l10n.languageSetting,
              subtitle: _localeName(locale),
              onTap: () => _pickLanguage(context),
            ),
            const SizedBox(height: 8),
            _SettingsTile(
              icon: Icons.info_outline,
              title: l10n.appAbout,
              subtitle: 'v1.0.0',
              onTap: () {},
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () async {
                await ref.read(authProvider.notifier).signOut();
              },
              icon: const Icon(Icons.logout, size: 18, color: kColorDanger),
              label: Text(l10n.logout, style: const TextStyle(color: kColorDanger)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: kColorDanger),
                foregroundColor: kColorDanger,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kColorWhite,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(color: Color(0x0C000000), blurRadius: 10, offset: Offset(0, 3)),
        ],
      ),
      child: ListTile(
        leading: Icon(icon, color: kColorPrimary, size: 20),
        title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: kColorTextMuted)),
        trailing: const Icon(Icons.chevron_right, color: kColorTextMuted, size: 18),
        onTap: onTap,
      ),
    );
  }
}
