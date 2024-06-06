import 'package:flutter/material.dart';
import 'package:final_2024_1/pages/personal_info/personal_info_confirmation_page.dart';
// import 'package:final_2024_1/pages/academic_info/subject_list_page.dart';
import 'academic_info_last_page.dart';
import 'subject_list_page.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';
import 'dart:async';

class AcademicInfoFourthPage extends StatefulWidget {
  final int userId;
  final String highestEdu;
  final String schoolName;
  final String major;
  final String userName;

  const AcademicInfoFourthPage({
    super.key,
    required this.userId,
    required this.highestEdu,
    required this.schoolName,
    required this.major,
    required this.userName,
  });

  @override
  _AcademicInfoFourthPageState createState() => _AcademicInfoFourthPageState();
}

class _AcademicInfoFourthPageState extends State<AcademicInfoFourthPage> {
  final TextEditingController _detailedMajorController = TextEditingController();
  bool _isDetailedMajorEmpty = false;
  bool _hasInputDetailedMajor = false;
  List<String> _subjectNames = [];

  @override
  void initState() {
    super.initState();
    _detailedMajorController.addListener(_updateDetailedMajorTextColor);
    _loadCsvData();
  }

  @override
  void dispose() {
    _detailedMajorController.removeListener(_updateDetailedMajorTextColor);
    _detailedMajorController.dispose();
    super.dispose();
  }

  void _updateDetailedMajorTextColor() {
    setState(() {
      _hasInputDetailedMajor = _detailedMajorController.text.isNotEmpty;
    });
  }

  Future<void> _loadCsvData() async {
    final String rawCsv = await rootBundle.loadString('assets/university_subjects.csv');
    List<List<dynamic>> csvTable = CsvToListConverter().convert(rawCsv);

    // Assuming the first row is the header and we are interested in the column with title "학과명"
    int columnIndex = csvTable[0].indexOf('학과명');
    if (columnIndex == -1) {
      throw Exception('학과명 column not found');
    }

    // Extract the column values (excluding the header)
    List<String> subjectNames = [];
    for (int i = 1; i < csvTable.length; i++) {
      subjectNames.add(csvTable[i][columnIndex]);
    }

    setState(() {
      _subjectNames = subjectNames;
    });
  }

  void _onNextButtonPressed() {
    setState(() {
      _isDetailedMajorEmpty = _detailedMajorController.text.isEmpty;
    });

    if (_isDetailedMajorEmpty) {
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PersonalInfoConfirmationPage(
          title: '세부 전공 확인',
          infoLabel: '세부 전공이',
          info: _detailedMajorController.text,
          onConfirmed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AcademicInfoLastPage(
                  userId: widget.userId,
                  highestEdu: widget.highestEdu,
                  schoolName: widget.schoolName,
                  major: widget.major,
                  detailedMajor: _detailedMajorController.text,
                  userName: widget.userName,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _onTextFieldClicked(BuildContext context) async {
    final selectedSubject = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SubjectListPage()),
    );

    if (selectedSubject != null) {
      setState(() {
        _detailedMajorController.text = selectedSubject;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Center(
              child: Column(
                children: [
                  SizedBox(height: 230),
                  Text(
                    '${widget.userName}님의\n세부 전공을\n입력해주세요',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      height: 1.0,
                    ),
                  ),
                  SizedBox(height: 10),
                  if (_isDetailedMajorEmpty)
                    Text(
                      '세부 전공을 정확히 입력해주세요.',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  SizedBox(height: 40),
                  Container(
                    width: 347,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24.0),
                      border: Border.all(
                        color: Color(0xFF001ED6),
                        width: 2.0,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: TextField(
                        controller: _detailedMajorController,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          color: _hasInputDetailedMajor ? Color(0xFF001ED6) : Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: InputDecoration(
                          hintText: '세부 전공',
                          hintStyle: TextStyle(
                            color: Colors.grey,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          border: InputBorder.none,
                        ),
                        onTap: () {
                          _onTextFieldClicked(context);
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 180),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF001ED6),
                      side: BorderSide(color: Color(0xFFFFFFFF), width: 2),
                      minimumSize: Size(345, 60),
                      shadowColor: Colors.black,
                      elevation: 6,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24.0),
                      ),
                    ),
                    onPressed: _onNextButtonPressed,
                    child: const Text(
                      '다음',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
