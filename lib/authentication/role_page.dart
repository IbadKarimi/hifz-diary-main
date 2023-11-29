import 'package:flutter/material.dart';
import 'package:hafiz_diary/admin/admin_login.dart';
import 'package:hafiz_diary/parents/parents_login.dart';
import 'package:hafiz_diary/widget/app_text.dart';

import '../admin/bottom_navigation.dart';
import '../constants.dart';
import '../staff/staff_bottom_navigation.dart';
import 'login_screen.dart';

class RolePage extends StatefulWidget {
  const RolePage({Key? key}) : super(key: key);

  @override
  State<RolePage> createState() => _RolePageState();
}

class _RolePageState extends State<RolePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(defPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AppText(
                  text: "Choose your role",
                  clr: primaryColor,
                  fontWeight: FontWeight.bold,
                  size: 22),
              AppText(
                text: "Choose who you are to manage this diary",
                clr: Colors.grey,
              ),
              SizedBox(
                height: defPadding * 2,
              ),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LoginScreen(
                                      isAdmin: true,
                                  accountType: "Admin",
                                    )));
                      },
                      child: Container(
                        padding: EdgeInsets.all(defPadding),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(defPadding),
                            border: Border.all(color: Colors.grey, width: 2)),
                        child: Column(
                          children: [
                            Image.asset("assets/images/admin_logo.png"),
                            AppText(
                                text: "ADMIN",
                                clr: primaryColor,
                                fontWeight: FontWeight.bold,
                                size: 15),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: defPadding / 2,
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LoginScreen(
                                      isAdmin: false,
                                   accountType: "Staff",
                                    ),),);
                      },
                      child: Container(
                        padding: EdgeInsets.all(defPadding),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(defPadding),
                            border: Border.all(color: Colors.grey, width: 2)),
                        child: Column(
                          children: [
                            Image.asset("assets/images/staff_logo.png"),
                            AppText(
                                text: "STAFF",
                                clr: primaryColor,
                                fontWeight: FontWeight.bold,
                                size: 15),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: defPadding / 2,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => LoginScreen(
                                    isAdmin: false,
                                accountType: "Student",
                                  ),),);
                    },
                    child: Container(
                      padding: EdgeInsets.all(defPadding),
                      height: 180,
                      width: 150,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(defPadding),
                          border: Border.all(color: Colors.grey, width: 2)),
                      child: Column(
                        children: [
                          Image.asset("assets/images/people_logo.png"),
                          AppText(
                              text: "PARENTS",
                              clr: primaryColor,
                              fontWeight: FontWeight.bold,
                              size: 15),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
