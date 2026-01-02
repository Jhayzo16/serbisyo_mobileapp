import 'package:flutter/material.dart';

class TabSwitcherWidget extends StatefulWidget {
  const TabSwitcherWidget({
    super.key,
    this.tabs = const ['Pending', 'In Progress', 'Completed'],
    this.initialIndex = 0,
    this.onChanged,
  }) : assert(tabs.length >= 2, 'TabSwitcherWidget requires at least 2 tabs');

  final List<String> tabs;
  final int initialIndex;
  final ValueChanged<int>? onChanged;

  @override
  State<TabSwitcherWidget> createState() => _TabSwitcherWidgetState();
}

class _TabSwitcherWidgetState extends State<TabSwitcherWidget> {
  static const _selectedColor = Color(0xff356785);
  static const _containerColor = Color(0xffF6F6F6);

  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex.clamp(0, widget.tabs.length - 1);
  }

  @override
  void didUpdateWidget(covariant TabSwitcherWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.tabs.length != widget.tabs.length) {
      _selectedIndex = _selectedIndex.clamp(0, widget.tabs.length - 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 24, left: 20, right: 20),
      padding: const EdgeInsets.all(10),
      height: 63,
      decoration: BoxDecoration(
        color: _containerColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          for (int index = 0; index < widget.tabs.length; index++)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 2),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      if (_selectedIndex == index) return;
                      setState(() => _selectedIndex = index);
                      widget.onChanged?.call(index);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 160),
                      curve: Curves.easeOut,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: _selectedIndex == index
                            ? Colors.white
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 7,
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            widget.tabs[index],
                            style: TextStyle(
                              fontSize: 12,
                              color: _selectedIndex == index
                                  ? _selectedColor
                                  : const Color(0xff254356),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
