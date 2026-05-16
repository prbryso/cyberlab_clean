import 'package:flutter/material.dart';
import '../phishing_widgets.dart';

class PhishingExamplesScreen extends StatelessWidget {
  const PhishingExamplesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Phishing Examples')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ExampleTile(
            title: 'Suspicious Invitation',
            subtitle: 'Emotional bait + BCC misuse',
            route: '/phishing/examples/invitation',
          ),
          ExampleTile(
            title: 'Fake Invoice',
            subtitle: 'Unexpected attachment',
            route: '/phishing/examples/invoice',
          ),
          ExampleTile(
            title: 'Password Reset Scam',
            subtitle: 'Fake login page',
            route: '/phishing/examples/password_reset',
          ),
          ExampleTile(
            title: 'Delivery Notification Scam',
            subtitle: 'Urgency + link trick',
            route: '/phishing/examples/delivery',
          ),
        ],
      ),
    );
  }
}

class ExampleTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String route;

  const ExampleTile({
    required this.title,
    required this.subtitle,
    required this.route,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.pushNamed(context, route),
      ),
    );
  }
}
