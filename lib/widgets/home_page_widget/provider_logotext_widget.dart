import 'package:flutter/material.dart';

class ProviderLogotextWidget extends StatelessWidget {
  const ProviderLogotextWidget({
    super.key,
    this.padding = const EdgeInsets.fromLTRB(20, 8, 20, 4),
  });

  final EdgeInsetsGeometry padding;

  static const _primaryColor = Color(0xff254356);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Expanded(
            child: Text(
              'Service Requests',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: _primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
