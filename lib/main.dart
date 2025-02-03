import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'page/main_message.dart';
import 'notifications.dart'; // นำเข้า FirebaseNotificationService

void main() async  {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseNotificationService notificationService = FirebaseNotificationService();
  await notificationService.initialize(); // เริ่มต้นการแจ้งเตือน
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TCH Message',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 40, 51, 172)),
        useMaterial3: true,
        textTheme: GoogleFonts.ubuntuTextTheme(), // กำหนดฟอนต์สำหรับทั้งแอปพลิเคชัน
      ),
      home: const MyHomePage(title: 'TCH Message'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  final Future<FirebaseApp> firebase = Firebase.initializeApp();

  void _login() async {
    if(_formKey.currentState!.validate()){
      try {
        UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        User? user = userCredential.user;
        if(user != null){
          /* ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Login Successful!')),
          ); */
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => MainMessage()), // เปลี่ยนหน้าไปยัง main_message.dart
            );
          });
        }
      } 
      catch(e){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login Failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: firebase,
      builder: (context, snapshot){
        if(snapshot.hasError){
          return Scaffold(
            appBar: AppBar(title: Text("Error")),
            body: Center(child: Text("Error: ${snapshot.error}")),
          );
        }

        if(snapshot.connectionState == ConnectionState.done){
          User? currentUser = _auth.currentUser;
          if(currentUser != null){
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => MainMessage()), // เปลี่ยนหน้าไปยัง main_message.dart
              );
            });
          }

          else{
            return Scaffold(
              //backgroundColor: Color.fromARGB(255, 162, 202, 255),
              body: Stack(children: [
                Positioned.fill(
                  child: Container(
                    /* decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/background.png'), // ไฟล์ SVG
                        fit: BoxFit.none, // No scaling
                        alignment: Alignment.topLeft,
                        repeat: ImageRepeat.repeat, // Repeat the image
                      ),
                    ), */
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color.fromARGB(255, 231, 242, 255),
                          const Color.fromARGB(255, 103, 164, 255),
                        ],
                      ),
                    ),
                  ),
                ),
                
                Center(
                  child: Align(
                    alignment: AlignmentDirectional(0.0, 0.0),
                    child: Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(50.0, 0.0, 50.0, 0.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            Align(
                              alignment: AlignmentDirectional(0.0, 0.0),
                              child: Padding(
                                padding:
                                    EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 15.0),
                                child: Text(
                                  '"Login" TCH Message',
                                  style: TextStyle(
                                    fontSize: 28.0,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.0,
                                    fontFamily: GoogleFonts.ubuntu().fontFamily,
                                  ),
                                ),
                              ),
                            ),

                            TextFormField(
                              controller: _emailController,
                              decoration: const InputDecoration(
                                labelText: 'Email',
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.blue,
                                    width: 1.0,
                                  ),
                                  borderRadius: BorderRadius.all(Radius.circular(50)),
                                ),
                                filled: true,
                                fillColor: Colors.white, // พื้นหลังขาว
                              ),
                              style: TextStyle(
                                letterSpacing: 2.0,
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter an email';
                                }
                                final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                                if (!emailRegex.hasMatch(value)) {
                                  return 'Please enter a valid email';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 10.0),

                            TextFormField(
                              controller: _passwordController,
                              obscureText: true,
                              decoration: const InputDecoration(
                                labelText: 'Password',
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.blue,
                                    width: 1.0,
                                  ),
                                  borderRadius: BorderRadius.all(Radius.circular(50)),
                                ),
                                filled: true,
                                fillColor: Colors.white, // พื้นหลังขาว
                              ),
                              style: TextStyle(
                                letterSpacing: 2.0,
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a password';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 10.0),
                            
                            ElevatedButton(
                              onPressed: _login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color.fromARGB(255, 40, 51, 172),
                                foregroundColor: Colors.white,
                              ),
                              child: const Text(
                                'Login',
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
              ]),
            );
          }
        }

        return Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      });
  }
}
