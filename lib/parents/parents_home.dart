import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hafiz_diary/NewScreens/join.dart';
import 'package:hafiz_diary/authentication/role_page.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart' as intl;
import 'package:shared_preferences/shared_preferences.dart';
import '../authentication/login_screen.dart';
import '../constants.dart';
import '../provider/provider_class.dart';
import '../widget/TextFormField.dart';
import '../widget/app_text.dart';
import '../widget/common_button.dart';

class ParentsHome extends StatefulWidget {
  const ParentsHome({Key? key}) : super(key: key);

  @override
  State<ParentsHome> createState() => _ParentsHomeState();
}

class _ParentsHomeState extends State<ParentsHome> {
  TextEditingController fromAyahController = TextEditingController();
  TextEditingController toAyahController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String? selectedPara;
  String? fromSurah;
  String? toSurah;
  @override
  void initState() {
    setState(() {
      selectedPara = paraNames.first;
      fromSurah = surahName.first;
      toSurah = surahName.first;
    });
    print(selectedPara);
    // TODO: implement initState
    checkAndCreateDocument(
        date: DateTime.now().toString().characters.take(10).toString(),
        studentId: FirebaseAuth.instance.currentUser!.uid);

    super.initState();
    _fetchFeeStatus();
  }
  bool _feeSubmitted = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  void _fetchFeeStatus() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot snapshot =
      await _firestore.collection('users').doc(user.uid).get();
      setState(() {
        _feeSubmitted = snapshot['feeSubmitted'] ?? false;
      });
    }
  }
  @override
  Widget build(BuildContext context) {

    return Consumer<ProviderClass>(builder: (context, providerClass, child) {
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
          FutureBuilder(
          future: FirebaseFirestore.instance
              .collection("users")
              .doc(FirebaseAuth.instance.currentUser!.uid)
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

            ],
          ),
          actions: [
            InkWell(
              onTap: () async{

                SharedPreferences prefs = await SharedPreferences.getInstance();
                prefs.remove("currentUserId");






                FirebaseAuth.instance.signOut().then(
                      (value) => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>Join(),
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
              child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection("attendance")
                      .where("studentId",
                          isEqualTo: FirebaseAuth.instance.currentUser!.uid)
                      .where("date",
                          isEqualTo: DateTime.now()
                              .toString()
                              .characters
                              .take(10)
                              .toString())
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      providerClass.isUpdated
                          ? null
                          : providerClass.updateCompleteList(
                              list: snapshot.data!.docs.first.get("Namaz"));

                      return Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                FutureBuilder(
                                    future: FirebaseFirestore.instance
                                        .collection("users")
                                        .doc(FirebaseAuth
                                            .instance.currentUser!.uid)
                                        .get(),
                                    builder: (context, snap) {
                                      if (snap.hasData) {
                                        return Column(
                                          children: [
                                            snap.data!
                                                    .get("img_url")
                                                    .toString()
                                                    .isEmpty
                                                ? Image.asset(
                                                    "assets/images/profile.png",
                                                    height: 50,
                                                    width: 70,
                                                  )
                                                : Image.network(
                                                    snap.data!.get("img_url"),
                                                    height: 50,
                                                    width: 70),
                                            AppText(
                                                text: snap.data!.get("name"))
                                          ],
                                        );
                                      } else {
                                        return const Center(
                                          child: CircularProgressIndicator(),
                                        );
                                      }
                                    }),
                                SizedBox(
                                  width: defPadding,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Builder(builder: (context) {
                                      final formatter =
                                          intl.DateFormat('MMMM d, y');

                                      return AppText(
                                        text: formatter.format(DateTime.now()),
                                        clr: primaryColor,
                                        fontWeight: FontWeight.bold,
                                        size: 22,
                                      );
                                    }),
                                    Builder(builder: (context) {
                                      final formatter = intl.DateFormat('EEEE');

                                      return AppText(
                                        text: formatter.format(DateTime.now()),
                                        clr: Colors.grey,
                                      );
                                    }),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(
                              height: defPadding / 2,
                            ),
                            IgnorePointer(
                              ignoring: true,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          snapshot.data!.docs.first
                                                  .get("Sabaq")['para']
                                                  .toString()
                                                  .isEmpty
                                              ? {
                                                  if (providerClass.sabaqType ==
                                                      0)
                                                    {
                                                      // providerClass
                                                      //     .updateSabaqType(
                                                      //         val: -1),
                                                    }
                                                  else
                                                    {
                                                      // providerClass
                                                      //     .updateSabaqType(
                                                      //         val: 0),
                                                    }
                                                }
                                              : null;
                                        },
                                        child: snapshot.data!.docs.first
                                                .get("Sabaq")['para']
                                                .toString()
                                                .isNotEmpty
                                            ? Icon(
                                                Icons.check_box,
                                                color: primaryColor,
                                              )
                                            : providerClass.sabaqType == 0
                                                ? Icon(
                                                    Icons.check_box,
                                                    color: primaryColor,
                                                  )
                                                : Icon(
                                                    Icons
                                                        .check_box_outline_blank,
                                                    color: primaryColor),
                                      ),
                                      SizedBox(
                                        width: defPadding / 2,
                                      ),
                                      const Directionality(
                                          textDirection: TextDirection.rtl,
                                          child: Text("سبق")),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          snapshot.data!.docs.first
                                                  .get("Sabqi")['para']
                                                  .toString()
                                                  .isEmpty
                                              ? {
                                                  if (providerClass.sabaqType ==
                                                      1)
                                                    {
                                                      // providerClass
                                                      //     .updateSabaqType(
                                                      //         val: -1),
                                                    }
                                                  else
                                                    {
                                                      // providerClass
                                                      //     .updateSabaqType(
                                                      //         val: 1),
                                                    }
                                                }
                                              : null;
                                        },
                                        child: snapshot.data!.docs.first
                                                .get("Sabqi")
                                            ? Icon(
                                                Icons.check_box,
                                                color: primaryColor,
                                              )
                                            : providerClass.sabaqType == 1
                                                ? Icon(
                                                    Icons.check_box,
                                                    color: primaryColor,
                                                  )
                                                : Icon(
                                                    Icons
                                                        .check_box_outline_blank,
                                                    color: primaryColor,
                                                  ),
                                      ),
                                      SizedBox(
                                        width: defPadding / 2,
                                      ),
                                      const Directionality(
                                          textDirection: TextDirection.rtl,
                                          child: Text("سبقی")),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          snapshot.data!.docs.first
                                                  .get("Manzil")
                                              ? {
                                                  if (providerClass.sabaqType ==
                                                      2)
                                                    {
                                                      // providerClass
                                                      //     .updateSabaqType(
                                                      //         val: -1),
                                                    }
                                                  else
                                                    {
                                                      // providerClass
                                                      //     .updateSabaqType(
                                                      //         val: 2),
                                                    }
                                                }
                                              : null;
                                        },
                                        child: snapshot.data!.docs.first
                                                .get("Manzil")
                                            ? Icon(
                                                Icons.check_box,
                                                color: primaryColor,
                                              )
                                            : providerClass.sabaqType == 2
                                                ? Icon(
                                                    Icons.check_box,
                                                    color: primaryColor,
                                                  )
                                                : Icon(
                                                    Icons
                                                        .check_box_outline_blank,
                                                    color: primaryColor,
                                                  ),
                                      ),
                                      SizedBox(
                                        width: defPadding / 2,
                                      ),
                                      const Directionality(
                                          textDirection: TextDirection.rtl,
                                          child: Text("منزل")),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: defPadding,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                               if(_feeSubmitted == false)
                                AppText(
                                    text:
                                        "Your fee is pending. Please clear your dues")
                              ],
                            ),
                            SizedBox(
                              height: defPadding,
                            ),
                            SizedBox(
                              height: defPadding,
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: defPadding / 2),
                              decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.circular(defPadding / 3),
                                  border: Border.all(color: Colors.grey)),
                              child:
                    IgnorePointer(
                    ignoring:true, // Disable the DropdownButton if isAdmin is false
                    child:


                              DropdownButton(
                                hint: AppText(text: "Parah"),
                                borderRadius:
                                    BorderRadius.circular(defPadding / 3),
                                isExpanded: true,
                                underline: const SizedBox(),
                                value: selectedPara,
                                icon: const Icon(Icons.keyboard_arrow_down),
                                items: paraNames.map((String item) {
                                  return DropdownMenuItem(
                                    value:
                                        item, // Assign a unique value for each item
                                    child: Text(item),
                                  );
                                }).toList(),
                                onChanged: (newValue) {
                                  setState(() {
                                    selectedPara = newValue
                                        as String; // Cast newValue to String
                                  });
                                },
                              ),)
                            ),
                            SizedBox(
                              height: defPadding,
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: defPadding / 2),
                              decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.circular(defPadding / 3),
                                  border: Border.all(color: Colors.grey)),
                              child:
                    IgnorePointer(
                    ignoring: true, // Disable the DropdownButton if isAdmin is false
                    child:


                              DropdownButton(
                                hint: AppText(text: "From Surah"),
                                borderRadius: BorderRadius.circular(defPadding),
                                isExpanded: true,
                                underline: const SizedBox(),
                                value: fromSurah,
                                icon: const Icon(Icons.keyboard_arrow_down),
                                items: surahName.map((String item) {
                                  return DropdownMenuItem(
                                    value:
                                        item, // Assign a unique value for each item
                                    child: Directionality(
                                        textDirection: TextDirection.rtl,
                                        child: Text(item)),
                                  );
                                }).toList(),
                                onChanged: (newValue) {
                                  setState(() {
                                    fromSurah = newValue
                                        as String; // Cast newValue to String
                                  });
                                },
                              )),
                            ),
                            SizedBox(
                              height: defPadding,
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: defPadding / 2),
                              decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.circular(defPadding / 3),
                                  border: Border.all(color: Colors.grey)),
                              child:
                    IgnorePointer(
                    ignoring: true, // Disable the DropdownButton if isAdmin is false
                    child:

                              DropdownButton(
                                hint: AppText(text: "To Surah"),
                                borderRadius: BorderRadius.circular(defPadding),
                                isExpanded: true,
                                underline: const SizedBox(),
                                value: toSurah,
                                icon: const Icon(Icons.keyboard_arrow_down),
                                items: surahName.map((String item) {
                                  return DropdownMenuItem(
                                    value:
                                        item, // Assign a unique value for each item
                                    child: Directionality(
                                        textDirection: TextDirection.rtl,
                                        child: Text(item)),
                                  );
                                }).toList(),
                                onChanged: (newValue) {
                                  setState(() {
                                    toSurah = newValue
                                        as String; // Cast newValue to String
                                  });
                                },
                              )),
                            ),
                            SizedBox(
                              height: defPadding,
                            ),
                            CustomTextField(
                              enabled:false,
                              validation: false,
                              controller: fromAyahController,
                              lableText: "From Ayah",
                            ),
                            SizedBox(
                              height: defPadding,
                            ),
                            CustomTextField(
                                enabled:false,
                                validation: false,
                                controller: toAyahController,
                                lableText: "To Ayah"),
                            SizedBox(
                              height: defPadding,
                            ),
                            AppText(
                              text: "Namaz",
                              clr: primaryColor,
                              fontWeight: FontWeight.bold,
                              size: 20,
                            ),
                            SizedBox(
                              height: defPadding / 2,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [AppText(text: "Marked By Parents")],
                            ),
                            SizedBox(
                              height: defPadding,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        if (providerClass.namaz[0]) {
                                          providerClass.updateList(
                                              num: 0, val: false);
                                        } else {
                                          providerClass.updateList(
                                              num: 0, val: true);
                                        }
                                      },
                                      child: providerClass.namaz[0]
                                          ? Icon(
                                              Icons.check_box,
                                              color: primaryColor,
                                            )
                                          : Icon(
                                              Icons.check_box_outline_blank,
                                              color: primaryColor,
                                            ),
                                    ),
                                    SizedBox(
                                      width: defPadding / 2,
                                    ),
                                    const Directionality(
                                        textDirection: TextDirection.rtl,
                                        child: Text("فجر")),
                                  ],
                                ),
                                Row(
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        if (providerClass.namaz[1]) {
                                          providerClass.updateList(
                                              num: 1, val: false);
                                        } else {
                                          providerClass.updateList(
                                              num: 1, val: true);
                                        }
                                      },
                                      child: providerClass.namaz[1]
                                          ? Icon(
                                              Icons.check_box,
                                              color: primaryColor,
                                            )
                                          : Icon(
                                              Icons.check_box_outline_blank,
                                              color: primaryColor,
                                            ),
                                    ),
                                    SizedBox(
                                      width: defPadding / 2,
                                    ),
                                    const Directionality(
                                        textDirection: TextDirection.rtl,
                                        child: Text("ظہر"))
                                  ],
                                ),
                                Row(
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        if (providerClass.namaz[2]) {
                                          providerClass.updateList(
                                              num: 2, val: false);
                                        } else {
                                          providerClass.updateList(
                                              num: 2, val: true);
                                        }
                                      },
                                      child: providerClass.namaz[2]
                                          ? Icon(
                                              Icons.check_box,
                                              color: primaryColor,
                                            )
                                          : Icon(
                                              Icons.check_box_outline_blank,
                                              color: primaryColor,
                                            ),
                                    ),
                                    SizedBox(
                                      width: defPadding / 2,
                                    ),
                                    const Directionality(
                                        textDirection: TextDirection.rtl,
                                        child: Text("عصر")),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(
                              height: defPadding / 2,
                            ),
                            Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  const SizedBox(),
                                  Row(
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          if (providerClass.namaz[3]) {
                                            providerClass.updateList(
                                                num: 3, val: false);
                                          } else {
                                            providerClass.updateList(
                                                num: 3, val: true);
                                          }
                                        },
                                        child: providerClass.namaz[3]
                                            ? Icon(
                                                Icons.check_box,
                                                color: primaryColor,
                                              )
                                            : Icon(
                                                Icons.check_box_outline_blank,
                                                color: primaryColor,
                                              ),
                                      ),
                                      SizedBox(
                                        width: defPadding / 2,
                                      ),
                                      const Directionality(
                                          textDirection: TextDirection.rtl,
                                          child: Text("مغرب")),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          if (providerClass.namaz[4]) {
                                            providerClass.updateList(
                                                num: 4, val: false);
                                          } else {
                                            providerClass.updateList(
                                                num: 4, val: true);
                                          }
                                        },
                                        child: providerClass.namaz[4]
                                            ? Icon(
                                                Icons.check_box,
                                                color: primaryColor,
                                              )
                                            : Icon(
                                                Icons.check_box_outline_blank,
                                                color: primaryColor,
                                              ),
                                      ),
                                      SizedBox(
                                        width: defPadding / 2,
                                      ),
                                      const Directionality(
                                          textDirection: TextDirection.rtl,
                                          child: Text("عشاء")),
                                    ],
                                  )
                                ]),
                            SizedBox(
                              height: defPadding,
                            ),
                            CommonButton(
                              text: "Update Namaz",
                              onTap: () {
                                FirebaseFirestore.instance
                                    .collection("attendance")
                                    .doc(snapshot.data!.docs.first.id)
                                    .set({"Namaz": providerClass.namaz},
                                        SetOptions(merge: true));
                              },
                              color: primaryColor,
                              textColor: Colors.white,
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
          ),
        ),
      ));
    });
  }

  Future<void> checkAndCreateDocument(
      {required String studentId, required String date}) async {
    try {
      final collectionRef = FirebaseFirestore.instance.collection('attendance');

      // Query the Firestore collection to check if the document exists
      final querySnapshot = await collectionRef
          .where('studentId', isEqualTo: studentId)
          .where('date', isEqualTo: date)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        // Document does not exist, create a new document
        await collectionRef.add({
          'studentId': studentId,
          'date': DateTime.now().toString().characters.take(10).toString(),
          "timestamp": DateTime.now(),
          'teacherID': FirebaseAuth.instance.currentUser!.uid,
          'Attendance': "",
          "Sabaq": {
            "para": "",
            "fromSurah": "",
            "toSurah": "",
            "fromAyah": "",
            "toAyah": ""
          },
          "Sabqi": false,
          "Manzil": false,
          "Namaz": [false, false, false, false, false],
          "notify": false,
        });

        print('Document created successfully.');
      } else {
        print('Document already exists.');
      }
    } catch (e) {
      print('Error: $e');
      // Handle any errors that occur during the process
    }
  }
}
