import 'package:flutter/material.dart';
import 'package:hafiz_diary/NewScreens/new_create_profile.dart';
import 'package:hafiz_diary/NewScreens/new_login.dart';
import 'package:hafiz_diary/authentication/login_screen.dart';
import 'package:hafiz_diary/profile/profile_screen.dart';
import 'package:hafiz_diary/services/auth_services.dart';

import '../constants.dart';
import '../widget/TextFormField.dart';
import '../widget/app_text.dart';
import '../widget/common_button.dart';


class NewSignUp extends StatefulWidget {
  final String accountType;
  const NewSignUp({Key? key, required this.accountType}) : super(key: key);

  @override
  State<NewSignUp> createState() => _NewSignUpState();
}

class _NewSignUpState extends State<NewSignUp> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  List<String> list = <String>[
    'Staff',
    'Student',
  ];
  String accountType = "0";

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    AuthServices authServices = AuthServices();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(defPadding*2),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [

                  Image.asset(
                    "assets/images/logo.png",
                    width: 200,
                    height: 200,
                    // height: 300,
                  ),
                  SizedBox(height: 60,),
                  AppText(
                    text: "Sign Up",
                    fontWeight: FontWeight.bold,
                    clr: primaryColor,
                    size: 22,
                  ),
                  SizedBox(height: 8,),
                  AppText(
                    text: "Sign Up for Hifz Online Diary",
                    clr: Colors.black,
                  ),
                  SizedBox(
                    height: defPadding,
                  ),
                  CustomTextField(
                      validation: false,
                      controller: nameController,
                      lableText: "Name"),
                  SizedBox(
                    height: defPadding / 2,
                  ),
                  CustomTextField(
                      validation: false,
                      controller: emailController,
                      lableText: "Email"),
                  SizedBox(
                    height: defPadding / 2,
                  ),
                  CustomTextField(
                      validation: false,
                      controller: phoneController,
                      lableText: "Phone Number"),
                  SizedBox(
                    height: defPadding / 2,
                  ),
                  CustomTextField(
                      validation: false,
                      controller: passwordController,
                      lableText: "Password"),
                  SizedBox(
                    height: defPadding / 2,
                  ),
                  CustomTextField(
                      validation: false,
                      controller: confirmPasswordController,
                      lableText: "Confirm Password"),
                  SizedBox(
                    height: defPadding*3,
                  ),
                  CommonButton(
                    text: "Sign Up",
                    onTap: () {
    if (formKey.currentState!.validate()) {
    authServices.signup(
    data: {
    "name": nameController.text,
    "email": emailController.text,
    "phone": phoneController.text,
    "type": 0,
    "status": true,
    "remarks": "approved",
    "img_url": ""
    },
    context: context,
    email: emailController.text.trim(),
    password: passwordController.text.trim());
    }



                      },


                    color: primaryColor,
                    textColor: Colors.white,
                  ),
                  SizedBox(
                    height: defPadding / 2,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AppText(
                        size: 16,
                        text: "Already have an account?",
                        clr: Colors.black,
                      ),
                      SizedBox(width: 2,),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => NewLogin()
                            ),
                          );
                        },
                        child: AppText(
                          fontWeight: FontWeight.w600,
                          size: 16,
                          text: "Login in",
                          clr: primaryColor,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
