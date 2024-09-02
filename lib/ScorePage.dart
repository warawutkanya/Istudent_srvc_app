import 'package:flutter/material.dart';
import 'theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ScorePage extends StatefulWidget {
  const ScorePage({super.key});

  @override
  State<ScorePage> createState() => _ScorePageState();
}

class _ScorePageState extends State<ScorePage> {
  bool _isDarkMode = false;
  // Example data
  final List<Map<String, String>> scores = [
    {
      'semester': '1',
      'year': '2566',
      'code': '30000-1101',
      'name': 'ทักษะภาษาไทยเชิงวิชาชีพ',
      'teacher': 'ครู ก',
      'score1': '10',
      'score2': '10',
      'score3': '20',
      'total': '40',
      'grade': 'A'
    },
    {
      'semester': '1',
      'year': '2566',
      'code': '30000-1102',
      'name': 'คณิตศาสตร์เบื้องต้น',
      'teacher': 'ครู ข',
      'score1': '8',
      'score2': '9',
      'score3': '15',
      'total': '32',
      'grade': 'B+'
    },
    {
      'semester': '1',
      'year': '2566',
      'code': '30000-1103',
      'name': 'วิทยาศาสตร์ทั่วไป',
      'teacher': 'ครู ค',
      'score1': '9',
      'score2': '9',
      'score3': '17',
      'total': '35',
      'grade': 'B'
    },
    {
      'semester': '1',
      'year': '2566',
      'code': '30000-1104',
      'name': 'ภาษาอังกฤษเบื้องต้น',
      'teacher': 'ครู ง',
      'score1': '10',
      'score2': '8',
      'score3': '18',
      'total': '36',
      'grade': 'A'
    },
    {
      'semester': '2',
      'year': '2566',
      'code': '30000-1105',
      'name': 'ประวัติศาสตร์ไทย',
      'teacher': 'ครู จ',
      'score1': '7',
      'score2': '8',
      'score3': '16',
      'total': '31',
      'grade': 'B'
    },
    {
      'semester': '2',
      'year': '2566',
      'code': '30000-1106',
      'name': 'ฟิสิกส์เบื้องต้น',
      'teacher': 'ครู ฉ',
      'score1': '6',
      'score2': '7',
      'score3': '14',
      'total': '27',
      'grade': 'C+'
    },
    {
      'semester': '2',
      'year': '2566',
      'code': '30000-1107',
      'name': 'เคมีเบื้องต้น',
      'teacher': 'ครู ช',
      'score1': '8',
      'score2': '8',
      'score3': '17',
      'total': '33',
      'grade': 'B+'
    },
    {
      'semester': '2',
      'year': '2566',
      'code': '30000-1108',
      'name': 'ชีววิทยาเบื้องต้น',
      'teacher': 'ครู ซ',
      'score1': '10',
      'score2': '10',
      'score3': '19',
      'total': '39',
      'grade': 'A'
    },
    {
      'semester': '2',
      'year': '2566',
      'code': '30000-1109',
      'name': 'ภูมิศาสตร์เบื้องต้น',
      'teacher': 'ครู ฌ',
      'score1': '9',
      'score2': '9',
      'score3': '18',
      'total': '36',
      'grade': 'A'
    },
    {
      'semester': '1',
      'year': '2567',
      'code': '30000-1110',
      'name': 'ศิลปะเบื้องต้น',
      'teacher': 'ครู ญ',
      'score1': '10',
      'score2': '9',
      'score3': '20',
      'total': '39',
      'grade': 'A'
    },
  ];
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
          'คะแนนเรียนระหว่างภาค',
          style: TextStyle(color: textColorSelected),
        ),
      ),
      body: Container(
        color: backgroundColorSelected,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight:
                  MediaQuery.of(context).size.height, // Ensure minimum height
            ),
            child: DataTable(
              headingRowColor:
                  MaterialStateProperty.all(backgroundColorSelected),
              dataRowColor: MaterialStateProperty.all(backgroundColorSelected),
              columnSpacing: 20,
              columns: [
                DataColumn(
                  label: Text('ภาคการศึกษา',
                      style: TextStyle(color: textColorSelected)),
                ),
                DataColumn(
                  label: Text('ปีการศึกษา',
                      style: TextStyle(color: textColorSelected)),
                ),
                DataColumn(
                  label: Text('รหัสวิชา',
                      style: TextStyle(color: textColorSelected)),
                ),
                DataColumn(
                  label: Text('ชื่อวิชา',
                      style: TextStyle(color: textColorSelected)),
                ),
                DataColumn(
                  label: Text('ผู้สอน',
                      style: TextStyle(color: textColorSelected)),
                ),
                DataColumn(
                  label: Text('คะแนนเก็บ',
                      style: TextStyle(color: textColorSelected)),
                ),
                DataColumn(
                  label: Text('คะแนนจิตพิสัย',
                      style: TextStyle(color: textColorSelected)),
                ),
                DataColumn(
                  label: Text('คะแนนปลายภาค',
                      style: TextStyle(color: textColorSelected)),
                ),
                DataColumn(
                  label: Text('คะแนนรวม',
                      style: TextStyle(color: textColorSelected)),
                ),
                DataColumn(
                  label: Text('ผลการเรียน',
                      style: TextStyle(color: textColorSelected)),
                ),
              ],
              rows: scores.map((score) {
                return DataRow(cells: [
                  DataCell(Text(score['semester']!,
                      style: TextStyle(color: textColorSelected))),
                  DataCell(Text(score['year']!,
                      style: TextStyle(color: textColorSelected))),
                  DataCell(Text(score['code']!,
                      style: TextStyle(color: textColorSelected))),
                  DataCell(Text(score['name']!,
                      style: TextStyle(color: textColorSelected))),
                  DataCell(Text(score['teacher']!,
                      style: TextStyle(color: textColorSelected))),
                  DataCell(Text(score['score1']!,
                      style: TextStyle(color: textColorSelected))),
                  DataCell(Text(score['score2']!,
                      style: TextStyle(color: textColorSelected))),
                  DataCell(Text(score['score3']!,
                      style: TextStyle(color: textColorSelected))),
                  DataCell(Text(score['total']!,
                      style: TextStyle(color: textColorSelected))),
                  DataCell(Text(score['grade']!,
                      style: TextStyle(color: textColorSelected))),
                ]);
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}
