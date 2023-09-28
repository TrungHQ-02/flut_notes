import 'package:flut_notes/constants/routes.dart';
import 'package:flut_notes/services/auth/auth_exceptions.dart';
import 'package:flut_notes/services/auth/auth_service.dart';
import 'package:flut_notes/utilities/show_error_dialog.dart';
import 'package:flutter/material.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
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
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Register'),
      ),
      body: Column(
        children: [
          TextField(
            decoration: const InputDecoration(hintText: 'Enter your email'),
            controller: _email,
            enableSuggestions: false,
            autocorrect: false,
            keyboardType: TextInputType.emailAddress,
          ),
          TextField(
            decoration: const InputDecoration(hintText: 'Enter your password'),
            controller: _password,
            obscureText: true,
            enableSuggestions: false,
            autocorrect: false,
          ),
          TextButton(
            onPressed: () async {
              final email = _email.text;
              final password = _password.text;

              try {
                await AuthService.firebase().createUser(
                  email: email,
                  password: password,
                );
                await AuthService.firebase().sendEmailVerification();
                if (!context.mounted) return;
                Navigator.of(context).pushNamed(verifyEmailRoute);
              } on WeakPasswordAuthException {
                if (!context.mounted) return;
                await showErrorDialog(
                  context,
                  'Weak password',
                );
              } on EmailAlreadyInUseAuthException {
                if (!context.mounted) return;
                await showErrorDialog(
                  context,
                  'Email is already in use!',
                );
              } on InvalidEmailAuthException {
                if (!context.mounted) return;
                await showErrorDialog(
                  context,
                  'Invalid email!',
                );
              } on GenericAuthException {
                if (!context.mounted) return;
                await showErrorDialog(
                  context,
                  'Failed to register',
                );
              }
            },
            child: const Text('Register'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context)
                  .pushNamedAndRemoveUntil(loginRoute, (route) => false);
            },
            child: const Text('Already registered, login here!'),
          )
        ],
      ),
    );
  }
}
