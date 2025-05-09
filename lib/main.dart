import 'package:flutter/material.dart';
import 'package:my_project/pages/webview_page.dart';
import 'pages/sign_in_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simple Flutter App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const WebViewPage(name: '', email: ''),
    );
  }
}
