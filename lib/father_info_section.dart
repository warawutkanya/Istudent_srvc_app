import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme.dart';

class FatherInfoSection extends StatefulWidget {
  final String stdCode;
  final String act;
  const FatherInfoSection({Key? key, required this.stdCode, required this.act})
      : super(key: key);
  @override
  _FatherInfoSectionState createState() => _FatherInfoSectionState();
}

class _FatherInfoSectionState extends State<FatherInfoSection> {
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
