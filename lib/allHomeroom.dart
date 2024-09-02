import 'package:flutter/material.dart';
import 'package:iteachers_application/JoinedPage.dart';
import 'package:iteachers_application/NotJoinedPage.dart';
import 'package:iteachers_application/TotalPage.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import shared_preferences
import 'theme.dart'; // Ensure theme.dart is correctly imported

class AllHomeroomPage extends StatefulWidget {
  final int total;
  final int initialIndex;

  AllHomeroomPage({required this.total, this.initialIndex = 0});

  @override
  _AllHomeroomPageState createState() => _AllHomeroomPageState();
}

class _AllHomeroomPageState extends State<AllHomeroomPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: widget.initialIndex,
    );
    _loadDarkMode();
  }

  void _loadDarkMode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    Color backgroundColorSelected =
        _isDarkMode ? backgroundColorDark : backgroundColorLight;
    Color textColorSelected = _isDarkMode ? textColorDark : textColorLight;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: backgroundColorSelected,
        leading: IconButton(
          icon: Icon(Icons.keyboard_arrow_left, color: textColorSelected),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          'กิจกรรมHomeroom',
          style: TextStyle(color: textColorSelected),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'กิจกรรมทั้งหมด'),
            Tab(text: 'เข้าร่วมกิจกรรม'),
            Tab(text: 'ไม่เข้าร่วม'),
          ],
          indicatorColor: textColorSelected, // Set tab indicator color
          labelColor: textColorSelected,
        ),
      ),
      body: Container(
        color: backgroundColorSelected, // Apply background color here
        child: TabBarView(
          controller: _tabController,
          children: [
            // TotalPage(title: 'กิจกรรมทั้งหมด', count: widget.total),
            // JoinedPage(title: 'Joined', count: widget.total),
            // NotJoinedPage(title: 'Not Joined', count: widget.total),
          ],
        ),
      ),
    );
  }
}
