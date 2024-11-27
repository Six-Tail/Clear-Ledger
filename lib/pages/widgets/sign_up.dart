import 'package:clear_ledger/pages/login_page.dart';
import 'package:clear_ledger/widgets/snackbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:clear_ledger/theme.dart';
import 'package:get/get.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

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
  bool isSignupScreen = true;

  TextEditingController signupEmailController = TextEditingController();
  TextEditingController signupNameController = TextEditingController();
  TextEditingController signupPasswordController = TextEditingController();
  TextEditingController signupConfirmPasswordController = TextEditingController();

  String? _nameError;
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;

  @override
  void dispose() {
    focusNodePassword.dispose();
    focusNodeConfirmPassword.dispose();
    focusNodeEmail.dispose();
    focusNodeName.dispose();
    super.dispose();
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
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 20.0, bottom: 20.0, left: 25.0, right: 25.0),
                        child: TextField(
                          focusNode: focusNodeName,
                          controller: signupNameController,
                          keyboardType: TextInputType.text,
                          textCapitalization: TextCapitalization.words,
                          autocorrect: false,
                          style: const TextStyle(
                              fontFamily: 'Hana2Bold',
                              fontSize: 14.0,
                              color: Colors.black),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            icon: Icon(
                              FontAwesomeIcons.user,
                              color: _nameError == null
                                  ? Colors.black
                                  : const Color(0xFFD90021), // 오류가 있으면 빨간색
                            ),
                            hintText: '닉네임',
                            hintStyle: const TextStyle(
                                fontFamily: 'Hana2Bold', fontSize: 14.0),
                          ),
                          onSubmitted: (_) {
                            focusNodeEmail.requestFocus();
                          },
                        ),
                      ),
                      Container(
                        width: 250.0,
                        height: 1.0,
                        color: Colors.grey[400],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 20.0, bottom: 20.0, left: 25.0, right: 25.0),
                        child: TextField(
                          focusNode: focusNodeEmail,
                          controller: signupEmailController,
                          keyboardType: TextInputType.emailAddress,
                          autocorrect: false,
                          style: const TextStyle(
                              fontFamily: 'Hana2Bold',
                              fontSize: 14.0,
                              color: Colors.black),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            icon: Icon(
                              FontAwesomeIcons.envelope,
                              color: _emailError == null
                                  ? Colors.black
                                  : const Color(0xFFD90021), // 오류가 있으면 빨간색
                            ),
                            hintText: '이메일 주소',
                            hintStyle: const TextStyle(
                                fontFamily: 'Hana2Bold', fontSize: 14.0),
                          ),
                          onSubmitted: (_) {
                            focusNodePassword.requestFocus();
                          },
                        ),
                      ),
                      Container(
                        width: 250.0,
                        height: 1.0,
                        color: Colors.grey[400],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 20.0, bottom: 20.0, left: 25.0, right: 25.0),
                        child: TextField(
                          focusNode: focusNodePassword,
                          controller: signupPasswordController,
                          obscureText: _obscureTextPassword,
                          autocorrect: false,
                          style: const TextStyle(
                              fontFamily: 'Hana2Bold',
                              fontSize: 14.0,
                              color: Colors.black),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            icon: Icon(
                              FontAwesomeIcons.lock,
                              color: _passwordError == null
                                  ? Colors.black
                                  : const Color(0xFFD90021), // 오류가 있으면 빨간색
                            ),
                            hintText: '비밀번호',
                            hintStyle: const TextStyle(
                                fontFamily: 'Hana2Bold', fontSize: 14.0),
                            suffixIcon: GestureDetector(
                              onTap: _toggleSignup,
                              child: Icon(
                                _obscureTextPassword
                                    ? FontAwesomeIcons.eye
                                    : FontAwesomeIcons.eyeSlash,
                                size: 15.0,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          onSubmitted: (_) {
                            focusNodeConfirmPassword.requestFocus();
                          },
                        ),
                      ),
                      Container(
                        width: 250.0,
                        height: 1.0,
                        color: Colors.grey[400],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 20.0, bottom: 20.0, left: 25.0, right: 25.0),
                        child: TextField(
                          focusNode: focusNodeConfirmPassword,
                          controller: signupConfirmPasswordController,
                          obscureText: _obscureTextConfirmPassword,
                          autocorrect: false,
                          style: const TextStyle(
                              fontFamily: 'Hana2Bold',
                              fontSize: 14.0,
                              color: Colors.black),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            icon: Icon(
                              FontAwesomeIcons.lock,
                              color: _confirmPasswordError == null
                                  ? Colors.black
                                  : const Color(0xFFD90021), // 오류가 있으면 빨간색
                            ),
                            hintText: '비밀번호 확인',
                            hintStyle: const TextStyle(
                                fontFamily: 'Hana2Bold', fontSize: 14.0),
                            suffixIcon: GestureDetector(
                              onTap: _toggleSignupConfirm,
                              child: Icon(
                                _obscureTextConfirmPassword
                                    ? FontAwesomeIcons.eye
                                    : FontAwesomeIcons.eyeSlash,
                                size: 15.0,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          onSubmitted: (_) {
                            _toggleSignUpButton();
                          },
                          textInputAction: TextInputAction.go,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 340.0),
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(5.0)),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: CustomTheme.loginGradientStart,
                      offset: Offset(1.0, 6.0),
                      blurRadius: 20.0,
                    ),
                    BoxShadow(
                      color: CustomTheme.loginGradientEnd,
                      offset: Offset(1.0, 6.0),
                      blurRadius: 20.0,
                    ),
                  ],
                  gradient: LinearGradient(
                      colors: <Color>[
                        CustomTheme.loginGradientEnd,
                        CustomTheme.loginGradientStart
                      ],
                      begin: FractionalOffset(0.2, 0.2),
                      end: FractionalOffset(1.0, 1.0),
                      stops: <double>[0.0, 1.0],
                      tileMode: TileMode.clamp),
                ),
                child: MaterialButton(
                  highlightColor: Colors.transparent,
                  splashColor: CustomTheme.loginGradientEnd,
                  //shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5.0))),
                  child: const Padding(
                    padding:
                    EdgeInsets.symmetric(vertical: 10.0, horizontal: 42.0),
                    child: Text(
                      '회원가입',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20.0,
                          fontFamily: 'Hana2Bold'),
                    ),
                  ),
                  onPressed: () => _toggleSignUpButton(),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  void _toggleSignUpButton() async {
    setState(() {
      _nameError = signupNameController.text.isEmpty
          ? '닉네임을 입력하세요'
          : (signupNameController.text.length < 2
          ? '닉네임은 2자 이상이어야 합니다'
          : null);

      _emailError = signupEmailController.text.isEmpty
          ? '이메일 주소를 입력하세요'
          : !RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
          .hasMatch(signupEmailController.text)
          ? '유효한 이메일 주소를 입력하세요'
          : null;

      _passwordError = signupPasswordController.text.isEmpty
          ? '비밀번호를 입력하세요'
          : !RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{6,}$')
          .hasMatch(signupPasswordController.text)
          ? '비밀번호는 영어와 숫자를 포함하여 6자 이상이어야 합니다'
          : null;

      _confirmPasswordError = signupConfirmPasswordController.text.isEmpty
          ? '비밀번호 확인을 입력하세요'
          : signupConfirmPasswordController.text !=
          signupPasswordController.text
          ? '비밀번호가 일치하지 않습니다'
          : null;
    });

    if (_nameError == null &&
        _emailError == null &&
        _passwordError == null &&
        _confirmPasswordError == null) {
      try {
        // Firebase Auth로 사용자 등록
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
            email: signupEmailController.text,
            password: signupPasswordController.text);

        // Firestore의 users 컬렉션에 데이터 저장
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
          'userName': signupNameController.text,
          'email': signupEmailController.text,
          'userImage': 'https://www.default_profile_image.com',
          'asset': 0,
          'accountType': 'ClearLedger 계정',
        });

        // 자동 로그인 해제
        await FirebaseAuth.instance.signOut();

        // 회원가입 성공 시 로그인 화면으로 이동, but check if it's the sign-up screen
        if (isSignupScreen) {
          Get.offAll(() => const LoginPage());
        }

        if (mounted) {
          CustomSnackBar(context, const Text('회원가입 성공!'));
        }
      } on FirebaseAuthException catch (e) {
        String errorMessage = '회원가입에 실패했습니다';
        if (e.code == 'email-already-in-use') {
          errorMessage = '이미 사용 중인 이메일입니다';
        } else if (e.code == 'weak-password') {
          errorMessage = '비밀번호가 너무 약합니다';
        }

        if (mounted) {
          CustomSnackBar(context, Text(errorMessage));
        }
      } catch (e) {
        if (mounted) {
          CustomSnackBar(context, const Text('알 수 없는 오류가 발생했습니다'));
        }
      }
    } else {
      if (mounted) {
        CustomSnackBar(context, Text(
            _nameError ?? _emailError ?? _passwordError ??
                _confirmPasswordError ?? '알 수 없는 오류'));
      }
    }
  }

  void _toggleSignup() {
    setState(() {
      _obscureTextPassword = !_obscureTextPassword;
    });
  }

  void _toggleSignupConfirm() {
    setState(() {
      _obscureTextConfirmPassword = !_obscureTextConfirmPassword;
    });
  }
}
