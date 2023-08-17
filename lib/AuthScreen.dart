
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_pw_validator/flutter_pw_validator.dart';

class AuthScreen extends StatefulWidget {
  final VoidCallback loginCallback;

   AuthScreen({required this.loginCallback});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
   TextEditingController userNameController= TextEditingController();
   TextEditingController passWordController=TextEditingController();


   final GlobalKey<FlutterPwValidatorState> validatorKey = GlobalKey<FlutterPwValidatorState>();

   bool isRegistrationEnabled = false;
   bool isLoginEnabled = false;

   void performRegistation() async{
     SharedPreferences pref=await SharedPreferences.getInstance();

     if(userNameController.text =='' || passWordController.text ==''){
        _showErrorDialog("Registersion Error", "Please! enter the valid input");
     }
     else {
       bool usernameTaken = await isUsernameTaken(userNameController.text);
     if (usernameTaken) {
       _showErrorDialog("Registration Error", "Username already taken");
     } else {
       await pref.setString('username', userNameController.text);
       await pref.setString('password', passWordController.text);
       widget.loginCallback();
     }
     }
   }


   void performLogin() async{
     SharedPreferences pref=await SharedPreferences.getInstance();

    String storedUserName=  pref.getString('username')?? '';
    String storedPassword= pref.getString('password') ?? '';

    if(userNameController.text=='' && passWordController.text== ''){
      _showErrorDialog("login Error", "please eneter the valid input");
    }
    else{
      if(userNameController.text == storedUserName ){
        if(passWordController.text == storedPassword) {
          widget.loginCallback();
        }
        else{
          _showErrorDialog("Login Error", "Invalid Password");

        }
      }
      else{
        _showErrorDialog("Login Error", "Invalid User Name");
      }
    }
   }

   void _showErrorDialog(String title, String content) {
     showDialog(
       context: context,
       builder: (context) {
         return AlertDialog(
           title: Text(title),
           content: Text(content),
           actions: [
             ElevatedButton(
               onPressed: () => Navigator.pop(context),
               child: Text('Ok'),
             )
           ],
         );
       },
     );
   }

   Future<bool> isUsernameTaken(String username) async {
     SharedPreferences pref = await SharedPreferences.getInstance();
     String storedUserName = pref.getString('username') ?? '';
     return storedUserName == username;
   }


   @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("BMI Login"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircleAvatar(
                radius: 110,
                backgroundColor: Colors.black26,
                child:  CircleAvatar(
                  backgroundImage:NetworkImage(
                      "https://d2gg9evh47fn9z.cloudfront.net/1600px_COLOURBOX43397224.jpg"),
                  radius: 100,
                ),
              ),

              TextField(
                controller: userNameController,
                decoration: const InputDecoration(labelText: "Username"),
              ),
              TextField(
                controller: passWordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: "Password"),
              ),
              const SizedBox(height: 16),
              FlutterPwValidator(
                controller: passWordController,
                minLength: 8,
                uppercaseCharCount: 1,
                lowercaseCharCount: 2,
                numericCharCount: 1,
                specialCharCount: 1,
                width: 400,
                height: 150,
                onSuccess: () async {
                  bool usernameNotTaken = !await isUsernameTaken(userNameController.text);
                  setState(() {
                    isRegistrationEnabled = usernameNotTaken;
                    isLoginEnabled=true;
                  });
                },
                onFail: () {
                  setState(() {
                    isRegistrationEnabled = false;
                    isLoginEnabled = false;
                  });
                },
              ),
              const SizedBox(height: 16),
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                        onPressed: isRegistrationEnabled ? performRegistation:null,
                        child: const Text('Register')
                    ),
                    ElevatedButton(
                        onPressed: isLoginEnabled ? performLogin:null,
                        child: const Text('Login')
                    )
                  ]
              ),
            ],
          ),
        ),
      ),
    );
  }
}
