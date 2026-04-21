import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_page.dart';
import 'language_manager.dart';
import 'screens/signup_screen.dart';
import 'screens/main_screen.dart';
import 'globals.dart';
import 'package:provider/provider.dart';
import 'providers/shelf_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Language Manager with saved preference
  await LanguageManager.instance.init();

  // Check session persistence
  final prefs = await SharedPreferences.getInstance();
  final String? userMobile = prefs.getString('user_mobile');
  if (userMobile != null && userMobile.isNotEmpty) {
    isAuthenticated = true;
  }

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Colors.black,
    systemNavigationBarIconBrightness: Brightness.light,
  ));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: LanguageManager.instance.displayLanguage,
      builder: (context, lang, child) {
        return MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => ShelfProvider()),
          ],
          child: MaterialApp(

          title: 'ChaiShots',
          key: ValueKey(lang),
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            primaryColor: const Color(0xFFFFD400),
            scaffoldBackgroundColor: Colors.black,
            appBarTheme: const AppBarTheme(
              elevation: 0,
              backgroundColor: Colors.black,
              scrolledUnderElevation: 0,
            ),
            bottomNavigationBarTheme: const BottomNavigationBarThemeData(
              backgroundColor: Colors.black,
              selectedItemColor: Color(0xFFFFD400),
              unselectedItemColor: Colors.white38,
              elevation: 0,
            ),
          ),
          builder: (context, child) {
            return Scaffold(
              backgroundColor: Colors.black,
              body: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 420),
                  decoration: const BoxDecoration(
                    color: Colors.black,
                  ),
                  child: child ?? const SizedBox.expand(),
                ),
              ),
            );
          },
          home: isAuthenticated ? const MainScreen() : const SignupScreen(),
          ),
        );
      },
    );
  }
}
