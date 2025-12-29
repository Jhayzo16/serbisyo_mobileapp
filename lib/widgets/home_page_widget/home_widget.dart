import 'package:flutter/material.dart';
import 'package:serbisyo_mobileapp/pages/custom_request_page.dart';

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

                  onPressed: () {
                    Navigator.of(context).push(
                      PageRouteBuilder(
                        transitionDuration: Duration(milliseconds: 350),
                        reverseTransitionDuration: Duration(milliseconds: 300),
                        pageBuilder: (context, animation, secondaryAnimation) => CustomRequestPage(),
                        transitionsBuilder: (context, animation, secondaryAnimation, child) {
                          final offsetTween = Tween<Offset>(begin: Offset(0, 0.08), end: Offset.zero)
                              .chain(CurveTween(curve: Curves.easeInOut));
                          final fadeTween = Tween<double>(begin: 0.0, end: 1.0)
                              .chain(CurveTween(curve: Curves.easeInOut));
                          final scaleTween = Tween<double>(begin: 0.98, end: 1.0)
                              .chain(CurveTween(curve: Curves.easeInOut));

                          return FadeTransition(
                            opacity: animation.drive(fadeTween),
                            child: SlideTransition(
                              position: animation.drive(offsetTween),
                              child: ScaleTransition(
                                scale: animation.drive(scaleTween),
                                child: child,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
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
