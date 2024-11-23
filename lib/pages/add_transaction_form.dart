import 'package:clear_ledger/pages/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AddTransactionForm extends StatefulWidget {
  final VoidCallback onCloseTransaction;

  const AddTransactionForm({super.key, required this.onCloseTransaction});

  @override
  State<AddTransactionForm> createState() => _AddTransactionFormState();
}

class _AddTransactionFormState extends State<AddTransactionForm> {
  String? selectedTransactionType;
  final TextEditingController contentController = TextEditingController();
  final TextEditingController yearController = TextEditingController();
  final TextEditingController monthController = TextEditingController();
  final TextEditingController dayController = TextEditingController();
  final TextEditingController amountController = TextEditingController();

  // 윤년 체크 함수
  bool isLeapYear(int year) {
    return (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
  }

  // 각 월별 최대 일 수 (윤년을 고려하여 2월도 처리)
  int getMaxDays(int month, int year) {
    switch (month) {
      case 2:
        return isLeapYear(year) ? 29 : 28;  // 2월은 윤년에 따라 다름
      case 4:
      case 6:
      case 9:
      case 11:
        return 30;  // 30일이 있는 달
      default:
        return 31;  // 31일이 있는 달
    }
  }

  // 유효성 검사 함수
  bool get isFormValid {
    int year = int.tryParse(yearController.text) ?? 0;
    int month = int.tryParse(monthController.text) ?? 0;
    int day = int.tryParse(dayController.text) ?? 0;

    return yearController.text.length == 4 &&
        monthController.text.length == 2 &&
        dayController.text.length == 2 &&
        contentController.text.isNotEmpty &&
        amountController.text.isNotEmpty &&
        selectedTransactionType != null &&
        month >= 1 && month <= 12 &&
        day >= 1 && day <= getMaxDays(month, year);
  }

  @override
  void initState() {
    super.initState();

    // 각 텍스트 필드에 리스너 추가
    yearController.addListener(_validateForm);
    monthController.addListener(_validateForm);
    dayController.addListener(_validateForm);
    contentController.addListener(_validateForm);
    amountController.addListener(_validateForm);
  }

  void _validateForm() {
    setState(() {}); // 값이 변경될 때마다 상태를 다시 빌드하여 유효성 검사 결과를 반영
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 610,
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '새로운 거래',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: 340,
            height: 1,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 10),
          const Text(
            '날짜',
            style: TextStyle(
              fontSize: 16,
              fontFamily: 'Hana2Bold',
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: CustomTextField(
                  controller: yearController,
                  hintText: '2000',
                  maxLength: 4,
                ),
              ),
              const SizedBox(width: 10),
              Flexible(
                child: CustomTextField(
                  controller: monthController,
                  hintText: '01',
                  maxLength: 2,
                ),
              ),
              const SizedBox(width: 10),
              Flexible(
                child: CustomTextField(
                  controller: dayController,
                  hintText: '01',
                  maxLength: 2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            '내용',
            style: TextStyle(
              fontSize: 16,
              fontFamily: 'Hana2Bold',
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      selectedTransactionType = 'income';
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: selectedTransactionType == 'income'
                        ? const Color(0xFF39A063)
                        : Colors.white,
                    foregroundColor: selectedTransactionType == 'income'
                        ? Colors.white
                        : Colors.black,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      side: BorderSide(
                        color: selectedTransactionType == 'income'
                            ? const Color(0xFF39A063)
                            : Colors.grey,
                        width: 1.0,
                      ),
                    ),
                  ),
                  child: const Text(
                    '들어온 돈',
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Hana2Medium',
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      selectedTransactionType = 'expense';
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: selectedTransactionType == 'expense'
                        ? Colors.red
                        : Colors.white,
                    foregroundColor: selectedTransactionType == 'expense'
                        ? Colors.white
                        : Colors.black,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      side: BorderSide(
                        color: selectedTransactionType == 'expense'
                            ? Colors.red
                            : Colors.grey,
                        width: 1.0,
                      ),
                    ),
                  ),
                  child: const Text(
                    '나간 돈',
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Hana2Medium',
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Flexible(
                child: TextField(
                  controller: contentController,
                  decoration: InputDecoration(
                    hintText: '내용을 입력하세요(예: 점심식사)',
                    border: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.grey,
                        width: 1.0,
                      ),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.grey,
                        width: 1.0,
                      ),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.grey,
                        width: 1.0,
                      ),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    filled: true,
                    fillColor: Colors.grey[200],
                  ),
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(50),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            '금액',
            style: TextStyle(
              fontSize: 16,
              fontFamily: 'Hana2Bold',
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Flexible(
                child: TextField(
                  keyboardType: TextInputType.number,
                  controller: amountController,
                  decoration: InputDecoration(
                    hintText: '금액을 입력하세요(예: 12000)',
                    border: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.grey,
                        width: 1.0,
                      ),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.grey,
                        width: 1.0,
                      ),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.grey,
                        width: 1.0,
                      ),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    filled: true,
                    fillColor: Colors.grey[200],
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(50),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Align(
            alignment: Alignment.center,
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isFormValid
                    ? () {
                  // 버튼 클릭 시 처리
                }
                    : null,  // 버튼이 비활성화 될 때는 null 처리
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF008AB2),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: const Text(
                  '입력하기',
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Hana2Medium',
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.bottomCenter,
            child: TextButton(
              onPressed: widget.onCloseTransaction,
              child: const Text(
                '닫기',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                  fontFamily: 'Hana2Medium',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    contentController.dispose();
    yearController.dispose();
    monthController.dispose();
    dayController.dispose();
    amountController.dispose();
    super.dispose();
  }
}
