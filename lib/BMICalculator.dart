import "package:flutter/material.dart";
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_fonts/google_fonts.dart';

class BMICalculator extends StatefulWidget {
  final VoidCallback logOutCallback;

  const BMICalculator({required this.logOutCallback});

  @override
  State<BMICalculator> createState() => _BMICalculatorState();
}

class _BMICalculatorState extends State<BMICalculator> {
  TextEditingController heightController=TextEditingController();
  TextEditingController weightController=TextEditingController();
  double bmiResult=0.0;
  String locationText="";
  String bmiCategory="";
  String heightUnit = 'cm'; // Default to centimeters


  void calculateBMI(){
    double heightCm=double.tryParse(heightController.text)?? 0.0;
    if(heightUnit =="inches"){
      heightCm *=2.54;
    }
    double weight=double.tryParse(weightController.text)??0.0;

    double heightM=heightCm/100;

    if(weight>0 && heightM >0){
      double bmi=weight/((heightM * heightM ));
      setState(() {
        bmiResult=bmi;

        if(bmi <18){
          bmiCategory="Your Under Weight";
        }
        if(bmi >=18 && bmi <= 25){
          bmiCategory="Your Normal Weight";
        }
        if(bmi >25 && bmi <=30){
          bmiCategory="Your OverWeight";
        }
        if(bmi >30){
          bmiCategory="Your Obese";
        }
      });
    }
  }



  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    return await Geolocator.getCurrentPosition();
  }


  void _getCurrentLocation() async {
    try {
      Position position = await _determinePosition();

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      String formattedLocation = placemarks.isNotEmpty
          ? '${placemarks[0].thoroughfare}, ${placemarks[0].locality}, ${placemarks[0].administrativeArea}'
          : 'Location not found';

      setState(() {
        locationText ="Your Location : "+ formattedLocation;
      });
    } catch (e) {
      setState(() {
        locationText = 'Failed to get location: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch:Colors.orange,
        textTheme: GoogleFonts.albertSansTextTheme(),
      ),
      darkTheme: ThemeData.dark(),
      home:Scaffold(
        appBar: AppBar(
          title: const Text('BMI Calculator'),
        ),
        drawer: Drawer(
          child:  ListView(
            // Important: Remove any padding from the ListView.
            padding: EdgeInsets.zero,
            children: [
              const DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.orange,
                  image: DecorationImage(
                      image: NetworkImage("https://d2gg9evh47fn9z.cloudfront.net/1600px_COLOURBOX43397224.jpg"),
                  fit:BoxFit.cover
                  ),
                ),
                child: Text(""),
              ),
          ListTile(
           leading: const Icon(
              Icons.logout,
            ),
          title: const Text('Logout'),
          onTap: () {
            widget.logOutCallback();
          },
          ),
          ],
        ),
        ),
        body:
            SingleChildScrollView(
              child:Padding(
                padding: const EdgeInsets.all(16.0),
                child:  Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.network("https://static.wixstatic.com/media/c10f9f_2db2b7985e9246e098a05f34367b1ca4~mv2.png/v1/fit/w_320%2Ch_363%2Cal_c,enc_auto/file.png",
                      height: 200,
                      width: 400,
                      fit: BoxFit.cover,
                    ),
                    TextField(
                      controller: heightController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText : 'Height ',
                      ),
                    ),
                    TextField(
                      controller:weightController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText:'Weight in kg',
                      ),
                    ),
                    const SizedBox(height:16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Height in "),
                        Radio(
                          value: 'cm',
                          groupValue: heightUnit,
                          onChanged: (value) {
                            setState(() {
                              heightUnit = value.toString();
                            });
                          },
                        ),
                        const Text('cm'),
                        Radio(
                          value: 'inches',
                          groupValue: heightUnit,
                          onChanged: (value) {
                            setState(() {
                              heightUnit = value.toString();
                            });
                          },
                        ),
                        const Text('inches'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: calculateBMI,
                      child: const Text('Calculate BMI'),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          'BMI: ${bmiResult.toStringAsFixed(2)}',
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight:
                              FontWeight.bold
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          bmiCategory.isEmpty?"":'Category: $bmiCategory',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _getCurrentLocation,
                      child: const Text("Get location"),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      locationText,
                      style: const TextStyle(fontSize: 18 ),
                    )
                  ],
                ),
              ),
            ),
      ),
    );
  }
}