import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const Color primaryColor = Color(0xFF2771FF);

final lightBackgroundColor = Colors.white;
final darkBackgroundColor = Colors.black;

ValueNotifier<bool> darkModeNotifier = ValueNotifier(false);

Color get backgroundColorSelected =>
    darkModeNotifier.value ? darkBackgroundColor : lightBackgroundColor;

// Light theme colors
const Color primaryColorLight = Color(0xFF2771FF);
const Color backgroundColorLight = Colors.white;
const Color textColorLight = Colors.black;
const Color tapColorLight = Colors.white;

// Dark theme colors
const Color primaryColorDark = Color(0xFF00BCD4); // Example dark mode color
const Color backgroundColorDark = Colors.black;
const Color textColorDark = Colors.white;
const Color tapColorDark = Colors.black;

class ThemeScreen extends StatefulWidget {
  @override
  _ThemeScreenState createState() => _ThemeScreenState();
}

class _ThemeScreenState extends State<ThemeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isDarkMode =
      darkModeNotifier.value; // Initialize with current dark mode state

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.index = _isDarkMode ? 1 : 0;
    _tabController.addListener(_handleTabSelection);
    _loadThemeMode();
  }

  void _handleTabSelection() {
    // Handle tab selection if needed
  }

  void _updateCounts(int index) {
    _tabController.animateTo(index);
    bool isDarkMode = index == 1;
    setState(() {
      _isDarkMode = index == 1; // Update _isDarkMode based on tab selection
      darkModeNotifier.value = _isDarkMode; // Update global dark mode state
    });
    _saveThemeMode(isDarkMode);
  }

  Future<void> _saveThemeMode(bool isDarkMode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDarkMode);
  }

  Future<void> _loadThemeMode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isDarkMode = prefs.getBool('isDarkMode') ?? false;
    setState(() {
      _isDarkMode = isDarkMode;
      darkModeNotifier.value = isDarkMode;
      _tabController.index = isDarkMode ? 1 : 0;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color backgroundColorSelected =
        _isDarkMode ? backgroundColorDark : backgroundColorLight;
    Color textColorSelected = _isDarkMode ? textColorDark : textColorLight;
    Color tapColorSelected = _isDarkMode ? tapColorDark : tapColorLight;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: backgroundColorSelected,
        leading: IconButton(
          icon: Icon(Icons.keyboard_arrow_left, color: textColorSelected),
          onPressed: () {
            Navigator.of(context).pop(_isDarkMode);
          },
        ),
        title: Text(
          'ธีมดํา',
          style: TextStyle(color: textColorSelected),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Container(
              color: backgroundColorSelected,
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildTab('ปิด', 0),
                  buildTab('เปิด', 1),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTab(String text, int index) {
    bool isSelected = _tabController.index == index;
    Color textColor = isSelected
        ? (_isDarkMode ? textColorDark : textColorLight)
        : (_isDarkMode ? tapColorLight : tapColorDark);
    Color tapColor = isSelected
        ? (_isDarkMode ? tapColorDark : tapColorLight)
        : (_isDarkMode ? tapColorDark : tapColorLight);

    return GestureDetector(
      onTap: () {
        _updateCounts(index);
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 0, horizontal: 0),
        width: double.infinity,
        child: Stack(
          children: [
            Container(
              padding: EdgeInsets.symmetric(vertical: 6, horizontal: 18),
              decoration: BoxDecoration(
                color: tapColor,
                borderRadius: BorderRadius.circular(0),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    text,
                    style: TextStyle(
                      color: textColor,
                    ),
                  ),
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected ? Colors.blue : Colors.transparent,
                      border: Border.all(
                        color: isSelected
                            ? Colors.transparent
                            : const Color.fromARGB(255, 99, 99, 99),
                        width: 2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
