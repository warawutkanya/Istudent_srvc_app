import 'package:flutter/material.dart';
import 'package:iteachers_application/JoinedPage.dart';
import 'package:iteachers_application/NotJoinedPage.dart';
import 'package:iteachers_application/TotalPage.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import shared_preferences
import 'theme.dart'; // Ensure theme.dart is correctly imported

class AllLineupPage extends StatefulWidget {
  final int total;
  final int joined;
  final int notJoined;
  final int initialIndex;
  final String stdCode;

  AllLineupPage({
    required this.total,
    required this.joined,
    required this.notJoined,
    this.initialIndex = 0,
    required this.stdCode,
  });

  @override
  _AllLineupPageState createState() => _AllLineupPageState();
}

class _AllLineupPageState extends State<AllLineupPage>
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
          'กิจกรรมเข้าเเถว',
          style: TextStyle(color: textColorSelected),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: '${widget.total} เข้าเเถวเเล้ว'),
            Tab(text: '${widget.joined} เข้าร่วม'),
            Tab(text: '${widget.notJoined} ไม่เข้าร่วม'),
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
            TotalPage(
              title: '',
              count: widget.total,
              stdCode: widget.stdCode,
            ),
            JoinedPage(
              title: '',
              count: widget.total,
              stdCode: widget.stdCode,
            ),
            NotJoinedPage(
              title: '',
              count: widget.total,
              stdCode: widget.stdCode,
            ),
          ],
        ),
      ),
    );
  }
}
