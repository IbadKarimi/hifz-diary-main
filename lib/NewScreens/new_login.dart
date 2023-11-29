import 'package:flutter/material.dart';
import 'package:hafiz_diary/NewScreens/new_sign_up.dart';
import 'package:hafiz_diary/admin/admin_home.dart';
import 'package:hafiz_diary/widget/TextFormField.dart';
import 'package:hafiz_diary/widget/common_button.dart';

import '../authentication/forgot_password.dart';
import '../constants.dart';
import '../services/auth_services.dart';
import '../widget/app_text.dart';

class NewLogin extends StatefulWidget {
  const NewLogin({Key? key}) : super(key: key);

  @override
  State<NewLogin> createState() => _NewLoginState();
}

class _NewLoginState extends State<NewLogin> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  AuthServices authServices = AuthServices();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Padding(
            padding: EdgeInsets.all(defPadding*2),
            child: Form(
                key: formKey,
                child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset("assets/images/logo.png",width: 200,height: 200,),
                  SizedBox(height:defPadding*3),
                  AppText(
                      text: "Login",
                      clr: primaryColor,
                      fontWeight: FontWeight.bold,
                      size: 22),
                  SizedBox(height:6),
                  AppText(
                    text: "Welcome back to HIfz Online Diary",
                    clr: Colors.grey,
                  ),
                  SizedBox(height:defPadding*2),

                  SizedBox(
                    height: defPadding / 2,
                  ),
                  CustomTextField(
                      validation: false,
                      controller: emailController,
                      lableText: "Email / Phone"),
                  SizedBox(
                    height: defPadding / 2,
                  ),


                  CustomTextField(
                      validation: false,
                      controller: passwordController,
                      lableText: "Password"),
                  SizedBox(
                    height: defPadding * 1,
                  ),
                  GestureDetector(
                    onTap: (){
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context){
                        return ForgotPassword();
                      }));
                    },
                    child: AppText(
                      text: "Forgot Password?",
                      clr: Colors.black,
                    ),
                  ),
                  SizedBox(
                    height: defPadding * 2,
                  ),
                  CommonButton(
                    text: "Login",
                    onTap: () {
                      if (formKey.currentState!.validate()) {
                        authServices.login(
                            email: emailController.text.trim(),
                            password: passwordController.text.trim(),
                            context: context);
                      }
                    },
                    color: primaryColor,
                    textColor: Colors.white,
                  ),
                  SizedBox(
                    height: defPadding * 2,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [

                      AppText(
                        size: 16,
                        text: "Don't have an account?",
                        clr: Colors.black,
                      ),
                      SizedBox(
                        width: defPadding * 0.2,
                      ),
                      GestureDetector(
                        onTap: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context){
                            return NewSignUp(accountType: "");
                          }));
                        },
                        child: AppText(
                          fontWeight: FontWeight.w600,
                          size: 16,
                          text: "Sign Up",
                          clr: primaryColor,

                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
