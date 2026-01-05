import 'package:flutter/material.dart';

class AppElevatedCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final Color? color;
  final double elevation;
  final BorderSide? borderSide;

  const AppElevatedCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius = 16,
    this.color,
    this.elevation = 6,
    this.borderSide,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = color ?? Theme.of(context).cardColor;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(borderRadius),
      side: borderSide ?? BorderSide.none,
    );

    return Container(
      margin: margin,
      child: Material(
        color: cardColor,
        elevation: elevation,
        shape: shape,
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: padding ?? EdgeInsets.zero,
          child: child,
        ),
      ),
    );
  }
}
