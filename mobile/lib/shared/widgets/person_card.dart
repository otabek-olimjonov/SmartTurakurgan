import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:smart_turakurgan/core/theme/colors.dart';

class PersonCard extends StatefulWidget {
  final String fullName;
  final String position;
  final String? photoUrl;
  final String? phone;
  final String? biography;
  final String? receptionDays;
  final VoidCallback? onCallTap;

  const PersonCard({
    super.key,
    required this.fullName,
    required this.position,
    this.photoUrl,
    this.phone,
    this.biography,
    this.receptionDays,
    this.onCallTap,
  });

  @override
  State<PersonCard> createState() => _PersonCardState();
}

class _PersonCardState extends State<PersonCard> {
  bool _expanded = false;

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
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildAvatar(),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.fullName,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: kColorInk),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.position,
                      style: const TextStyle(fontSize: 13, color: kColorTextMuted),
                    ),
                  ],
                ),
              ),
              if (widget.phone != null)
                GestureDetector(
                  onTap: widget.onCallTap,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: kColorPrimary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.phone_outlined, color: Colors.white, size: 18),
                  ),
                ),
            ],
          ),
          if (widget.biography != null && widget.biography!.isNotEmpty) ...[
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => setState(() => _expanded = !_expanded),
              child: Text(
                widget.biography!,
                maxLines: _expanded ? null : 2,
                overflow: _expanded ? null : TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13, color: kColorTextMuted, height: 1.5),
              ),
            ),
          ],
          if (widget.receptionDays != null) ...[
            const SizedBox(height: 8),
            Row(children: [
              const Icon(Icons.calendar_today_outlined, size: 14, color: kColorTextMuted),
              const SizedBox(width: 4),
              Text(widget.receptionDays!, style: const TextStyle(fontSize: 12, color: kColorTextMuted)),
            ]),
          ],
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    if (widget.photoUrl != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: CachedNetworkImage(
          imageUrl: widget.photoUrl!,
          width: 48,
          height: 48,
          fit: BoxFit.cover,
          placeholder: (_, __) => _initialsCircle(),
          errorWidget: (_, __, ___) => _initialsCircle(),
        ),
      );
    }
    return _initialsCircle();
  }

  Widget _initialsCircle() {
    final initials = widget.fullName
        .split(' ')
        .take(2)
        .map((w) => w.isNotEmpty ? w[0].toUpperCase() : '')
        .join();
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: kColorPrimary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(24),
      ),
      alignment: Alignment.center,
      child: Text(initials,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: kColorPrimary)),
    );
  }
}
