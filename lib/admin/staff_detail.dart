import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hafiz_diary/constants.dart';
import 'package:hafiz_diary/widget/app_text.dart';
import 'package:hafiz_diary/widget/common_button.dart';

class StaffDetail extends StatefulWidget {
  final String staffID;
  const StaffDetail({Key? key, required this.staffID}) : super(key: key);

  @override
  State<StaffDetail> createState() => _StaffDetailState();
}

class _StaffDetailState extends State<StaffDetail> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        backgroundColor: primaryColor,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(
              text: "Staff Detail",
              clr: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            AppText(
              text: "Manage Staff Here",
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
          child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection("users")
                  .doc(widget.staffID)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Column(
                    children: [
                      snapshot.data!.get("img_url").toString().isEmpty
                          ? const CircleAvatar(
                              radius: 50,
                            )
                          : CircleAvatar(
                              radius: 50,
                              backgroundImage:
                                  NetworkImage(snapshot.data?.get("img_url")),
                            ),
                      SizedBox(
                        height: defPadding,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AppText(
                              text: snapshot.data!.get("name"),
                              fontWeight: FontWeight.bold,
                              clr: primaryColor,
                              size: 18),
                          SizedBox(
                            height: defPadding / 2,
                          ),
                          SizedBox(
                            width: defPadding / 2,
                          ),
                          // Icon(Icons.edit_note_sharp)
                        ],
                      ),
                      AppText(text: "Staff", clr: Colors.grey),
                      const Divider(),
                      SizedBox(
                        height: defPadding / 2,
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                              child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppText(
                                  text: "Status",
                                  clr: primaryColor,
                                  fontWeight: FontWeight.bold),
                              SizedBox(
                                height: defPadding / 2,
                              ),
                              AppText(
                                text: "Teaching",
                                clr: Colors.grey,
                              ),
                              SizedBox(
                                height: defPadding,
                              ),
                              AppText(
                                  text: "Start Time",
                                  clr: primaryColor,
                                  fontWeight: FontWeight.bold),
                              SizedBox(
                                height: defPadding / 2,
                              ),
                              AppText(
                                text: "8:00 AM",
                                clr: Colors.grey,
                              ),
                              SizedBox(
                                height: defPadding,
                              ),
                              AppText(
                                  text: "Working",
                                  clr: primaryColor,
                                  fontWeight: FontWeight.bold),
                              SizedBox(
                                height: defPadding / 2,
                              ),
                              AppText(
                                text: "14 Days of April",
                                clr: Colors.grey,
                              ),
                              SizedBox(
                                height: defPadding,
                              ),
                            ],
                          )),
                          Expanded(
                              child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppText(
                                  text: "Class",
                                  clr: primaryColor,
                                  fontWeight: FontWeight.bold),
                              SizedBox(
                                height: defPadding / 2,
                              ),
                              FutureBuilder(
                                  future: FirebaseFirestore.instance
                                      .collection("classes")
                                      .where("teachers",
                                          arrayContains: widget.staffID)
                                      .get(),
                                  builder: (context, snap) {
                                    if (snap.hasData) {
                                      return ListView.builder(
                                          shrinkWrap: true,
                                          itemCount: snap.data!.docs.length,
                                          itemBuilder: (context, index) {
                                            return Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                      "${snap.data!.docs[index].get("class_name")}"),
                                                ),
                                                Builder(builder: (context) {
                                                  return InkWell(
                                                      onTap: () {
                                                        List<dynamic>
                                                            classList = snap
                                                                .data!
                                                                .docs[index]
                                                                .get(
                                                                    "teachers");
                                                        classList.remove(
                                                            widget.staffID);
                                                        FirebaseFirestore
                                                            .instance
                                                            .collection(
                                                                "classes")
                                                            .doc(snap.data!
                                                                .docs[index].id)
                                                            .set(
                                                                {
                                                              "teachers":
                                                                  classList
                                                            },
                                                                SetOptions(
                                                                    merge:
                                                                        true)).then(
                                                                (value) {
                                                          setState(() {});
                                                        });
                                                      },
                                                      child: Icon(
                                                        Icons.remove_circle,
                                                        color: Colors.red,
                                                      ));
                                                })
                                              ],
                                            );
                                          });
                                    } else {
                                      return const Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    }
                                  }),
                              SizedBox(
                                height: defPadding,
                              ),
                            ],
                          )),
                        ],
                      ),
                      // CommonButton(
                      //   text: "Save Changes",
                      //   onTap: () {},
                      //   color: primaryColor,
                      //   textColor: Colors.white,
                      // )
                    ],
                  );
                } else {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
              }),
        ),
      ),
    );
  }
}
