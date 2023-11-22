import 'package:flut_notes/services/auth/auth_service.dart';
import 'package:flut_notes/services/auth/bloc/auth_bloc.dart';
import 'package:flut_notes/services/auth/bloc/auth_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({super.key});

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Email Verification'),
      ),
      body: Column(
        children: [
          const Text(
              'We have sent you a code via your email address. Please open it to verify your account!'),
          TextButton(
            onPressed: () async {
              await AuthService.firebase().sendEmailVerification();
            },
            child: const Text('You dont get the email! Resend it here!'),
          ),
          TextButton(
            onPressed: () async {
              context.read()<AuthBloc>().add(const AuthEventLogout());
            },
            child: const Text('Restart'),
          )
        ],
      ),
    );
  }
}
