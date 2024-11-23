import 'package:clear_ledger/pages/widgets/add_transaction_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

import '../services/user_service.dart';
import 'package:clear_ledger/pages/widgets/income_expense_box.dart';
import 'package:clear_ledger/pages/utils/logout.dart';
import 'package:clear_ledger/pages/widgets/menu_widget.dart'; // MenuWidget을 import합니다.

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  MainPageState createState() => MainPageState();
}

class MainPageState extends State<MainPage> {
  String userName = '';
  int asset = 0;
  final UserService _userService = UserService();

  int incomingAmount = 980000; // 들어온 돈 (예시 값)
  int outcomingAmount = 110000; // 나간 돈 (예시 값)

  int selectedIndex = 0;

  bool _isAddingTransaction = false;

  final ScrollController _scrollController = ScrollController(); // ScrollController 추가

  void _addTransaction() {
    setState(() {
      _isAddingTransaction = true; // 새로운 거래 창 열기
    });

    // 렌더링 후 스크롤을 아래로 이동시키기 위해 addPostFrameCallback 사용
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 화면이 렌더링 된 후 스크롤을 끝으로 이동
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent, // 화면 끝으로 이동
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  void _closeTransaction() {
    setState(() {
      _isAddingTransaction = false; // 새로운 거래 창 닫기
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
      setState(() {
        userName = fetchedName ?? '';
        asset = fetchedAssetValue ?? 0;
      });

      // 자산 계산 (incomingAmount - outcomingAmount)
      int newAssetValue = incomingAmount - outcomingAmount;
      setState(() {
        asset = newAssetValue;
      });

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

  // 메뉴별 내용을 반환하는 함수
  Widget _buildMenuContent() {
    if (selectedIndex == 0) {
      // 전체 내역 내용
      return const Text('내역이 없습니다', style: TextStyle(fontSize: 16));
    } else if (selectedIndex == 1) {
      // 수입 내용
      return const Text('내역이 없습니다', style: TextStyle(fontSize: 16));
    } else if (selectedIndex == 2) {
      // 지출 내용
      return const Text('내역이 없습니다', style: TextStyle(fontSize: 16));
    }
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          scrolledUnderElevation: 0,
          title: const Text(
            '작심소비',
            style: TextStyle(fontSize: 20, fontFamily: 'Hana2Medium'),
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
          controller: _scrollController, // ScrollController를 SingleChildScrollView에 연결
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
                Text(
                  userName.isNotEmpty
                      ? '안녕하세요, $userName님!\n지난 1개월 간의 거래 내역을\n확인해보세요.'
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
                AddTransactionWidget(onAddTransaction: _addTransaction),
                const SizedBox(height: 40),
                const Divider(
                    height: 2, thickness: 10, color: Color(0xFFD3D4D7)),
                if (_isAddingTransaction) ...[
                  Container(
                    height: 300,
                    // 높이를 기존보다 늘려 날짜 입력 필드를 포함
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
                          color: Colors.grey[300], // 밑줄 색상 설정
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          '날짜',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey[200], // 배경색 설정
                                  borderRadius: BorderRadius.circular(8.0), // 배경 둥글게 설정
                                ),
                                child: TextField(
                                  textAlign: TextAlign.center, // 텍스트 가운데 정렬
                                  decoration: InputDecoration(
                                    hintText: '2000',
                                    border: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                        color: Colors.grey, // 테두리 색상
                                        width: 1.0, // 테두리 두께 조정
                                      ),
                                      borderRadius: BorderRadius.circular(10.0), // 테두리 둥글게 설정
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                        color: Colors.grey, // 테두리 색상
                                        width: 1.0, // 테두리 두께 조정
                                      ),
                                      borderRadius: BorderRadius.circular(10.0), // 테두리 둥글게 설정
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                        color: Colors.grey, // 테두리 색상 (포커스 상태)
                                        width: 1.0, // 테두리 두께 유지
                                      ),
                                      borderRadius: BorderRadius.circular(10.0), // 테두리 둥글게 설정
                                    ),// 입력 필드 크기 줄이기
                                    filled: true, // 배경색 활성화
                                    fillColor: Colors.grey[200], // 배경색 설정
                                  ),
                                  keyboardType: TextInputType.number, // 숫자 키보드
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly, // 숫자만 허용
                                    LengthLimitingTextInputFormatter(4), // 4자리로 제한
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Flexible(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey[200], // 배경색 설정
                                  borderRadius: BorderRadius.circular(8.0), // 배경 둥글게 설정
                                ),
                                child: TextField(
                                  textAlign: TextAlign.center, // 텍스트 가운데 정렬
                                  decoration: InputDecoration(
                                    hintText: '01',
                                    border: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                        color: Colors.grey, // 테두리 색상
                                        width: 1.0, // 테두리 두께 조정
                                      ),
                                      borderRadius: BorderRadius.circular(10.0), // 테두리 둥글게 설정
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                        color: Colors.grey, // 테두리 색상
                                        width: 1.0, // 테두리 두께 조정
                                      ),
                                      borderRadius: BorderRadius.circular(10.0), // 테두리 둥글게 설정
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                        color: Colors.grey, // 테두리 색상 (포커스 상태)
                                        width: 1.0, // 테두리 두께 유지
                                      ),
                                      borderRadius: BorderRadius.circular(10.0), // 테두리 둥글게 설정
                                    ),// 입력 필드 크기 줄이기
                                    filled: true, // 배경색 활성화
                                    fillColor: Colors.grey[200], // 배경색 설정
                                  ),
                                  keyboardType: TextInputType.number, // 숫자 키보드
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly, // 숫자만 허용
                                    LengthLimitingTextInputFormatter(2), // 4자리로 제한
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Flexible(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey[200], // 배경색 설정
                                  borderRadius: BorderRadius.circular(8.0), // 배경 둥글게 설정
                                ),
                                child: TextField(
                                  textAlign: TextAlign.center, // 텍스트 가운데 정렬
                                  decoration: InputDecoration(
                                    hintText: '01',
                                    border: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                        color: Colors.grey, // 테두리 색상
                                        width: 1.0, // 테두리 두께 조정
                                      ),
                                      borderRadius: BorderRadius.circular(10.0), // 테두리 둥글게 설정
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                        color: Colors.grey, // 테두리 색상
                                        width: 1.0, // 테두리 두께 조정
                                      ),
                                      borderRadius: BorderRadius.circular(10.0), // 테두리 둥글게 설정
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                        color: Colors.grey, // 테두리 색상 (포커스 상태)
                                        width: 1.0, // 테두리 두께 유지
                                      ),
                                      borderRadius: BorderRadius.circular(10.0), // 테두리 둥글게 설정
                                    ),// 입력 필드 크기 줄이기
                                    filled: true, // 배경색 활성화
                                    fillColor: Colors.grey[200], // 배경색 설정
                                  ),
                                  keyboardType: TextInputType.number, // 숫자 키보드
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly, // 숫자만 허용
                                    LengthLimitingTextInputFormatter(2), // 4자리로 제한
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Spacer(), // 남은 공간을 채워 닫기 버튼을 아래로 정렬
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: TextButton(
                            onPressed: _closeTransaction,
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
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
