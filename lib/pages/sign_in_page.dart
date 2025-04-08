import 'package:flutter/material.dart';
import 'webview_page.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final TextEditingController nameController = TextEditingController(
    text: 'Manar',
  ); // default name
  final TextEditingController emailController = TextEditingController(
    text: 'manar@mail.com',
  ); // default email

  void _signIn() {
    final name = Uri.encodeComponent(nameController.text);
    final email = Uri.encodeComponent(emailController.text);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WebViewPage(name: name, email: email),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sign In")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Name"),
            ),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: "Email"),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _signIn, child: const Text("Sign In")),
          ],
        ),
      ),
    );
  }
}
