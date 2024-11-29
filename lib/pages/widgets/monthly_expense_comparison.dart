import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/transactions_service.dart';

class MonthlyExpenseComparison extends StatelessWidget {
  final String previousMonthExpenseLabel;
  final String presentMonthExpenseLabel;
  final DateTime selectedDate;

  const MonthlyExpenseComparison({
    super.key,
    required this.previousMonthExpenseLabel,
    required this.presentMonthExpenseLabel,
    required this.selectedDate,
  });

  Future<int> getPreviousMonthTotalExpense() async {
    final previousMonth = DateTime(selectedDate.year, selectedDate.month - 1, 1);
    return await getTotalExpense(previousMonth);
  }

  Future<int> getCurrentMonthTotalExpense() async {
    return await getTotalExpense(selectedDate);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          const Row(
            children: [
              Text(
                '지출 비교',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // 구분선
          Container(
            width: double.infinity,
            height: 1,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 20),
          // 카드 시작
          Card(
            color: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // 지난달 지출과 이번달 지출을 가로로 배치
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    // 가로로 균등하게 배치
                    children: [
                      // 지난달 지출
                      _buildExpenseBox(
                        label: previousMonthExpenseLabel,
                        future: getPreviousMonthTotalExpense(),
                        color: const Color(0xFF008AB2),
                      ),
                      // 'VS' 텍스트 추가
                      const Padding(
                        padding: EdgeInsets.only(top: 22.0),
                        child: Text(
                          'VS',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      // 이번달 지출
                      _buildExpenseBox(
                        label: presentMonthExpenseLabel,
                        future: getCurrentMonthTotalExpense(),
                        color: const Color(0xFF3E00B2),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // 그래프와 비교 텍스트
                  FutureBuilder<int>(
                    future: getCurrentMonthTotalExpense(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text("Error: ${snapshot.error}");
                      } else if (snapshot.hasData) {
                        int currentMonthExpense = snapshot.data ?? 0;
                        return FutureBuilder<int>(
                          future: getPreviousMonthTotalExpense(),
                          builder: (context, previousMonthSnapshot) {
                            if (previousMonthSnapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const CircularProgressIndicator();
                            } else if (previousMonthSnapshot.hasError) {
                              return Text(
                                  "Error: ${previousMonthSnapshot.error}");
                            } else if (previousMonthSnapshot.hasData) {
                              int previousMonthExpense =
                                  previousMonthSnapshot.data ?? 0;

                              int totalExpense =
                                  previousMonthExpense + currentMonthExpense;
                              double previousMonthRatio = totalExpense == 0
                                  ? 0
                                  : (previousMonthExpense / totalExpense)
                                      .clamp(0.0, 1.0);
                              double currentMonthRatio = totalExpense == 0
                                  ? 0
                                  : (currentMonthExpense / totalExpense)
                                      .clamp(0.0, 1.0);

                              Widget comparisonText;
                              if (previousMonthExpense > 0) {
                                double percentageChange =
                                    ((currentMonthExpense -
                                                previousMonthExpense) /
                                            previousMonthExpense *
                                            100)
                                        .roundToDouble();

                                if (percentageChange > 0) {
                                  comparisonText = _buildComparisonText(
                                    label: '저번 달 대비 지출이 ',
                                    value: '$percentageChange% 증가',
                                    valueColor: const Color(0xFFD90021),
                                  );
                                } else if (percentageChange < 0) {
                                  comparisonText = _buildComparisonText(
                                    label: '저번 달 대비 지출이 ',
                                    value: '${percentageChange.abs()}% 감소',
                                    valueColor: const Color(0xFF0F00D9),
                                  );
                                } else {
                                  comparisonText = const Text(
                                    '저번 달과 지출이 동일합니다.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  );
                                }
                              } else {
                                comparisonText = const Text(
                                  '저번 달 지출 데이터가 없습니다.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                );
                              }

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  _buildComparisonGraph(
                                    previousRatio: previousMonthRatio,
                                    currentRatio: currentMonthRatio,
                                    context: context,
                                  ),
                                  const SizedBox(height: 16),
                                  comparisonText,
                                ],
                              );
                            } else {
                              return const Text('지출 데이터가 없습니다.');
                            }
                          },
                        );
                      } else {
                        return const Text(
                          '지출 데이터가 없습니다.',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          textAlign: TextAlign.center,
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseBox({
    required String label,
    required Future<int> future,
    required Color color,
  }) {
    final formatter = NumberFormat('#,###'); // 숫자를 천단위로 포맷팅

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black54,
          ),
        ),
        FutureBuilder<int>(
          future: future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasError) {
              return Text("Error: ${snapshot.error}");
            } else {
              int expense = snapshot.data ?? 0;
              String formattedExpense = formatter.format(expense);

              // 숫자 길이에 따라 폰트 크기 조정
              double fontSize = 20; // 기본 폰트 크기
              if (formattedExpense.length > 10) {
                fontSize = 14;
              } else if (formattedExpense.length > 7) {
                fontSize = 16;
              }

              return Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                padding: const EdgeInsets.all(12),
                height: 60, // 고정된 높이 설정
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center( // 텍스트를 박스 중앙에 배치
                  child: Text(
                    '₩$formattedExpense', // 숫자 포맷팅 적용
                    style: TextStyle(
                      fontSize: fontSize,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildComparisonGraph({
    required BuildContext context,
    required double previousRatio,
    required double currentRatio,
  }) {
    return Container(
      height: 24,
      width: double.infinity, // 부모의 가로 크기에 맞게 확장
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12), // 전체적인 둥근 모서리
        color: Colors.grey[300],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12), // 전체적으로 둥글게
        child: Row(
          children: [
            // 왼쪽 부분
            Expanded(
              flex: (previousRatio * 100).toInt(), // 비율에 따라 크기 비례
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF008AB2), Color(0xFF00D4FF)],
                  ),
                ),
              ),
            ),
            // 오른쪽 부분
            Expanded(
              flex: (currentRatio * 100).toInt(), // 비율에 따라 크기 비례
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF3E00B2), Color(0xFF8A2BE2)],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonText({
    required String label,
    required String value,
    required Color valueColor,
  }) {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        text: label,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
        children: [
          TextSpan(
            text: value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
          const TextSpan(
            text: '하였습니다.',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
