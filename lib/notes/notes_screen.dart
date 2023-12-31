import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hafiz_diary/widget/TextFormField.dart';
import 'package:hafiz_diary/widget/common_button.dart';

import '../constants.dart';
import '../widget/app_text.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({Key? key}) : super(key: key);

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  TextEditingController headingController = TextEditingController();
  TextEditingController notesController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  @override
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
              text: "Notes",
              clr: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            AppText(
              text: "Add Notes About your Madrisa",
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
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(defPadding),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  CustomTextField(
                      validation: false,
                      controller: headingController,
                      lableText: "Heading"),
                  SizedBox(
                    height: defPadding / 2,
                  ),
                  CustomTextField(
                      validation: false,
                      controller: notesController,
                      lableText: "Add your notes",
                      maxLines: 5),
                  SizedBox(
                    height: defPadding / 2,
                  ),
                  CommonButton(
                    text: "Add Note",
                    onTap: () {
                      if (_formKey.currentState!.validate()) {
                        FirebaseFirestore.instance.collection("notes").add({
                          "date": DateTime.now()
                              .toString()
                              .characters
                              .take(10)
                              .toString(),
                          "added_by": FirebaseAuth.instance.currentUser!.uid,
                          "heading": headingController.text,
                          "notes": notesController.text
                        }).then((value) {
                          headingController.clear();
                          notesController.clear();
                        });
                      }
                    },
                    color: primaryColor,
                    textColor: Colors.white,
                  ),
                  SizedBox(
                    height: defPadding,
                  ),
                  StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection("notes")
                        .orderBy("date", descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return ListView.builder(
                          itemCount: snapshot.data!.docs.length,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            return Container(
                              padding: EdgeInsets.all(defPadding),
                              margin: EdgeInsets.symmetric(
                                  vertical: defPadding / 2),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(defPadding),
                                border: Border.all(
                                  color: Colors.grey,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      AppText(
                                        text: snapshot.data!.docs[index]
                                            .get("heading"),
                                        fontWeight: FontWeight.bold,
                                        clr: primaryColor,
                                        size: 22,
                                      ),
                                      InkWell(
                                          onTap: () {
                                            FirebaseFirestore.instance
                                                .collection("notes")
                                                .doc(snapshot
                                                    .data!.docs[index].id)
                                                .delete();
                                          },
                                          child: Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                          ))
                                    ],
                                  ),
                                  SizedBox(
                                    height: defPadding / 2,
                                  ),
                                  AppText(
                                    text:
                                        snapshot.data!.docs[index].get("notes"),
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            "Added By:",
                                            style: TextStyle(
                                                color: Colors.grey
                                                    .withOpacity(0.5),
                                                fontSize: 12),
                                          ),
                                          FutureBuilder(
                                              future: FirebaseFirestore.instance
                                                  .collection("users")
                                                  .doc(snapshot
                                                      .data!.docs[index]
                                                      .get("added_by"))
                                                  .get(),
                                              builder: (context, snap) {
                                                if (snapshot.hasData) {
                                                  return Text(
                                                    snap.data!.get("name"),
                                                    style: TextStyle(
                                                        color: Colors.grey
                                                            .withOpacity(0.5),
                                                        fontSize: 12),
                                                  );
                                                } else {
                                                  return const Center(
                                                    child:
                                                        CircularProgressIndicator(),
                                                  );
                                                }
                                              })
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            "Date:",
                                            style: TextStyle(
                                                color: Colors.grey
                                                    .withOpacity(0.5),
                                                fontSize: 12),
                                          ),
                                          Text(
                                            snapshot.data!.docs[index]
                                                .get("date"),
                                            style: TextStyle(
                                                color: Colors.grey
                                                    .withOpacity(0.5),
                                                fontSize: 12),
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      } else {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                    },
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    ));
  }
}
