import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'main_menu_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://iwnnwqbtmpeqhdysoewk.supabase.co', // Twój Project URL
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Iml3bm53cWJ0bXBlcWhkeXNvZXdrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTEzNjkyMDUsImV4cCI6MjA2Njk0NTIwNX0.OMS1eH18KfIQJ903a2CMNSRee1B51wdtq-Ce0WirDzw',
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Menu główne',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MainMenuScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}