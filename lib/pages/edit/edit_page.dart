import 'package:flutter/material.dart';
import '../../services/user_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditPage extends StatefulWidget {
  const EditPage({super.key});

  @override
  _EditPageState createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  final TextEditingController _nicknameController = TextEditingController();
  final UserService _userService = UserService();
  final User? _firebaseUser = FirebaseAuth.instance.currentUser;
  final FocusNode _focusNode = FocusNode(); // FocusNode 추가

  @override
  void initState() {
    super.initState();
    _loadUserName(); // 사용자 이름 초기화
  }

  // Firestore에서 사용자 닉네임 불러오기
  Future<void> _loadUserName() async {
    String? userName = await _userService.fetchUserName();
    if (mounted) {
      setState(() {
        _nicknameController.text = userName ?? '닉네임 불러오기 실패';
      });
    }
  }

  // 닉네임 업데이트 및 반환
  Future<void> _updateUserName() async {
    if (_firebaseUser != null) {
      String newUserName = _nicknameController.text.trim();
      if (newUserName.isNotEmpty) {
        // Firestore에 사용자 이름 업데이트
        await _userService.updateUserInfo(_firebaseUser.uid, userName: newUserName);

        // 닉네임 저장 후 화면 닫기 및 데이터 반환
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                '닉네임이 성공적으로 저장되었습니다.',
                style: TextStyle(color: Colors.black), // 텍스트 색상
                textAlign: TextAlign.center, // 텍스트 가운데 정렬
              ),
              backgroundColor: Colors.white, // 배경색
              behavior: SnackBarBehavior.floating, // 스낵바를 떠 있는 형태로 변경 (옵션)
            ),
          );
          Navigator.pop(context, newUserName); // 수정된 닉네임 반환
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
          title: const Text(
            '사용자 이름 설정',
            style: TextStyle(color: Colors.black),
          ),
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
                    child: Container(
                      padding: const EdgeInsets.all(2.0), // 그라데이션 테두리 두께
                      decoration: BoxDecoration(
                        gradient: _focusNode.hasFocus
                            ? const LinearGradient(
                          colors: [Color(0xFF008AB2), Color(0xFFD6FFDE)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                            : null, // 포커스가 없을 때는 그라데이션 제거
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: TextField(
                        controller: _nicknameController, // 닉네임 컨트롤러 사용
                        maxLength: 20,
                        focusNode: _focusNode,
                        decoration: InputDecoration(
                          filled: true, // 배경색 활성화
                          fillColor: Colors.grey.shade100, // 배경색 지정
                          hintText: '사용자 이름 입력',
                          hintStyle: TextStyle(
                            color: Colors.grey.shade600, // 힌트 텍스트 색상
                            fontSize: 16,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 16.0,
                            horizontal: 20.0,
                          ), // 패딩 추가
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              width: 2.0,
                              color: Colors.grey.shade400,
                            ),
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              width: 0, // 포커스시 기존 테두리 제거
                              color: Colors.transparent,
                            ),
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          suffixIcon: Icon(
                            Icons.edit,
                            color: Colors.grey.shade600, // 아이콘 추가
                          ),
                        ),
                        style: const TextStyle(
                          color: Colors.black, // 입력 텍스트 색상
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // 저장 버튼
                  GestureDetector(
                    onTap: _updateUserName, // _updateUserName 호출
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // 외곽선 역할의 Container
                        Container(
                          height: screenHeight * 0.068 + 6, // 외곽선 두께만큼 크기 증가
                          width: screenWidth * 0.8 + 6,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF008AB2), Color(0xFFD6FFDE)], // 같은 색으로 시작 및 종료
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(36), // 외곽선 반지름
                          ),
                        ),
                        // 버튼 본체
                        Container(
                          alignment: Alignment.center,
                          height: screenHeight * 0.068,
                          width: screenWidth * 0.8,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF008AB2), Color(0xFFD6FFDE)], // 같은 색으로 시작 및 종료
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(33), // 내부 반지름
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
                      ],
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
