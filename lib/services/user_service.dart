import 'package:firebase_auth/firebase_auth.dart'; // firebase_auth 임포트 추가
import 'package:cloud_firestore/cloud_firestore.dart'; // cloud_firestore 임포트
import 'package:flutter/foundation.dart';

class UserService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  // 사용자 정보를 Firestore에 저장하는 함수
  Future<void> saveUserToFirestoreIfNew(String userId, String? displayName, String? photoURL, String? email, String accountType) async {
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();

    // 만약 사용자 정보가 존재하지 않으면 새로 저장
    if (!userDoc.exists) {
      await FirebaseFirestore.instance.collection('users').doc(userId).set({
        'userName': displayName ?? 'Anonymous',
        'email': email,
        'userImage': photoURL ?? 'https://www.default_profile_image.com',
        'asset': 0,
        'accountType': accountType,
      });
    }
  }

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

  Future<void> updateUserInfo(String uid, {required String userName}) async {
    try {
      // Firestore의 users 컬렉션에서 사용자 UID에 해당하는 문서 업데이트
      await firestore.collection('users').doc(uid).update({
        'userName': userName, // userName 필드를 업데이트
        'updatedAt': FieldValue.serverTimestamp(), // 마지막 업데이트 시간 기록
      });
      if (kDebugMode) {
        print("사용자 이름이 업데이트되었습니다: $userName");
      }
    } catch (e) {
      if (kDebugMode) {
        print("사용자 정보 업데이트 중 오류 발생: $e");
      }
    }
  }

  Future<void> saveUserToFirestore(String uid,
      String? name,
      String? profileImage,
      String? email,
      String accountType,) async {
    final userRef = FirebaseFirestore.instance.collection('users').doc(uid);

    // Firestore에서 현재 asset 값을 가져옴
    final docSnapshot = await userRef.get();
    int currentAssetValue = docSnapshot.exists && docSnapshot.data() != null
        ? (docSnapshot.data()!['asset'] ?? 0) as int
        : 0;

    // Firestore에 데이터 저장
    await userRef.set({
      'userName': name ?? '',
      'userImage': profileImage ?? '',
      'accountType': accountType,
      'email': email ?? '', // 이메일 값을 저장합니다. 없으면 빈 문자열
      'createdAt': FieldValue.serverTimestamp(),
      'asset': currentAssetValue, // 기존 값을 유지
    }, SetOptions(merge: true)); // merge: true 옵션으로 기존 데이터 병합

    if (kDebugMode) {
      print("사용자 정보가 Firestore에 저장되었습니다.");
    }
  }

  // Firestore에서 사용자 자산 값을 업데이트하는 메서드
  Future<void> updateUserAssetValue(int incomingAmount,
      int outcomingAmount) async {
    try {
      User? user = auth.currentUser; // 현재 로그인한 사용자 가져오기
      if (user != null) {
        DocumentSnapshot userDoc = await firestore
            .collection('users') // Firestore의 user 컬렉션
            .doc(user.uid) // 현재 사용자의 UID로 문서 조회
            .get();
        if (userDoc.exists) {
          // 새 자산 값 계산 (들어온 돈 - 나간 돈)
          int newAssetValue = incomingAmount - outcomingAmount;

          // Firestore에 자산 값 업데이트
          await firestore.collection('users').doc(user.uid).update({
            'asset': newAssetValue,
          });

          if (kDebugMode) {
            print("User asset updated: $newAssetValue");
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error updating user asset value: $e");
      }
    }
  }

  // 사용자 이름을 Firestore에서 가져오는 함수
  Future<String?> fetchUserName() async {
    try {
      User? user = auth.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc =
        await firestore.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          return userDoc['userName'] as String;
        }
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching user name: $e");
      }
      return null;
    }
  }

  // 사용자 자산 값을 Firestore에서 가져오는 함수
  Future<int?> fetchUserAssetValue() async {
    try {
      User? user = auth.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc =
        await firestore.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          return userDoc['asset'] as int;
        }
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching user asset: $e");
      }
      return null;
    }
  }
}
