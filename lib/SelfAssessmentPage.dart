import 'package:flutter/material.dart';
import 'theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SelfassessmentPage extends StatefulWidget {
  const SelfassessmentPage({Key? key}) : super(key: key);

  @override
  _SelfassessmentPageState createState() => _SelfassessmentPageState();
}

class _SelfassessmentPageState extends State<SelfassessmentPage> {
  bool _isDarkMode = false;
  List<String> assessments = [
    'แบบประเมินความคิดเห็นทางสังคม',
    'แบบประเมินพฤติกรรมเสี่ยง',
    'แบบประเมินพฤติกรรมรุนแรง'
  ];
  List<bool> completed = [false, false, false];

  void navigateToAssessment(int index) {
    switch (index) {
      case 0:
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => SocialViewAssessmentPage(
              onCompleted: () {
                setState(() {
                  completed[index] = true;
                });
              },
            ),
          ),
        );
        break;
      case 1:
        // Navigate to the "Risk Behavior Assessment"
        break;
      case 2:
        // Navigate to the "Violent Behavior Assessment"
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    _loadDarkMode();
    // Set default selected subject to the first item
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
    int completedCount = completed.where((e) => e).length;
    double progress = completedCount / assessments.length;

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
          'เเบบประเมินตนเอง',
          style: TextStyle(color: textColorSelected),
        ),
      ),
      body: Container(
        color: backgroundColorSelected,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'เลือกแบบประเมิน:',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: textColorSelected),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: assessments.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(
                      assessments[index],
                      style: TextStyle(color: textColorSelected),
                    ),
                    trailing: completed[index]
                        ? Icon(Icons.check, color: Colors.green)
                        : null,
                    onTap: () => navigateToAssessment(index),
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            LinearProgressIndicator(
              value: progress,
              backgroundColor:
                  _isDarkMode ? Colors.grey[800] : Colors.grey[300],
              color: Colors.blue,
              minHeight: 10,
            ),
            SizedBox(height: 10),
            Text(
              'ทำไปแล้ว ${completedCount} / ${assessments.length} อัน',
              style: TextStyle(fontSize: 16, color: textColorSelected),
            ),
          ],
        ),
      ),
    );
  }
}

class SocialViewAssessmentPage extends StatefulWidget {
  final VoidCallback onCompleted;

  const SocialViewAssessmentPage({required this.onCompleted, Key? key})
      : super(key: key);

  @override
  _SocialViewAssessmentPageState createState() =>
      _SocialViewAssessmentPageState();
}

class _SocialViewAssessmentPageState extends State<SocialViewAssessmentPage> {
  List<String> questions = [
    'ใครมาดูหมิ่นสถาบันต้องตอบโต้กลับเพื่อรักษาศักดิ์ศรี',
    'การมีเรื่องกับสถาบันอื่นตามธรรมเนียมสืบทอดกันมาเป็นการแสดงถึงความภักดีต่อสถาบัน',
    'ลูกผู้ชายอาชีวะต้องตอบโต้แบบ “ตาต่อตา ฟันต่อฟัน”',
    'ความคิดเรื่องการเป็นอริกับสถาบันอื่นเป็นสิ่งถูกต้อง',
    'การโต้กลับเป็นการแสดงออกถึงความมีศักดิ์ศรี',
    'ค่านิยมเรื่องการเอาคืนเป็นสิ่งที่ถูกต้อง',
    'พร้อมที่จะมีเรื่องราว และใช้ความรุนแรง',
    'การทำร้ายฝ่ายตรงข้ามไม่ใช่เรื่องผิด',
    'พยายามทำทุกอย่างเพื่อให้เพื่อนยอมรับ แม้ว่าต้องมีเรื่องกับผู้อื่น',
    'การมีเรื่องมีราวทำให้เป็นที่ยอมรับเข้าไปอยู่ในกลุ่ม'
  ];

  List<int?> answers = List.filled(10, null);
  bool _isDarkMode = false;

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

  @override
  Widget build(BuildContext context) {
    Color backgroundColorSelected =
        _isDarkMode ? backgroundColorDark : backgroundColorLight;
    Color textColorSelected = _isDarkMode ? textColorDark : textColorLight;

    int completedCount = answers.where((e) => e != null).length;
    double progress = completedCount / questions.length;

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
          'แบบประเมินความคิดเห็นทางสังคม',
          style: TextStyle(color: textColorSelected),
        ),
      ),
      body: Container(
        color: backgroundColorSelected, // Set the background color here
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                elevation: 3,
                margin: EdgeInsets.only(bottom: 16),
                color: _isDarkMode ? backgroundColorDark : Colors.white,
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'แบบประเมินความคิดเห็นทางสังคมสำหรับวัยรุ่น – ฉบับ 10 คำถาม (Adolescent Social View Scale – 10 items; ASV -10)',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: textColorSelected,
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'ค่านิยมทางสังคมเป็นความคิดเห็น ส่วนบุคคล อาจมีความแตกต่างกันได้ การทำความเข้าใจในสิ่งเหล่านั้นจะเป็นประโยชน์ต่อการปรับตัวของท่าน โปรดคลิกช่องที่ตรงกับความเป็นจริงเกี่ยวกับตัวท่าน ',
                        style:
                            TextStyle(fontSize: 16, color: textColorSelected),
                      ),
                      Text(
                        'ไม่เห็นด้วยอย่างยิ่งให้                     1 คะแนน',
                        style:
                            TextStyle(fontSize: 16, color: textColorSelected),
                      ),
                      Text(
                        'ไม่เห็นด้วยให้                                  2 คะแนน',
                        style:
                            TextStyle(fontSize: 16, color: textColorSelected),
                      ),
                      Text(
                        'เห็นด้วยและไม่เห็นด้วยพอๆกันให้    3 คะแนน',
                        style:
                            TextStyle(fontSize: 16, color: textColorSelected),
                      ),
                      Text(
                        'เห็นด้วยให้                                      4 คะแนน',
                        style:
                            TextStyle(fontSize: 16, color: textColorSelected),
                      ),
                      Text(
                        'เห็นด้วยอย่างยิ่งให้                         5 คะแนน',
                        style:
                            TextStyle(fontSize: 16, color: textColorSelected),
                      ),
                    ],
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(
                  questions.length,
                  (index) => Card(
                    elevation: 3,
                    margin: EdgeInsets.only(bottom: 16),
                    color: _isDarkMode ? backgroundColorDark : Colors.white,
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${index + 1}. ${questions[index]}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: textColorSelected,
                            ),
                          ),
                          SizedBox(height: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Radio<int>(
                                    value: 1,
                                    groupValue: answers[index],
                                    onChanged: (value) {
                                      setState(() {
                                        answers[index] = value;
                                      });
                                    },
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'ไม่เห็นด้วยอย่างยิ่ง',
                                    style: TextStyle(color: textColorSelected),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Radio<int>(
                                    value: 2,
                                    groupValue: answers[index],
                                    onChanged: (value) {
                                      setState(() {
                                        answers[index] = value;
                                      });
                                    },
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'ไม่เห็นด้วย',
                                    style: TextStyle(color: textColorSelected),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Radio<int>(
                                    value: 3,
                                    groupValue: answers[index],
                                    onChanged: (value) {
                                      setState(() {
                                        answers[index] = value;
                                      });
                                    },
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'เห็นด้วยและไม่เห็นด้วยพอๆกัน',
                                    style: TextStyle(color: textColorSelected),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Radio<int>(
                                    value: 4,
                                    groupValue: answers[index],
                                    onChanged: (value) {
                                      setState(() {
                                        answers[index] = value;
                                      });
                                    },
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'เห็นด้วย',
                                    style: TextStyle(color: textColorSelected),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Radio<int>(
                                    value: 5,
                                    groupValue: answers[index],
                                    onChanged: (value) {
                                      setState(() {
                                        answers[index] = value;
                                      });
                                    },
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'เห็นด้วยอย่างยิ่ง',
                                    style: TextStyle(color: textColorSelected),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FloatingActionButton(
          onPressed: () {
            // Handle saving the answers or any other action
            print('Answers: $answers');
            widget.onCompleted();
            Navigator.of(context).pop();
          },
          child: Icon(Icons.save),
        ),
      ),
    );
  }
}
