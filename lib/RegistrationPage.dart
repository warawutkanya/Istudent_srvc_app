import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme.dart';

class Registrationpage extends StatefulWidget {
  @override
  _RegistrationpageState createState() => _RegistrationpageState();
}

class _RegistrationpageState extends State<Registrationpage> {
  bool _isDarkMode = false;
  void initState() {
    super.initState();
    _loadDarkMode();
  }

  void _loadDarkMode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isDarkMode = prefs.getBool('isDarkMode') ?? false;
    setState(() {
      _isDarkMode = isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Define colors based on the theme mode
    Color backgroundColorSelected =
        _isDarkMode ? backgroundColorDark : backgroundColorLight;
    Color textColorSelected = _isDarkMode ? textColorDark : textColorLight;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'ลงทะเบียนเเก้0/มส.',
          style: TextStyle(color: textColorSelected),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColorSelected),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        backgroundColor: backgroundColorSelected,
      ),
      body: Container(
        color: backgroundColorSelected,
        child: Center(
          child: Text(
            'Payment Page Content',
            style: TextStyle(fontSize: 24, color: textColorSelected),
          ),
        ),
      ),
    );
  }
}
