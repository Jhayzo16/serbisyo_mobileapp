import 'package:flutter/material.dart';

class HomeWidget extends StatelessWidget {
  const HomeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 20, right: 20, top: 20),
      height: 184,
      width: 370,
      decoration: BoxDecoration(
        color: Color(0xff254356),
        borderRadius: BorderRadius.circular(15),
      ),

      child: Row(
        children: [
          Column(
            children: [
              Container(
                padding: EdgeInsets.only(left: 20, top: 30),
                child: Text(
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xffFFFFFF),
                    fontWeight: FontWeight.bold,
                  ),
                  'Discover quick,\nseamless, and\nhassle-free services\nall in one app.',
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 10, left: 20),
                height: 36,
                width: 155,
                child: TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Color(0xffFFFFFF).withOpacity(0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),

                  onPressed: () {},
                  child: Text(
                    style: TextStyle(fontSize: 10, color: Color(0xffFFFFFF)),
                    'Request Custom Services',
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: Container(

              height: 237,
              width: 367, 
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/icons/MascPeng.png'),
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
