import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../secure_storage_service.dart';
import '../set_pin_screen.dart';
import '../pin_login_screen.dart';
import '../main_menu_screen.dart';
import 'screens/login_screen.dart';
import 'screens/intro_screen.dart';
import '../../screens/User_home_screen.dart';
import 'match3_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://iwnnwqbtmpeqhdysoewk.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Iml3bm53cWJ0bXBlcWhkeXNvZXdrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTEzNjkyMDUsImV4cCI6MjA2Njk0NTIwNX0.OMS1eH18KfIQJ903a2CMNSRee1B51wdtq-Ce0WirDzw',
      authOptions: const FlutterAuthClientOptions(
        autoRefreshToken: true,
      ),
  );

  final savedPin = await SecureStorageService.getPin();

  runApp(MyApp(startRoute: savedPin == null ? "/login" : "/pinLogin",));
}

class MyApp extends StatelessWidget {
  final String startRoute;

  const MyApp({super.key, this.startRoute = "/pinLogin"});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: startRoute,
      routes: {
        "/login": (_) => const LoginScreen(),
        "/setPin": (_) => const SetPinScreen(),
        "/pinLogin": (_) => const PinLoginScreen(),
        "/intro": (_) => const IntroScreen(),
        '/match3': (_) => const Match3Screen(),
      },
    );
  }
}
