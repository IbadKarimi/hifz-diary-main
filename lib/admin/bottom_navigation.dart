import 'dart:math';

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
import 'package:shared_preferences/shared_preferences.dart';

class AdminHomeNavigation extends StatefulWidget {
  const AdminHomeNavigation({Key? key}) : super(key: key);

  @override
  State<AdminHomeNavigation> createState() => _AdminHomeNavigationState();
}

class _AdminHomeNavigationState extends State<AdminHomeNavigation> {
  TextEditingController classNameController = TextEditingController();
  TextEditingController classCodeController = TextEditingController();
  TextEditingController classDescController = TextEditingController();
  var currentUserId;
  final _formKey = GlobalKey<FormState>();
  int Value = 0;
  @override
  getCurrentUserId()async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      currentUserId= prefs.getString("currentUserId") ;
    });

  }
  void initState() {
     getCurrentUserId();
    setState(() {
      classCodeController.text = Random().nextInt(100000).toString();
    });
    // TODO: implement initState
    super.initState();
  }



  int _selectedIndex = 0;
  static const TextStyle optionStyle =
  TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  static  List<Widget> _widgetOptions = <Widget>[

    AdminHome(),
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
    return Scaffold(
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
          : SizedBox(),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        children: [

          Expanded(
            child: _widgetOptions.elementAt(_selectedIndex),
          ),

        ],
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
                text: "Create Class",
                clr: primaryColor,
              )
            ],
          ),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: ListBody(
                children: <Widget>[
                  SizedBox(
                    height: defPadding,
                  ),
                  CustomTextField(
                    validation: false,
                    controller: classNameController,
                    lableText: "Class Name",
                  ),
                  SizedBox(
                    height: defPadding,
                  ),
                  CustomTextField(
                      validation: false,
                      controller: classCodeController,
                      lableText: "Class Code"),
                  SizedBox(
                    height: defPadding,
                  ),
                  CustomTextField(
                      validation: false,
                      controller: classDescController,
                      lableText: "Class Description"),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: CommonButton(
                text: "Create Class--------------",
                onTap: () {
                  if (_formKey.currentState!.validate()) {
                    FirebaseFirestore.instance.collection("classes").add({
                      "class_name": classNameController.text,
                      "class_code": classCodeController.text,
                      "teachers": [],
                      "students": [],
                      "created_by": currentUserId.toString(),
                      "class_desc": classDescController.text,
                    }).then((value) {
                      Navigator.pop(context);
                      setState(() {
                        classNameController.clear();
                        classDescController.clear();
                        classCodeController.text =
                            Random().nextInt(1000000).toString();
                      });
                    });
                  }
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
