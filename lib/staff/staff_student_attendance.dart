import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hafiz_diary/widget/TextFormField.dart';
import 'package:intl/intl.dart' as intl;
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import '../admin/admin_home.dart';
import '../constants.dart';
import '../provider/provider_class.dart';
import '../widget/app_text.dart';
import '../widget/common_button.dart';

class StaffStudentAttendance extends StatefulWidget {
  final String studentID;
  final String studentName;
  final String imgURL;
  final bool? isAdmin;

  const StaffStudentAttendance(
      {Key? key,
      required this.studentID,
      required this.studentName,
      required this.imgURL,
      required this.isAdmin})
      : super(key: key);

  @override
  State<StaffStudentAttendance> createState() => _StaffStudentAttendanceState();
}

class _StaffStudentAttendanceState extends State<StaffStudentAttendance> {
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
        studentId: widget.studentID);

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
      await _firestore.collection('users').doc(widget.studentID).get();
      setState(() {
        _feeSubmitted = snapshot['feeSubmitted'] ?? false;
      });
    }
  }

  void deleteUser() async {
    try {
      _firestore.collection('users').doc(widget.studentID).delete();
      print('User with ID ${widget.studentID} has been deleted.');
      final classesCollection = FirebaseFirestore.instance.collection('classes');

      final querySnapshot = await classesCollection.get();

      for (final doc in querySnapshot.docs) {
        final classReference = classesCollection.doc(doc.id);

        await classReference.update({
          'students': FieldValue.arrayRemove([widget.studentID]),
        });

        print('Removed student ${widget.studentID} from class ${doc.id}');
      }


      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => const AdminHome()));
    } catch (e) {
      print('Error deleting user: $e');
    }
  }
  void _updateFeeStatus(bool status) async {
    User? user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(widget.studentID).update({
        'feeSubmitted': status,
      });
    }
    _fetchFeeStatus();

  }

  @override
  void dispose() {
    fromAyahController.clear();
    toAyahController.clear();
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProviderClass>(builder: (context, providerClass, child) {
      return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: true,
          backgroundColor: primaryColor,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                text: widget.studentName,
                clr: Colors.white,
                fontWeight: FontWeight.bold,
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
        body: SingleChildScrollView(
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.all(defPadding),
              child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection("attendance")
                      .where("studentId", isEqualTo: widget.studentID)
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
                          : {
                              providerClass.updateCompleteList(
                                  list: snapshot.data!.docs.first.get("Namaz")),
                              providerClass.updateSabaqList(list: []),
                            };

                      return IgnorePointer(
                        ignoring: snapshot.data!.docs.first.get("Attendance") ==
                            "absent",
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Row(
                                children: [
                                  Column(
                                    children: [
                                      widget.imgURL.isEmpty
                                          ? Image.asset(
                                              "assets/images/profile.png",
                                              height: 50,
                                              width: 70,
                                            )
                                          : Image.network(widget.imgURL,
                                              height: 50, width: 70),
                                      AppText(text: widget.studentName)
                                    ],
                                  ),
                                  SizedBox(
                                    width: defPadding,
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Builder(builder: (context) {
                                        final formatter =
                                            intl.DateFormat('MMMM d, y');

                                        return AppText(
                                          text:
                                              formatter.format(DateTime.now()),
                                          clr: primaryColor,
                                          fontWeight: FontWeight.bold,
                                          size: 22,
                                        );
                                      }),
                                      Builder(builder: (context) {
                                        final formatter =
                                            intl.DateFormat('EEEE');

                                        return AppText(
                                          text:
                                              formatter.format(DateTime.now()),
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
                              !widget.isAdmin!
                                  ? snapshot.data!.docs.first
                                          .get("Attendance")
                                          .toString()
                                          .isEmpty
                                      ? Row(
                                          children: [
                                            Expanded(
                                              child: CommonButton(
                                                  text: "Mark Present",
                                                  onTap: () {
                                                    FirebaseFirestore.instance
                                                        .collection(
                                                            "attendance")
                                                        .doc(snapshot.data!.docs
                                                            .first.id)
                                                        .set({
                                                      "Attendance": "present"
                                                    }, SetOptions(merge: true));
                                                  },
                                                  color: primaryColor,
                                                  textColor: Colors.white),
                                            ),
                                            SizedBox(width: defPadding),
                                            Expanded(
                                              child: CommonButton(
                                                  text: "Mark Absent",
                                                  onTap: () {
                                                    FirebaseFirestore.instance
                                                        .collection(
                                                            "attendance")
                                                        .doc(snapshot.data!.docs
                                                            .first.id)
                                                        .set(
                                                      {"Attendance": "absent"},
                                                      SetOptions(merge: true),
                                                    );
                                                  },
                                                  color: primaryColor,
                                                  textColor: Colors.white),
                                            ),
                                          ],
                                        )
                                      : CommonButton(
                                          text: "Update Attendance",
                                          onTap: () {
                                            if (_formKey.currentState!
                                                .validate()) {
                                              FirebaseFirestore.instance
                                                  .collection("attendance")
                                                  .doc(snapshot
                                                      .data!.docs.first.id)
                                                  .set({
                                                // "attendance":
                                                "Sabaq": {
                                                  "para": providerClass
                                                          .sabaqType
                                                          .contains(0)
                                                      ? selectedPara
                                                      : "",
                                                  "fromSurah": providerClass
                                                          .sabaqType
                                                          .contains(0)
                                                      ? fromSurah
                                                      : "",
                                                  "toSurah": providerClass
                                                          .sabaqType
                                                          .contains(0)
                                                      ? toSurah
                                                      : '',
                                                  "fromAyah": providerClass
                                                          .sabaqType
                                                          .contains(0)
                                                      ? fromAyahController.text
                                                      : "",
                                                  "toAyah": providerClass
                                                          .sabaqType
                                                          .contains(0)
                                                      ? toAyahController.text
                                                      : ""
                                                },
                                                "Sabqi": providerClass.sabaqType
                                                        .contains(1)
                                                    ? true
                                                    : false,
                                                "Manzil": providerClass
                                                        .sabaqType
                                                        .contains(2)
                                                    ? true
                                                    : false,
                                                "notify":
                                                    providerClass.notifyAdmin,
                                                "Namaz": providerClass.namaz
                                              }, SetOptions(merge: true));
                                            }
                                          },
                                          color: primaryColor,
                                          textColor: Colors.white)
                                  : const SizedBox(),
                              SizedBox(
                                height: defPadding,
                              ),
                              Row(
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
                                                  if (providerClass.sabaqType
                                                      .contains(0))
                                                    {
                                                      providerClass.removeSabaq(
                                                        num: 0,
                                                      ),
                                                    }
                                                  else
                                                    {
                                                      providerClass.updateSabaq(
                                                          num: 0),
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
                                            : providerClass.sabaqType
                                                    .contains(0)
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
                                          snapshot.data!.docs.first.get("Sabqi")
                                              ? {}
                                              : {
                                                  if (providerClass.sabaqType
                                                      .contains(1))
                                                    {
                                                      providerClass.removeSabaq(
                                                          num: 1),
                                                    }
                                                  else
                                                    {
                                                      providerClass.updateSabaq(
                                                          num: 1),
                                                    }
                                                };
                                        },
                                        child: snapshot.data!.docs.first
                                                .get("Sabqi")
                                            ? Icon(
                                                Icons.check_box,
                                                color: primaryColor,
                                              )
                                            : providerClass.sabaqType
                                                    .contains(1)
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
                                              ? {}
                                              : {
                                                  if (providerClass.sabaqType
                                                      .contains(2))
                                                    {
                                                      providerClass.removeSabaq(
                                                          num: 2),
                                                    }
                                                  else
                                                    {
                                                      providerClass.updateSabaq(
                                                          num: 2),
                                                    }
                                                };
                                        },
                                        child: snapshot.data!.docs.first
                                                .get("Manzil")
                                            ? Icon(
                                                Icons.check_box,
                                                color: primaryColor,
                                              )
                                            : providerClass.sabaqType
                                                    .contains(2)
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
                              SizedBox(
                                height: defPadding,
                              ),
                              snapshot.data!.docs.first
                                      .get("Sabaq")['para']
                                      .toString()
                                      .isEmpty
                                  ? Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        if(widget.isAdmin! == false)
                                        AppText(text: "Notify Admin"),
                                        if(widget.isAdmin! == false)

                                          InkWell(
                                          onTap: () {
                                            if (providerClass.notifyAdmin!) {
                                              providerClass.updateNotify(
                                                  val: false);
                                            } else {
                                              providerClass.updateNotify(
                                                  val: true);
                                            }
                                          },
                                          child: providerClass.notifyAdmin!
                                              ? Icon(
                                                  Icons.check_box,
                                                  color: primaryColor,
                                                )
                                              : Icon(
                                                  Icons.check_box_outline_blank,
                                                  color: primaryColor,
                                                ),
                                        ),
                                      ],
                                    )
                                  : const SizedBox(),
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
                                  hint: AppText(text: "Parah"),
                                  borderRadius:
                                      BorderRadius.circular(defPadding / 3),
                                  isExpanded: true,
                                  underline: const SizedBox(),
                                  value: selectedPara,
                                  icon: const Icon(Icons.keyboard_arrow_down),
                                  items: paraNames.map((String item) {
                                    return DropdownMenuItem(
                                      value: item,
                                      // Assign a unique value for each item
                                      child: Text(item),
                                    );
                                  }).toList(),
                                  onChanged: (newValue) {
                                    setState(() {
                                      selectedPara = newValue
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
                                  hint: AppText(text: "From Surah"),
                                  borderRadius:
                                      BorderRadius.circular(defPadding),
                                  isExpanded: true,
                                  underline: const SizedBox(),
                                  value: fromSurah,
                                  icon: const Icon(Icons.keyboard_arrow_down),
                                  items: surahName.map((String item) {
                                    return DropdownMenuItem(
                                      value: item,
                                      // Assign a unique value for each item
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
                                  borderRadius:
                                      BorderRadius.circular(defPadding),
                                  isExpanded: true,
                                  underline: const SizedBox(),
                                  value: toSurah,
                                  icon: const Icon(Icons.keyboard_arrow_down),
                                  items: surahName.map((String item) {
                                    return DropdownMenuItem(
                                      value: item,
                                      // Assign a unique value for each item
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
                                validation: false,
                                controller: fromAyahController,
                                lableText: "From Ayah",
                              ),
                              SizedBox(
                                height: defPadding,
                              ),
                              CustomTextField(
                                  validation: false,
                                  controller: toAyahController,
                                  lableText: "To Ayah"),
                              SizedBox(
                                height: defPadding,
                              ),
                              if (widget.isAdmin!)
                                ElevatedButton(
                                  onPressed: () => deleteUser(),
                                  style: ElevatedButton.styleFrom(
                                    primary: Colors.green,
                                    textStyle: TextStyle(color: Colors.white), // Set text color to white
                                  ),
                                  child: Text('Delete User'),
                                ),
                              Container(
                                color: Colors.green,
                                padding: EdgeInsets.all(16.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Student Fee Is Submitted?',
                                      style: TextStyle(
                                        fontSize: 24.0,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(height: 16.0),
                                    Text(
                                      'Status: ${_feeSubmitted ? 'Paid' : 'Not Paid'}.',
                                      style: TextStyle(
                                        fontSize: 16.0,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(height: 32.0),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        ElevatedButton(
                                          onPressed: () {
                                            _updateFeeStatus(
                                                true); // Set fee status to true
                                          },
                                          style: ElevatedButton.styleFrom(
                                            primary: Colors.green[600],
                                          ),
                                          child: Text('Yes'),
                                        ),
                                        SizedBox(width: 16.0),
                                        ElevatedButton(
                                          onPressed: () {
                                            _updateFeeStatus(
                                                false); // Set fee status to false
                                          },
                                          style: ElevatedButton.styleFrom(
                                            primary: Colors.green[600],
                                          ),
                                          child: Text('No'),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              AppText(
                                text: "Namaz",
                                clr: primaryColor,
                                fontWeight: FontWeight.bold,
                                size: 20,
                              ),
                              SizedBox(
                                height: defPadding,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                                          child: Text("ظہر")),
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
                                  ),
                                  const SizedBox(),
                                ],
                              ),
                              SizedBox(
                                height: defPadding,
                              ),
                              widget.isAdmin!
                                  ? CommonButton(
                                      text: "Download Report",
                                      onTap: () async {
                                        String studentName = '';
                                        await FirebaseFirestore.instance
                                            .collection("users"
                                                "")
                                            .doc(snapshot.data!.docs.first
                                                .get("studentId"))
                                            .get()
                                            .then((value) {
                                          setState(() {
                                            studentName = value.get("name");
                                          });
                                        });
                                        generatePdf(
                                            snapshot.data!.docs.first
                                                .get("studentId"),
                                            studentName);
                                      },
                                      color: primaryColor,
                                      textColor: Colors.white,
                                    )
                                  : const SizedBox()
                            ],
                          ),
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
      );
    });
  }

  Future<void> showNotification(Uint8List pdfBytes) async {
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'Hifz Diary',
      'Pdf Downloaded',
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0,
      'PDF Saved',
      'Tap to open the PDF file',
      platformChannelSpecifics,
      // payload: pdfBytes.toString(),
    );
  }

  void generatePdf(String studentId, String studentName) async {
    final List<Map<String, dynamic>> data = await fetchFirestoreData(studentId);
    final List<pw.Widget> pdfContent =
        await generatePdfContent(data, studentName);

    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            children: pdfContent,
          );
        },
      ),
    );

    final Uint8List pdfBytes = await pdf.save();

    // Save the PDF file or use any desired method (e.g., share, print, etc.)
    await Printing.sharePdf(
        bytes: pdfBytes, filename: '$studentName Attendance.pdf');
    await showNotification(pdfBytes);
  }

  Future<List<pw.Widget>> generatePdfContent(
    List<Map<String, dynamic>> data,
    String name,
  ) async {
    final urduFont =
        pw.Font.ttf(await rootBundle.load('assets/json/urdu_font.ttf'));

    // List<Map<String, dynamic>> finalData = jsonDecode(data);
    final List<pw.Widget> content = [];
    content.add(pw.Text("$name Attendance",
        style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16)));
    content.add(pw.Divider());
    content.add(pw.SizedBox(height: defPadding));
    content.add(pw.Row(children: [
      pw.Expanded(
          child: pw.Text("Date",
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
      pw.Expanded(
          child: pw.Text("Sabaq",
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
      pw.Expanded(
          child: pw.Text("Sabqi",
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
      pw.Expanded(
          child: pw.Text("Manzal",
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
    ]));
    print("My Data is");
    print(data);

    // Add data to the PDF content
    for (final item in data) {
      content.add(pw.Column(children: [
        pw.Row(
          children: [
            pw.Expanded(
              child: pw.Text(
                item['date'],
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
            ),
            pw.Expanded(
              child: (item['Sabaq']["para"]!.toString().isEmpty)
                  ? pw.Text(
                      "No",
                      style: pw.TextStyle(
                          color: PdfColors.red, fontWeight: pw.FontWeight.bold),
                    )
                  : pw.Text(
                      "Yes",
                      style: pw.TextStyle(
                          color: PdfColors.green,
                          fontWeight: pw.FontWeight.bold),
                    ),
            ),
            pw.Expanded(
              child: pw.Text(
                (item['Sabqi'] ?? true) ? "Not Good" : "Good",

                // item['Sabqi'].toString(),
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
            ),
            pw.Expanded(
              child: pw.Text(
                (item['Manzil'] ?? true) ? "Not Good" : "Good",
                // item['Manzil'].toString(),
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 8),
      ]));
      // content.add(pw.Text(item['date'].toString()));
    }

    return content;
  }

  Future<List<Map<String, dynamic>>> fetchFirestoreData(
      String studentID) async {
    final QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('attendance')
        .orderBy("timestamp", descending: true)
        .where('studentId', isEqualTo: studentID)
        .get();

    final List<Map<String, dynamic>> data =
        snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    print(data);

    return data;
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
