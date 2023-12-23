import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:initial/constants/routes.dart';

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
        title: const Text('Verify Email'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Column(
        children: [
          const Text(
              'We have send you an email verification. Please open it to verify your account'),
          const Text(
              'If you haven\'t received a verification yet, press the button below'),
          TextButton(
            onPressed: () async {
              final user = FirebaseAuth.instance.currentUser;

              await user?.sendEmailVerification();
            },
            child: const Text('Send email Verification'),
          ),
          TextButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.of(context).pushNamedAndRemoveUntil(
                registerRoute,
                (route) => false,
              );
            },
            child: const Text('Restart'),
          ),
        ],
      ),
    );
  }
}
