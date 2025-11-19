import 'package:flutter/material.dart';
import 'package:storage/uploadPage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  await Supabase.initialize(
    url: 'https://gfhdvdiupstpyudvimec.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdmaGR2ZGl1cHN0cHl1ZHZpbWVjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjM1MDk5MjIsImV4cCI6MjA3OTA4NTkyMn0.zKrM5HfzjvjyLX6kM_PmPKiA8xIdjgITIk8qTsICsdo'
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: UploadPage(),
      ),
    );
  }

}