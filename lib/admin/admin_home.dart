import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hafiz_diary/NewScreens/new_create_profile.dart';
import 'package:hafiz_diary/admin/class_detail.dart';
import 'package:hafiz_diary/admin/defaulter_students.dart';
import 'package:hafiz_diary/admin/staff_detail.dart';
import 'package:hafiz_diary/admin/users_approval.dart';
import 'package:hafiz_diary/authentication/login_screen.dart';
import 'package:hafiz_diary/authentication/role_page.dart';
import 'package:hafiz_diary/authentication/splash_screen.dart';
import 'package:hafiz_diary/constants.dart';
import 'package:hafiz_diary/notification/notification_screen.dart';
import 'package:hafiz_diary/widget/app_text.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../NewScreens/join.dart';
import '../widget/common_button.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({Key? key}) : super(key: key);

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  String? uId;

  void initState() {

    super.initState();
    initMethod();
  }

  initMethod() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      uId=preferences.getString("currentUserId")!;
    }
    );




  }
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          // Prevent going back to the login screen
          return false;
        },
        child:
      Scaffold(
      appBar:
      AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: primaryColor,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder(
                future: FirebaseFirestore.instance
                    .collection("users")
                    .doc(uId)
                    .get(),
                builder: (context, snap) {
                  if (snap.hasData) {
                    return AppText(
                      text: "Hi, ${snap.data!.get("name")}",
                      clr: Colors.white,
                      fontWeight: FontWeight.bold,

                    );
                  } else {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                }),
            AppText(
              text: "Manage your madrisa here",
              clr: Colors.white60,
              size: 11,
            ),

          ],
        ),
        actions: [

          InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const NotificationScreen()));
            },
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Icon(
                Icons.notifications,
                color: Colors.white,
              ),
            ),
          ),
          InkWell(
            onTap: ()async {

         /*  Navigator.push(context, MaterialPageRoute(builder: (context){
             return SplashScreen();
           }));*/

              SharedPreferences prefs = await SharedPreferences.getInstance();
              prefs.remove("currentUserId");








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
                SizedBox(height: 20,),
                SizedBox(
                  width: 350,
                  height: 50,
                  child: CommonButton(
                    width: 150,
                    height: 50,
                    text: "Create Profile",
                    onTap: () {

                     Navigator.push(context, MaterialPageRoute(builder: (context){
                       return NewProfile();
                     }));

                    },
                    color: primaryColor,
                    textColor: Colors.white,
                  ),
                ),
                SizedBox(height: 20,),

                Row(
                  children: [
                    AppText(
                        text: "STAFF",
                        fontWeight: FontWeight.bold,
                        clr: primaryColor,
                        size: 18),
                  ],
                ),
                SizedBox(
                  height: defPadding / 2,
                ),
                StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection("users")
                        .where("status", isEqualTo: true)
                        .where("remarks", isEqualTo: "approved")
                        .where("type", isEqualTo: 1)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Row(
                          children: [
                            SizedBox(
                              height: 100,
                              child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: snapshot.data!.docs.length,
                                  scrollDirection: Axis.horizontal,
                                  itemBuilder: (context, index) {
                                    if (snapshot.hasData) {
                                      return InkWell(
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      StaffDetail(
                                                        staffID: snapshot.data!
                                                            .docs[index].id!,
                                                      )));
                                        },
                                        child: Column(
                                          children: [
                                            Container(
                                              height: 70,
                                              width: 70,
                                              child: Stack(
                                                children: [
                                                  CircleAvatar(
                                                    radius: 35, // Adjust the radius as needed
                                                    backgroundImage: NetworkImage(
                                                      snapshot.data!.docs[index].get("img_url"),
                                                    ),
                                                  ),
                                                  Positioned.fill(
                                                    child: ClipOval(
                                                      child: Image.network(
                                                        snapshot.data!.docs[index].get("img_url"),
                                                        fit: BoxFit.cover,
                                                        errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                                                          // Return the default image if an error occurs while loading the image
                                                          return Image.asset(
                                                            "assets/images/profile.png",
                                                            fit: BoxFit.cover,
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),



                                            AppText(
                                              text: snapshot.data!.docs[index]
                                                  .get("name"),
                                              clr: Colors.grey,
                                            )
                                          ],
                                        ),
                                      );
                                    } else {
                                      return const Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    }
                                  }),
                            ),
                          ],
                        );
                      } else {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                    }),
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
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const DefaulterStudents(),
                          ),
                        );
                      },
                      child: AppText(
                          text: "Defaulter",
                          clr: primaryColor,
                          fontWeight: FontWeight.bold,
                          textDecoration: TextDecoration.underline),
                    ),
                  ],
                ),
                SizedBox(
                  height: defPadding / 2,
                ),
                StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection("classes")
                        .where("created_by", isEqualTo: uId)
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
                                      builder: (context) => ClassDetail(
                                        classID: snapshot.data!.docs[index].id,
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
                                          SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.6,
                                            child: AppText(
                                              text: snapshot.data!.docs[index]
                                                  .get("class_desc"),
                                              clr: Colors.grey,
                                              maxLines: 3,
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              );
                            });
                      } else {
                        return const Center(
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
