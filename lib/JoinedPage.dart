import 'dart:math';

import 'package:flutter/material.dart';
import 'package:iteachers_application/constants.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import shared_preferences
import 'package:http/http.dart' as http; // Import http package
import 'dart:convert'; // Import dart:convert for JSON decoding
import 'theme.dart'; // Ensure theme.dart is correctly imported

class JoinedPage extends StatefulWidget {
  final String title;
  final int count;
  final String stdCode;

  JoinedPage({
    required this.title,
    required this.count,
    required this.stdCode,
  });

  @override
  _JoinedPageState createState() => _JoinedPageState();
}

class _JoinedPageState extends State<JoinedPage> {
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

  void fetchActivityData(String stdcode) async {
    try {
      final response = await http.post(
        apiUrlactivitydetail, // Replace with your API URL
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          'act': 'JoinedPage',
          'stdCode': stdcode, // Replace with actual student code if needed
          'semes': '1', // Ensure semes is included
          'years': '2566' // Ensure years is included
        }),
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body);

        if (data['status'] == 'success') {
          setState(() {
            _activityData =
                List<Map<String, dynamic>>.from(data['activities'] ?? []);
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
                  child: DataTable(
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
    return DataRow(
      cells: <DataCell>[
        DataCell(Text(date, style: TextStyle(color: rowTextColor))),
        DataCell(Text('$T $time',
            style: TextStyle(
                color: rowTextColor))), // Combine studentStatus and time
        DataCell(Text('มา',
            style: TextStyle(
                color: rowTextColor))), // Always display 'มา' in teacher column
        DataCell(Text(T == 'ขาด' ? 'ขาด' : 'มา',
            style: TextStyle(color: rowTextColor))),
      ],
    );
  }
}
