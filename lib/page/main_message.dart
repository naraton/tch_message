import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:tch_message/page/change_password.dart';
import 'package:tch_message/page/profile.dart';
import '../main.dart';

class MainMessage extends StatefulWidget {
  const MainMessage({super.key});

  @override
  State<MainMessage> createState() => _MainMessageState();
}

class _MainMessageState extends State<MainMessage> {
  late Query refQ;
  bool isLoading = true;
  String? uid;

  @override
  void initState() {
    super.initState();
    final User? user = FirebaseAuth.instance.currentUser;

    if(user != null){
      uid = user.uid;

      refQ = FirebaseDatabase.instance
          .ref()
          .child('messages')
          .orderByChild('uid')
          .equalTo(user.uid)
          .limitToLast(100); // ดึงข้อมูล 100 รายการล่าสุด
      refQ.once().then((_) {
        setState(() {
          isLoading = false;
        });
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  void showAlertDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("แจ้งเตือน", textAlign: TextAlign.center), // จัดกลางหัวข้อ
          content: Text(
            '"คุณต้องการลบ Message ทั้งหมด"\nคุณต้องการดำเนินการต่อหรือไม่?',
            textAlign: TextAlign.center,
          ),
          actionsAlignment: MainAxisAlignment.center, // จัดปุ่มให้อยู่กึ่งกลาง
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // ปิด Popup
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFBDBDBD),
                foregroundColor: Colors.black,
              ),
              child: Text("ยกเลิก"),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // ปิด Popup
                deleteMessagesByUID(uid!);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE53935),
                foregroundColor: Colors.white,
              ),
              child: Text("ตกลง"),
            ),
          ],
        );
      },
    );
  }

  Future<void> deleteMessagesByUID(String uid) async {
    DatabaseReference database = FirebaseDatabase.instance.ref("messages");

    database.orderByChild("uid").equalTo(uid).once().then((snapshot) {
      if (snapshot.snapshot.value != null) {
        Map<dynamic, dynamic> values = snapshot.snapshot.value as Map<dynamic, dynamic>;

        values.forEach((key, value) {
          database.child(key).remove();
        });
      }
    });
  }

  Future<void> deleteMessagesByDocumentId(String documentId) async {
    DatabaseReference database = FirebaseDatabase.instance.ref("messages");

    database.once().then((snapshot) {
      if (snapshot.snapshot.value != null) {
        Map<dynamic, dynamic> values = snapshot.snapshot.value as Map<dynamic, dynamic>;

        values.forEach((key, value) {
          if (key == documentId) {
            database.child(key).remove();
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },

      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Color(0xFF4B39EF),
          automaticallyImplyLeading: false,
          title: Text(
            'TCH Messages',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22.0,
              letterSpacing: 0.0,
            ),
          ),

          actions: [
            Theme(
              data: Theme.of(context).copyWith(
                popupMenuTheme: PopupMenuThemeData(
                  color: Colors.grey[800], // กำหนดสีพื้นหลังของ PopupMenuButton
                ),
              ),

              child: PopupMenuButton<String>(
                icon: Icon(Icons.settings, color: Colors.white),
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(
                    value: 'Profile',
                    child: Row(
                      children: [
                        Icon(Icons.person, color: Colors.white),
                        SizedBox(width: 6.5),
                        Text('Profile', style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),

                  const PopupMenuItem<String>(
                    value: 'Change Password',
                    child: Row(
                      children: [
                        Icon(Icons.screen_lock_rotation, color: Colors.white),
                        SizedBox(width: 6.5),
                        Text('Change Password', style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),

                  const PopupMenuItem<String>(
                    value: 'Delete Message',
                    child: Row(
                      children: [
                        Icon(Icons.delete_sweep, color: Colors.white),
                        SizedBox(width: 6.5),
                        Text('Delete Message', style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),

                  const PopupMenuDivider(
                    height: 0.5, // กำหนดความสูงของเส้นแบ่ง
                  ),

                  const PopupMenuItem<String>(
                    value: 'Logout',
                    child: Row(
                      children: [
                        Icon(Icons.logout, color: Colors.white),
                        SizedBox(width: 6.5),
                        Text('Logout', style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                ],

                onSelected: (String result) async {
                  switch (result) {
                    case 'Profile':
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => ProfileWidget()),
                      );
                    break;

                    case 'Change Password':
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => ChangepassswordWidget()),
                      );
                    break;

                    case 'Delete Message':
                      refQ.once().then((snapshot) {
                        if(snapshot.snapshot.value != null){
                          showAlertDialog(context);
                        }
                        else{
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("ไม่มีรายการข้อความให้ลบ"),
                              duration: Duration(seconds: 3),
                            ),
                          );
                        }
                      });
                    break;

                    case 'Logout':
                      await FirebaseAuth.instance.signOut();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const MyApp()),
                      );
                    break;

                    default: break;
                  }
                },
              ),
            ),
          ],
          centerTitle: false,
          elevation: 2.0,
        ),

        body: SafeArea(
          top: true,
          child: StreamBuilder(
            stream: refQ.onValue, // ดึงข้อมูลจาก Firebase
            builder: (context, snapshot) {
              if(snapshot.connectionState == ConnectionState.waiting){
                return Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              if(!snapshot.hasData || snapshot.data!.snapshot.value == null){
                return Center(
                  child: Text(
                    "ไม่มีรายการ",
                    style: TextStyle(color: Colors.black),
                  ),
                );
              }
              
              return FirebaseAnimatedList(
                query: refQ,
                itemBuilder: (context, snapshot, animation, index) {
                  Map messageMap = snapshot.value as Map;
                  return Column(
                    children: [
                      Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(10.0, 10.0, 10.0, 2.0),
                        child: Material(
                          color: Colors.transparent,
                          elevation: 0.0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: GestureDetector(
                            onLongPress: () {
                              // เมื่อกดค้างแสดงข้อความแจ้งเตือน
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text("ยืนยันการลบ", textAlign: TextAlign.center),
                                    content: Text("คุณต้องการลบข้อความนี้ใช่หรือไม่?"),
                                    actionsAlignment: MainAxisAlignment.center, // จัดปุ่มให้อยู่กึ่งกลาง
                                    actions: <Widget>[
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.of(context).pop(); // ปิด Popup
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFFBDBDBD),
                                          foregroundColor: Colors.black,
                                        ),
                                        child: Text("ยกเลิก"),
                                      ),

                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.of(context).pop(); // ปิด Dialog
                                          deleteMessagesByDocumentId(snapshot.key!);
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFFE53935),
                                          foregroundColor: Colors.white,
                                        ),
                                        child: Text("ตกลง"),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },

                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    blurRadius: 8.0,
                                    color: Color(0x33000000),
                                    offset: Offset(0.0, 2.0),
                                    spreadRadius: 1.0,
                                  )
                                ],
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(12.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 44.0,
                                      height: 44.0,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: const Color(0xFF4B39EF),
                                          width: 2.0,
                                        ),
                                      ),
                                      child: Padding(
                                        padding: EdgeInsets.all(2.0),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(40.0),
                                          child: Image.network(
                                            messageMap['image'],
                                            width: 44.0,
                                            height: 44.0,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(8.0, 0.0, 0.0, 0.0),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.max,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              messageMap['title'] ?? 'No Title',
                                              textAlign: TextAlign.start,
                                              style: TextStyle(
                                                fontSize: 18.0,
                                                letterSpacing: 0.0,
                                                color: Colors.black,
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsetsDirectional.fromSTEB(0.0, 4.0, 0.0, 0.0),
                                              child: Text(
                                                messageMap['message'] ?? 'No Message',
                                                textAlign: TextAlign.start,
                                                style: TextStyle(
                                                  letterSpacing: 0.0,
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ),
                                            Row(
                                              mainAxisSize: MainAxisSize.max,
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Padding(
                                                  padding: EdgeInsetsDirectional.fromSTEB(0.0, 4.0, 0.0, 0.0),
                                                  child: Text(
                                                    '${messageMap['date']} - ${messageMap['time']}',
                                                    textAlign: TextAlign.start,
                                                    style: TextStyle(
                                                      letterSpacing: 0.0,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}