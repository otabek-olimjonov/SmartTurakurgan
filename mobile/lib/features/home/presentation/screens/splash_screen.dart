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
      backgroundColor: Colors.black,
      body: Column(
        children: [
          // ── Background image — fills all available space ──────────────────
          Expanded(
            child: Image.asset(
              'assets/images/splash_bg.png',
              fit: BoxFit.cover,
              width: double.infinity,
            ),
          ),
          // ── Progress bar + message — outside the image, always visible ────
          Container(
            width: double.infinity,
            color: Colors.black,
            padding: const EdgeInsets.fromLTRB(40, 20, 40, 48),
            child: Column(
              mainAxisSize: MainAxisSize.min,
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
                      color: Colors.white70,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
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
        backgroundColor: Colors.white24,
        valueColor: const AlwaysStoppedAnimation(Colors.white),
      );
    }
    // Determinate mode — animated
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => LinearProgressIndicator(
        value: _anim.value,
        minHeight: 3,
        backgroundColor: Colors.white24,
        valueColor: const AlwaysStoppedAnimation(Colors.white),
      ),
    );
  }
}
