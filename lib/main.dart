import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'screens/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Inisialisasi Supabase
  await Supabase.initialize(
    url: 'https://khrlrtsapdqbkjuzskew.supabase.co', // ganti dengan URL projectmu
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtocmxydHNhcGRxYmtqdXpza2V3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc5ODM0MjUsImV4cCI6MjA3MzU1OTQyNX0.V7u0uiOPIWN325dueyTn8KNqUd0zMettNSej44VsKDw', // ganti dengan anon key projectmu
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pendaftaran Sekolah',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      home: const SplashScreen(), // mulai dari splash screen
    );
  }
}
