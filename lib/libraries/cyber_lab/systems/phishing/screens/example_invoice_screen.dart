import 'package:flutter/material.dart';
import '../phishing_widgets.dart';

class ExampleInvoiceScreen extends StatelessWidget {
  const ExampleInvoiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Example: Fake Invoice')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SectionCard(
            title: 'Fake Invoice Email',
            children: [
              KeyValue('Subject', 'Invoice #88421 — Payment Required'),
              KeyValue(
                'From',
                'Billing Department <billing@payments-center.com>',
              ),
              KeyValue('To', 'you@example.com'),
              const SizedBox(height: 12),
              const Text(
                '“Your payment is overdue. Please review the attached invoice to avoid penalties.”',
              ),
              const SizedBox(height: 16),
              KeyValue('Attachment', 'invoice_88421.pdf'),
            ],
          ),

          SectionCard(
            title: 'Red Flags',
            children: const [
              Bullet('Unexpected invoice — you didn’t buy anything.'),
              Bullet('Urgent tone designed to scare you.'),
              Bullet('Attachment instead of a secure portal link.'),
              Bullet('Suspicious domain (payments-center.com).'),
              Bullet('Generic “Billing Department” sender.'),
            ],
          ),

          SectionCard(
            title: 'Why This Is Phishing',
            children: const [
              Text(
                'Attackers use fake invoices because people panic when they see unexpected charges. '
                'The attachment often contains malware or a fake login page.',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
