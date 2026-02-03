import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../main_menu_screen.dart';
import 'user_home_screen.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;

      if (user == null) {
        Navigator.pushReplacementNamed(context, "/login");
        return;
      }

      final profile = await Supabase.instance.client
          .from('profiles')
          .select('first_name, last_name, title, is_admin')
          .eq('id', user.id)
          .single();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => UserHomeScreen(
            firstName: profile['first_name'] ?? '',
            lastName: profile['last_name'] ?? '',
            title: profile['title'] ?? '',
            isAdmin: profile['is_admin'] ?? false,
          ),
        ),
      );
    } catch (e) {
      Navigator.pushReplacementNamed(context, "/login");
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
    );
  }
}
