import 'package:flutter/material.dart';
import 'theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TimePage extends StatefulWidget {
  @override
  _TimePageState createState() => _TimePageState();
}

class _TimePageState extends State<TimePage> {
  bool _isDarkMode = false;
  String? selectedSubject;

  // Example data for Science subject
  final List<Map<String, String>> scienceTimetable = [
    {'date': '01/07/2024', 'period': '1 คาบ', 'status': 'มา'},
    {'date': '02/07/2024', 'period': '2 คาบ', 'status': 'ขาด'},
    {'date': '03/07/2024', 'period': '1 คาบ', 'status': 'สาย'},
    {'date': '04/07/2024', 'period': '2 คาบ', 'status': 'มา'},
    {'date': '05/07/2024', 'period': '1 คาบ', 'status': 'มา'},
    {'date': '06/07/2024', 'period': '2 คาบ', 'status': 'ขาด'},
  ];

  // Example data for English subject
  final List<Map<String, String>> englishTimetable = [
    {'date': '01/07/2024', 'period': '1 คาบ', 'status': 'มา'},
    {'date': '02/07/2024', 'period': '1 คาบ', 'status': 'ขาด'},
    {'date': '03/07/2024', 'period': '1 คาบ', 'status': 'มา'},
    {'date': '04/07/2024', 'period': '1 คาบ', 'status': 'มา'},
    {'date': '05/07/2024', 'period': '1 คาบ', 'status': 'ขาด'},
    {'date': '06/07/2024', 'period': '1 คาบ', 'status': 'มา'},
  ];

  @override
  void initState() {
    super.initState();
    _loadDarkMode();
    // Set default selected subject to the first item
    selectedSubject = 'วิทยาศาสตร์ทั่วไป';
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

    return Scaffold(
      appBar: AppBar(
        backgroundColor: backgroundColorSelected,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColorSelected),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          'เวลาเรียนระหว่างภาค',
          style: TextStyle(color: textColorSelected),
        ),
      ),
      body: Container(
        color: backgroundColorSelected,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Text(
                    'เลือกวิชา:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textColorSelected,
                    ),
                  ),
                  SizedBox(width: 16), // Space between text and dropdown
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: selectedSubject,
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedSubject = newValue!;
                        });
                      },
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: backgroundColorSelected,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      dropdownColor: backgroundColorSelected,
                      items: <String>['วิทยาศาสตร์ทั่วไป', 'ภาษาอังกฤษ']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value,
                              style: TextStyle(color: textColorSelected)),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: selectedSubject == null
                  ? Center(
                      child: Text('กรุณาเลือกวิชา',
                          style: TextStyle(color: textColorSelected)))
                  : _buildTimetable(selectedSubject!, backgroundColorSelected,
                      textColorSelected),
            ),
            Container(
              height: 2,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimetable(String subjectName, Color backgroundColorSelected,
      Color textColorSelected) {
    List<Map<String, String>> timetable;

    if (subjectName == 'วิทยาศาสตร์ทั่วไป') {
      timetable = scienceTimetable;
    } else if (subjectName == 'ภาษาอังกฤษ') {
      timetable = englishTimetable;
    } else {
      timetable = [];
    }

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columnSpacing: 20,
          headingRowColor: MaterialStateProperty.all(backgroundColorSelected),
          dataRowColor: MaterialStateProperty.all(backgroundColorSelected),
          columns: [
            DataColumn(
              label: Text('วันที่', style: TextStyle(color: textColorSelected)),
            ),
            DataColumn(
              label: Text('คาบ', style: TextStyle(color: textColorSelected)),
            ),
            DataColumn(
              label: Text('สถานะ', style: TextStyle(color: textColorSelected)),
            ),
          ],
          rows: timetable.map((entry) {
            return DataRow(cells: [
              DataCell(Text(entry['date']!,
                  style: TextStyle(color: textColorSelected))),
              DataCell(Text(entry['period']!,
                  style: TextStyle(color: textColorSelected))),
              DataCell(Text(entry['status']!,
                  style: TextStyle(color: textColorSelected))),
            ]);
          }).toList(),
        ),
      ),
    );
  }
}
