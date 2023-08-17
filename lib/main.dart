import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'BMICalculator.dart';
import 'AuthScreen.dart';
import 'package:google_fonts/google_fonts.dart';


void main() {
  runApp(const BmiApp());
}

class BmiApp extends StatelessWidget {
  const BmiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch:Colors.orange,
        textTheme: GoogleFonts.albertSansTextTheme(),
      ),
      home: const AuthWarpper(),

    );
  }
}

class AuthWarpper extends StatefulWidget {
  const AuthWarpper({super.key});


  @override
  State<AuthWarpper> createState() => _AuthWarpperState();
}

class _AuthWarpperState extends State<AuthWarpper> {

  late bool isLoggedIn;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkLoginStatus();
  }

  void checkLoginStatus() async {
    SharedPreferences pref= await SharedPreferences.getInstance();
    setState(() {
      isLoggedIn=pref.getBool("isLoggedIn")?? false;
    });
  }

  void Login() async{
    SharedPreferences pref=await SharedPreferences.getInstance();
    await pref.setBool("isLoggedIn",true);
    setState(() {
      isLoggedIn=true;
    });
  }

  void Logout() async{
    SharedPreferences pref=await SharedPreferences.getInstance();
    await pref.setBool("isLoggedIn",false);
    setState(() {
      isLoggedIn=false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if(isLoggedIn){
      return BMICalculator(logOutCallback: Logout,);
    }
    else{
      return AuthScreen(loginCallback: Login);
    }
  }
}




