import 'package:clear_ledger/pages/main_page.dart';
import 'package:clear_ledger/theme.dart';
import 'package:clear_ledger/widgets/snackbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/user_service.dart';

class SignIn extends StatefulWidget {
  final PageController pageController;

  const SignIn({super.key, required this.pageController});

  @override
  _SignInState createState() => _SignInState();
}


class _SignInState extends State<SignIn> {
  TextEditingController loginEmailController = TextEditingController();
  TextEditingController loginPasswordController = TextEditingController();

  final FocusNode focusNodeEmail = FocusNode();
  final FocusNode focusNodePassword = FocusNode();

  bool _obscureTextPassword = true;
  bool isLoginAttempt = false;
  bool isLoggedIn = false;

  @override
  void dispose() {
    focusNodeEmail.dispose();
    focusNodePassword.dispose();
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
                  height: 190.0,
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 20.0, bottom: 20.0, left: 25.0, right: 25.0),
                        child: TextField(
                          focusNode: focusNodeEmail,
                          controller: loginEmailController,
                          keyboardType: TextInputType.emailAddress,
                          style: const TextStyle(
                              fontFamily: 'Hana2Bold',
                              fontSize: 14.0,
                              color: Colors.black),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            icon: Icon(
                              FontAwesomeIcons.envelope,
                              color: Colors.black,
                              size: 22.0,
                            ),
                            hintText: '이메일 주소',
                            hintStyle: TextStyle(
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
                          controller: loginPasswordController,
                          obscureText: _obscureTextPassword,
                          style: const TextStyle(
                              fontFamily: 'Hana2Bold',
                              fontSize: 14.0,
                              color: Colors.black),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            icon: const Icon(
                              FontAwesomeIcons.lock,
                              size: 22.0,
                              color: Colors.black,
                            ),
                            hintText: '비밀번호',
                            hintStyle: const TextStyle(
                                fontFamily: 'Hana2Bold', fontSize: 14.0),
                            suffixIcon: GestureDetector(
                              onTap: _toggleLogin,
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
                            _toggleSignInButton();
                          },
                          textInputAction: TextInputAction.go,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 170.0),
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
                    child: const Padding(
                      padding:
                      EdgeInsets.symmetric(vertical: 10.0, horizontal: 42.0),
                      child: Text(
                        '로그인',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20.0,
                            fontFamily: 'Hana2Bold'),
                      ),
                    ),
                    onPressed: () => CustomSnackBar(
                        context, const Text('Login Button Pressed'))),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  '계정이 없으신가요?',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Hana2Medium',
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    // Use widget.pageController here
                    widget.pageController.animateToPage(
                      1,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: Container(
                    decoration: const BoxDecoration(
                        border: Border(
                            bottom: BorderSide(
                                color: Colors.white, width: 2.0))),
                    child: const Row(
                      children: [
                        Text(
                          '회원가입',
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Hana2Medium',
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                        colors: <Color>[
                          Colors.white10,
                          Colors.white,
                        ],
                        begin: FractionalOffset(0.0, 0.0),
                        end: FractionalOffset(1.0, 1.0),
                        stops: <double>[0.0, 1.0],
                        tileMode: TileMode.clamp),
                  ),
                  width: 100.0,
                  height: 1.0,
                ),
                const Padding(
                  padding: EdgeInsets.only(left: 15.0, right: 15.0),
                  child: Text(
                    'Or',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.0,
                        fontFamily: 'Hana2Medium'),
                  ),
                ),
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                        colors: <Color>[
                          Colors.white,
                          Colors.white10,
                        ],
                        begin: FractionalOffset(0.0, 0.0),
                        end: FractionalOffset(1.0, 1.0),
                        stops: <double>[0.0, 1.0],
                        tileMode: TileMode.clamp),
                  ),
                  width: 100.0,
                  height: 1.0,
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 10.0, right: 40.0),
                child: GestureDetector(
                  onTap: () async {
                    await signInWithGitHub();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(15.0),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: const Icon(
                      FontAwesomeIcons.github,
                      color: Color(0xFF000000),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: GestureDetector(
                  onTap: () async {
                    await signInWithGoogle();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(15.0),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: const Icon(
                      FontAwesomeIcons.google,
                      color: Color(0xFF000000),
                    ),
                  ),
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  void navigatorToMainPage() {
    Get.off(() => const MainPage());
  }

  void _toggleLogin() {
    setState(() {
      _obscureTextPassword = !_obscureTextPassword;
    });
  }

  void _toggleSignInButton() {
    CustomSnackBar(context, const Text('Signin Button Pressed'));
  }

  // 구글 로그인 구현
  Future<void> signInWithGoogle() async {
    setState(() {
      isLoginAttempt = true;
    });
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;
      if (googleAuth == null) {
        setState(() {
          isLoginAttempt = false;
        });
        return;
      }
      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await firebase_auth.FirebaseAuth.instance.signInWithCredential(credential);
      await _saveLoginState();

      final firebase_auth.User? user = firebase_auth.FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userService = UserService(); // UserService 인스턴스 생성
        await userService.saveUserToFirestore(
          user.uid,
          user.displayName,
          user.photoURL,
          "Google 계정",
        );
        if (kDebugMode) {
          print('구글 계정 FireStore 저장 성공');
        }
      }
      navigatorToMainPage();
    } catch (error) {
      if (kDebugMode) {
        print('Google 로그인 실패 $error');
      }
    }
  }

  Future<void> signInWithGitHub() async {
    setState(() {
      isLoginAttempt = true;
    });

    try {
      final FirebaseAuth auth = FirebaseAuth.instance;
      UserCredential userCredential;

      if (kIsWeb) {
        // 웹 환경: 팝업을 사용한 GitHub 로그인
        GithubAuthProvider githubProvider = GithubAuthProvider();
        userCredential = await auth.signInWithPopup(githubProvider);
      } else {
        // 모바일 환경: GitHub OAuth 플로우
        GithubAuthProvider githubProvider = GithubAuthProvider();
        userCredential = await auth.signInWithProvider(githubProvider);
      }

      // 로그인 성공 후 사용자 정보 처리
      final User? user = userCredential.user;
      if (user != null) {
        final userService = UserService(); // UserService 인스턴스 생성
        await userService.saveUserToFirestore(
          user.uid,
          user.displayName,
          user.photoURL,
          "GitHub 계정",
        );

        if (kDebugMode) {
          print('GitHub 계정 Firestore 저장 성공');
        }
      }

      // 로그인 상태 저장 및 메인 페이지로 이동
      await _saveLoginState();
      navigatorToMainPage();
    } catch (error) {
      if (kDebugMode) {
        print('GitHub 로그인 실패: $error');
      }
    } finally {
      setState(() {
        isLoginAttempt = false;
      });
    }
  }

  Future<void> _saveLoginState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
  }

  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    await firebase_auth.FirebaseAuth.instance.signOut();
  }

}
