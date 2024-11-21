import 'package:clear_ledger/services/user_service.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:clear_ledger/pages/login_page.dart';
import 'package:flutter/material.dart';

// 로그아웃 처리 클래스
class Logout {
  Future<void> signOut() async {
    bool logoutSuccessful = true;
    final UserService userService = UserService();
    final firebaseUser = firebase_auth.FirebaseAuth.instance.currentUser;

    if (firebaseUser != null) {
      try {
        // 현재 로그인한 사용자 정보 가져오기
        Map<String, dynamic>? userInfo = await userService.getUserInfo(firebaseUser.uid);

        if (userInfo?['accountType'] != null) {
          String accountType = userInfo?['accountType'];

          // accountType에 따라 다르게 처리
          if (accountType == 'Google 계정') {
            try {
              // Google 계정 로그아웃 시도
              await firebase_auth.FirebaseAuth.instance.signOut();
              if (kDebugMode) {
                print('Google 계정 로그아웃');
              }
            } catch (error) {
              if (kDebugMode) {
                print('Google 계정 로그아웃 실패 $error');
              }
              logoutSuccessful = false;
            }
          } else if (accountType == 'GitHub 계정') {
            try {
              // GitHub 계정 로그아웃 시도
              await firebase_auth.FirebaseAuth.instance.signOut();
              if (kDebugMode) {
                print('GitHub 계정 로그아웃');
              }
            } catch (error) {
              if (kDebugMode) {
                print('GitHub 계정 로그아웃 실패 $error');
              }
              logoutSuccessful = false;
            }
          } else {
            try {
              // 기타 계정 타입 로그아웃 시도
              await firebase_auth.FirebaseAuth.instance.signOut();
              if (kDebugMode) {
                print('ClearLedger 계정 로그아웃');
              }
            } catch (error) {
              if (kDebugMode) {
                print('ClearLedger 계정 로그아웃 실패 $error');
              }
              logoutSuccessful = false;
            }
          }
        }
      } catch (error) {
        if (kDebugMode) {
          print('사용자 정보 가져오기 실패 $error');
        }
        logoutSuccessful = false;
      }
    } else {
      if (kDebugMode) {
        print('현재 로그인된 사용자가 없습니다.');
      }
      logoutSuccessful = false;
    }

    // SharedPreferences에 로그인 상태 저장
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);

    if (logoutSuccessful) {
      Get.offAll(() => const LoginPage());
    }
  }

  // 로그아웃 확인 다이얼로그
  void showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text('로그아웃'),
          content: const Text('로그아웃 하시겠습니까?'),
          actions: [
            TextButton(
              child: const Text('예', style: TextStyle(color: Colors.red)),
              onPressed: () async {
                Navigator.of(context).pop(); // 다이얼로그 닫기
                await signOut(); // 로그아웃 함수 호출
              },
            ),
            TextButton(
              child: const Text('아니오', style: TextStyle(color: Colors.black)),
              onPressed: () {
                Navigator.of(context).pop(); // 다이얼로그 닫기
              },
            ),
          ],
        );
      },
    );
  }
}

// ListTile(
//  title: const Text('로그아웃'),
//  trailing: const Icon(Icons.chevron_right),
//  leading: const Icon(Icons.logout),
//  onTap: () {
//    // Logout을 사용하여 로그아웃 다이얼로그 표시
//    Logout logout = Logout();
//    logout.showLogoutDialog(context);
//  },
// ),
