import 'package:flutter/material.dart';
import 'package:hafiz_diary/admin/admin_home.dart';
import 'package:hafiz_diary/widget/TextFormField.dart';
import 'package:hafiz_diary/widget/common_button.dart';

import '../constants.dart';
import '../services/auth_services.dart';
import '../widget/app_text.dart';

class NewProfile extends StatefulWidget {
  const NewProfile({Key? key}) : super(key: key);

  @override
  State<NewProfile> createState() => _NewProfileState();
}

class _NewProfileState extends State<NewProfile> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  List<String> Role = [

    "Parent",
    'Staff',


  ];
  String _selectedValue = "Parent";
  final formKey = GlobalKey<FormState>();
  AuthServices authServices = AuthServices();
  int accountType=2;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(defPadding),
          child: Form(
            key:formKey,
            child: Column(
             crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                AppText(
                    text: "Create Profile",
                    clr: primaryColor,
                    fontWeight: FontWeight.bold,
                    size: 22),
                SizedBox(height: defPadding/2,),
                AppText(
                  text: "Setup profile of Parents & Staff",
                  clr: Colors.grey,
                ),

                SizedBox(
                  height: defPadding*5 ,
                ),

                Align(
                  alignment: AlignmentDirectional.topStart,

                  child: AppText(

                      text: "Select Role",
                      clr: primaryColor,

                      size: 18),
                ),


                Container(


                    margin:  EdgeInsets.only(top: 10,left:0),
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.black38, width: 1),
                        borderRadius: BorderRadius.circular(5),
                        boxShadow: <BoxShadow>[]),
                    child: DropdownButtonHideUnderline(
                        child: DropdownButtonFormField(
                          value: _selectedValue,
                          items: Role.map((e) {
                            return DropdownMenuItem<String>(
                                child:
                                Padding(
                                  padding: const EdgeInsets.only(left:5),
                                  child: Text(e.toString(),style: TextStyle(color: Colors.grey),),
                                ), value: e);
                          }).toList(),
                          onChanged: (newValue) {
                            setState(() {
                              _selectedValue = newValue as String;
                              if(_selectedValue=="Staff"){
                                setState(() {
                                  accountType=1;
                                });

                              }else{
                                setState(() {
                                  accountType=2;
                                });
                              }

                            });
                          },
                          isExpanded: true,
                        ))),
                SizedBox(
                  height: defPadding/2 ,
                ),


                Align(
                  alignment: AlignmentDirectional.topStart,

                  child: AppText(

                      text: "Set Credentials",
                      clr: primaryColor,

                      size: 18),
                ),
                SizedBox(
                  height: defPadding/2 ,
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
                  height: defPadding*3,
                ),
                CommonButton(
                  text: "Create Profile",
                  onTap: () {

                 if (formKey.currentState!.validate()) {
                authServices.signup(
     data: {
     "name": nameController.text,
    "email": emailController.text,
    "phone": phoneController.text,
    "type": accountType,
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


              ],
            ),
          ),
        ),
      ),
    );
  }
}
