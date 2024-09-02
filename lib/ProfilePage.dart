import 'dart:math';
import 'constants.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:iteachers_application/father_info_section.dart';
import 'package:iteachers_application/guardian_info_section.dart';
import 'package:iteachers_application/mother_info_section.dart';
import 'package:iteachers_application/student_info_section.dart';

class ProfilePage extends StatefulWidget {
  final String stdCode;
  final String act;

  const ProfilePage({Key? key, required this.stdCode, required this.act})
      : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    fetchProfileData(widget.stdCode);
    _loadDarkMode();
  }

  String stdParent = '';
  bool isLoading = true; // Add a loading state
  int _selectedIndex = 0;

  Future<void> fetchProfileData(String stdCode) async {
    try {
      var response = await http.post(
        apiUrl,
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          'act': 'profile',
          'stdCode': stdCode,
        }),
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body);

        if (data['status'] == 'success') {
          var student = data['student'];

          setState(() {
            stdParent = student['stdParent']?.toString() ?? '';
            isLoading = false; // Set loading to false
          });
        } else {
          setState(() {
            print('Failed to load profile data: ${data['message']}');
            isLoading = false; // Set loading to false
          });
        }
      } else {
        setState(() {
          print('HTTP Error ${response.statusCode}');
          isLoading = false; // Set loading to false
        });
      }
    } catch (e) {
      setState(() {
        print('Exception during profile data fetch: $e');
        isLoading = false; // Set loading to false
      });
    }
  }

  List<Widget> _sections() => [
        StudentInfoSection(
          stdCode: widget.stdCode,
          act: widget.act,
        ),
        MotherInfoSection(
          stdCode: widget.stdCode,
          act: widget.act,
        ),
        FatherInfoSection(
          stdCode: widget.stdCode,
          act: widget.act,
        ),
        GuardianInfoSection(
          stdCode: widget.stdCode,
          act: widget.act,
          stdParent: stdParent,
        ),
      ];

  void _updateIndex(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  bool _isDarkMode = false;

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

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'ประวัติ',
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
      body: isLoading
          ? Center(child: CircularProgressIndicator()) // Show loading indicator
          : Column(
              children: [
                Container(
                  padding: EdgeInsets.all(16),
                  color: backgroundColorSelected,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        buildTab(
                          'ข้อมูลนักศึกษา',
                          0,
                          backgroundColorSelected, // Selected background color
                          textColorSelected, // Selected text color
                        ),
                        buildTab(
                          'ข้อมูลมารดา',
                          1,
                          backgroundColorSelected, // Selected background color
                          textColorSelected, // Selected text color
                        ),
                        buildTab(
                          'ข้อมูลบิดา',
                          2,
                          backgroundColorSelected, // Selected background color
                          textColorSelected, // Selected text color
                        ),
                        buildTab(
                          'ข้อมูลผู้ปกครอง',
                          3,
                          backgroundColorSelected, // Selected background color
                          textColorSelected, // Selected text color
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: IndexedStack(
                    index: _selectedIndex,
                    children: _sections(),
                  ),
                ),
              ],
            ),
    );
  }

  Widget buildTab(String text, int index, Color backgroundColorSelected,
      Color textColorSelected) {
    bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        _updateIndex(index);
      },
      child: Container(
        margin: EdgeInsets.symmetric(
            vertical: 4, horizontal: 8), // Adjust margin to reduce size
        child: Container(
          padding: EdgeInsets.symmetric(
              vertical: 6, horizontal: 18), // Inner padding for text
          decoration: BoxDecoration(
            color: isSelected
                ? primaryColorLight
                : backgroundColorSelected, // Change background color
            borderRadius: BorderRadius.circular(5), // Reduce rounded corners
          ),
          child: Text(
            text,
            style: TextStyle(
              color: isSelected
                  ? backgroundColorLight
                  : textColorSelected, // Change text color
            ),
          ),
        ),
      ),
    );
  }
}
