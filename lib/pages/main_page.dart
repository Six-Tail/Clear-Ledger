import 'package:clear_ledger/pages/widgets/add_transaction_widget.dart';
import 'package:clear_ledger/pages/widgets/monthly_expense_comparison.dart';
import 'package:clear_ledger/pages/widgets/transactions_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

import '../services/user_service.dart';
import 'package:clear_ledger/pages/widgets/income_expense_box.dart';
import 'package:clear_ledger/pages/utils/logout.dart';
import 'package:clear_ledger/pages/widgets/menu_widget.dart';

import 'add_transaction_form.dart';
import 'edit/edit_page.dart'; // MenuWidget을 import합니다.

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  MainPageState createState() => MainPageState();
}

class MainPageState extends State<MainPage> {
  final UserService _userService = UserService();
  final ScrollController _scrollController = ScrollController();

  int asset = 0;
  int incomingAmount = 0; // 들어온 돈
  int outcomingAmount = 0; // 나간 돈
  int selectedIndex = 0;

  bool _isAddingTransaction = false;

  String userName = '';
  String selectedMonth =
      DateFormat('yyyy년 MM월').format(DateTime.now()); // 현재 년도와 월
  DateTime selectedDate = DateTime.now(); // 현재 날짜를 기본값으로 설정

  // 현재 년도와 월을 가져오는 코드
  String getFormattedDate(DateTime date) {
    return DateFormat('yyyy년 MM월').format(date);
  }

  // 년도와 월만 선택하는 함수 (CupertinoDatePicker 사용)
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showModalBottomSheet<DateTime>(
      context: context,
      builder: (BuildContext context) {
        return SizedBox(
          height: 250,
          child: CupertinoDatePicker(
            mode: CupertinoDatePickerMode.monthYear,
            initialDateTime: selectedDate, // 선택된 날짜 전달
            onDateTimeChanged: (DateTime newDate) {
              setState(() {
                selectedDate = DateTime(newDate.year, newDate.month, 1); // 1일로 설정
                selectedMonth = getFormattedDate(selectedDate); // 월 및 년도 포맷
                // 날짜 선택 후 자산 값을 업데이트
                _updateAmounts();
                // Firebase에 자산 값 업데이트
                _userService.updateUserAssetValue(incomingAmount, outcomingAmount);
              });
            },
            minimumDate: DateTime(2020),
            maximumDate: DateTime(2100),
          ),
        );
      },
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = DateTime(picked.year, picked.month, 1);
        selectedMonth = getFormattedDate(selectedDate);
      });
    }
  }

  String getPreviousMonthLabel() {
    final previousMonthDate = DateTime(selectedDate.year, selectedDate.month - 1, 1);
    return DateFormat('yyyy년 MM월 지출').format(previousMonthDate);
  }

  String getPresentMonthLabel() {
    final presentMonthDate = DateTime(selectedDate.year, selectedDate.month, 1);
    return DateFormat('yyyy년 MM월 지출').format(presentMonthDate);
  }

  Future<void> _updateAmounts() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // 선택한 달의 시작일과 마지막 일을 계산
    final startOfMonth = DateTime(selectedDate.year, selectedDate.month, 1);
    final endOfMonth = DateTime(selectedDate.year, selectedDate.month + 1, 1)
        .subtract(const Duration(days: 1));

    try {
      final transactionsSnapshot = await FirebaseFirestore.instance
          .collection('trade')
          .where('userId', isEqualTo: user.uid)
          .where('date', isGreaterThanOrEqualTo: startOfMonth)
          .where('date', isLessThanOrEqualTo: endOfMonth)
          .get();

      int incomeSum = 0;
      int expenseSum = 0;

      if (transactionsSnapshot.docs.isEmpty) {
        if (kDebugMode) {
          print("No transactions found for the selected date range.");
        }
      }

      for (var doc in transactionsSnapshot.docs) {
        final type = doc['type'];
        final amount = doc['amount'] as int;

        if (type == 'income') {
          incomeSum += amount;
        } else if (type == 'expense') {
          expenseSum += amount;
        }
      }

      // 자산 값 갱신 및 화면 새로 고침
      setState(() {
        incomingAmount = incomeSum; // 수입 금액 업데이트
        outcomingAmount = expenseSum; // 지출 금액 업데이트
        asset = incomingAmount - outcomingAmount; // 자산 계산
      });

      if (kDebugMode) {
        print('수입 금액: $incomingAmount');
        print('지출 금액: $outcomingAmount');
        print('현재 자산: $asset');
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error while fetching transactions: $e");
      }
    }
  }

  void _addTransaction() {
    setState(() {
      _isAddingTransaction = true; // 새로운 거래 창 열기
    });

    // 렌더링 후 스크롤을 아래로 이동시키기 위해 addPostFrameCallback 사용
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 화면 렌더링 후 스크롤을 끝으로 이동
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollToBottom(); // _scrollToBottom() 함수 호출
      });
    });
  }

  void _closeTransaction() {
    setState(() {
      _isAddingTransaction = false; // 새로운 거래 창 닫기
    });

    // 렌더링 후 스크롤을 맨 위로 이동시키기 위해 addPostFrameCallback 사용
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 화면 렌더링 후 스크롤을 끝으로 이동
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          // ScrollController 연결된 경우에만
          _scrollToTop();
        }
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _initializeUserData();
  }

  Future<void> _initializeUserData() async {
    String? fetchedName = await _userService.fetchUserName();
    int? fetchedAssetValue = await _userService.fetchUserAssetValue();

    if (mounted) {
      // 위젯이 여전히 트리에 있을 때만 setState 호출
      setState(() {
        userName = fetchedName ?? '';
        asset = fetchedAssetValue ?? 0;
      });

      // 자산 계산 (incomingAmount - outcomingAmount)
      int newAssetValue = incomingAmount - outcomingAmount;
      if (mounted) {
        setState(() {
          asset = newAssetValue;
        });
      }

      // 업데이트된 수입과 지출 금액을 계산하기
      await _updateAmounts();
      // Firebase에 자산 값 업데이트
      await _userService.updateUserAssetValue(incomingAmount, outcomingAmount);
    }
  }

  String formatAssetValue(int value) {
    final formatter = NumberFormat('#,###');
    return formatter.format(value);
  }

  // 메뉴 항목 선택 시 인덱스를 업데이트 하는 함수
  void _onMenuItemSelected(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  // 거래 추가 후 자산 갱신
  Future<void> _updateAssetAfterTransaction() async {
    await _updateAmounts();
    // Firebase에 자산 값 업데이트
    await _userService.updateUserAssetValue(incomingAmount, outcomingAmount);

    // 자산 갱신 후 스크롤을 맨 위로 이동
    _scrollToTop();
  }

// 스크롤을 맨 위로 이동시키는 함수
  void _scrollToTop() {
    _scrollController.animateTo(
      0.0, // 화면의 맨 위로 이동
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent, // 화면의 맨 아래로 이동
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Widget _buildMenuContent() {
    return TransactionsWidget(
      selectedIndex: selectedIndex,
      updateAmounts: _updateAmounts,
      selectedDate: selectedDate, // 업데이트 함수 전달
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          scrolledUnderElevation: 0,
          title: GestureDetector(
            onTap: () => _selectDate(context), // 앱바의 날짜를 탭하면 선택 가능
            child: Text(
              selectedMonth, // 선택된 년도와 월
              style: const TextStyle(fontSize: 20, fontFamily: 'Hana2Medium'),
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          actions: [
            Theme(
              data: Theme.of(context).copyWith(
                popupMenuTheme: const PopupMenuThemeData(
                  color: Colors.white, // 팝업 메뉴 배경색 하얀색으로 설정
                ),
              ),
              child: PopupMenuButton(
                icon: const Icon(
                  FontAwesomeIcons.bars,
                  color: Colors.grey,
                ),
                onSelected: (value) async {
                  if (value == 'edit') {
                    final updatedName = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const EditPage()),
                    );
                    // 수정된 닉네임이 반환되었을 때만 업데이트
                    if (updatedName != null && updatedName is String) {
                      setState(() {
                        userName = updatedName;
                      });
                    }
                  } else if (value == 'logout') {
                    Logout logout = Logout();
                    logout.showLogoutDialog(context);
                  }
                },
                itemBuilder: (BuildContext context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Text('정보 수정'),
                  ),
                  const PopupMenuItem(
                    value: 'logout',
                    child: Text('로그아웃'),
                  ),
                ],
              ),
            )
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1.0),
            child: Container(
              color: Colors.grey[300],
              height: 1.0,
            ),
          ),
        ),
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          controller: _scrollController,
          // ScrollController를 SingleChildScrollView에 연결
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                Image.asset(
                  'assets/images/login_logo.png',
                  width: 120,
                  height: 120,
                ),
                const SizedBox(height: 20),
                // Text 위젯 수정
                Text(
                  userName.isNotEmpty
                      ? '안녕하세요, $userName님!\n$selectedMonth 간의 거래 내역을\n확인해보세요.'
                      : '사용자 정보를 가져오는 중입니다...',
                  textAlign: TextAlign.center,
                  style:
                      const TextStyle(fontSize: 18, fontFamily: 'Hana2Regular'),
                ),
                const SizedBox(height: 20),
                // 애니메이션 적용된 자산 값 출력
                TweenAnimationBuilder<int>(
                  tween: IntTween(begin: 0, end: asset), // 0에서 asset 값까지 변동
                  duration: const Duration(seconds: 3), // 애니메이션 지속 시간
                  builder: (context, value, child) {
                    return Text(
                      '₩${formatAssetValue(value)}',
                      style: const TextStyle(
                        color: Color(0xFF008AB2),
                        fontSize: 34,
                        fontFamily: 'Hana2Medium',
                      ),
                    );
                  },
                ),
                const SizedBox(height: 30),
                IncomeExpenseBox(
                  incomingAmount: incomingAmount,
                  outcomingAmount: outcomingAmount,
                ),
                const SizedBox(height: 30),
                const Divider(
                    height: 2, thickness: 10, color: Color(0xFFD3D4D7)),
                MonthlyExpenseComparison(
                  previousMonthExpenseLabel: getPreviousMonthLabel(),
                  presentMonthExpenseLabel: getPresentMonthLabel(),
                  selectedDate: selectedDate,
                ),
                const SizedBox(height: 10),
                const Divider(
                    height: 2, thickness: 10, color: Color(0xFFD3D4D7)),
                const SizedBox(height: 20),
                // 메뉴 항목들 및 밑줄 추가
                MenuWidget(
                  selectedIndex: selectedIndex,
                  onMenuItemSelected: _onMenuItemSelected,
                ),
                const SizedBox(height: 10),
                Container(
                  width: 340,
                  height: 1,
                  color: Colors.grey[300], // 밑줄 색상 설정
                ),
                const SizedBox(height: 20),
                // 메뉴 선택에 따른 내용 출력
                _buildMenuContent(),
                const SizedBox(height: 20),
                AddTransactionWidget(
                  onAddTransaction: () async {
                    // 거래 추가 창 열기
                    _addTransaction();
                  },
                ),
                const SizedBox(height: 40),
                const Divider(
                    height: 2, thickness: 10, color: Color(0xFFD3D4D7)),
                // 새로운 거래 창을 _isAddingTransaction이 true일 때만 표시
                if (_isAddingTransaction)
                  AddTransactionForm(
                    onCloseTransaction: _closeTransaction,
                    onTransactionAdded:
                        _updateAssetAfterTransaction, // 거래 추가 후 자산 갱신
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
