import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/user_service.dart';

class EditPage extends StatefulWidget {
  @override
  _EditPageState createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  final TextEditingController _nameController = TextEditingController();
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
        _nameController.text = userName; // 사용자 이름을 텍스트 필드에 설정
      });
    }
  }

  Future<void> _saveUserName() async {
    String newName = _nameController.text;
    User? user = _userService.auth.currentUser;
    if (user != null) {
      await _userService.saveUserToFirestore(
        user.uid,
        newName,
        null,
        null,
        'user', // 임의의 accountType 값
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('이름이 성공적으로 저장되었습니다.')),
      );
      Navigator.pop(context); // 수정 후 이전 화면으로 돌아가기
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('정보 수정'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: '이름 수정'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveUserName,
              child: Text('저장하기'),
            ),
          ],
        ),
      ),
    );
  }
}
