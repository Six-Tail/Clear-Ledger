import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import '../../services/transactions_service.dart';


class TransactionsWidget extends StatelessWidget {
  final int selectedIndex;
  final Future<void> Function() updateAmounts;
  final DateTime selectedDate; // 선택된 월

  const TransactionsWidget({
    super.key,
    required this.selectedIndex,
    required this.updateAmounts,
    required this.selectedDate, // 선택된 월 추가
  });

  String formatAssetValue(int value) {
    final formatter = NumberFormat('#,###');
    return formatter.format(value);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: getTransactions(selectedIndex, selectedDate), // 선택된 달 반영
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(child: Text('오류가 발생했습니다.'));
        }

        final transactions = snapshot.data?.docs ?? [];

        if (transactions.isEmpty) {
          return const Center(child: Text('등록된 거래 내역이 없습니다.'));
        }

        return SingleChildScrollView(
          child: Column(
            children: [
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: transactions.length,
                itemBuilder: (context, index) {
                  final transaction = transactions[index];
                  final transactionId = transaction.id;
                  final date = (transaction['date'] as Timestamp).toDate();
                  final content = transaction['content'];
                  final amount = transaction['amount'];
                  final type = transaction['type'];

                  // 금액 색상 및 부호 설정
                  Color amountColor = type == 'income'
                      ? const Color(0xFF39A063)
                      : const Color(0xFFD90021);
                  String amountPrefix = type == 'income' ? '+' : '-';

                  return Dismissible(
                    key: Key(transactionId),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      color: Colors.white,
                      child: const Icon(
                        Icons.delete,
                        color: Color(0xFFD90021),
                      ),
                    ),
                    confirmDismiss: (direction) async {
                      return await showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          backgroundColor: Colors.white,
                          contentPadding: const EdgeInsets.all(20.0),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.warning_rounded,
                                size: 50.0,
                                color: Color(0xFFD90021),
                              ),
                              const SizedBox(height: 20.0),
                              const Text(
                                '거래 내역 삭제',
                                style: TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 10.0),
                              Text(
                                '이 거래 내역을 정말로 삭제하시겠습니까?',
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
                              onPressed: () => Navigator.of(context).pop(false),
                              style: TextButton.styleFrom(
                                foregroundColor: const Color(0xFF39A063),
                                textStyle: const TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              child: const Text('취소'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              style: TextButton.styleFrom(
                                backgroundColor: const Color(0xFFD90021),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                textStyle: const TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              child: const Text('삭제'),
                            ),
                          ],
                        ),
                      );
                    },
                    onDismissed: (direction) async {
                      await FirebaseFirestore.instance
                          .collection('trade')
                          .doc(transactionId)
                          .delete();
                      await updateAmounts();
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                          vertical: 4.0, horizontal: 22.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10.0),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 4.0,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(10.0),
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              DateFormat('yyyy-MM-dd').format(date),
                              style: const TextStyle(
                                  fontSize: 14.0, color: Colors.grey),
                            ),
                            const SizedBox(height: 2.0),
                            Text(
                              content,
                              style: const TextStyle(
                                  fontSize: 16.0, fontFamily: 'Hana2Bold'),
                            ),
                          ],
                        ),
                        trailing: Text(
                          '$amountPrefix${formatAssetValue(amount)}',
                          style: TextStyle(
                            fontSize: 18.0,
                            fontFamily: 'Hana2Bold',
                            color: amountColor,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
