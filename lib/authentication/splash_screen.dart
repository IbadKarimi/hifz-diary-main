import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hafiz_diary/NewScreens/join.dart';
import 'package:hafiz_diary/NewScreens/new_create_profile.dart';
import 'package:hafiz_diary/admin/bottom_navigation.dart';
import 'package:hafiz_diary/authentication/login_screen.dart';
import 'package:hafiz_diary/parents/parents_bottom_navigation.dart';
import 'package:hafiz_diary/parents/parents_login.dart';
import 'package:hafiz_diary/staff/staff_bottom_navigation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'role_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  String ?currectUserId;


  void initState() {

      getCurrentUser();
      initializeApp();



    print("Current User is "+FirebaseAuth.instance.currentUser.toString() );


    // TODO: implement initState
    super.initState();
  }
  Future<void> getCurrentUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      currectUserId = prefs.getString("currentUserId");
      print("Current User id is**************** " + currectUserId.toString());
    });
  }
  Future<void> initializeApp() async {


    await getCurrentUser();




    if (currectUserId!= null) {

      FirebaseFirestore.instance
          .collection("users")
          .doc(currectUserId.toString())
          .get()
          .then((value) {
          if (value.get("type") == 0) {
            Timer(
              const Duration(seconds: 5),
                  () =>
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AdminHomeNavigation(),
                    ),
                  ),
            );
          } else if (value.get("type") == 1) {
            Timer(
              const Duration(seconds: 5),
                  () =>
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          StaffBottomNavigation(
                              isApproved: value.get("status")),
                    ),
                  ),
            );
          } else {
            //----------Parents login
            Timer(
                const Duration(seconds: 5),
                    () =>
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                ParentsLogin(
                                  isApproved: value.get("status"),
                                )

                        )
                    )
            );
          }
        },
      );
    } else {
      Timer(
        const Duration(seconds: 5),
            () =>
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const Join(),
              ),
            ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(

            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset("assets/images/logo.png",width: 200,height: 200,)
            ],
          ),
        ),
      ),
    );
  }
}
