import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:iteachers_application/ActivitiesPage.dart';
import 'package:iteachers_application/ExamSchedulePage.dart';
import 'package:iteachers_application/HomeVisitPage.dart';
import 'package:iteachers_application/JoinClubPage.dart';
import 'package:iteachers_application/PaymentPage.dart';
import 'package:iteachers_application/RegistrationDuplicatePage.dart';
import 'package:iteachers_application/RegistrationPage.dart';
import 'package:iteachers_application/SchedulePage.dart';
import 'package:iteachers_application/ScorePage.dart';
import 'package:iteachers_application/SelfAssessmentPage.dart';
import 'package:iteachers_application/TimePage.dart';
import 'package:iteachers_application/Vcop.dart';
import 'package:iteachers_application/allCenterActivities.dart';
import 'package:iteachers_application/allClubActivities.dart';
import 'package:iteachers_application/allHomeroom.dart';
import 'constants.dart';
import 'package:http/http.dart' as http;
import 'package:iteachers_application/JoinedPage.dart';
import 'package:iteachers_application/NotJoinedPage.dart';
import 'package:iteachers_application/ProfilePage.dart';
import 'package:iteachers_application/ResultPage.dart';
import 'package:iteachers_application/TotalPage.dart';
import 'package:iteachers_application/allLineup.dart';
import 'package:iteachers_application/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme.dart';
import 'main.dart';

class HomePage extends StatefulWidget {
  final String stdPrefix;
  final String stdFName;
  final String stdLName;
  final String stdCode;

  HomePage({
    Key? key,
    required this.stdPrefix,
    required this.stdFName,
    required this.stdLName,
    required this.stdCode,
  }) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late TabController _tabController;
  late TabController _tabController2; // Add another TabController
  late String stdCode;
  bool _isDarkMode = false;
  int total = 5;
  int joined = 5;
  int notJoined = 0;
  String selectedActivity = 'กิจกรรมเข้าแถว';
  String classDescript = 'Loading...';
  String proxyUrl = 'https://cors.bridged.cc/';
  String imageUrl = '';
  bool isLoading = true;

  List<dynamic> classrooms = []; // Store fetched classrooms data here

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
        length: 4, vsync: this); // Adjusted length for the first set of tabs
    _tabController2 = TabController(
        length: 2, vsync: this); // Define length for the second set of tabs
    stdCode = widget.stdCode;
    fetchProfileData(widget.stdCode); // Fetch data on initialization
    _updateCounts(0, stdCode);

    _loadDarkMode();
  }

  void _loadDarkMode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isDarkMode = prefs.getBool('isDarkMode') ?? false;
    setState(() {
      _isDarkMode = isDarkMode;
    });
  }

  Future<void> _logout(BuildContext context) async {
    // Clear user data from SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('stdPrefix');
    await prefs.remove('stdFName');
    await prefs.remove('stdLName');
    await prefs.remove('stdCode');
    await prefs.setBool('isLoggedIn', false);

    // Navigate back to the LoginPage
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => const LoginPage(title: 'Istudent'),
      ),
      (Route<dynamic> route) => false,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _tabController2.dispose(); // Dispose of the second TabController
    super.dispose();
  }

  void fetchProfileData(String stdCode) async {
    try {
      var response = await http.post(
        apiUrl,
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          'act': 'homepage',
          'stdCode': stdCode,
        }),
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body);

        if (data['status'] == 'success') {
          var classroomsData = data['classrooms'];

          setState(() {
            classrooms = classroomsData; // Update classrooms data
            if (classrooms.isNotEmpty) {
              classDescript =
                  classrooms[0]['classDescript'] ?? 'No description';
            } else {
              classDescript = 'No classrooms found';
            }
            String firstTwoDigits = widget.stdCode.substring(0, 2);
            imageUrl =
                "${proxyUrl}https://iteachers.srvc.ac.th/images/student/$firstTwoDigits/${widget.stdCode}.jpg";
            isLoading = false;
          });
        } else {
          setState(() {
            classDescript = 'Failed to fetch data';
            isLoading = false; // Handle loading state
          });
        }
      } else {
        setState(() {
          classDescript = 'Failed to fetch data';
          isLoading = false; // Handle loading state
        });
      }
    } catch (e) {
      setState(() {
        classDescript = 'Exception occurred while fetching data: $e';
        isLoading = false; // Handle loading state
      });
    }
  }

  void _updateCounts(int index, String stdCode) async {
    // Default values
    int total = 0;
    int joined = 0;
    int notJoined = 0;
    String selectedActivity = '';

    try {
      if (index == 0) {
        // Fetch data from the server for index 0
        final response = await http.post(
          apiUrl, // Ensure Uri.parse() is used for proper URL handling
          headers: {"Content-Type": "application/json"},
          body: json.encode({
            'act': 'getActivity',
            'stdCode': stdCode,
          }),
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          // Extract values from the response
          total = data['total'] ?? 0;
          joined = data['joined'] ?? 0;
          notJoined =
              data['notJoined'] ?? 0; // Ensure the key matches the response

          // Set selectedActivity for index 0
          selectedActivity = 'กิจกรรมเข้าแถว';
        } else {
          print('Failed to load data. Status code: ${response.statusCode}');
        }
      } else {
        // Use predefined values for other indices
        switch (index) {
          case 1:
            selectedActivity = 'กิจกรรมโฮมรูม';
            total = 10;
            joined = 7;
            notJoined = 3;
            break;
          case 2:
            selectedActivity = 'กิจกรรมกลาง';
            total = 8;
            joined = 6;
            notJoined = 2;
            break;
          case 3:
            selectedActivity = 'กิจกรรมชมรมวิชาชีพโปรแกรมเมอร์และสารสนเทศ';
            total = 12;
            joined = 9;
            notJoined = 3;
            break;
        }
      }

      // Update the state with the new values
      setState(() {
        this.selectedActivity = selectedActivity;
        this.total = total;
        this.joined = joined;
        this.notJoined = notJoined;

        // Update the tab controller index
        _tabController.index = index;
      });
    } catch (e) {
      print('Exception: $e');
    }
  }

  void onTabTapped(int index) {
    setState(() {
      _tabController.index = index;
    });
  }

  void onTabTapped2(int index) {
    setState(() {
      _tabController2.index = index;
    });
  }

  Widget buildTab(String text, int index, Color backgroundColorSelected,
      textColorSelected, String stdCode) {
    bool isSelected = _tabController.index == index;
    return GestureDetector(
      onTap: () {
        _updateCounts(index, stdCode);
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

  Widget buildTab2(String text, int index, Color backgroundColorSelected,
      textColorSelected) {
    Color textColorSelected2 = _isDarkMode ? textColorLight : textColorDark;
    return GestureDetector(
      onTap: () => onTabTapped2(index),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: _tabController2.index == index
                  ? primaryColorLight
                  : textColorSelected2,
              width: 2,
            ),
          ),
        ),
        width: MediaQuery.of(context).size.width / 2,
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: textColorSelected,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget buildProfileWidget(
      Color backgroundColorSelected, Color textColorSelected) {
    return Container(
      color: backgroundColorSelected,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            SizedBox(
              width: 80,
              height: 100,
              child: imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      loadingBuilder: (BuildContext context, Widget child,
                          ImageChunkEvent? loadingProgress) {
                        if (loadingProgress == null) {
                          return child;
                        } else {
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          );
                        }
                      },
                      errorBuilder: (BuildContext context, Object error,
                          StackTrace? stackTrace) {
                        return Icon(Icons.error, color: Colors.red);
                      },
                    )
                  : CircularProgressIndicator(),
            ),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${widget.stdPrefix} ${widget.stdFName} ${widget.stdLName}',
                    style: TextStyle(
                        color: textColorSelected,
                        fontWeight: FontWeight.normal,
                        fontSize: 20),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "แผนก $classDescript",
                    style: TextStyle(
                      color: textColorSelected,
                      fontWeight: FontWeight.normal,
                    ),
                    softWrap: true,
                    overflow: TextOverflow.visible,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildActivityContent(
      Color backgroundColorSelected, Color textColorSelected, int tabIndex) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    // Determine which page to navigate to based on tabIndex
                    Widget page;
                    switch (tabIndex) {
                      case 0:
                        page = AllLineupPage(
                          total: total,
                          joined: joined,
                          notJoined: notJoined,
                          initialIndex: 0, // Index for 'Not Joined' tab
                          stdCode: stdCode,
                        );
                        break;
                      case 1:
                        page = AllHomeroomPage(
                          total: total,
                          initialIndex: 0, // Adjust as needed
                        );
                        break;
                      case 2:
                        page = AllCenterActivitiesPage(
                          total: total,
                          initialIndex: 0, // Adjust as needed
                        );
                        break;
                      case 3:
                        page = AllClubActivitiesPage(
                          total: total,
                          initialIndex: 0, // Adjust as needed
                        );
                        break;
                      default:
                        page = AllLineupPage(
                          total: total,
                          joined: joined,
                          notJoined: notJoined,
                          initialIndex: 0, // Default case if needed
                          stdCode: stdCode,
                        );
                    }
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => page,
                      ),
                    );
                  },
                  child: Container(
                    color: backgroundColorSelected,
                    child: Padding(
                      padding: EdgeInsets.zero,
                      child: Column(
                        children: [
                          Text(
                            total.toString(),
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: textColorSelected),
                          ),
                          Text(
                            'เข้าแถวแล้ว',
                            style: TextStyle(color: textColorSelected),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    // Handle the tap for "เข้าร่วมกิจกรรม"
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AllLineupPage(
                          total: total,
                          joined: joined,
                          notJoined: notJoined,
                          initialIndex: 1, // Index for 'Not Joined' tab
                          stdCode: stdCode,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    color: backgroundColorSelected,
                    child: Padding(
                      padding: EdgeInsets.zero,
                      child: Column(
                        children: [
                          Text(
                            joined.toString(),
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: textColorSelected,
                            ),
                          ),
                          Text(
                            'นักศึกษาเข้าร่วม',
                            style: TextStyle(color: textColorSelected),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    // Handle the tap for "ยังไม่เข้าร่วม"
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AllLineupPage(
                          total: total,
                          joined: joined,
                          notJoined: notJoined,
                          initialIndex: 2, // Index for 'Not Joined' tab
                          stdCode: stdCode,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    color: backgroundColorSelected,
                    child: Padding(
                      padding: EdgeInsets.zero,
                      child: Column(
                        children: [
                          Text(
                            notJoined.toString(),
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: textColorSelected,
                            ),
                          ),
                          Text(
                            'นักศึกษาไม่เข้าร่วม',
                            style: TextStyle(color: textColorSelected),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Color backgroundColorSelected =
        _isDarkMode ? backgroundColorDark : backgroundColorLight;
    Color textColorSelected = _isDarkMode ? textColorDark : textColorLight;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: backgroundColorSelected,
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Istudent',
              style: TextStyle(
                color: _isDarkMode ? textColorDark : primaryColorLight,
                fontWeight: FontWeight.bold,
              ),
            ),
            PopupMenuButton(
              icon: Icon(Icons.menu, color: textColorSelected),
              itemBuilder: (BuildContext context) => [
                PopupMenuItem(
                  child: ListTile(
                    leading: Icon(Icons.color_lens,
                        color:
                            textColorSelected), // Customize leading icon color
                    title: Text('ธีมดํา',
                        style: TextStyle(
                            color: textColorSelected)), // Customize text color

                    onTap: () async {
                      bool? result = await Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => ThemeScreen()),
                      );
                      if (result != null) {
                        setState(() {
                          _isDarkMode = result;
                        });
                        Navigator.of(context).pop();
                      }
                    },
                  ),
                ),
                PopupMenuItem(
                  child: ListTile(
                    leading: Icon(Icons.exit_to_app, color: textColorSelected),
                    title: Text('ออกจากระบบ',
                        style: TextStyle(color: textColorSelected)),
                    onTap: () {
                      _logout(context);
                    },
                  ),
                ),
              ],
              tooltip: 'This is a demo tooltip',
              elevation: 10,
              color: backgroundColorSelected,
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Divider(height: 0.4, color: Colors.grey), // Small divider line
            buildProfileWidget(backgroundColorSelected, textColorSelected),
            Container(
              height: 0.2, // กำหนดความสูงของ divider เป็น 0.2 (หน่วย pixel)
              color: Colors.grey, // กำหนดสีของ divider เป็นสีเทา
            ),
            Container(
              color: backgroundColorSelected,
              child: Column(
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        buildTab('กิจกรรมเข้าแถว', 0, backgroundColorSelected,
                            textColorSelected, stdCode),
                        buildTab('กิจกรรมโฮมรูม', 1, backgroundColorSelected,
                            textColorSelected, stdCode),
                        buildTab('กิจกรรมกลาง', 2, backgroundColorSelected,
                            textColorSelected, stdCode),
                        buildTab(
                            'ชมรมวิชาชีพคอมพิวเตอร์โปรแกรมเมอร์และเทคโนโลยีสารสนเทศ',
                            3,
                            backgroundColorSelected,
                            textColorSelected,
                            stdCode),
                      ],
                    ),
                  ),
                  IndexedStack(
                    index: _tabController.index,
                    children: [
                      buildActivityContent(
                          backgroundColorSelected, textColorSelected, 0),
                      buildActivityContent(
                          backgroundColorSelected, textColorSelected, 1),
                      buildActivityContent(
                          backgroundColorSelected, textColorSelected, 2),
                      buildActivityContent(
                          backgroundColorSelected, textColorSelected, 3)
                    ],
                  ),
                ],
              ),
            ),

            Container(
              height: 0.2, // กำหนดความสูงของ divider เป็น 0.2 (หน่วย pixel)
              color: Colors.grey, // กำหนดสีของ divider เป็นสีเทา
            ),
            Container(
              color: backgroundColorSelected,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      buildTab2('เมนูหลัก', 0, backgroundColorSelected,
                          textColorSelected),
                      buildTab2('เมนูอื่นๆ', 1, backgroundColorSelected,
                          textColorSelected),
                      // Add more tabs as needed
                    ],
                  ),
                  IndexedStack(
                    index: _tabController2.index,
                    children: [
                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              manu(
                                  Icons.align_vertical_bottom,
                                  'ผลการเรียน',
                                  primaryColorLight,
                                  backgroundColorSelected,
                                  textColorSelected,
                                  context,
                                  widget.stdCode),
                              manu(
                                  Icons.calculate,
                                  'คะแนนเรียนระหว่างภาค',
                                  primaryColorLight,
                                  backgroundColorSelected,
                                  textColorSelected,
                                  context,
                                  widget.stdCode),
                              manu(
                                  Icons.timer,
                                  'เวลาเรียนระหว่างภาค',
                                  primaryColorLight,
                                  backgroundColorSelected,
                                  textColorSelected,
                                  context,
                                  widget.stdCode),
                            ],
                          ),
                          SizedBox(height: 4.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              manu(
                                  Icons.check,
                                  'แบบประเมินตนเอง',
                                  primaryColorLight,
                                  backgroundColorSelected,
                                  textColorSelected,
                                  context,
                                  widget.stdCode),
                              manu(
                                  Icons.payment,
                                  'ชำระเงินค่าลงทะเบียน',
                                  primaryColorLight,
                                  backgroundColorSelected,
                                  textColorSelected,
                                  context,
                                  widget.stdCode),
                              manu(
                                  Icons.payment,
                                  'V-COP',
                                  primaryColorLight,
                                  backgroundColorSelected,
                                  textColorSelected,
                                  context,
                                  widget.stdCode),
                            ],
                          ),
                          SizedBox(height: 4.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              manu(
                                  Icons.schedule,
                                  'ตารางเรียน',
                                  primaryColorLight,
                                  backgroundColorSelected,
                                  textColorSelected,
                                  context,
                                  widget.stdCode),
                              manu(
                                  Icons.event,
                                  'ตารางสอบ',
                                  primaryColorLight,
                                  backgroundColorSelected,
                                  textColorSelected,
                                  context,
                                  widget.stdCode),
                              manu(
                                  null,
                                  '',
                                  primaryColorLight,
                                  backgroundColorSelected,
                                  textColorSelected,
                                  context,
                                  widget.stdCode),
                            ],
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              manu(
                                  Icons.person,
                                  'ประวัติ',
                                  primaryColorLight,
                                  backgroundColorSelected,
                                  textColorSelected,
                                  context,
                                  widget.stdCode),
                              manu(
                                  Icons.app_registration,
                                  'ลงทะเบียนเเก้0/มส.',
                                  primaryColorLight,
                                  backgroundColorSelected,
                                  textColorSelected,
                                  context,
                                  widget.stdCode),
                              manu(
                                  Icons.app_registration,
                                  'ลงทะเบียนกิจกรรม',
                                  primaryColorLight,
                                  backgroundColorSelected,
                                  textColorSelected,
                                  context,
                                  widget.stdCode),
                            ],
                          ),
                          SizedBox(height: 4.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              manu(
                                  Icons.app_registration,
                                  'ลงทะเบียนเรียนซ้ำ/เพิ่ม',
                                  primaryColorLight,
                                  backgroundColorSelected,
                                  textColorSelected,
                                  context,
                                  widget.stdCode),
                              manu(
                                  Icons.home,
                                  'เยี่ยมบ้าน',
                                  primaryColorLight,
                                  backgroundColorSelected,
                                  textColorSelected,
                                  context,
                                  widget.stdCode),
                              manu(
                                  Icons.group,
                                  'สมัครชมรม',
                                  primaryColorLight,
                                  backgroundColorSelected,
                                  textColorSelected,
                                  context,
                                  widget.stdCode),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget manu(
    IconData? icon,
    String label,
    Color iconColor,
    Color backgroundColorSelected,
    Color labelColor,
    BuildContext context,
    String stdCode) {
  // Handle navigation based on label
  if (label == 'ผลการเรียน') {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ResultPage()),
        );
      },
      child: buildMenuItem(
          icon, label, iconColor, backgroundColorSelected, labelColor),
    );
  } else if (label == 'คะแนนเรียนระหว่างภาค') {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  ScorePage()), // Replace with your History page widget
        );
      },
      child: buildMenuItem(
          icon, label, iconColor, backgroundColorSelected, labelColor),
    );
  } else if (label == 'เวลาเรียนระหว่างภาค') {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  TimePage()), // Replace with your History page widget
        );
      },
      child: buildMenuItem(
          icon, label, iconColor, backgroundColorSelected, labelColor),
    );
  } else if (label == 'แบบประเมินตนเอง') {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  SelfassessmentPage()), // Replace with your History page widget
        );
      },
      child: buildMenuItem(
          icon, label, iconColor, backgroundColorSelected, labelColor),
    );
  } else if (label == 'ชำระเงินค่าลงทะเบียน') {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  PaymentPage()), // Replace with your History page widget
        );
      },
      child: buildMenuItem(
          icon, label, iconColor, backgroundColorSelected, labelColor),
    );
  } else if (label == 'V-COP') {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  Vcop()), // Replace with your History page widget
        );
      },
      child: buildMenuItem(
          icon, label, iconColor, backgroundColorSelected, labelColor),
    );
  } else if (label == 'ตารางเรียน') {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  SchedulePage()), // Replace with your History page widget
        );
      },
      child: buildMenuItem(
          icon, label, iconColor, backgroundColorSelected, labelColor),
    );
  } else if (label == 'ตารางสอบ') {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  ExamSchedulePage()), // Replace with your History page widget
        );
      },
      child: buildMenuItem(
          icon, label, iconColor, backgroundColorSelected, labelColor),
    );
  } else if (label == 'ประวัติ') {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ProfilePage(
                    stdCode: stdCode,
                    act: 'profile',
                  )), // Replace with your History page widget
        );
      },
      child: buildMenuItem(
          icon, label, iconColor, backgroundColorSelected, labelColor),
    );
  } else if (label == 'ลงทะเบียนเเก้0/มส.') {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  Registrationpage()), // Replace with your History page widget
        );
      },
      child: buildMenuItem(
          icon, label, iconColor, backgroundColorSelected, labelColor),
    );
  } else if (label == 'ลงทะเบียนกิจกรรม') {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  Activitiespage()), // Replace with your History page widget
        );
      },
      child: buildMenuItem(
          icon, label, iconColor, backgroundColorSelected, labelColor),
    );
  } else if (label == 'ลงทะเบียนเรียนซ้ำ/เพิ่ม') {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  Registrationduplicatepage()), // Replace with your History page widget
        );
      },
      child: buildMenuItem(
          icon, label, iconColor, backgroundColorSelected, labelColor),
    );
  } else if (label == 'เยี่ยมบ้าน') {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  Homevisitpage()), // Replace with your History page widget
        );
      },
      child: buildMenuItem(
          icon, label, iconColor, backgroundColorSelected, labelColor),
    );
  } else if (label == 'สมัครชมรม') {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  Joinclubpage()), // Replace with your History page widget
        );
      },
      child: buildMenuItem(
          icon, label, iconColor, backgroundColorSelected, labelColor),
    );
  } else {
    // For other menu items, just build the UI without navigation
    return buildMenuItem(
        icon, label, iconColor, backgroundColorSelected, labelColor);
  }
}

Widget buildMenuItem(IconData? icon, String label, Color iconColor,
    backgroundColorSelected, Color labelColor) {
  if (icon == null || label.isEmpty) {
    return SizedBox(width: 120, height: 120);
  }
  return SizedBox(
    width: 120, // Adjust width as needed
    height: 120, // Adjust height as needed
    child: Container(
      decoration: BoxDecoration(
        color: backgroundColorSelected,
        border: Border.all(
          color: Color.fromARGB(255, 231, 231, 231),
          width: 0.1,
        ),
        borderRadius: BorderRadius.circular(0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(1),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: iconColor),
            SizedBox(height: 4.0),
            Text(
              label,
              style: TextStyle(color: labelColor),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    ),
  );
}
