import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import '../main.dart';

class MainMessage extends StatefulWidget {
  const MainMessage({super.key});

  @override
  State<MainMessage> createState() => _MainMessageState();
}

class _MainMessageState extends State<MainMessage> {
  late Query refQ;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
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
          backgroundColor: Color.fromARGB(255, 40, 51, 172),
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
                    value: 'Change Password',
                    child: Row(
                      children: [
                        Icon(Icons.screen_lock_rotation, color: Colors.white),
                        SizedBox(width: 8),
                        Text('Change Password', style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),

                  const PopupMenuItem<String>(
                    value: 'Logout',
                    child: Row(
                      children: [
                        Icon(Icons.logout, color: Colors.white),
                        SizedBox(width: 8),
                        Text('Logout', style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                ],

                onSelected: (String result) {
                  switch (result) {
                    case 'Logout':
                      FirebaseAuth.instance.signOut();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const MyApp()),
                      );
                      break;
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
          child: isLoading ? Center(child: CircularProgressIndicator()) : FirebaseAnimatedList(
            query: refQ,
            //reverse: true, // แสดงผลจากมากไปน้อย
            itemBuilder: (context, snapshot, animation, index) {
              Map messageMap = snapshot.value as Map;
              return Column(
                children: [
                  Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(0.0, 1.0, 0.0, 0.0),
                    child: Material(
                      elevation: 0.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(0.0),
                      ),
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(0.0),
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
                                  //color: const Color.fromARGB(255, 172, 138, 250),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.indigo[900]!,
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
                  Divider(
                    height: 0.5,
                    thickness: 0.5,
                    color: Color.fromARGB(255, 146, 146, 146),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}