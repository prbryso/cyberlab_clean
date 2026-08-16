import 'package:flutter/material.dart';
import '../phishing_widgets.dart';

class SpotRedFlagsScreen extends StatefulWidget {
  const SpotRedFlagsScreen({super.key});

  @override
  State<SpotRedFlagsScreen> createState() => SpotRedFlagsScreenState();
}

class SpotRedFlagsScreenState extends State<SpotRedFlagsScreen> {
  final Set<int> found = {};

  final List<Map<String, String>> flags = [
    {
      'title': 'Vague Subject Line',
      'desc': 'The subject is emotional but provides no real details.',
    },
    {
      'title': 'Unexpected Attachment',
      'desc': 'Attachments are the #1 malware delivery method.',
    },
    {
      'title': 'Sender Mismatch',
      'desc': 'The sender name doesn’t match the email address.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Spot the Red Flags')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Below is a simplified mock email. Tap each red flag you notice.',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),

          // Mock email card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('From: Sender Name <sender@example.com>'),
                  Text('To: (Recipient hidden — BCC)'),
                  Text('Subject: You’re invited to join her…'),
                  SizedBox(height: 12),
                  Text(
                    '“Please open the event page on your computer — the view is clearer '
                    'and the RSVP is effortless!”',
                  ),
                  SizedBox(height: 12),
                  Text('Attachment: invitation_page.html'),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),
          const Text('Tap each red flag below:'),
          const SizedBox(height: 12),

          ...List.generate(flags.length, (i) {
            final isFound = found.contains(i);
            return Card(
              child: ListTile(
                title: Text(flags[i]['title']!),
                trailing: Icon(
                  isFound ? Icons.check_circle : Icons.circle_outlined,
                  color: isFound ? Colors.green : Colors.grey,
                ),
                onTap: () => setState(() => found.add(i)),
                subtitle: isFound ? Text(flags[i]['desc']!) : null,
              ),
            );
          }),

          const SizedBox(height: 24),
          Text(
            'Found ${found.length} of ${flags.length} red flags',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
