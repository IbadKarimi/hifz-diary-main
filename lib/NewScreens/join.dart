import 'package:flutter/material.dart';
import 'package:hafiz_diary/NewScreens/new_login.dart';
import 'package:hafiz_diary/admin/admin_home.dart';
import 'package:hafiz_diary/authentication/sign_up.dart';
import 'package:hafiz_diary/widget/TextFormField.dart';
import 'package:hafiz_diary/widget/common_button.dart';

import '../constants.dart';
import '../widget/app_text.dart';
import 'new_sign_up.dart';

class Join extends StatefulWidget {
  const Join({Key? key}) : super(key: key);

  @override
  State<Join> createState() => _Join();
}

class _Join extends State<Join> {
  TextEditingController controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(defPadding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 200,),
              Image.asset("assets/images/logo.png",width: 200,height: 200,),
              SizedBox(height: 70,),
              CommonButton(
                text: "Join in Madrissa",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NewLogin(),
                    ),
                  );
                },
                color: primaryColor,
                textColor: Colors.white,
              ),
              SizedBox(height: 20,),
              CommonButton(
                text: "Create Madrissa",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NewSignUp(accountType: "0"),
                    ),
                  );
                },
                color: primaryColor,
                textColor: Colors.white,
              ),


            ],
          ),
        ),
      ),
    );
  }
}
