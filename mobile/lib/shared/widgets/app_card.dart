import 'package:flutter/material.dart';
import 'package:smart_turakurgan/core/theme/colors.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets? padding;
  final double radius;

  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.radius = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: kColorWhite,
      borderRadius: BorderRadius.circular(radius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: kColorStone, width: 0.5),
          ),
          padding: padding ?? const EdgeInsets.all(16),
          child: child,
        ),
      ),
    );
  }
}
