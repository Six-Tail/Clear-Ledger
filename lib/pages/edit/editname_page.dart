import 'package:flutter/material.dart';
import '../../services/user_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditNicknameScreen extends StatefulWidget {
  const EditNicknameScreen({super.key, required String currentName});

  @override
  _EditNicknameScreenState createState() => _EditNicknameScreenState();
}

class _EditNicknameScreenState extends State<EditNicknameScreen> {
  final TextEditingController _nicknameController = TextEditingController();
  final UserService _userService = UserService();
  final User? _firebaseUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _nicknameController.text = ''; // 초기 사용자 이름 값 설정 (예: 기존 사용자 이름)
  }

  // 사용자 이름 업데이트 함수
  Future<void> _updateUserName() async {
    if (_firebaseUser != null) {
      String newUserName = _nicknameController.text.trim();
      if (newUserName.isNotEmpty) {
        // Firebase에 사용자 이름 업데이트
        await _userService.updateUserInfo(_firebaseUser.uid, userName: newUserName);

        // 위젯이 여전히 활성 상태인지 확인 후 화면 닫기
        if (mounted) {
          Navigator.pop(context, newUserName); // 새로운 사용자 이름을 전달하며 화면 닫기
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus(); // 화면 탭 시 키보드 숨김
      },
      child: Scaffold(
        backgroundColor: const Color(0xffffffff),
        appBar: AppBar(
          scrolledUnderElevation: 0,
          backgroundColor: const Color(0xffffffff),
          title: const Text('사용자 이름 설정', style: TextStyle(color: Colors.black)),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    '사용자 이름을 입력해 주세요.',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 20),
                  // 사용자 이름 입력 필드
                  SizedBox(
                    height: 70,
                    child: TextField(
                      controller: _nicknameController,
                      maxLength: 20,
                      decoration: const InputDecoration(
                        hintText: '사용자 이름 입력',
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(width: 4.0, color: Colors.grey),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(width: 4.0, color: Colors.black),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // 저장 버튼
                  GestureDetector(
                    onTap: _updateUserName,
                    child: Container(
                      alignment: Alignment.center,
                      height: screenHeight * 0.068,
                      width: screenWidth * 0.8,
                      decoration: ShapeDecoration(
                        color: Colors.greenAccent,
                        shape: RoundedRectangleBorder(
                          side: const BorderSide(width: 3, color: Colors.greenAccent),
                          borderRadius: BorderRadius.circular(33),
                        ),
                      ),
                      child: Text(
                        '저장',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: screenHeight * 0.022,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.25,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
