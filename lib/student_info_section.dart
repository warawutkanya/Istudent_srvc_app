import 'dart:math';
import 'package:flutter/material.dart';
import 'constants.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StudentInfoSection extends StatefulWidget {
  final String stdCode;
  final String act;

  const StudentInfoSection({Key? key, required this.stdCode, required this.act})
      : super(key: key);

  @override
  _StudentInfoSectionState createState() => _StudentInfoSectionState();
}

class _StudentInfoSectionState extends State<StudentInfoSection> {
  String? selectedProvinceID;

  Widget _buildPrefixDropdown(Color textColor, Color backgroundColor) {
    return Card(
      color: backgroundColor,
      elevation: 4,
      margin: EdgeInsets.all(10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'คำนำหน้าชื่อ:',
              style: TextStyle(
                  color: textColor, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: textColor),
              ),
              child: DropdownButton<String>(
                value: stdPrefix,
                icon: Icon(Icons.arrow_drop_down, color: textColor),
                iconSize: 24,
                elevation: 16,
                style: TextStyle(color: textColor),
                dropdownColor: backgroundColor,
                isExpanded: true,
                underline: Container(),
                onChanged: (String? newValue) {
                  setState(() {
                    stdPrefix = newValue!;
                  });
                },
                items: <String>['นางสาว', 'นาย', 'เด็กหญิง', 'เด็กชาย', 'นาง']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value, style: TextStyle(color: textColor)),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEngPrefixDropdown(Color textColor, Color backgroundColor) {
    return Card(
      color: backgroundColor,
      elevation: 4,
      margin: EdgeInsets.all(10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Prefix',
              style: TextStyle(
                  color: textColor, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: textColor),
              ),
              child: DropdownButton<String>(
                value: stdEngPrefix,
                icon: Icon(Icons.arrow_drop_down, color: textColor),
                iconSize: 24,
                elevation: 16,
                style: TextStyle(color: textColor),
                dropdownColor: backgroundColor,
                isExpanded: true,
                underline: Container(),
                onChanged: (String? newValue) {
                  setState(() {
                    stdEngPrefix = newValue!;
                  });
                },
                items: <String>['Ms.', 'Mr.', 'Mrs.']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value, style: TextStyle(color: textColor)),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProvinceDropdown(Color textColor, Color backgroundColor) {
    return Card(
      color: backgroundColor,
      elevation: 4,
      margin: EdgeInsets.all(10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'จังหวัด',
              style: TextStyle(
                color: textColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: textColor),
              ),
              child: DropdownButton<String>(
                hint: Text('เลือกจังหวัด', style: TextStyle(color: textColor)),
                value: stdProvinceId.isNotEmpty
                    ? provinces.firstWhere(
                        (province) => province['provinceID'] == stdProvinceId,
                        orElse: () =>
                            {'provinceThaiName': ''})['provinceThaiName']
                    : null,
                icon: Icon(Icons.arrow_drop_down, color: textColor),
                iconSize: 24,
                elevation: 16,
                style: TextStyle(color: textColor),
                dropdownColor: backgroundColor,
                isExpanded: true,
                underline: Container(),
                onChanged: (String? newValue) {
                  setState(() {
                    stdProvinceId = provinces.firstWhere(
                          (province) =>
                              province['provinceThaiName'] == newValue,
                          orElse: () => {'provinceID': ''},
                        )['provinceID'] ??
                        '';

                    stdProvince = newValue ?? '';
                    print("Selected stdProvinceId: $stdProvinceId");
                    print("Selected stdProvince: $stdProvince");

                    // Reset district and sub-district
                    stdDistrict = '';
                    stdSubDistrict = '';

                    // Fetch districts based on the new province
                    fetchDistricts(stdProvinceId);
                  });
                },
                items: [
                  DropdownMenuItem<String>(
                    value: '',
                    child: Text('เลือกจังหวัด',
                        style: TextStyle(color: textColor)),
                  ),
                  ...provinces.map<DropdownMenuItem<String>>((province) {
                    return DropdownMenuItem<String>(
                      value: province['provinceThaiName'],
                      child: Text(province['provinceThaiName']!,
                          style: TextStyle(color: textColor)),
                    );
                  }).toList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDistrictDropdown(Color textColor, Color backgroundColor) {
    return Card(
      color: backgroundColor,
      elevation: 4,
      margin: EdgeInsets.all(10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'อำเภอ',
              style: TextStyle(
                  color: textColor, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: textColor),
              ),
              child: DropdownButton<String>(
                hint: Text('เลือกอำเภอ', style: TextStyle(color: textColor)),
                value: stdDistrict.isNotEmpty
                    ? districts.firstWhere(
                        (district) => district['districtID'] == stdDistrict,
                        orElse: () =>
                            {'districtThaiName': ''})['districtThaiName']
                    : null,
                icon: Icon(Icons.arrow_drop_down, color: textColor),
                iconSize: 24,
                elevation: 16,
                style: TextStyle(color: textColor),
                dropdownColor: backgroundColor,
                isExpanded: true,
                underline: Container(),
                onChanged: (String? newValue) {
                  setState(() {
                    stdDistrict = districts.firstWhere(
                          (district) =>
                              district['districtThaiName'] == newValue,
                          orElse: () => {'districtID': ''},
                        )['districtID'] ??
                        '';

                    stdDistrictName = newValue ?? '';
                    print("Selected stdDistrictId: $stdDistrict");
                    print("Selected stdDistrictName: $stdDistrictName");

                    // Reset sub-district
                    stdSubDistrict = '';

                    // Fetch sub-districts based on the new district
                    fetchSubDistricts(stdDistrict);
                  });
                },
                items: [
                  DropdownMenuItem<String>(
                    value: '',
                    child:
                        Text('เลือกอำเภอ', style: TextStyle(color: textColor)),
                  ),
                  ...districts.map<DropdownMenuItem<String>>((district) {
                    return DropdownMenuItem<String>(
                      value: district['districtThaiName'],
                      child: Text(district['districtThaiName']!,
                          style: TextStyle(color: textColor)),
                    );
                  }).toList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubDistrictDropdown(Color textColor, Color backgroundColor) {
    return Card(
      color: backgroundColor,
      elevation: 4,
      margin: EdgeInsets.all(10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ตำบล',
              style: TextStyle(
                  color: textColor, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: textColor),
              ),
              child: DropdownButton<String>(
                hint: Text('เลือกตำบล', style: TextStyle(color: textColor)),
                value: stdSubDistrict.isNotEmpty
                    ? subDistricts.firstWhere(
                        (subDistrict) =>
                            subDistrict['subDistrictID'] == stdSubDistrict,
                        orElse: () =>
                            {'subDistrictThaiName': ''})['subDistrictThaiName']
                    : null,
                icon: Icon(Icons.arrow_drop_down, color: textColor),
                iconSize: 24,
                elevation: 16,
                style: TextStyle(color: textColor),
                dropdownColor: backgroundColor,
                isExpanded: true,
                underline: Container(),
                onChanged: (String? newValue) {
                  setState(() {
                    stdSubDistrict = subDistricts.firstWhere(
                          (subDistrict) =>
                              subDistrict['subDistrictThaiName'] == newValue,
                          orElse: () => {'subDistrictID': ''},
                        )['subDistrictID'] ??
                        '';

                    stdZipCode = subDistricts.firstWhere(
                          (subDistrict) =>
                              subDistrict['subDistrictThaiName'] == newValue,
                          orElse: () => {'zip_code': ''},
                        )['zip_code'] ??
                        '';

                    print("Selected stdSubDistrictId: $stdSubDistrict");
                    print("Selected Zip Code: $stdZipCode");
                  });
                },
                items: [
                  DropdownMenuItem<String>(
                    value: '',
                    child:
                        Text('เลือกตำบล', style: TextStyle(color: textColor)),
                  ),
                  ...subDistricts.map<DropdownMenuItem<String>>((subDistrict) {
                    return DropdownMenuItem<String>(
                      value: subDistrict['subDistrictThaiName'],
                      child: Text(subDistrict['subDistrictThaiName']!,
                          style: TextStyle(color: textColor)),
                    );
                  }).toList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMaritalStatusRadioButtons(
      Color textColor, Color backgroundColor) {
    return Card(
      color: backgroundColor,
      elevation: 4,
      margin: EdgeInsets.all(10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'สถานภาพสมรส:',
              style: TextStyle(
                  color: textColor, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            ListTile(
              title: Text(
                'อยู่ด้วยกัน ',
                style: TextStyle(color: textColor),
              ),
              leading: Radio<String>(
                value: '1',
                groupValue: maritalFamily,
                onChanged: (String? value) {
                  setState(() {
                    maritalFamily = value!;
                  });
                },
              ),
            ),
            ListTile(
              title: Text(
                'แยกกันอยู่',
                style: TextStyle(color: textColor),
              ),
              leading: Radio<String>(
                value: '2',
                groupValue: maritalFamily,
                onChanged: (String? value) {
                  setState(() {
                    maritalFamily = value!;
                  });
                },
              ),
            ),
            ListTile(
              title: Text(
                'หย่าร้าง',
                style: TextStyle(color: textColor),
              ),
              leading: Radio<String>(
                value: '3',
                groupValue: maritalFamily,
                onChanged: (String? value) {
                  setState(() {
                    maritalFamily = value!;
                  });
                },
              ),
            ),
            ListTile(
              title: Text(
                'เสียชีวิต',
                style: TextStyle(color: textColor),
              ),
              leading: Radio<String>(
                value: '4',
                groupValue: maritalFamily,
                onChanged: (String? value) {
                  setState(() {
                    maritalFamily = value!;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIncomeRadioButtons(Color textColor, Color backgroundColor) {
    return Card(
      color: backgroundColor,
      elevation: 4,
      margin: EdgeInsets.all(10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ฐานะครอบครัว',
              style: TextStyle(
                  color: textColor, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            ListTile(
              title: Text(
                'ฐานะยากจน ',
                style: TextStyle(color: textColor),
              ),
              leading: Radio<String>(
                value: '1',
                groupValue: maritalFamily,
                onChanged: (String? value) {
                  setState(() {
                    maritalFamily = value!;
                  });
                },
              ),
            ),
            ListTile(
              title: Text(
                'ฐานะปานกลาง',
                style: TextStyle(color: textColor),
              ),
              leading: Radio<String>(
                value: '2',
                groupValue: maritalFamily,
                onChanged: (String? value) {
                  setState(() {
                    maritalFamily = value!;
                  });
                },
              ),
            ),
            ListTile(
              title: Text(
                'ฐานะดี',
                style: TextStyle(color: textColor),
              ),
              leading: Radio<String>(
                value: '3',
                groupValue: maritalFamily,
                onChanged: (String? value) {
                  setState(() {
                    maritalFamily = value!;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String proxyUrl = 'https://cors.bridged.cc/';
  List<Map<String, String>> provinces = [];
  List<Map<String, String>> districts = [];
  List<Map<String, String>> subDistricts = [];
  bool isLoading = true;
  String stdProvinceId = '';
  String stdProvinceName = '';
  String errorMessage = '';
  bool _isDarkMode = false;
  String imageUrl = '';
  String stdPrefix = '';
  String stdFName = '';
  String stdLName = '';
  String stdPinID = '';
  String stdBDate = '';
  String stdNickName = '';
  String stdAddrNo = '';
  String stdAddrMoo = '';
  String stdAddrBaan = '';
  String stdAddrAlley = '';
  String stdAddrRoad = '';
  String stdSubDistrict = '';
  String stdDistrictName = '';
  String stdDistrict = '';
  String? stdProvince;
  String stdZipCode = '';
  String stdPhone = '';
  String stdLineID = '';
  String stdEmail = '';
  String stdEngPrefix = '';
  String stdEngFName = '';
  String stdEngLName = '';
  String maritalFamily = '';
  String incomeFamily = '';
  // String stdDistrictId = '';
  // String stdSubDistrictName = '';
  // String stdSubDistrictId = '';
  int stdWeight = 0;
  int stdHeight = 0;
  String congenitalDisease = '';
  String drug = '';

  @override
  void initState() {
    super.initState();
    fetchProfileData(widget.stdCode);
    fetchProvinces();
    _loadDarkMode();
  }

  void _loadDarkMode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isDarkMode = prefs.getBool('isDarkMode') ?? false;
    setState(() {
      _isDarkMode = isDarkMode;
    });
  }

  void fetchProfileData(String stdCode) async {
    try {
      setState(() {
        isLoading = true; // Ensure loading state is set
      });

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
            stdPrefix = student['stdPrefix']?.toString() ?? '';
            stdFName = student['stdFName']?.toString() ?? '';
            stdLName = student['stdLName']?.toString() ?? '';
            stdPinID = student['stdPinID']?.toString() ?? '';
            stdBDate = student['stdBDate']?.toString() ?? '';
            stdNickName = student['stdNickName']?.toString() ?? '';
            stdAddrNo = student['stdAddrNo']?.toString() ?? '';
            stdAddrMoo = student['stdAddrMoo']?.toString() ?? '';
            stdAddrBaan = student['stdAddrBaan']?.toString() ?? '';
            stdAddrAlley = student['stdAddrAlley']?.toString() ?? '';
            stdAddrRoad = student['stdAddrRoad']?.toString() ?? '';
            stdSubDistrict = student['stdSubDistrict']?.toString() ?? '';
            stdDistrict = student['stdDistrict']?.toString() ?? '';
            stdProvinceId = student['stdProvince']?.toString() ?? '';
            stdZipCode = student['stdZipCode']?.toString() ?? '';
            stdPhone = student['stdPhone']?.toString() ?? '';
            stdLineID = student['stdLineID']?.toString() ?? '';
            stdEmail = student['stdEmail']?.toString() ?? '';
            stdEngPrefix = student['stdEngPrefix']?.toString() ?? '';
            stdEngFName = student['stdEngFName']?.toString() ?? '';
            stdEngLName = student['stdEngLName']?.toString() ?? '';
            maritalFamily = student['maritalFamily']?.toString() ?? '';
            incomeFamily = student['incomeFamily']?.toString() ?? '';
            stdWeight = student['stdWeight'] is int
                ? student['stdWeight']
                : int.tryParse(student['stdWeight']?.toString() ?? '0') ?? 0;
            stdHeight = student['stdHeight'] is int
                ? student['stdHeight']
                : int.tryParse(student['stdHeight']?.toString() ?? '0') ?? 0;
            congenitalDisease = student['congenitalDisease']?.toString() ?? '';
            drug = student['drug']?.toString() ?? '';

            // Construct the image URL
            String firstTwoDigits = widget.stdCode.substring(0, 2);
            imageUrl =
                "${proxyUrl}https://iteachers.srvc.ac.th/images/student/$firstTwoDigits/${widget.stdCode}.jpg";
            isLoading = false;
          });

          // Fetch province ID and then districts and sub-districts
          if (stdProvinceId != null && stdProvinceId!.isNotEmpty) {
            fetchDistricts(stdProvinceId!);
            if (stdDistrict.isNotEmpty) {
              fetchSubDistricts(stdDistrict);
            }
          }
        } else {
          print("Error fetching profile data: ${data['message']}");
        }
      } else {
        print(
            "Failed to fetch profile data. Status code: ${response.statusCode}");
      }
    } catch (e) {
      print("Exception during profile data fetch: $e");
    }
  }

  Future<String> getDistrictID(String provinceID, String districtName) async {
    try {
      final response = await http.post(
        apiUrl,
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          'act': 'getDistricts',
          'provinceID': provinceID, // Use provided provinceID
        }),
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body);

        if (data['status'] == 'success') {
          var districts = data['districts'] as List<dynamic>;
          for (var district in districts) {
            if (district['districtThaiName'] == districtName) {
              return district['districtID'].toString();
            }
          }
        } else {
          print("Error fetching districts: ${data['message']}");
        }
      } else {
        print("Failed to fetch districts. Status code: ${response.statusCode}");
      }
    } catch (e) {
      print("Exception during districtID fetch: $e");
    }

    return '0'; // Return '0' if not found
  }

  Future<String> getProvinceID(String provinceName) async {
    final response = await http.post(
      apiUrl,
      headers: {"Content-Type": "application/json"},
      body: json.encode({'act': 'getProvinces'}),
    );

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      if (data['status'] == 'success') {
        var provinces = data['provinces'] as List<dynamic>;
        for (var province in provinces) {
          if (province['provinceThaiName'] == provinceName) {
            return province['provinceID'].toString();
          }
        }
      }
    }
    return '0';
  }

  void saveProfileData() async {
    try {
      final response = await http.post(
        apiUrl,
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          'act': 'update_profile_student',
          'stdCode': widget.stdCode,
          'stdPrefix': stdPrefix,
          'stdFName': stdFName,
          'stdLName': stdLName,
          'stdPinID': stdPinID,
          'stdEngPrefix': stdEngPrefix,
          'stdEngFName': stdEngFName,
          'stdEngLName': stdEngLName,
          'stdBDate': stdBDate,
          'stdNickName': stdNickName,
          'stdAddrNo': stdAddrNo,
          'stdAddrMoo': stdAddrMoo,
          'stdAddrBaan': stdAddrBaan,
          'stdAddrAlley': stdAddrAlley,
          'stdAddrRoad': stdAddrRoad,
          'stdSubDistrict': stdSubDistrict,
          'stdDistrict': stdDistrict,
          'stdProvince': stdProvinceId,
          'stdZipCode': stdZipCode,
          'stdPhone': stdPhone,
          'stdLineID': stdLineID,
          'stdEmail': stdEmail,
          'maritalFamily': maritalFamily,
          'incomeFamily': incomeFamily,
          'stdWeight': stdWeight,
          'stdHeight': stdHeight,
          'congenitalDisease': congenitalDisease,
          'drug': drug,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Response data: $data');

        if (data['status'] == 'success') {
          print('Profile data updated successfully');

          // Show success alert dialog
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('สำเร็จ'),
                content: Text('บันทึกข้อมูลสำเร็จ'),
                actions: [
                  TextButton(
                    child: Text('ตกลง'),
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the dialog
                    },
                  ),
                ],
              );
            },
          );
        } else {
          setState(() {
            errorMessage = 'Failed to update profile data: ${data['message']}';
          });
          print(errorMessage);
        }
      } else {
        setState(() {
          errorMessage = 'HTTP Error ${response.statusCode}';
        });
        print(errorMessage);
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Exception during profile data update: $e';
      });
      print(errorMessage);
    }
  }

  Future<void> updateStudentDetail(Map<String, dynamic> studentData) async {
    final response = await http.post(
      apiUrl,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'act': 'update_studentdetail', ...studentData}),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      final String status = responseData['status']
          .toString(); // Ensure status is treated as a string

      if (status == '1') {
        // Success
        print(responseData['message']);
      } else if (status == '0') {
        // No changes made
        print(responseData['message']);
      } else {
        // Error
        print('Error: ${responseData['message']}');
      }
    } else {
      print('Server error: ${response.statusCode}');
    }
  }

  Future<void> fetchProvinces() async {
    try {
      final response = await http.post(
        apiUrl,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({'act': 'getProvinces'}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data is Map<String, dynamic> && data['status'] == 'success') {
          var provincesData = data['provinces'] as List<dynamic>;
          List<Map<String, String>> fetchedProvinces =
              provincesData.map((province) {
            if (province is Map<String, dynamic>) {
              return {
                'provinceThaiName':
                    province['provinceThaiName']?.toString() ?? '',
                'provinceID': province['provinceID']?.toString() ?? '',
              };
            }
            return {'provinceThaiName': '', 'provinceID': ''};
          }).toList();

          setState(() {
            provinces = fetchedProvinces;
            isLoading = false;
          });

          // Call fetchDistricts for the first province if available
          if (fetchedProvinces.isNotEmpty) {
            selectedProvinceID = fetchedProvinces.first['provinceID'];
          }
        } else {
          setState(() {
            errorMessage = 'Failed to load provinces: ${data['message']}';
            isLoading = false;
          });
        }
      } else {
        setState(() {
          errorMessage = 'HTTP Error ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Exception during province fetch: $e';
        isLoading = false;
      });
    }
  }

  void fetchDistricts(String? provinceID) async {
    try {
      if (provinceID == null || provinceID.isEmpty) {
        print("Error: provinceID is null or empty");
        return;
      }

      final response = await http.post(
        apiUrl,
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          'act': 'getDistricts',
          'provinceID': provinceID,
        }),
      );

      if (response.statusCode == 200) {
        try {
          var responseBody = response.body;
          if (responseBody.trim().startsWith('{') &&
              responseBody.trim().endsWith('}')) {
            var data = json.decode(responseBody);

            if (data['status'] == 'success') {
              List<Map<String, String>> fetchedDistricts =
                  (data['districts'] as List<dynamic>).map((dynamic district) {
                Map<String, dynamic> districtMap =
                    district as Map<String, dynamic>;
                return {
                  'districtID': (districtMap['districtID'] as int).toString(),
                  'districtThaiName': districtMap['districtThaiName'] as String,
                  'districtEngName': districtMap['districtEngName'] as String,
                  'provinceID': (districtMap['provinceID'] as int).toString(),
                };
              }).toList();

              setState(() {
                districts = fetchedDistricts;
                isLoading = false;
              });
            } else {
              print("Error fetching districts: ${data['message']}");
            }
          } else {
            print("Malformed JSON response: $responseBody");
          }
        } catch (jsonError) {
          print("JSON Parsing Error: $jsonError");
        }
      } else {
        print("Failed to fetch districts. Status code: ${response.statusCode}");
      }
    } catch (e) {
      print("Exception during districts fetch: $e");
    }
  }

  Future<void> fetchSubDistricts(String? districtID) async {
    try {
      if (districtID == null || districtID.isEmpty) {
        print("Error: districtID is null or empty");
        return;
      }

      final response = await http.post(
        apiUrl,
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          'act': 'getSubDistricts',
          'districtID': districtID,
        }),
      );

      if (response.statusCode == 200) {
        try {
          var responseBody = response.body;
          if (responseBody.trim().startsWith('{') &&
              responseBody.trim().endsWith('}')) {
            var data = json.decode(responseBody);

            if (data['status'] == 'success') {
              List<Map<String, String>> fetchedSubDistricts =
                  (data['subdistricts'] as List<dynamic>)
                      .map((dynamic subDistrict) {
                Map<String, dynamic> subDistrictMap =
                    subDistrict as Map<String, dynamic>;
                return {
                  'subDistrictID':
                      (subDistrictMap['subDistrictID'] as int).toString(),
                  'subDistrictThaiName':
                      subDistrictMap['subDistrictThaiName'] as String,
                  'subDistrictEngName':
                      subDistrictMap['subDistrictEngName'] as String,
                  'districtID':
                      (subDistrictMap['districtID'] as int).toString(),
                  'latitude': subDistrictMap['latitude']?.toString() ?? '',
                  'longitude': subDistrictMap['longitude']?.toString() ?? '',
                  'zip_code': subDistrictMap['zip_code']?.toString() ?? '',
                };
              }).toList();

              setState(() {
                subDistricts = fetchedSubDistricts;
                isLoading = false;
              });
            } else {
              print("Error fetching sub-districts: ${data['message']}");
            }
          } else {
            print("Malformed JSON response: $responseBody");
          }
        } catch (jsonError) {
          print("JSON Parsing Error: $jsonError");
        }
      } else {
        print(
            "Failed to fetch sub-districts. Status code: ${response.statusCode}");
      }
    } catch (e) {
      print("Exception during sub-districts fetch: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    Color backgroundColorSelected =
        _isDarkMode ? backgroundColorDark : backgroundColorLight;
    Color textColorSelected = _isDarkMode ? textColorDark : textColorLight;

    return Scaffold(
        body: Container(
      color: backgroundColorSelected,
      child: Center(
        child: isLoading
            ? const CircularProgressIndicator()
            : errorMessage.isNotEmpty
                ? Text(
                    errorMessage,
                    style: const TextStyle(color: Colors.red),
                  )
                : SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Card(
                            color: backgroundColorSelected,
                            elevation: 4,
                            child: SizedBox(
                              width: 80,
                              height: 80,
                              child: imageUrl.isNotEmpty
                                  ? Image.network(
                                      imageUrl,
                                      fit: BoxFit.cover,
                                      loadingBuilder: (BuildContext context,
                                          Widget child,
                                          ImageChunkEvent? loadingProgress) {
                                        if (loadingProgress == null) {
                                          return child;
                                        } else {
                                          return Center(
                                            child: CircularProgressIndicator(
                                              value: loadingProgress
                                                          .expectedTotalBytes !=
                                                      null
                                                  ? loadingProgress
                                                          .cumulativeBytesLoaded /
                                                      loadingProgress
                                                          .expectedTotalBytes!
                                                  : null,
                                            ),
                                          );
                                        }
                                      },
                                      errorBuilder: (BuildContext context,
                                          Object error,
                                          StackTrace? stackTrace) {
                                        return Icon(Icons.error,
                                            color: Colors.red);
                                      },
                                    )
                                  : CircularProgressIndicator(),
                            ),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'ข้อมูลนักศึกษา',
                            style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: textColorSelected),
                          ),
                          SizedBox(height: 16),
                          buildProfileCard('รหัสนักศึกษา', widget.stdCode,
                              textColor: textColorSelected,
                              backgroundColor: backgroundColorSelected),
                          _buildPrefixDropdown(
                              textColorSelected, backgroundColorSelected),
                          buildEditableProfileCard('ชื่อ', stdFName,
                              onChanged: (value) => stdFName = value,
                              textColor: textColorSelected,
                              backgroundColor: backgroundColorSelected),
                          buildEditableProfileCard('นามสกุล', stdLName,
                              onChanged: (value) => stdLName = value,
                              textColor: textColorSelected,
                              backgroundColor: backgroundColorSelected),
                          buildEditableProfileCard('รหัสประจำตัว', stdPinID,
                              onChanged: (value) => stdPinID = value,
                              textColor: textColorSelected,
                              backgroundColor: backgroundColorSelected),
                          buildEditableProfileCard('วันเกิด', stdBDate,
                              onChanged: (value) => stdBDate = value,
                              textColor: textColorSelected,
                              backgroundColor: backgroundColorSelected),
                          buildEditableProfileCard('ชื่อเล่น', stdNickName,
                              onChanged: (value) => stdNickName = value,
                              textColor: textColorSelected,
                              backgroundColor: backgroundColorSelected),
                          buildEditableProfileCard('เบอร์โทรศัพท์', stdPhone,
                              onChanged: (value) => stdPhone = value,
                              textColor: textColorSelected,
                              backgroundColor: backgroundColorSelected),
                          buildEditableProfileCard('Line ID', stdLineID,
                              onChanged: (value) => stdLineID = value,
                              textColor: textColorSelected,
                              backgroundColor: backgroundColorSelected),
                          buildEditableProfileCard('อีเมล', stdEmail,
                              onChanged: (value) => stdEmail = value,
                              textColor: textColorSelected,
                              backgroundColor: backgroundColorSelected),
                          _buildEngPrefixDropdown(
                              textColorSelected, backgroundColorSelected),
                          buildEditableProfileCard('Prefix', stdEngPrefix,
                              onChanged: (value) => stdEngPrefix = value,
                              textColor: textColorSelected,
                              backgroundColor: backgroundColorSelected),
                          buildEditableProfileCard('First Name', stdEngFName,
                              onChanged: (value) => stdEngFName = value,
                              textColor: textColorSelected,
                              backgroundColor: backgroundColorSelected),
                          buildEditableProfileCard('Last Name', stdEngLName,
                              onChanged: (value) => stdEngLName = value,
                              textColor: textColorSelected,
                              backgroundColor: backgroundColorSelected),
                          buildEditableProfileCard('บ้านเลขที่', stdAddrNo,
                              onChanged: (value) => stdAddrNo = value,
                              textColor: textColorSelected,
                              backgroundColor: backgroundColorSelected),
                          buildEditableProfileCard('หมู่', stdAddrMoo,
                              onChanged: (value) => stdAddrMoo = value,
                              textColor: textColorSelected,
                              backgroundColor: backgroundColorSelected),
                          buildEditableProfileCard('บ้าน', stdAddrBaan,
                              onChanged: (value) => stdAddrBaan = value,
                              textColor: textColorSelected,
                              backgroundColor: backgroundColorSelected),
                          buildEditableProfileCard('ซอย', stdAddrAlley,
                              onChanged: (value) => stdAddrAlley = value,
                              textColor: textColorSelected,
                              backgroundColor: backgroundColorSelected),
                          buildEditableProfileCard('ถนน', stdAddrRoad,
                              onChanged: (value) => stdAddrRoad = value,
                              textColor: textColorSelected,
                              backgroundColor: backgroundColorSelected),
                          _buildProvinceDropdown(
                              textColorSelected, backgroundColorSelected),
                          _buildDistrictDropdown(
                              textColorSelected, backgroundColorSelected),
                          _buildSubDistrictDropdown(
                              textColorSelected, backgroundColorSelected),
                          buildProfileCard('รหัสไปรษณีย์', stdZipCode,
                              textColor: textColorSelected,
                              backgroundColor: backgroundColorSelected),
                          _buildMaritalStatusRadioButtons(
                              textColorSelected, backgroundColorSelected),
                          _buildIncomeRadioButtons(
                              textColorSelected, backgroundColorSelected),
                          buildEditableProfileCard(
                              'น้ำหนัก(กิโลกรัม)', stdWeight.toString(),
                              onChanged: (value) => stdWeight =
                                  int.tryParse(value) ?? 0, // Update stdWeight
                              textColor: textColorSelected,
                              backgroundColor: backgroundColorSelected),
                          buildEditableProfileCard(
                              'ส่วนสูง(เซนติเมตร)', stdHeight.toString(),
                              onChanged: (value) => stdHeight =
                                  int.tryParse(value) ?? 0, // Update stdHeight
                              textColor: textColorSelected,
                              backgroundColor: backgroundColorSelected),
                          buildEditableProfileCard(
                              'โรคประจำตัว', congenitalDisease,
                              onChanged: (value) => congenitalDisease =
                                  value, // Update congenitalDisease
                              textColor: textColorSelected,
                              backgroundColor: backgroundColorSelected),
                          buildEditableProfileCard('ประวัติแพ้ยา/อาหาร', drug,
                              onChanged: (value) => drug = value, // Update drug
                              textColor: textColorSelected,
                              backgroundColor: backgroundColorSelected),
                          ElevatedButton(
                            onPressed: saveProfileData,
                            style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all<Color>(Colors.blue),
                              foregroundColor: MaterialStateProperty.all<Color>(
                                  Colors.white),
                              padding:
                                  MaterialStateProperty.all<EdgeInsetsGeometry>(
                                EdgeInsets.symmetric(
                                    horizontal: 32.0, vertical: 16.0),
                              ),
                              minimumSize: MaterialStateProperty.all<Size>(
                                  Size(200, 60)),
                            ),
                            child: const Text('บันทึกข้อมูล'),
                          ),
                        ],
                      ),
                    ),
                  ),
      ),
    ));
  }

  Widget buildProfileCard(String label, String value,
      {required Color textColor, required Color backgroundColor}) {
    return Card(
      color: backgroundColor, // Set the card background color
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        title: Text(
          label,
          style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
        ),
        subtitle: Text(
          value,
          style: TextStyle(color: textColor),
        ),
      ),
    );
  }

  Widget buildEditableProfileCard(String label, String value,
      {bool readOnly = false,
      Function(String)? onChanged,
      required Color textColor,
      required Color backgroundColor}) {
    TextEditingController controller = TextEditingController(text: value);

    return Card(
      color: backgroundColor, // Set the card background color
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        title: Text(
          label,
          style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
        ),
        subtitle: TextField(
          controller: controller,
          readOnly: readOnly,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            hintStyle: TextStyle(color: textColor),
          ),
          style: TextStyle(color: textColor),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
