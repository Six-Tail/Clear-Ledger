import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';

class AddTransactionWidget extends StatelessWidget {
  final VoidCallback onAddTransaction;

  const AddTransactionWidget({
    super.key,
    required this.onAddTransaction,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onAddTransaction,
      child: Container(
        height: 140,
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: DottedBorder(
          borderType: BorderType.RRect,
          radius: const Radius.circular(12),
          padding: const EdgeInsets.all(16),
          strokeWidth: 2,
          color: const Color(0xFF008AB2),
          dashPattern: const [8, 4],
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 동그라미 안에 '+' 아이콘
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,  // 배경 색상
                    border: Border.all(
                      color: const Color(0xFF008AB2),
                      width: 1,
                    )
                  ),
                  child: const Center(
                    child: Text(
                      '+',
                      style: TextStyle(
                        fontSize: 32,
                        color: Color(0xFF008AB2),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '새 거래 내역을 추가하세요',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF008AB2),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
