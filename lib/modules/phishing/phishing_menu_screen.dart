import 'package:flutter/material.dart';

class PhishingMenuScreen extends StatelessWidget {
  const PhishingMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Phishing Detective')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _MenuTile(
            title: 'Overview',
            subtitle: 'Learn what phishing is and how it works.',
            route: '/phishing/module',
          ),
          _MenuTile(
            title: 'Examples Gallery',
            subtitle: 'See real-world phishing scenarios.',
            route: '/phishing/examples',
          ),
          _MenuTile(
            title: 'Spot the Red Flags',
            subtitle: 'Interactive phishing detection activity.',
            route: '/phishing/spot',
          ),
          _MenuTile(
            title: 'Header Analyzer',
            subtitle: 'Learn how attackers spoof email headers.',
            route: '/phishing/header',
          ),
          _MenuTile(
            title: 'Phishing Quiz',
            subtitle: 'Test your knowledge.',
            route: '/phishing/quiz',
          ),
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String route;

  const _MenuTile({
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
