import 'package:firebase_auth/firebase_auth.dart';  // firebase_auth 임포트 추가
import 'package:cloud_firestore/cloud_firestore.dart'; // cloud_firestore 임포트
import 'package:flutter/foundation.dart';

class UserService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // 사용자 정보 가져오기
  Future<Map<String, dynamic>?> getUserInfo(String uid) async {
    try {
      DocumentSnapshot userDoc =
      await firestore.collection('users').doc(uid).get();
      return userDoc.exists ? userDoc.data() as Map<String, dynamic>? : null;
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching user info: $e");
      }
      return null;
    }
  }

  /// Firestore에 사용자 정보를 저장하는 함수
  Future<void> saveUserToFirestore(
      String uid,
      String? name,
      String? profileImage,
      String accountType,
      ) async {
    final userRef = FirebaseFirestore.instance.collection('users').doc(uid);

    // 현재 로그인한 사용자의 이메일을 가져옵니다
    final email = FirebaseAuth.instance.currentUser?.email; // firebase_auth 패키지 사용

    await userRef.set({
      'userName': name ?? '',
      'userImage': profileImage ?? '',
      'accountType': accountType,
      'email': email ?? '',  // 이메일 값을 저장합니다. 없으면 빈 문자열
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true)); // merge: true 옵션 추가

    if (kDebugMode) {
      print("사용자 정보가 Firestore에 저장되었습니다.");
    }
  }
}
