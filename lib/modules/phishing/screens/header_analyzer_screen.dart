import 'package:flutter/material.dart';
import '../phishing_widgets.dart';

class HeaderAnalyzerScreen extends StatelessWidget {
  const HeaderAnalyzerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Email Header Analyzer')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          SectionCard(
            title: 'From',
            children: [
              KeyValue('Value', 'sender@example.com'),
              Text('This can be spoofed or forged. Always verify.'),
            ],
          ),
          SectionCard(
            title: 'Reply-To',
            children: [
              KeyValue('Value', 'attacker@evil.com'),
              Text('Attackers often redirect replies to a different address.'),
            ],
          ),
          SectionCard(
            title: 'To',
            children: [
              KeyValue('Value', '(undisclosed recipients)'),
              Text('Indicates mass BCC sending — a common phishing tactic.'),
            ],
          ),
          SectionCard(
            title: 'Received',
            children: [
              KeyValue('Value', 'from unknown server (RU)'),
              Text('Shows the real sending server. This one is suspicious.'),
            ],
          ),
        ],
      ),
    );
  }
}
