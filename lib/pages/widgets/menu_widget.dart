import 'package:flutter/material.dart';

class MenuWidget extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onMenuItemSelected;

  const MenuWidget({
    super.key,
    required this.selectedIndex,
    required this.onMenuItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start, // 메뉴 왼쪽 정렬
      children: [
        const SizedBox(width: 20), // 왼쪽 여백 추가
        GestureDetector(
          onTap: () => onMenuItemSelected(0),
          child: Text(
            '전체 내역',
            style: TextStyle(
              fontSize: 18,
              color: selectedIndex == 0 ? Colors.black : Colors.grey,
              fontWeight: selectedIndex == 0 ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
        GestureDetector(
          onTap: () => onMenuItemSelected(1),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Text(
              '수입',
              style: TextStyle(
                fontSize: 18,
                color: selectedIndex == 1 ? Colors.black : Colors.grey,
                fontWeight: selectedIndex == 1 ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
        GestureDetector(
          onTap: () => onMenuItemSelected(2),
          child: Text(
            '지출',
            style: TextStyle(
              fontSize: 18,
              color: selectedIndex == 2 ? Colors.black : Colors.grey,
              fontWeight: selectedIndex == 2 ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }
}
