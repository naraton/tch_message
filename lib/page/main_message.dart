import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../main.dart';

class MainMessage extends StatefulWidget {
  const MainMessage({super.key});

  @override
  State<MainMessage> createState() => _MainMessageState();
}

class _MainMessageState extends State<MainMessage> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
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
                    value: 'Logout',
                    child: Row(
                      children: [
                        Icon(Icons.logout, color: Colors.white),
                        SizedBox(width: 8),
                        Text('Logout', style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'Profile',
                    child: Row(
                      children: [
                        Icon(Icons.person, color: Colors.white),
                        SizedBox(width: 8),
                        Text('Profile', style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'Settings',
                    child: Row(
                      children: [
                        Icon(Icons.settings, color: Colors.white),
                        SizedBox(width: 8),
                        Text('Settings', style: TextStyle(color: Colors.white)),
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
                    case 'Profile':
                      // เพิ่มการทำงานเมื่อเลือก Profile
                      break;
                    case 'Settings':
                      // เพิ่มการทำงานเมื่อเลือก Settings
                      break;
                    // เพิ่มกรณีอื่น ๆ ที่ต้องการ
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
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(0.0, 1.0, 0.0, 0.0),
                child: Column(

                )
              ),
            ],
          ),
        ),
      ),
    );
  }
}