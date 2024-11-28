import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

// 총 지출 금액을 계산하는 메서드 추가
Future<int> getTotalExpense(DateTime selectedDate) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return 0; // 로그인된 사용자가 없으면 0 반환

  // 선택된 월의 시작일과 마지막일 계산
  final startOfMonth = DateTime(selectedDate.year, selectedDate.month, 1);
  final endOfMonth = DateTime(selectedDate.year, selectedDate.month + 1, 1)
      .subtract(const Duration(days: 1));

  try {
    // Firestore에서 지출 거래만 필터링
    final querySnapshot = await FirebaseFirestore.instance
        .collection('trade')
        .where('userId', isEqualTo: user.uid)
        .where('type', isEqualTo: 'expense')
        .where('date', isGreaterThanOrEqualTo: startOfMonth)
        .where('date', isLessThanOrEqualTo: endOfMonth)
        .get();

    int totalExpense = 0;

    // 문서의 amount 값을 합산
    for (var doc in querySnapshot.docs) {
      final amount = doc['amount'] as int;
      totalExpense += amount;
    }

    return totalExpense;
  } catch (e) {
    if (kDebugMode) {
      print("Error fetching expense data: $e");
    }
    return 0; // 에러 발생 시 0 반환
  }
}

Stream<QuerySnapshot> getTransactions(
    int selectedIndex, DateTime selectedDate) {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    return const Stream.empty();
  }

  // 선택된 달의 시작일과 종료일 계산
  final startOfMonth = DateTime(selectedDate.year, selectedDate.month, 1);
  final endOfMonth = DateTime(selectedDate.year, selectedDate.month + 1, 0);

  if (selectedIndex == 0) {
    return FirebaseFirestore.instance
        .collection('trade')
        .where('userId', isEqualTo: user.uid)
        .where('date', isGreaterThanOrEqualTo: startOfMonth)
        .where('date', isLessThanOrEqualTo: endOfMonth)
        .orderBy('date', descending: true)
        .orderBy('createdAt', descending: true)
        .snapshots();
  } else if (selectedIndex == 1) {
    return FirebaseFirestore.instance
        .collection('trade')
        .where('userId', isEqualTo: user.uid)
        .where('type', isEqualTo: 'income')
        .where('date', isGreaterThanOrEqualTo: startOfMonth)
        .where('date', isLessThanOrEqualTo: endOfMonth)
        .orderBy('date', descending: true)
        .orderBy('createdAt', descending: true)
        .snapshots();
  } else {
    return FirebaseFirestore.instance
        .collection('trade')
        .where('userId', isEqualTo: user.uid)
        .where('type', isEqualTo: 'expense')
        .where('date', isGreaterThanOrEqualTo: startOfMonth)
        .where('date', isLessThanOrEqualTo: endOfMonth)
        .orderBy('date', descending: true)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }
}
