import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme.dart';

class MotherInfoSection extends StatefulWidget {
  final String stdCode;
  final String act;
  const MotherInfoSection({Key? key, required this.stdCode, required this.act})
      : super(key: key);
  @override
  _MotherInfoSectionState createState() => _MotherInfoSectionState();
}

class _MotherInfoSectionState extends State<MotherInfoSection> {
  bool _isDarkMode = false;

  @override
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
    Color backgroundColorSelected =
        _isDarkMode ? backgroundColorDark : backgroundColorLight;
    Color textColorSelected = _isDarkMode ? textColorDark : textColorLight;

    return Container(
      color: backgroundColorSelected,
      child: Center(
        child: Text(
          'Mother Information Section Content',
          style: TextStyle(fontSize: 24, color: textColorSelected),
        ),
      ),
    );
  }
}
