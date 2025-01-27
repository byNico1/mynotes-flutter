import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login"),
      ),
      body: Column(children: [
        TextField(
          controller: _email,
          enableSuggestions: false,
          autocorrect: false,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(hintText: "Enter your email"),
        ),
        TextField(
          controller: _password,
          obscureText: true,
          enableSuggestions: false,
          autocorrect: false,
          decoration: const InputDecoration(hintText: "Enter your password"),
        ),
        TextButton(
            onPressed: () async {
              final email = _email.text;
              final password = _password.text;
              try {
                final userCredentials = await FirebaseAuth.instance
                    .signInWithEmailAndPassword(
                        email: email, password: password);
                print('userCredentials: $userCredentials');
              } on FirebaseAuthException catch (e) {
                switch (e.code) {
                  case "invalid-credential":
                    print("Incorrect e-mail or password.");
                    break;
                  case "invalid-email":
                    print("Invalid e-mail provided.");
                    break;
                  default:
                    print("An error occurred: ${e.message}");
                    print('error code: ${e.code}');
                }
              }
            },
            child: const Text("Login")),
        TextButton(
            onPressed: () {
              Navigator.of(context)
                  .pushNamedAndRemoveUntil("/register/", (route) => false);
            },
            child: const Text("Not registered yet? Register here"))
      ]),
    );
  }
}
