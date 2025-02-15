import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tch_message/main.dart';
import 'package:tch_message/page/main_message.dart';

class ChangepassswordWidget extends StatefulWidget {
  const ChangepassswordWidget({super.key});

  @override
  State<ChangepassswordWidget> createState() => _ChangepassswordWidgetState();
}

class _ChangepassswordWidgetState extends State<ChangepassswordWidget> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void _changePassword() async {
   
    if (_formKey.currentState!.validate()) {
      User? user = _auth.currentUser;

      try{
        if(user != null){
          // ตรวจสอบรหัสผ่านเก่าด้วย re-authentication
          AuthCredential credential = EmailAuthProvider.credential(
            email: user.email!,
            password: _oldPasswordController.text,
          );
          await user.reauthenticateWithCredential(credential);
        }
      }
      catch(e){
        // ตรวจสอบว่า Error เป็นรหัสผ่านผิดหรือไม่
        if(e is FirebaseAuthException && e.code == 'invalid-credential'){
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("The old password is incorrect.")),
          );
        } 
        else{
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("An error occurred. : ${e.toString()}")),
          );
        }
        return;
      }

      if(_newPasswordController.text != _confirmPasswordController.text){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("New passwords do not match")),
        );
        return;
      }

      // อัปเดตรหัสผ่านใหม่
      await user?.updatePassword(_newPasswordController.text);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Password changed successfully and your login new agent.")),
      );

      // รอให้ SnackBar แสดงเสร็จ จากนั้นนำผู้ใช้ไปหน้าอื่น
      Future.delayed(Duration(seconds: 5), () async {
        await FirebaseAuth.instance.signOut();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MyApp()),
        );
      });
    }
  }

  /* @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  } */

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFF4B39EF),
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_rounded,
              color: Colors.white,
              size: 30.0,
            ),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => MainMessage()),  // หรือหน้าที่ต้องการ
              );
            },
          ),
          
          title: Text(
            'Change Password',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24.0,
              letterSpacing: 0.0,
              fontWeight: FontWeight.w500,
            ),
          ),
          actions: [],
          centerTitle: false,
          elevation: 2.0,
        ),

        body: SafeArea(
          top: true,
          child: Align(
            alignment: AlignmentDirectional(0.0, 0.0),
            child: Padding(
              padding: EdgeInsetsDirectional.fromSTEB(50.0, 0.0, 50.0, 0.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    const SizedBox(height: 20.0),

                    TextFormField(
                      controller: _oldPasswordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Old Password',
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Color(0xFF4B39EF),
                            width: 1.0,
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                        ),
                        filled: true,
                        fillColor: Colors.white, // พื้นหลังขาว
                      ),
                      style: TextStyle(
                        letterSpacing: 2.0,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter old password';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 10.0),

                    TextFormField(
                      controller: _newPasswordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'New Password',
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Color(0xFF4B39EF),
                            width: 1.0,
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                        ),
                        filled: true,
                        fillColor: Colors.white, // พื้นหลังขาว
                      ),
                      style: TextStyle(
                        letterSpacing: 2.0,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter new password';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 10.0),
                    
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Confirm New Password',
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Color(0xFF4B39EF),
                            width: 1.0,
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                        ),
                        filled: true,
                        fillColor: Colors.white, // พื้นหลังขาว
                      ),
                      style: TextStyle(
                        letterSpacing: 2.0,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter confirm new password';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 10.0),

                    ElevatedButton(
                      onPressed: _changePassword,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4B39EF),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15), // ปรับค่าโค้งมนของปุ่ม
                        ),
                      ),
                      child: const Text(
                        'Change Password',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
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
    );
  }
}
