import 'package:clear_ledger/pages/utils/logout.dart';
import 'package:flutter/material.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                '로그인 성공!',
                style: TextStyle(fontSize: 24),
              ),
              const SizedBox(height: 20), // 간격 추가
              ListTile(
                title: const Text('로그아웃'),
                trailing: const Icon(Icons.chevron_right),
                leading: const Icon(Icons.logout),
                onTap: () {
                  // Logout을 사용하여 로그아웃 다이얼로그 표시
                  Logout logout = Logout();
                  logout.showLogoutDialog(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
