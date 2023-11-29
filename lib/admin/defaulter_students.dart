import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants.dart';
import '../widget/app_text.dart';

class DefaulterStudents extends StatefulWidget {
  const DefaulterStudents({Key? key}) : super(key: key);

  @override
  State<DefaulterStudents> createState() => _DefaulterStudentsState();
}

class _DefaulterStudentsState extends State<DefaulterStudents> {
  bool isWidgetVisible = false;
  @override
  Widget build(BuildContext context) {
    SharedPreferences sharedPreferences;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        backgroundColor: primaryColor,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(
              text: "Defaulter",
              clr: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            AppText(
              text: "Each Student who didn't tested sabaq",
              clr: Colors.white60,
              size: 11,
            ),
          ],
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomRight: Radius.circular(defPadding),
            bottomLeft: Radius.circular(defPadding),
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(defPadding),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        isWidgetVisible = !isWidgetVisible;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Colors.green,
                    ),
                    child: Text(
                      isWidgetVisible ? "Hide Other" : "Show Other",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),

                Visibility(
            visible: isWidgetVisible,
            maintainState: true,
            child:
            FutureBuilder(
                    future: FirebaseFirestore.instance
                        .collection("attendance")
                        .where("Attendance", isEqualTo: "present")
                        .where("date",
                            isEqualTo: DateTime.now()
                                .toString()
                                .characters
                                .take(10)
                                .toString())
                        .get(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Column(
                          children: [
                            Row(
                              children: [
                                AppText(
                                  text: "Sabaq",
                                  fontWeight: FontWeight.bold,
                                  clr: primaryColor,
                                  size: 18,
                                ),
                              ],
                            ),
                            SizedBox(
                              height: defPadding / 2,
                            ),
                            SizedBox(
                              height: 120,
                              child: ListView.builder(
                                  itemCount: snapshot.data!.docs
                                      .where((snap) =>
                                          snap.get("Sabaq")['para'] == '')
                                      .length,
                                  scrollDirection: Axis.horizontal,
                                  itemBuilder: (context, index) {
                                    if (snapshot.data!.docs[index]
                                        .get("Sabaq")['para']
                                        .toString()
                                        .isEmpty) {
                                      return FutureBuilder(
                                          future: FirebaseFirestore.instance
                                              .collection("users")
                                              .doc(snapshot.data!.docs[index]
                                                  .get("studentId"))
                                              .get(),
                                          builder: (context, futurSnap) {
                                            if (snapshot.hasData) {
                                              return Column(
                                                children: [
                                                  futurSnap.data!
                                                          .get("img_url")
                                                          .toString()
                                                          .isEmpty
                                                      ? Image.asset(
                                                          "assets/images/profile.png",
                                                          height: 70,
                                                          width: 70,
                                                        )
                                                      : Image.network(
                                                          futurSnap.data!
                                                              .get("img_url"),
                                                          height: 70,
                                                          width: 70,
                                                        ),
                                                  AppText(
                                                      text: futurSnap.data!
                                                          .get("name"))
                                                ],
                                              );
                                            } else {
                                              return CircularProgressIndicator();
                                            }
                                          });
                                    }
                                  }),
                            ),
                            SizedBox(
                              height: defPadding / 2,
                            ),
                            Row(
                              children: [
                                lang == "en"
                                    ? Text(
                                        "Sabqi",
                                        style: TextStyle(
                                            color: primaryColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18),
                                      )
                                    : Directionality(
                                        textDirection: TextDirection.rtl,
                                        child: Text(
                                          "سبقی",
                                          style: TextStyle(
                                              fontSize: 18,
                                              color: primaryColor,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                              ],
                            ),
                            SizedBox(
                              height: defPadding / 2,
                            ),
                            SizedBox(
                              height: 120,
                              child: ListView.builder(
                                  itemCount: snapshot.data!.docs
                                      .where(
                                          (snap) => snap.get("Sabqi") == false)
                                      .length,
                                  scrollDirection: Axis.horizontal,
                                  itemBuilder: (context, index) {
                                    if (!snapshot.data!.docs[index]
                                        .get("Sabqi")) {
                                      return FutureBuilder(
                                          future: FirebaseFirestore.instance
                                              .collection("users")
                                              .doc(snapshot.data!.docs[index]
                                                  .get("studentId"))
                                              .get(),
                                          builder: (context, futurSnap) {
                                            if (snapshot.hasData) {
                                              return Column(
                                                children: [
                                                  futurSnap.data!
                                                          .get("img_url")
                                                          .toString()
                                                          .isEmpty
                                                      ? Image.asset(
                                                          "assets/images/profile.png",
                                                          height: 70,
                                                          width: 70,
                                                        )
                                                      : Image.network(
                                                          futurSnap.data!
                                                              .get("img_url"),
                                                          height: 70,
                                                          width: 70,
                                                        ),
                                                  AppText(
                                                      text: futurSnap.data!
                                                          .get("name"))
                                                ],
                                              );
                                            } else {
                                              return CircularProgressIndicator();
                                            }
                                          });
                                    }
                                  }),
                            ),
                            SizedBox(
                              height: defPadding / 2,
                            ),
                            Row(
                              children: [
                                lang == "en"
                                    ? Text(
                                  "Manzil",
                                  style: TextStyle(
                                      color: primaryColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18),
                                )
                                    : Directionality(
                                  textDirection: TextDirection.rtl,
                                  child: Text(
                                    "منزل",
                                    style: TextStyle(
                                        fontSize: 18,
                                        color: primaryColor,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: defPadding / 2,
                            ),
                            SizedBox(
                              height: 120,
                              child: ListView.builder(
                                  itemCount: snapshot.data!.docs
                                      .where(
                                          (snap) => snap.get("Manzil") == false)
                                      .length,
                                  scrollDirection: Axis.horizontal,
                                  itemBuilder: (context, index) {
                                    if (!snapshot.data!.docs[index]
                                        .get("Manzil")) {
                                      return FutureBuilder(
                                          future: FirebaseFirestore.instance
                                              .collection("users")
                                              .doc(snapshot.data!.docs[index]
                                                  .get("studentId"))
                                              .get(),
                                          builder: (context, futurSnap) {
                                            if (snapshot.hasData) {
                                              return Column(
                                                children: [
                                                  futurSnap.data!
                                                          .get("img_url")
                                                          .toString()
                                                          .isEmpty
                                                      ? Image.asset(
                                                          "assets/images/profile.png",
                                                          height: 70,
                                                          width: 70,
                                                        )
                                                      : Image.network(
                                                          futurSnap.data!
                                                              .get("img_url"),
                                                          height: 70,
                                                          width: 70,
                                                        ),
                                                  AppText(
                                                      text: futurSnap.data!
                                                          .get("name"))
                                                ],
                                              );
                                            } else {
                                              return CircularProgressIndicator();
                                            }
                                          });
                                    }
                                  }),
                            )
                          ],
                        );
                      } else {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                    })),
                SizedBox(
                  height: defPadding / 2,
                ),
                AppText(
                  text: "Absent",
                  fontWeight: FontWeight.bold,
                  clr: primaryColor,
                  size: 18,
                ),
                SizedBox(
                  height: defPadding / 2,
                ),
                FutureBuilder(
                    future: FirebaseFirestore.instance
                        .collection("attendance")
                        .where("Attendance", isEqualTo: "absent")
                        .where("date",
                            isEqualTo: DateTime.now()
                                .toString()
                                .characters
                                .take(10)
                                .toString())
                        .get(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return SizedBox(
                          height: 120,
                          child: ListView.builder(
                              itemCount: snapshot.data!.docs.length,
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (context, index) {
                                return FutureBuilder(
                                    future: FirebaseFirestore.instance
                                        .collection("users")
                                        .doc(snapshot.data!.docs[index]
                                            .get("studentId"))
                                        .get(),
                                    builder: (context, futurSnap) {
                                      if (snapshot.hasData) {
                                        return Column(
                                          children: [
                                            futurSnap.data!
                                                    .get("img_url")
                                                    .toString()
                                                    .isEmpty
                                                ? Image.asset(
                                                    "assets/images/profile.png",
                                                    height: 70,
                                                    width: 70,
                                                  )
                                                : Image.network(
                                                    futurSnap.data!
                                                        .get("img_url"),
                                                    height: 70,
                                                    width: 70,
                                                  ),
                                            AppText(
                                                text:
                                                    futurSnap.data!.get("name"))
                                          ],
                                        );
                                      } else {
                                        return CircularProgressIndicator();
                                      }
                                    });
                              }),
                        );
                      } else {
                        return CircularProgressIndicator();
                      }
                    }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
