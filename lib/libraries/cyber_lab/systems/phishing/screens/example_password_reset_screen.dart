import 'package:flutter/material.dart';
import '../phishing_widgets.dart';

class ExamplePasswordResetScreen extends StatelessWidget {
  const ExamplePasswordResetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Example: Password Reset Scam')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SectionCard(
            title: 'Password Reset Scam',
            children: [
              KeyValue('Subject', 'Your Password Reset Request'),
              KeyValue(
                'From',
                'Security Team <no-reply@secure-login-alert.com>',
              ),
              KeyValue('To', 'you@example.com'),
              const SizedBox(height: 12),
              const Text(
                '“We received a request to reset your password. If this was not you, '
                'please verify your account immediately.”',
              ),
              const SizedBox(height: 16),
              KeyValue('Link', 'secure-login-alert.com/reset'),
            ],
          ),

          SectionCard(
            title: 'Red Flags',
            children: const [
              Bullet('You did NOT request a password reset.'),
              Bullet('Suspicious domain name (secure-login-alert.com).'),
              Bullet('Urgency designed to make you click quickly.'),
              Bullet('Link does not match any real service you use.'),
              Bullet('Generic “Security Team” sender.'),
            ],
          ),

          SectionCard(
            title: 'Why This Is Phishing',
            children: const [
              Text(
                'Fake password reset emails are extremely common. '
                'They lead to fake login pages that steal your credentials.',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
