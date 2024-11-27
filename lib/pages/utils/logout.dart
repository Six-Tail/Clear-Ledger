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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          backgroundColor: Colors.white,
          contentPadding: const EdgeInsets.all(20.0),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.logout_rounded,
                size: 50.0,
                color: Color(0xFFD90021),
              ),
              const SizedBox(height: 20.0),
              const Text(
                '로그아웃',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 10.0),
              Text(
                '로그아웃 하시겠습니까?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text(
                '아니오',
                style: TextStyle(
                  color: Color(0xFF39A063),
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop(); // 다이얼로그 닫기
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  vertical: 10.0,
                  horizontal: 20.0,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              onPressed: () async {
                Navigator.of(context).pop(); // 다이얼로그 닫기
                await signOut(); // 로그아웃 함수 호출
              },
              child: const Text(
                '예',
                style: TextStyle(
                  color: Color(0xFFD90021),
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

}
