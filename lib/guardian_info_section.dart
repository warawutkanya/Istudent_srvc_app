import 'dart:math';
import 'package:flutter/material.dart';
import 'constants.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GuardianInfoSection extends StatefulWidget {
  final String stdCode;
  final String act;
  final String stdParent;

  const GuardianInfoSection({
    Key? key,
    required this.stdCode,
    required this.act,
    required this.stdParent,
  }) : super(key: key);

  @override
  _GuardianInfoSectionState createState() => _GuardianInfoSectionState();
}

class _GuardianInfoSectionState extends State<GuardianInfoSection> {
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
                value: parentPrefix,
                icon: Icon(Icons.arrow_drop_down, color: textColor),
                iconSize: 24,
                elevation: 16,
                style: TextStyle(color: textColor),
                dropdownColor: backgroundColor,
                isExpanded: true,
                underline: Container(),
                onChanged: (String? newValue) {
                  setState(() {
                    parentPrefix = newValue!;
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
                value: parentProvinceId.isNotEmpty
                    ? provinces.firstWhere(
                        (province) =>
                            province['provinceID'] == parentProvinceId,
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
                    parentProvinceId = provinces.firstWhere(
                          (province) =>
                              province['provinceThaiName'] == newValue,
                          orElse: () => {'provinceID': ''},
                        )['provinceID'] ??
                        '';

                    parentProvince = newValue ?? '';
                    print("Selected parentProvinceId: $parentProvinceId");
                    print("Selected parentProvince: $parentProvince");

                    // Reset district and sub-district
                    parentDistrict = '';
                    parentSubDistrict = '';

                    // Fetch districts based on the new province
                    fetchDistricts(parentProvinceId);
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
                value: parentDistrict.isNotEmpty
                    ? districts.firstWhere(
                        (district) => district['districtID'] == parentDistrict,
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
                    parentDistrict = districts.firstWhere(
                          (district) =>
                              district['districtThaiName'] == newValue,
                          orElse: () => {'districtID': ''},
                        )['districtID'] ??
                        '';

                    parentDistrictName = newValue ?? '';
                    print("Selected parentDistrictId: $parentDistrict");
                    print("Selected parentDistrictName: $parentDistrictName");

                    // Reset sub-district
                    parentSubDistrict = '';

                    // Fetch sub-districts based on the new district
                    fetchSubDistricts(parentDistrict);
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
                value: parentSubDistrict.isNotEmpty
                    ? subDistricts.firstWhere(
                        (subDistrict) =>
                            subDistrict['subDistrictID'] == parentSubDistrict,
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
                    parentSubDistrict = subDistricts.firstWhere(
                          (subDistrict) =>
                              subDistrict['subDistrictThaiName'] == newValue,
                          orElse: () => {'subDistrictID': ''},
                        )['subDistrictID'] ??
                        '';

                    parentZipcode = subDistricts.firstWhere(
                          (subDistrict) =>
                              subDistrict['subDistrictThaiName'] == newValue,
                          orElse: () => {'zip_code': ''},
                        )['zip_code'] ??
                        '';

                    print("Selected parentSubDistrictId: $parentSubDistrict");
                    print("Selected Zip Code: $parentZipcode");
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

  List<Map<String, String>> provinces = [];
  List<Map<String, String>> districts = [];
  List<Map<String, String>> subDistricts = [];
  bool isLoading = true;
  String parentProvinceId = '';
  String parentProvinceName = '';
  String errorMessage = '';
  bool _isDarkMode = false;
  String parentPinId = '';
  String parentPrefix = '';
  String parentFName = '';
  String parentLName = '';
  String parentPhone = '';
  String parentEmail = '';
  String parentNo = '';
  String parentMoo = '';
  String parentBaan = '';
  String parentAlley = '';
  String parentRoad = '';
  String parentSubDistrict = '';
  String parentDistrict = '';
  String? parentProvince;
  String parentZipcode = '';
  String parentBdate = '';
  String parentOccupation = '';
  String parentDistrictName = '';
  String parentDistrictId = '';
  String parentSubDistrictName = '';
  String parentSubDistrictId = '';

  @override
  void initState() {
    super.initState();
    fetchProfileData(widget.stdParent);
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

  void fetchProfileData(String stdParent) async {
    try {
      setState(() {
        isLoading = true; // Ensure loading state is set
      });

      var response = await http.post(
        apiUrl,
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          'act': 'profileparent',
          'stdParent': stdParent,
        }),
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body);

        if (data['status'] == 'success') {
          var parent = data['parent'];
          setState(() {
            parentPinId = parent['parentPinId']?.toString() ?? '';
            parentPrefix = parent['parentPrefix']?.toString() ?? '';
            parentFName = parent['parentFName']?.toString() ?? '';
            parentLName = parent['parentLName']?.toString() ?? '';
            parentPhone = parent['parentPhone']?.toString() ?? '';
            parentEmail = parent['parentEmail']?.toString() ?? '';
            parentNo = parent['parentNo']?.toString() ?? '';
            parentMoo = parent['parentMoo']?.toString() ?? '';
            parentBaan = parent['parentBaan']?.toString() ?? '';
            parentAlley = parent['parentAlley']?.toString() ?? '';
            parentRoad = parent['parentRoad']?.toString() ?? '';
            parentSubDistrict = parent['parentSubDistrict']?.toString() ?? '';
            parentDistrict = parent['parentDistrict']?.toString() ?? '';
            parentProvinceId = parent['parentProvince']?.toString() ?? '';
            parentZipcode = parent['parentZipcode']?.toString() ?? '';
            parentBdate = parent['parentBdate']?.toString() ?? '';
            parentOccupation = parent['parentOccupation']?.toString() ?? '';
            isLoading = false;
          });

          // Fetch province ID and then districts and sub-districts
          if (parentProvinceId != null && parentProvinceId!.isNotEmpty) {
            fetchDistricts(
                parentProvinceId!); // Fetch all districts for the province
            if (parentDistrict.isNotEmpty) {
              fetchSubDistricts(
                  parentDistrict); // Fetch sub-districts for the district
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

  Future<String> getDistrictID(String provinceID, String districtName) async {
    try {
      final response = await http.post(
        apiUrl,
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          'act': 'getDistricts',
          'provinceID': provinceID,
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

  void saveProfileData() async {
    try {
      final response = await http.post(
        apiUrl,
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          'act': 'update_profile_parent',
          'parentPinId': parentPinId,
          'parentPrefix': parentPrefix,
          'parentFName': parentFName,
          'parentLName': parentLName,
          'parentPhone': parentPhone,
          'parentEmail': parentEmail,
          'parentNo': parentNo,
          'parentMoo': parentMoo,
          'parentBaan': parentBaan,
          'parentAlley': parentAlley,
          'parentRoad': parentRoad,
          'parentSubDistrict': parentSubDistrict,
          'parentDistrict': parentDistrict,
          'parentProvince': parentProvinceId,
          'parentZipcode': parentZipcode,
          'parentBdate': parentBdate,
          'parentOccupation': parentOccupation,
        }),
      );

      // Log the entire response

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

          // Call fetchDistricts for the selected province if available
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
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 16),
                Text(
                  'ข้อมูลผู้ปกครอง',
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: textColorSelected),
                ),
                SizedBox(height: 16),
                buildEditableProfileCard('รหัสประจำตัว', parentPinId,
                    onChanged: (value) => setState(() => parentPinId = value),
                    textColor: textColorSelected,
                    backgroundColor: backgroundColorSelected),
                _buildPrefixDropdown(
                    textColorSelected, backgroundColorSelected),
                buildEditableProfileCard('ชื่อ', parentFName,
                    onChanged: (value) => setState(() => parentFName = value),
                    textColor: textColorSelected,
                    backgroundColor: backgroundColorSelected),
                buildEditableProfileCard('นามสกุล', parentLName,
                    onChanged: (value) => setState(() => parentLName = value),
                    textColor: textColorSelected,
                    backgroundColor: backgroundColorSelected),
                buildEditableProfileCard('เบอร์โทรศัพท์', parentPhone,
                    onChanged: (value) => setState(() => parentPhone = value),
                    textColor: textColorSelected,
                    backgroundColor: backgroundColorSelected),
                buildEditableProfileCard('อีเมล', parentEmail,
                    onChanged: (value) => setState(() => parentEmail = value),
                    textColor: textColorSelected,
                    backgroundColor: backgroundColorSelected),
                buildEditableProfileCard('วันเกิด', parentBdate,
                    onChanged: (value) => setState(() => parentBdate = value),
                    textColor: textColorSelected,
                    backgroundColor: backgroundColorSelected),
                buildEditableProfileCard('บ้านเลขที่', parentNo,
                    onChanged: (value) => setState(() => parentNo = value),
                    textColor: textColorSelected,
                    backgroundColor: backgroundColorSelected),
                buildEditableProfileCard('หมู่', parentMoo,
                    onChanged: (value) => setState(() => parentMoo = value),
                    textColor: textColorSelected,
                    backgroundColor: backgroundColorSelected),
                buildEditableProfileCard('บ้าน', parentBaan,
                    onChanged: (value) => setState(() => parentBaan = value),
                    textColor: textColorSelected,
                    backgroundColor: backgroundColorSelected),
                buildEditableProfileCard('ซอย', parentAlley,
                    onChanged: (value) => setState(() => parentAlley = value),
                    textColor: textColorSelected,
                    backgroundColor: backgroundColorSelected),
                buildEditableProfileCard('ถนน', parentRoad,
                    onChanged: (value) => setState(() => parentRoad = value),
                    textColor: textColorSelected,
                    backgroundColor: backgroundColorSelected),
                _buildProvinceDropdown(
                    textColorSelected, backgroundColorSelected),
                _buildDistrictDropdown(
                    textColorSelected, backgroundColorSelected),
                _buildSubDistrictDropdown(
                    textColorSelected, backgroundColorSelected),
                buildProfileCard('รหัสไปรษณีย์', parentZipcode,
                    textColor: textColorSelected,
                    backgroundColor: backgroundColorSelected),
                buildEditableProfileCard('อาชีพ', parentOccupation,
                    onChanged: (value) =>
                        setState(() => parentOccupation = value),
                    textColor: textColorSelected,
                    backgroundColor: backgroundColorSelected),
                ElevatedButton(
                  onPressed: saveProfileData,
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.blue),
                    foregroundColor:
                        MaterialStateProperty.all<Color>(Colors.white),
                    padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                      EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
                    ),
                    minimumSize: MaterialStateProperty.all<Size>(
                      Size(200, 60),
                    ),
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
