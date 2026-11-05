import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'services/secure_storage_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Secure Storage & HTTP',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const AuthGate(),
    );
  }
}

// Menentukan halaman awal: sudah ada token -> HomeScreen, belum -> LoginScreen
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: SecureStorageService().hasToken(),
      builder: (context, snapshot) {
        // Tampilkan loading selama mengecek token
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Jika terjadi error saat baca storage (misal di web), arahkan ke Login
        if (snapshot.hasError) {
          print('AuthGate error: ${snapshot.error}');
          return const LoginScreen();
        }

        // Arahkan berdasarkan keberadaan token
        return snapshot.data == true ? const HomeScreen() : const LoginScreen();
      },
    );
  }
}
