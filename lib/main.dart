import 'package:clear_ledger/firebase_options.dart';
import 'package:clear_ledger/pages/main_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:clear_ledger/pages/login_page.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:get/get_navigation/src/root/get_material_app.dart'; // Firebase Auth에 별칭 부여

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase 초기화
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ClearLedger',
      // 아래 코드를 추가
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        Locale('en', ''), // English, no country code
        Locale('ko', ''), // Korean, no country code
      ],
      home: AuthWrapper(),
    );
  }
}

// 로그인 상태를 관리하는 위젯
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<firebase.User?>(
        stream: firebase.FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // 사용자가 로그인되어 있으면 메인 화면으로, 아니면 로그인 화면으로 이동
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator()); // 로딩 중 화면
          } else if (snapshot.hasData) {
            // 사용자가 이미 로그인되어 있는 경우
            return const MainPage(); // 로그인한 경우 메인 화면
          } else {
            return const LoginPage(); // 로그인하지 않는 경우 로그인 화면
          }
        });
  }
}
