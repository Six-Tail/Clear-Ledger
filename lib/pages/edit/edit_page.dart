import 'package:flutter/material.dart';
import 'editname_page.dart'; // editname_page 추가
import '../../services/user_service.dart';

class EditPage extends StatefulWidget {
  @override
  _EditPageState createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  String _userName = '닉네임 불러오는 중...'; // 초기 닉네임
  final UserService _userService = UserService();

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    String? userName = await _userService.fetchUserName();
    if (userName != null) {
      setState(() {
        _userName = userName; // 사용자 닉네임 설정
      });
    }
  }

  Future<void> _navigateToEditNamePage() async {
    String? updatedName = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditNicknameScreen(currentName: _userName),
      ),
    );

    if (updatedName != null) {
      setState(() {
        _userName = updatedName; // 업데이트된 닉네임 설정
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('닉네임이 업데이트되었습니다: $updatedName')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('정보 수정'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: _navigateToEditNamePage, // 터치 시 이름 수정 페이지로 이동
              child: Row(
                children: [
                  const Text(
                    '이름: ',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    _userName,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.blue,
                      decoration: TextDecoration.underline, // 밑줄 추가
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
