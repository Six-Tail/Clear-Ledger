import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Stream<QuerySnapshot> getTransactions(int selectedIndex, DateTime selectedDate) {
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
