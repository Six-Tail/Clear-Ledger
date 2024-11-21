import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class UserService {

  /// Firestore에 사용자 정보를 저장하는 함수
  Future<void> saveUserToFirestore(
      String uid,
      String? name,
      String? profileImage,
      String accountType,
      ) async {
    final userRef = FirebaseFirestore.instance.collection('users').doc(uid);

    await userRef.set({
      'userName': name ?? '',
      'userImage': profileImage ?? '',
      'accountType': accountType,
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true)); // merge: true 옵션 추가

    if (kDebugMode) {
      print("사용자 정보가 Firestore에 저장되었습니다.");
    }
  }
}
