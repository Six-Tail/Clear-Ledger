import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:clear_ledger/services/user_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';

import '../main_page.dart'; // Get 패키지 import

// 로그인 상태를 저장하는 함수
Future<void> saveLoginState() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('isLoggedIn', true);
}

// 구글 로그인 함수
Future<void> signInWithGoogle() async {
  try {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;
    if (googleAuth == null) {
      return;
    }
    final credential = firebase_auth.GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    await firebase_auth.FirebaseAuth.instance.signInWithCredential(credential);
    await saveLoginState();

    final firebase_auth.User? user = firebase_auth.FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userService = UserService();
      await userService.saveUserToFirestore(
        user.uid,
        user.displayName,
        user.photoURL,
        "Google 계정",
      );
    }
    navigatorToMainPage();  // 로그인 후 메인 페이지로 이동
  } catch (error) {
    if (kDebugMode) {
      print('Google 로그인 실패 $error');
    }
  }
}

// GitHub 로그인 함수
Future<void> signInWithGitHub() async {
  try {
    final FirebaseAuth auth = FirebaseAuth.instance;
    UserCredential userCredential;
    GithubAuthProvider githubProvider = GithubAuthProvider();

    if (kIsWeb) {
      userCredential = await auth.signInWithPopup(githubProvider);
    } else {
      userCredential = await auth.signInWithProvider(githubProvider);
    }

    final User? user = userCredential.user;
    if (user != null) {
      final userService = UserService();
      await userService.saveUserToFirestore(
        user.uid,
        user.displayName,
        user.photoURL,
        "GitHub 계정",
      );
    }

    await saveLoginState();
    navigatorToMainPage();  // 로그인 후 메인 페이지로 이동
  } catch (error) {
    if (kDebugMode) {
      print('GitHub 로그인 실패: $error');
    }
  }
}
// 로그인 성공 후 메인 페이지로 이동
void navigatorToMainPage() {
  Get.off(() => const MainPage());  // Get.off()을 사용하여 메인 페이지로 이동
}
