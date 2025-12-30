import 'package:flutter/material.dart';
import 'package:serbisyo_mobileapp/models/cleaning_services/cleaning_service_model.dart';
import 'package:serbisyo_mobileapp/widgets/cleaning_service_widget/cleaning_service_cards.dart';
import 'package:serbisyo_mobileapp/pages/cleaning_request_page.dart';

class CleaningServicesPage extends StatelessWidget {
   CleaningServicesPage({super.key});


  final List<CleaningServiceModel> services = [

    CleaningServiceModel(
      name: 'House Cleaning', 
      description: 'General cleaning of your home', 
      price: 1500,
      duration: '2-3 hours',
      rating: 4.5,
      icon: Icons.home,
    ),

      CleaningServiceModel(
      name: 'Deep Cleaning', 
      description: 'Thorough cleaning of different surfaces', 
      price: 2000,
      duration: '3-5 hours',
      rating: 4.5,
      icon: Icons.cleaning_services,
    ),

      CleaningServiceModel(
      name: 'Window Cleaning', 
      description: 'Cleaning of windows and frames', 
      price: 700,
      duration: '1-2 hours',
      rating: 4.5,
      icon: Icons.window,
    ),


  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xff254356)
          ),
          'Cleaning Services'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.only(top: 70, left: 40, right: 20),
              child: Text(
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff254356),
                ),
                'Description of Service',
              ),
            ),
            ListView.separated(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              padding: EdgeInsets.only(top: 18),
              itemCount: services.length,
              separatorBuilder: (_, __) => SizedBox(height: 18),
              itemBuilder: (context, index) {
                return CleaningServiceCards(
                  service: services[index],
                  selected: index == 0,
                );
              },
            ),
            SizedBox(height: 40),
            SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.only(left: 40, right: 40, bottom: 24),
                child: Center(
                  child: SizedBox(
                    height: 48,
                    width: 210,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => CleaningRequestPage(
                              service: services.first,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xff356785),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        'View Details',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      

    );
  }
}