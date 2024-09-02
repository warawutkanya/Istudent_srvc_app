import 'package:flutter/material.dart';
import 'constants.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'homepage.dart';
import 'theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> saveLoginData(
    String stdPrefix, String stdFName, String stdLName, String stdCode) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('stdPrefix', stdPrefix);
  await prefs.setString('stdFName', stdFName);
  await prefs.setString('stdLName', stdLName);
  await prefs.setString('stdCode', stdCode);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String stdPrefix = prefs.getString('stdPrefix') ?? '';
  String stdFName = prefs.getString('stdFName') ?? '';
  String stdLName = prefs.getString('stdLName') ?? '';
  String stdCode = prefs.getString('stdCode') ?? '';
  bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

  runApp(MyApp(
    isLoggedIn: isLoggedIn,
    stdPrefix: stdPrefix,
    stdFName: stdFName,
    stdLName: stdLName,
    stdCode: stdCode,
  ));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  final String stdPrefix;
  final String stdFName;
  final String stdLName;
  final String stdCode;

  const MyApp({
    Key? key,
    required this.isLoggedIn,
    required this.stdPrefix,
    required this.stdFName,
    required this.stdLName,
    required this.stdCode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primaryColor: primaryColor,
        appBarTheme: const AppBarTheme(
          backgroundColor: primaryColor,
          centerTitle: true,
        ),
      ),
      home: isLoggedIn
          ? HomePage(
              stdPrefix: stdPrefix,
              stdFName: stdFName,
              stdLName: stdLName,
              stdCode: stdCode,
            )
          : const LoginPage(title: 'Istudent'),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String id = '';
  String password = '';
  String loginText = 'ล็อคอินเข้าสู่ระบบ';
  late List<String> bannerImages;
  bool idTouched = false;
  bool passwordTouched = false;
  late PageController _pageController;
  int _currentPage = 0;
  late Timer _timer;

  bool isValidInput() {
    return id.isNotEmpty && password.isNotEmpty;
  }

  @override
  void initState() {
    super.initState();
    bannerImages = [
      'assets/6-65.jpg', // Replace with your banner image asset paths
      'assets/7-65.jpg',
    ];
    _pageController = PageController(initialPage: 0);
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(Duration(seconds: 3), (Timer timer) {
      if (_currentPage < bannerImages.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }

      _pageController.animateToPage(
        _currentPage,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    try {
      if (!isValidInput()) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('โปรดระบุข้อมูลให้ครบถ้วน'),
          ),
        );
        return;
      }

      final response = await http.post(
        apiUrl, // Replace with your endpoint
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          'act': 'login',
          'stdCode': id,
          'stdPassword': password,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['status'] == 'success') {
          final student = responseData['student'];
          final stdPrefix = student['stdPrefix'];
          final stdFName = student['stdFName'];
          final stdLName = student['stdLName'];
          final stdCode = student['stdCode'];

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('เข้าสู่ระบบสำเร็จ'),
            ),
          );

          // Save login state to SharedPreferences
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setBool('isLoggedIn', true);
          await prefs.setString('stdPrefix', stdPrefix);
          await prefs.setString('stdFName', stdFName);
          await prefs.setString('stdLName', stdLName);
          await prefs.setString('stdCode', stdCode);

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomePage(
                stdPrefix: stdPrefix,
                stdFName: stdFName,
                stdLName: stdLName,
                stdCode: stdCode,
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(responseData['message']),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'เกิดข้อผิดพลาดระหว่างเข้าสู่ระบบ: ${response.statusCode}'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('เกิดข้อผิดพลาดระหว่างเข้าสู่ระบบ: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.normal,
          ),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  height: 15,
                ),
                Container(
                  height: 140, // Adjust height as needed
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: bannerImages.length,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: EdgeInsets.only(bottom: 20.0),
                        child: Image.asset(
                          bannerImages[index],
                          fit: BoxFit.cover,
                        ),
                      );
                    },
                  ),
                ),
                Text(
                  loginText,
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.normal,
                    fontSize: 20.0,
                  ),
                ),
                SizedBox(height: 10),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color.fromARGB(255, 210, 210, 210),
                      width: 0.5,
                    ),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Container(
                          child: Image.asset(
                            'assets/1.png',
                            width: 30,
                            height: 30,
                            color: primaryColor,
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          'รหัสนักศึกษา',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                TextField(
                  onChanged: (value) {
                    setState(() {
                      id = value;
                    });
                  },
                  onTap: () {
                    setState(() {
                      idTouched = true;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'ระบุข้อมูล',
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Color.fromARGB(255, 210, 210, 210),
                      ),
                    ),
                    errorText: idTouched && id.isEmpty
                        ? '⚠️ โปรดระบุรหัสนักศึกษา'
                        : null,
                  ),
                ),
                SizedBox(height: 10.0),
                Text(
                  "รหัสผ่าน",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                TextField(
                  onChanged: (value) {
                    setState(() {
                      password = value;
                    });
                  },
                  onTap: () {
                    setState(() {
                      passwordTouched = true;
                    });
                  },
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'ระบุข้อมูล',
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Color.fromARGB(255, 210, 210, 210),
                      ),
                    ),
                    errorText: passwordTouched && password.isEmpty
                        ? '⚠️ โปรดระบุรหัสผ่าน'
                        : null,
                  ),
                ),
                SizedBox(height: 80),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isValidInput() ? _login : null,
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.resolveWith<Color>(
                      (Set<MaterialState> states) {
                        if (states.contains(MaterialState.disabled)) {
                          return Colors.grey.withOpacity(0.5);
                        }
                        return primaryColor;
                      },
                    ),
                    foregroundColor:
                        MaterialStateProperty.all<Color>(Colors.white),
                    overlayColor: MaterialStateProperty.resolveWith<Color>(
                      (Set<MaterialState> states) {
                        return const Color(0xFF0054A5);
                      },
                    ),
                    padding: MaterialStateProperty.all<EdgeInsets>(
                      EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
                    ),
                    minimumSize: MaterialStateProperty.all<Size>(
                      const Size(double.infinity, 60),
                    ),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                    ),
                  ),
                  child: Text(
                    'เข้าสู่ระบบ',
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
