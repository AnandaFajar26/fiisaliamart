import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'profil/profil_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://ycnwnnvafilxemgmtfco.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InljbndubnZhZmlseGVtZ210ZmNvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTAwMzkxNzIsImV4cCI6MjA2NTYxNTE3Mn0._3Y1fP4VUBqnrf_zNHF1Vz5nfZ41x-z3UlLeG-9j-SI',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: ProfilScreen(),
    );
  }
}
