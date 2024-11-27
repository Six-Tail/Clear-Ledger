import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class IncomeExpenseBox extends StatefulWidget {
  final int incomingAmount; // 들어온 돈
  final int outcomingAmount; // 나간 돈

  const IncomeExpenseBox({
    super.key,
    required this.incomingAmount,
    required this.outcomingAmount,
  });

  @override
  IncomeExpenseBoxState createState() => IncomeExpenseBoxState();
}

class IncomeExpenseBoxState extends State<IncomeExpenseBox> {
  // 숫자를 포맷팅하는 메서드
  String formatAssetValue(int value) {
    final formatter = NumberFormat('#,###');
    return formatter.format(value);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 120,
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey, width: 1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          // 들어온 돈
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center, // 텍스트를 가운데 정렬
              children: [
                const Text(
                  '들어온 돈',
                  style: TextStyle(fontSize: 18, fontFamily: 'Hana2Medium'),
                ),
                Text(
                  formatAssetValue(widget.incomingAmount), // widget을 통해 값을 사용
                  style: const TextStyle(
                    fontSize: 18,
                    color: Color(0xFF39A063),
                    fontFamily: 'Hana2Medium',
                  ),
                ),
              ],
            ),
          ),
          // 경계선
          const SizedBox(
            height: 60, // 원하는 높이를 설정
            child: VerticalDivider(
              thickness: 1,
              color: Color(0xFFE4E4E4),
            ),
          ),
          // 나간 돈
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center, // 텍스트를 가운데 정렬
              children: [
                const Text(
                  '나간 돈',
                  style: TextStyle(fontSize: 18, fontFamily: 'Hana2Medium'),
                ),
                Text(
                  '-${formatAssetValue(widget.outcomingAmount)}', // widget을 통해 값을 사용
                  style: const TextStyle(
                    fontSize: 18,
                    color: Color(0xFFD90021),
                    fontFamily: 'Hana2Medium',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
