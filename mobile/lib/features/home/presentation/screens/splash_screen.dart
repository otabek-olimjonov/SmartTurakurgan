import 'package:flutter/material.dart';
import 'package:smart_turakurgan/core/theme/colors.dart';

/// Full-screen splash shown during auth check and initial sync.
///
/// - [progress] `null`   → indeterminate animated bar (auth check phase)
/// - [progress] 0.0–1.0  → determinate bar with real sync progress
class SplashScreen extends StatelessWidget {
  final double? progress;
  final String message;

  const SplashScreen({
    super.key,
    this.progress,
    this.message = 'Yuklanmoqda...',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kColorCream,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 3),
            // ── Logo ──────────────────────────────────────────────────────────
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: kColorPrimary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.location_city_rounded,
                color: Colors.white,
                size: 42,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Smart Turakurgan',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w500,
                color: kColorInk,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Barcha xizmatlar — bitta ilovada',
              style: TextStyle(
                fontSize: 13,
                color: kColorTextMuted,
              ),
            ),
            const Spacer(flex: 4),
            // ── Progress bar + message ────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(40, 0, 40, 52),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: _AnimatedProgressBar(progress: progress),
                  ),
                  const SizedBox(height: 12),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Text(
                      message,
                      key: ValueKey(message),
                      style: const TextStyle(
                        fontSize: 12,
                        color: kColorTextMuted,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Smoothly animates from one progress value to the next using a tween.
/// When [progress] is null, renders an indeterminate bar.
class _AnimatedProgressBar extends StatefulWidget {
  final double? progress;
  const _AnimatedProgressBar({required this.progress});

  @override
  State<_AnimatedProgressBar> createState() => _AnimatedProgressBarState();
}

class _AnimatedProgressBarState extends State<_AnimatedProgressBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;
  double _from = 0.0;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    final target = widget.progress ?? 0.0;
    _anim = Tween<double>(begin: 0.0, end: target).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
    if (widget.progress != null) _ctrl.forward();
  }

  @override
  void didUpdateWidget(_AnimatedProgressBar old) {
    super.didUpdateWidget(old);
    if (old.progress != widget.progress && widget.progress != null) {
      _from = _anim.value;
      _anim = Tween<double>(begin: _from, end: widget.progress!).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
      );
      _ctrl
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Indeterminate mode
    if (widget.progress == null) {
      return LinearProgressIndicator(
        minHeight: 3,
        backgroundColor: kColorStone,
        valueColor: const AlwaysStoppedAnimation(kColorPrimary),
      );
    }
    // Determinate mode — animated
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => LinearProgressIndicator(
        value: _anim.value,
        minHeight: 3,
        backgroundColor: kColorStone,
        valueColor: const AlwaysStoppedAnimation(kColorPrimary),
      ),
    );
  }
}
