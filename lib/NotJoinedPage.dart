import 'dart:math';

import 'package:flutter/material.dart';
import 'package:iteachers_application/constants.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import shared_preferences
import 'package:http/http.dart' as http; // Import http package
import 'dart:convert'; // Import dart:convert for JSON decoding
import 'theme.dart'; // Ensure theme.dart is correctly imported

class NotJoinedPage extends StatefulWidget {
  final String title;
  final int count;
  final String stdCode;

  NotJoinedPage({
    required this.title,
    required this.count,
    required this.stdCode,
  });

  @override
  _NotJoinedPageState createState() => _NotJoinedPageState();
}

class _NotJoinedPageState extends State<NotJoinedPage> {
  bool _isDarkMode = false;
  List<Map<String, dynamic>> _activityData = []; // Holds the activity data

  @override
  void initState() {
    super.initState();
    _loadDarkMode();
    fetchActivityData(
        widget.stdCode); // Fetch data when the page is initialized
  }

  void _loadDarkMode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    });
  }

  void fetchActivityData(String stdCode) async {
    try {
      final response = await http.post(
        apiUrlactivitydetail, // Replace with your API URL
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          'act': 'NotJoinedPage',
          'stdCode': stdCode, // Replace with actual student code if needed
          'semes': '1', // Ensure semes is included
          'years': '2566' // Ensure years is included
        }),
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body);

        if (data['status'] == 'success') {
          setState(() {
            _activityData = List<Map<String, dynamic>>.from(
                data['notJoinedActivities'] ?? []);
          });
        } else {
          print('Error: ${data['message']}');
        }
      } else {
        print('Failed to load data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    Color backgroundColorSelected =
        _isDarkMode ? backgroundColorDark : backgroundColorLight;
    Color textColorSelected = _isDarkMode ? textColorDark : textColorLight;
    Color rowTextColor = _isDarkMode ? Colors.white : Colors.black;

    return Scaffold(
      body: Container(
        color: backgroundColorSelected, // Apply background color here
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: MediaQuery.of(context).size.width,
                  ),
                  child: _activityData.isNotEmpty
                      ? DataTable(
                          columnSpacing: 25,
                          columns: <DataColumn>[
                            DataColumn(
                              label: Expanded(
                                child: Text(
                                  'วันที่เข้าแถว',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: textColorSelected),
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'นักศึกษา',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: textColorSelected),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'ครู',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: textColorSelected),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'สถานะ',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: textColorSelected),
                              ),
                            ),
                          ],
                          rows: _activityData.map((activity) {
                            return _buildDataRow(
                              activity['chkDate'] ?? '',
                              activity['chkTime'] ?? '',
                              activity['T'] ?? '',
                              rowTextColor,
                            );
                          }).toList(),
                        )
                      : Center(
                          child: CircularProgressIndicator(),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  DataRow _buildDataRow(
    String date,
    String time,
    String T,
    Color rowTextColor,
  ) {
    // Check if chkTime is empty, and if so, set the text color to red
    Color cellTextColor = time.isEmpty ? Colors.red : rowTextColor;

    return DataRow(
      cells: <DataCell>[
        DataCell(Text(date, style: TextStyle(color: cellTextColor))),
        DataCell(Text('$T $time', style: TextStyle(color: cellTextColor))),
        DataCell(Text('มา', style: TextStyle(color: cellTextColor))),
        DataCell(Text(T == 'ขาด' ? 'ขาด' : 'มา',
            style: TextStyle(color: cellTextColor))),
      ],
    );
  }
}
