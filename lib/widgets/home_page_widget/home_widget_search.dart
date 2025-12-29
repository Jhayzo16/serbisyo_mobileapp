import 'package:flutter/material.dart';

class HomeWidgetSearch extends StatelessWidget {
  const HomeWidgetSearch({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      margin: EdgeInsets.only(left: 20, right: 20, top: 20),
      child: TextField(
        decoration: InputDecoration(
          filled: true,
          fillColor:  Color(0xFFF6F6F6),
          prefixIcon:  Icon(
            Icons.search,
            color: Color(0xFFADACAD),
          ),
          hintText: 'Search services.....',
          hintStyle: TextStyle(
            color: Color(0xFFCACACA),
            fontSize: 12,
          ),
          contentPadding:  EdgeInsets.symmetric(vertical: 14),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}