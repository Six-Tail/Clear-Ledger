import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:clear_ledger/theme.dart';

class SignUp extends StatefulWidget {
  final PageController pageController;
  const SignUp({super.key, required this.pageController});

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final FocusNode focusNodePassword = FocusNode();
  final FocusNode focusNodeConfirmPassword = FocusNode();
  final FocusNode focusNodeEmail = FocusNode();
  final FocusNode focusNodeName = FocusNode();

  bool _obscureTextPassword = true;
  bool _obscureTextConfirmPassword = true;

  TextEditingController signupEmailController = TextEditingController();
  TextEditingController signupNameController = TextEditingController();
  TextEditingController signupPasswordController = TextEditingController();
  TextEditingController signupConfirmPasswordController = TextEditingController();

  @override
  void dispose() {
    focusNodePassword.dispose();
    focusNodeConfirmPassword.dispose();
    focusNodeEmail.dispose();
    focusNodeName.dispose();
    super.dispose();
  }

  void _createAccount() async {
    // 입력값 검증
    if (_validateInputs()) {
      try {
        // Firebase에 이메일 및 비밀번호로 계정 생성
        final newUser = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: signupEmailController.text.trim(),
          password: signupPasswordController.text.trim(),
        );

        if (newUser.user != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('회원가입 성공! 로그인하세요.')),
          );

                    // Use widget.pageController here
                    widget.pageController.animateToPage(
                      0,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                   // 이전 화면(로그인)으로 이동
        }
      } on FirebaseAuthException catch (e) {
        // Firebase 에러 처리
        _handleFirebaseErrors(e);
      }
    }
  }

  bool _validateInputs() {
    // 닉네임, 이메일, 비밀번호, 비밀번호 확인 입력 검증
    if (signupNameController.text.isEmpty ||
        signupEmailController.text.isEmpty ||
        signupPasswordController.text.isEmpty ||
        signupConfirmPasswordController.text.isEmpty) {
      _showError('모든 필드를 입력해주세요.');
      return false;
    }
    if (signupPasswordController.text != signupConfirmPasswordController.text) {
      _showError('비밀번호가 일치하지 않습니다.');
      return false;
    }
    return true;
  }

  void _handleFirebaseErrors(FirebaseAuthException e) {
    String message;
    switch (e.code) {
      case 'email-already-in-use':
        message = '이미 사용 중인 이메일입니다.';
        break;
      case 'weak-password':
        message = '비밀번호가 너무 약합니다.';
        break;
      case 'invalid-email':
        message = '유효하지 않은 이메일 형식입니다.';
        break;
      default:
        message = '회원가입에 실패했습니다. 다시 시도해주세요.';
    }
    _showError(message);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 23.0),
      child: Column(
        children: <Widget>[
          Stack(
            alignment: Alignment.topCenter,
            children: <Widget>[
              Card(
                elevation: 2.0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: SizedBox(
                  width: 300.0,
                  height: 360.0,
                  child: Column(
                    children: <Widget>[
                      // 닉네임 입력
                      _buildInputField(
                        controller: signupNameController,
                        focusNode: focusNodeName,
                        hintText: '닉네임',
                        icon: FontAwesomeIcons.user,
                        nextFocusNode: focusNodeEmail,
                      ),
                      _divider(),
                      // 이메일 입력
                      _buildInputField(
                        controller: signupEmailController,
                        focusNode: focusNodeEmail,
                        hintText: '이메일 주소',
                        icon: FontAwesomeIcons.envelope,
                        nextFocusNode: focusNodePassword,
                      ),
                      _divider(),
                      // 비밀번호 입력
                      _buildPasswordField(
                        controller: signupPasswordController,
                        focusNode: focusNodePassword,
                        hintText: '비밀번호',
                        isObscured: _obscureTextPassword,
                        toggleVisibility: _toggleSignupPasswordVisibility,
                        nextFocusNode: focusNodeConfirmPassword,
                      ),
                      _divider(),
                      // 비밀번호 확인 입력
                      _buildPasswordField(
                        controller: signupConfirmPasswordController,
                        focusNode: focusNodeConfirmPassword,
                        hintText: '비밀번호 확인',
                        isObscured: _obscureTextConfirmPassword,
                        toggleVisibility: _toggleSignupConfirmPasswordVisibility,
                        nextFocusNode: null,
                      ),
                    ],
                  ),
                ),
              ),
              // 회원가입 버튼
              Container(
                margin: const EdgeInsets.only(top: 340.0),
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(5.0)),
                  gradient: LinearGradient(
                    colors: <Color>[
                      CustomTheme.loginGradientStart,
                      CustomTheme.loginGradientEnd,
                    ],
                  ),
                ),
                child: MaterialButton(
                  highlightColor: Colors.transparent,
                  splashColor: CustomTheme.loginGradientEnd,
                  onPressed: _createAccount, // 회원가입 로직 연결
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 42.0),
                    child: Text(
                      '회원가입',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20.0,
                          fontFamily: 'Hana2Bold'),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hintText,
    required IconData icon,
    FocusNode? nextFocusNode,
  }) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        decoration: InputDecoration(
          hintText: hintText,
          icon: Icon(icon),
        ),
        onSubmitted: (_) {
          if (nextFocusNode != null) {
            FocusScope.of(context).requestFocus(nextFocusNode);
          }
        },
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hintText,
    required bool isObscured,
    required VoidCallback toggleVisibility,
    FocusNode? nextFocusNode,
  }) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        obscureText: isObscured,
        decoration: InputDecoration(
          hintText: hintText,
          icon: const Icon(FontAwesomeIcons.lock),
          suffixIcon: IconButton(
            icon: Icon(isObscured ? Icons.visibility_off : Icons.visibility),
            onPressed: toggleVisibility,
          ),
        ),
        onSubmitted: (_) {
          if (nextFocusNode != null) {
            FocusScope.of(context).requestFocus(nextFocusNode);
          }
        },
      ),
    );
  }

  void _toggleSignupPasswordVisibility() {
    setState(() {
      _obscureTextPassword = !_obscureTextPassword;
    });
  }

  void _toggleSignupConfirmPasswordVisibility() {
    setState(() {
      _obscureTextConfirmPassword = !_obscureTextConfirmPassword;
    });
  }

  Widget _divider() => Container(width: 250.0, height: 1.0, color: Colors.grey[400]);
}
