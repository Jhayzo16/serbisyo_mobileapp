import 'package:flutter/material.dart';
import 'package:serbisyo_mobileapp/widgets/homepagewidg/home_widget.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(),
      body: Column(
        children: [
          HomeWidget(),
        ],
      ),
    );
  }

  AppBar appBar() {
    return AppBar(
      actions: [
        Container(
          margin: EdgeInsets.only(top: 50, right: 20),
          child: Icon(
            size: 40,
            color: Colors.black,
            Icons.notifications),
        )
      ],
      toolbarHeight: 100,
      title: Container(
        margin: EdgeInsets.only(top: 50, left: 20),
        child: Text(
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24
          ),
          'Hello, Higala!'),
      ),
    );
  }
}