import 'package:flutter/material.dart';

class JobTabSwitcher extends StatefulWidget {
  final bool initialIsActive;
  final ValueChanged<bool>? onChanged;

  const JobTabSwitcher({
    super.key,
    this.initialIsActive = true,
    this.onChanged,
  });

  @override
  State<JobTabSwitcher> createState() => _JobTabSwitcherState();
}

class _JobTabSwitcherState extends State<JobTabSwitcher> {
  late bool _isActive;

  double _measureTextWidth(BuildContext context, String text, TextStyle style) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: 1,
      textDirection: Directionality.of(context),
    )..layout();
    return painter.size.width;
  }

  @override
  void initState() {
    super.initState();
    _isActive = widget.initialIsActive;
  }

  void _select(bool isActive) {
    if (_isActive == isActive) return;
    setState(() => _isActive = isActive);
    widget.onChanged?.call(_isActive);
  }

  @override
  Widget build(BuildContext context) {
    const selectedColor = Color(0xff254356);
    const unselectedColor = Color(0xff7C7979);

    Widget tab({required String label, required bool selected, required VoidCallback onTap}) {
      final textStyle = TextStyle(
        fontFamily: 'Poppins',
        fontSize: 18,
        fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
        color: selected ? selectedColor : unselectedColor,
      );

      return GestureDetector(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              style: textStyle,
              child: Text(label),
            ),
            const SizedBox(height: 6),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              width: _measureTextWidth(
                context,
                label,
                TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              height: 2,
              decoration: BoxDecoration(
                color: selected ? selectedColor : Colors.transparent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        tab(
          label: 'Active',
          selected: _isActive,
          onTap: () => _select(true),
        ),
        const SizedBox(width: 22),
        tab(
          label: 'Completed',
          selected: !_isActive,
          onTap: () => _select(false),
        ),
      ],
    );
  }
}