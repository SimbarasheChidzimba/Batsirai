import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: Padding(
        padding: const EdgeInsets.all(Spacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Create Account', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: Spacing.xl),
            const TextField(decoration: InputDecoration(labelText: 'Email')),
            const SizedBox(height: Spacing.md),
            const TextField(decoration: InputDecoration(labelText: 'Phone Number')),
            const SizedBox(height: Spacing.md),
            const TextField(decoration: InputDecoration(labelText: 'Password'), obscureText: true),
            const SizedBox(height: Spacing.xl),
            ElevatedButton(onPressed: () => context.go('/home'), child: const Text('Create Account')),
          ],
        ),
      ),
    );
  }
}
