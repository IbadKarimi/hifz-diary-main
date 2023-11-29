import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hafiz_diary/admin/admin_home.dart';
import 'package:hafiz_diary/constants.dart';
import 'package:hafiz_diary/notes/notes_screen.dart';
import 'package:hafiz_diary/profile/profile_screen.dart';
import 'package:hafiz_diary/widget/TextFormField.dart';
import 'package:hafiz_diary/widget/app_text.dart';
import 'package:hafiz_diary/widget/common_button.dart';

import 'staff_home.dart';

class StaffBottomNavigation extends StatefulWidget {
  final bool isApproved;
  const StaffBottomNavigation({Key? key, required this.isApproved})
      : super(key: key);

  @override
  State<StaffBottomNavigation> createState() => _StaffBottomNavigationState();
}

class _StaffBottomNavigationState extends State<StaffBottomNavigation> {
  TextEditingController controller = TextEditingController();
  int _selectedIndex = 0;
  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  static const List<Widget> _widgetOptions = <Widget>[
    StaffHome(),
    NotesScreen(),
    ProfileScreen(),
  ];
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.isApproved
        ? Scaffold(
            floatingActionButton: _selectedIndex == 0
                ? FloatingActionButton(
                    backgroundColor: primaryColor,
                    onPressed: () {
                      _createClass();
                    },
                    child: const Icon(
                      Icons.add,
                      color: Colors.white,
                    ),
                  )
                : const SizedBox(),
            body: Center(
              child: _widgetOptions.elementAt(_selectedIndex),
            ),
            bottomNavigationBar: BottomNavigationBar(
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: '',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.list_alt),
                  label: '',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: '',
                ),
              ],
              currentIndex: _selectedIndex,
              selectedItemColor: primaryColor,
              onTap: _onItemTapped,
            ),
          )
        : const Scaffold(
            body: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Center(
                    child:
                        Text("Wait Until your account is approved by admin")),
              ],
            ),
          );
  }

  Future<void> _createClass() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AppText(
                text: "Join a Class",
                clr: primaryColor,
              )
            ],
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                CustomTextField(
                  validation: false,
                  controller: controller,
                  lableText: "Enter Class Code",
                ),
              ],
            ),
          ),
          actions: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: CommonButton(
                text: "Join Class",
                onTap: () {
                  FirebaseFirestore.instance
                      .collection("classes")
                      .where("class_code", isEqualTo: controller.text)
                      .get()
                      .then(
                    (value) {
                      if (!value.docs.first
                          .get("teachers")
                          .toString()
                          .contains(FirebaseAuth.instance.currentUser!.uid)) {
                        FirebaseFirestore.instance
                            .collection("classes")
                            .doc(value.docs.first.id)
                            .set(
                          {
                            "teachers": FieldValue.arrayUnion(
                                [FirebaseAuth.instance.currentUser!.uid])
                          },
                          SetOptions(merge: true),
                        );
                      }
                    },
                  ).catchError((e) => print(e.message));

                  Navigator.pop(context);
                },
                color: primaryColor,
                textColor: Colors.white,
              ),
            )
          ],
        );
      },
    );
  }
}
