import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hafiz_diary/staff/staff_student_attendance.dart';

import '../constants.dart';
import '../widget/app_text.dart';

class StaffClass extends StatefulWidget {
  final String classCode;
  final String className;
  const StaffClass({Key? key, required this.classCode, required this.className})
      : super(key: key);

  @override
  State<StaffClass> createState() => _StaffClassState();
}

class _StaffClassState extends State<StaffClass> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // automaticallyImplyLeading: false,
        backgroundColor: primaryColor,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(
              text: widget.className,
              clr: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            AppText(
              text: "See The Details of Each Student",
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
          padding: EdgeInsets.symmetric(horizontal: defPadding),
          child: SingleChildScrollView(
            child: Column(
              children: [
                FutureBuilder(
                    future: FirebaseFirestore.instance
                        .collection("classes")
                        .where("class_code", isEqualTo: widget.classCode)
                        .get(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return GridView.builder(
                            gridDelegate:
                                const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 200,
                              childAspectRatio: 3 / 2.5,
                              crossAxisSpacing: 20,
                              mainAxisSpacing: 10,
                            ),
                            itemCount: snapshot.data!.docs.first
                                .get("students")
                                .length,
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemBuilder: (BuildContext ctx, index) {
                              if (snapshot.hasData) {
                                return FutureBuilder(
                                  future: FirebaseFirestore.instance
                                      .collection("users")
                                      .doc(snapshot.data!.docs.first
                                          .get("students")[index])
                                      .get(),
                                  builder: (context, futureSnap) {
                                    if (snapshot.hasData) {
                                      return InkWell(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  StaffStudentAttendance(
                                                    isAdmin: false,
                                                studentID: futureSnap.data!.id,
                                                studentName: futureSnap.data!
                                                    .get("name"),
                                                imgURL: futureSnap.data!
                                                    .get("img_url"),
                                              ),
                                            ),
                                          );
                                        },
                                        child: Column(
                                          children: [
                                            // futureSnap.data!
                                            //         .get("img_url")
                                            //         .toString()
                                            //         .isEmpty
                                            //     ? Image.asset(
                                            //         "assets/images/profile.png",
                                            //         height: 100,
                                            //         width: 100,
                                            //       )
                                            //     : Image.network(
                                            //         futureSnap.data!
                                            //             .get("img_url"),
                                            //         height: 100,
                                            //         width: 100,
                                            //       ),

                                            SizedBox(
                                              height: 22,
                                            ),

                                            Container(
                                              height: 70,
                                              width: 70,
                                              child: Stack(
                                                children: [
                                                  CircleAvatar(
                                                    radius: 35, // Adjust the radius as needed
                                                    backgroundImage: NetworkImage(
                                                      futureSnap.data!.get("img_url"),
                                                    ),
                                                  ),
                                                  Positioned.fill(
                                                    child: ClipOval(
                                                      child: Image.network(
                                                        futureSnap.data!.get("img_url"),
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




                                            SizedBox(
                                              height: defPadding / 2,
                                            ),
                                            AppText(
                                                text: futureSnap.data!
                                                    .get("name"))
                                          ],
                                        ),
                                      );
                                    } else {
                                      return const SizedBox();
                                    }
                                  },
                                );
                              } else {
                                return const SizedBox();
                              }
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
    );
  }
}
