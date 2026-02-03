import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'secure_storage_service.dart';
import 'pin_login_screen.dart';
import 'set_pin_screen.dart';
import 'screens/login_screen.dart';
import 'reset_password_with_pin.dart';
import 'register_screen.dart';

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  Future<void> _loginWithPinOrBiometrics(BuildContext context) async {
    final savedPin = await SecureStorageService.getPin();
    final auth = LocalAuthentication();

    // 🔥 Jeśli PIN nie ustawiony → ustawiamy PIN
    if (savedPin == null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const SetPinScreen()),
      );
      return;
    }

    // 🔥 Sprawdzamy czy biometria jest dostępna i skonfigurowana
    bool canCheck = false;
    try {
      canCheck = await auth.canCheckBiometrics;
    } catch (_) {
      canCheck = false;
    }

    List<BiometricType> available = [];
    try {
      available = await auth.getAvailableBiometrics();
    } catch (_) {
      available = [];
    }

    final bool biometriaDostepna = canCheck && available.isNotEmpty;

    // 🔥 Jeśli biometria dostępna → próbujemy logować
    if (biometriaDostepna) {
      try {
        final bool success = await auth.authenticate(
          localizedReason: "Zaloguj się biometrią",
          options: const AuthenticationOptions(
            biometricOnly: true,
            stickyAuth: true,
          ),
        );

        if (success) {
          Navigator.pushReplacementNamed(context, "/userHome");
          return;
        }
      } catch (_) {
        // biometria rzuciła wyjątek → przechodzimy do PIN
      }
    }

    // 🔥 Jeśli biometria niedostępna lub nieudana → PIN
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PinLoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Menu główne')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.fingerprint),
                label: const Text('Zaloguj PIN / Biometria'),
                onPressed: () => _loginWithPinOrBiometrics(context),
              ),
              const SizedBox(height: 32),

              ElevatedButton.icon(
                icon: const Icon(Icons.login),
                label: const Text('Zaloguj się (email + hasło)'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                },
              ),
              const SizedBox(height: 24),

              OutlinedButton.icon(
                icon: const Icon(Icons.password),
                label: const Text('Zapomniałem hasła'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ResetPasswordWithPinScreen()),
                  );
                },
              ),
              const SizedBox(height: 24),

              ElevatedButton.icon(
                icon: const Icon(Icons.person_add),
                label: const Text('Zarejestruj się'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RegisterScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
