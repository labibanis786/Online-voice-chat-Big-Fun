import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  String? _verificationId;
  bool _codeSent = false;
  bool _loading = false;

  Future<void> _verifyPhone() async {
    setState(() { _loading = true; });
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: _phoneController.text.trim(),
      verificationCompleted: (PhoneAuthCredential credential) async {
        await FirebaseAuth.instance.signInWithCredential(credential);
        Navigator.pushReplacementNamed(context, '/home');
      },
      verificationFailed: (e) {
        setState(() { _loading = false; });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Verification failed: \$e')));
      },
      codeSent: (verificationId, resendToken) {
        setState(() { _verificationId = verificationId; _codeSent = true; _loading = false; });
      },
      codeAutoRetrievalTimeout: (verificationId) {
        _verificationId = verificationId;
      },
    );
  }

  Future<void> _signInWithCode() async {
    if (_verificationId == null) return;
    final cred = PhoneAuthProvider.credential(verificationId: _verificationId!, smsCode: _codeController.text.trim());
    await FirebaseAuth.instance.signInWithCredential(cred);
    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login with Phone')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _phoneController, decoration: const InputDecoration(labelText: 'Phone e.g. +8801XXXXXXXXX')),
            const SizedBox(height: 12),
            if (_codeSent) TextField(controller: _codeController, decoration: const InputDecoration(labelText: 'SMS Code')),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _loading ? null : () async {
                if (!_codeSent) {
                  await _verifyPhone();
                } else {
                  await _signInWithCode();
                }
              },
              child: Text(_codeSent ? 'Verify Code' : 'Send Code'),
            ),
          ],
        ),
      ),
    );
  }
}