import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hafiz_diary/NewScreens/join.dart';
import 'package:hafiz_diary/authentication/role_page.dart';
import 'package:hafiz_diary/staff/staff_class.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../admin/class_detail.dart';
import '../admin/defaulter_students.dart';
import '../admin/staff_detail.dart';
import '../authentication/login_screen.dart';
import '../constants.dart';
import '../notification/notification_screen.dart';
import '../widget/app_text.dart';

class StaffHome extends StatefulWidget {
  const StaffHome({Key? key}) : super(key: key);

  @override
  State<StaffHome> createState() => _StaffHomeState();
}

class _StaffHomeState extends State<StaffHome> {
  @override
  var  currectUserId;

  Future<void> getCurrentUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      currectUserId = prefs.getString("currentUserId")!;
      print("Current User id is**************** " + currectUserId.toString());
    });
  }
  void initState(){
    getCurrentUser();
    super.initState();
  }
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
      // Prevent going back to the login screen
      return false;
    },
    child:

      Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: primaryColor,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(
              text: "Hi, Abdul",
              clr: Colors.white,
              fontWeight: FontWeight.bold,
            ),

          ],
        ),
        actions: [
          InkWell(
            onTap: ()async {

              SharedPreferences prefs =await SharedPreferences.getInstance();
              prefs.setString("currentUserId", "");








              FirebaseAuth.instance.signOut().then(
                    (value) => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Join(),
                      ),
                    ),
                  );
            },
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Icon(
                Icons.logout,
                color: Colors.white,
              ),
            ),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomRight: Radius.circular(defPadding),
            bottomLeft: Radius.circular(defPadding),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(defPadding),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    AppText(
                      text: "Classes",
                      clr: primaryColor,
                      fontWeight: FontWeight.bold,
                      size: 18,
                    ),
                  ],
                ),
                SizedBox(
                  height: defPadding / 2,
                ),
                StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection("classes")
                        .where("teachers",
                            arrayContains:
                            currectUserId)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return ListView.builder(
                            shrinkWrap: true,
                            itemCount: snapshot.data!.docs.length,
                            physics: const NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              return InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => StaffClass(
                                          classCode: snapshot.data?.docs[index]
                                              .get("class_code"),
                                        className: snapshot.data?.docs[index]
                                            .get("class_name"),
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                  padding: EdgeInsets.all(defPadding / 2),
                                  margin: EdgeInsets.symmetric(
                                      vertical: defPadding / 2),
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius:
                                          BorderRadius.circular(defPadding),
                                      boxShadow: [
                                        BoxShadow(
                                            color: Colors.grey.withOpacity(0.5),
                                            offset: const Offset(0, 0),
                                            spreadRadius: 2,
                                            blurRadius: 1)
                                      ]),
                                  child: Row(
                                    children: [
                                      Image.asset(
                                        "assets/images/model.png",
                                        height: 70,
                                        width: 70,
                                      ),
                                      SizedBox(
                                        width: defPadding / 2,
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          AppText(
                                            text: snapshot.data!.docs[index]
                                                .get("class_name"),
                                            clr: primaryColor,
                                            fontWeight: FontWeight.bold,
                                            size: 16,
                                          ),
                                          AppText(
                                            text: snapshot.data!.docs[index]
                                                .get("class_desc"),
                                            clr: Colors.grey,
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              );
                            });
                      } else {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                    })
              ],
            ),
          ),
        ),
      ),
    ));
  }
}
