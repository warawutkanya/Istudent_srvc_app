import 'package:flutter/material.dart';
import 'theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ResultPage extends StatefulWidget {
  @override
  _ResultPageState createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  bool _isDarkMode = false;
  final List<Map<String, String>> grades = [
    {
      'semester': '1/2566',
      'code': '30000-1101',
      'name': 'ทักษะภาษาไทย\nเชิงวิชาชีพ',
      'credits': '3',
      'grade': '4.00'
    },
    {
      'semester': '1/2566',
      'code': '30000-1102',
      'name': 'คณิตศาสตร์\nเบื้องต้น',
      'credits': '3',
      'grade': '3.50'
    },
    {
      'semester': '1/2566',
      'code': '30000-1103',
      'name': 'วิทยาศาสตร์\nทั่วไป',
      'credits': '3',
      'grade': '3.00'
    },
    {
      'semester': '1/2566',
      'code': '30000-1104',
      'name': 'ภาษาอังกฤษ\nเบื้องต้น',
      'credits': '3',
      'grade': '3.75'
    },
    {
      'semester': '2/2566',
      'code': '30000-1105',
      'name': 'ประวัติศาสตร์ไทย',
      'credits': '3',
      'grade': '3.25'
    },
    {
      'semester': '2/2566',
      'code': '30000-1106',
      'name': 'ฟิสิกส์เบื้องต้น',
      'credits': '3',
      'grade': '2.75'
    },
    {
      'semester': '2/2566',
      'code': '30000-1107',
      'name': 'เคมีเบื้องต้น',
      'credits': '3',
      'grade': '3.00'
    },
    {
      'semester': '2/2566',
      'code': '30000-1108',
      'name': 'ชีววิทยาเบื้องต้น',
      'credits': '3',
      'grade': '4.00'
    },
    {
      'semester': '2/2566',
      'code': '30000-1109',
      'name': 'ภูมิศาสตร์เบื้องต้น',
      'credits': '3',
      'grade': '3.75'
    },
    {
      'semester': '1/2567',
      'code': '30000-1110',
      'name': 'ศิลปะเบื้องต้น',
      'credits': '2',
      'grade': '4.00'
    },
  ];
  String selectedSemester = '1/2566';

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

  double calculateGPA(List<Map<String, String>> grades) {
    double totalCredits = 0.0;
    double totalPoints = 0.0;

    for (var grade in grades) {
      double credits = double.parse(grade['credits']!);
      double points = double.parse(grade['grade']!);
      totalCredits += credits;
      totalPoints += (points * credits);
    }
    return totalPoints / totalCredits;
  }

  @override
  Widget build(BuildContext context) {
    Color backgroundColorSelected =
        _isDarkMode ? backgroundColorDark : backgroundColorLight;
    Color textColorSelected = _isDarkMode ? textColorDark : textColorLight;
    List<Map<String, String>> filteredGrades =
        grades.where((grade) => grade['semester'] == selectedSemester).toList();
    double semesterGPA = calculateGPA(filteredGrades);
    double cumulativeGPA = calculateGPA(grades);

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
          'ผลการเรียน',
          style: TextStyle(color: textColorSelected),
        ),
      ),
      body: Container(
        color: backgroundColorSelected, // Set the background color here
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Text(
                    'เลือกภาคการศึกษา: ',
                    style: TextStyle(fontSize: 16, color: textColorSelected),
                  ),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: selectedSemester,
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedSemester = newValue!;
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
                      items: grades
                          .map((grade) => grade['semester'])
                          .toSet()
                          .map<DropdownMenuItem<String>>((String? value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value!,
                              style: TextStyle(color: textColorSelected)),
                        );
                      }).toList(),
                    ),
                  )
                ],
              ),
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minWidth: constraints.maxWidth,
                        ),
                        child: DataTable(
                          columnSpacing: 0,
                          columns: [
                            DataColumn(
                                label: Text('รหัสวิชา',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: textColorSelected))),
                            DataColumn(
                                label: Text('ชื่อวิชา',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: textColorSelected))),
                            DataColumn(
                                label: Text('หน่วยกิต',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: textColorSelected))),
                            DataColumn(
                                label: Text('ผลการเรียน',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: textColorSelected))),
                          ],
                          rows: [
                            ...filteredGrades.map((grade) {
                              return DataRow(cells: [
                                DataCell(Text(grade['code']!,
                                    style:
                                        TextStyle(color: textColorSelected))),
                                DataCell(Text(grade['name']!,
                                    style:
                                        TextStyle(color: textColorSelected))),
                                DataCell(Text(grade['credits']!,
                                    style:
                                        TextStyle(color: textColorSelected))),
                                DataCell(Text(grade['grade']!,
                                    style:
                                        TextStyle(color: textColorSelected))),
                              ]);
                            }).toList(),
                            DataRow(cells: [
                              DataCell(Text(
                                'เกรดเฉลี่ย',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: textColorSelected),
                              )),
                              DataCell(Text('')),
                              DataCell(Text('')),
                              DataCell(Text(semesterGPA.toStringAsFixed(2),
                                  style: TextStyle(color: textColorSelected))),
                            ]),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        color: backgroundColorSelected,
        padding: const EdgeInsets.all(16.0),
        child: Text(
          'เกรดเฉลี่ยรวม: ${cumulativeGPA.toStringAsFixed(2)}',
          style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: textColorSelected),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
