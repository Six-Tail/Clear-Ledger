import 'package:clear_ledger/pages/widgets/add_transaction_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

import '../services/user_service.dart';
import 'package:clear_ledger/pages/widgets/income_expense_box.dart';
import 'package:clear_ledger/pages/utils/logout.dart';
import 'package:clear_ledger/pages/widgets/menu_widget.dart';

import 'add_transaction_form.dart'; // MenuWidget을 import합니다.

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  MainPageState createState() => MainPageState();
}

class MainPageState extends State<MainPage> {
  String userName = '';
  String selectedMonth = DateFormat('yyyy년 MM월').format(DateTime.now()); // 현재 년도와 월
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
            mode: CupertinoDatePickerMode.date, // 여전히 date 모드를 사용
            initialDateTime: selectedDate,
            onDateTimeChanged: (DateTime newDate) {
              setState(() {
                selectedDate = DateTime(newDate.year, newDate.month, 1); // 일자는 항상 1일로 설정
                selectedMonth = getFormattedDate(selectedDate); // 선택된 월과 년도 업데이트
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
        selectedDate = DateTime(picked.year, picked.month, 1); // 선택된 년도와 월만 반영, 일자는 1일로 설정
        selectedMonth = getFormattedDate(selectedDate); // 선택된 월과 년도 업데이트
      });
    }
  }

  final UserService _userService = UserService();

  int asset = 0;
  int incomingAmount = 0; // 들어온 돈
  int outcomingAmount = 0; // 나간 돈
  int selectedIndex = 0;

  bool _isAddingTransaction = false;

  final ScrollController _scrollController =
  ScrollController(); // ScrollController 추가

  void _addTransaction() {
    setState(() {
      _isAddingTransaction = true; // 새로운 거래 창 열기
    });

    // 렌더링 후 스크롤을 아래로 이동시키기 위해 addPostFrameCallback 사용
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 화면 렌더링 후 스크롤을 끝으로 이동
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollToBottom();  // _scrollToBottom() 함수 호출
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
        if (_scrollController.hasClients) {  // ScrollController가 연결된 경우에만
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

    if (mounted) {  // 위젯이 여전히 트리에 있을 때만 setState 호출
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

  // _updateAmounts 함수 수정
  Future<void> _updateAmounts() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final oneMonthAgo = getOneMonthAgo();

    final transactionsSnapshot = await FirebaseFirestore.instance
        .collection('trade')
        .where('userId', isEqualTo: user.uid)
        .where('date', isGreaterThanOrEqualTo: oneMonthAgo)
        .get();

    int incomeSum = 0;
    int expenseSum = 0;

    for (var doc in transactionsSnapshot.docs) {
      final type = doc['type'];
      final amount = doc['amount'] as int;

      if (type == 'income') {
        incomeSum += amount;
      } else if (type == 'expense') {
        expenseSum += amount;
      }
    }

    setState(() {
      incomingAmount = incomeSum; // 수입 금액 업데이트
      outcomingAmount = expenseSum; // 지출 금액 업데이트
      asset = incomingAmount - outcomingAmount; // 자산 계산
    });
  }

  // 1개월 전의 날짜를 계산하는 함수
  DateTime getOneMonthAgo() {
    final now = DateTime.now();
    final oneMonthAgo = now.subtract(const Duration(days: 30)); // 1개월 전 날짜
    return oneMonthAgo;
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

  Stream<QuerySnapshot> getTransactions() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Stream.empty();
    }

    final oneMonthAgo = getOneMonthAgo(); // 1개월 전 날짜 가져오기

    if (selectedIndex == 0) {
      return FirebaseFirestore.instance
          .collection('trade')
          .where('userId', isEqualTo: user.uid)
          .where('date', isGreaterThanOrEqualTo: oneMonthAgo) // 1개월 전 이후의 데이터만
          .orderBy('date', descending: true) // 날짜를 기준으로 내림차순 정렬
          .orderBy('createdAt', descending: true) // 등록된 날짜 순으로 내림차순 정렬
          .snapshots();
    } else if (selectedIndex == 1) {
      return FirebaseFirestore.instance
          .collection('trade')
          .where('userId', isEqualTo: user.uid)
          .where('type', isEqualTo: 'income')
          .where('date', isGreaterThanOrEqualTo: oneMonthAgo) // 1개월 전 이후의 데이터만
          .orderBy('date', descending: true) // 날짜를 기준으로 내림차순 정렬
          .orderBy('createdAt', descending: true) // 등록된 날짜 순으로 내림차순 정렬
          .snapshots();
    } else {
      return FirebaseFirestore.instance
          .collection('trade')
          .where('userId', isEqualTo: user.uid)
          .where('type', isEqualTo: 'expense')
          .where('date', isGreaterThanOrEqualTo: oneMonthAgo) // 1개월 전 이후의 데이터만
          .orderBy('date', descending: true) // 날짜를 기준으로 내림차순 정렬
          .orderBy('createdAt', descending: true) // 등록된 날짜 순으로 내림차순 정렬
          .snapshots();
    }
  }

  Widget _buildMenuContent() {
    return StreamBuilder<QuerySnapshot>(
      stream: getTransactions(),
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

        return SingleChildScrollView(  // 스크롤이 가능한 영역으로 ListView.builder 감쌈
          child: Column(
            children: [
              ListView.builder(
                shrinkWrap: true, // ListView의 크기를 자식에 맞게 조정
                physics: const NeverScrollableScrollPhysics(), // ListView에서 자체 스크롤을 막음
                itemCount: transactions.length,
                itemBuilder: (context, index) {
                  final transaction = transactions[index];
                  final transactionId = transaction.id; // 삭제를 위해 문서 ID 저장
                  final date = (transaction['date'] as Timestamp).toDate();
                  final content = transaction['content'];
                  final amount = transaction['amount'];
                  final type = transaction['type'];

                  // 금액의 색상과 부호 결정
                  Color amountColor = type == 'income' ? const Color(0xFF39A063) : const Color(0xFFD90021);
                  String amountPrefix = type == 'income' ? '+' : '-';

                  return Dismissible(
                    key: Key(transactionId), // 고유 키 설정
                    direction: DismissDirection.endToStart, // 오른쪽에서 왼쪽으로 스와이프
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
                          backgroundColor: Colors.white,
                          title: const Text('삭제 확인'),
                          content: const Text('이 거래 내역을 삭제하시겠습니까?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text('취소'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: const Text('삭제'),
                            ),
                          ],
                        ),
                      );
                    },
                    onDismissed: (direction) async {
                      // Firestore에서 해당 문서를 삭제
                      await FirebaseFirestore.instance
                          .collection('trade')
                          .doc(transactionId)
                          .delete();
                      // 삭제 후 UI 갱신
                      setState(() async {
                        transactions.removeAt(index);
                        await _updateAmounts();
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 22.0),
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
                              style: const TextStyle(fontSize: 14.0, color: Colors.grey),
                            ),
                            const SizedBox(height: 2.0),
                            Text(
                              content,
                              style: const TextStyle(fontSize: 16.0, fontFamily: 'Hana2Bold'),
                            ),
                          ],
                        ),
                        trailing: Text(
                          '$amountPrefix${formatAssetValue(amount)}', // 금액 포맷팅
                          style: TextStyle(
                            fontSize: 18.0,
                            fontFamily: 'Hana2Bold',
                            color: amountColor, // 금액의 색상 설정
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
            IconButton(
              icon: const Icon(
                FontAwesomeIcons.bars,
                color: Colors.grey,
              ),
              onPressed: () {
                Logout logout = Logout();
                logout.showLogoutDialog(context);
              },
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
                  style: const TextStyle(fontSize: 18, fontFamily: 'Hana2Regular'),
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
                    onTransactionAdded: _updateAssetAfterTransaction, // 거래 추가 후 자산 갱신
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
