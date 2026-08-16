import 'package:flutter/material.dart';
import '../phishing_widgets.dart';

class ExampleInvitationScreen extends StatelessWidget {
  const ExampleInvitationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Example: Suspicious Invitation')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SectionCard(
            title: 'Suspicious Invitation Email',
            children: [
              KeyValue(
                'Subject',
                'You’re invited to join her in celebrating a special moment',
              ),
              KeyValue('From', 'Sender Name <sender@example.com>'),
              KeyValue('To', '(Recipient hidden — you were BCC’d)'),
              const SizedBox(height: 12),
              const Text(
                '“Please open the event page on your computer — the view is clearer '
                'and the RSVP is effortless!”',
              ),
              const SizedBox(height: 16),
              KeyValue('Attachment', 'invitation_page.html'),
            ],
          ),

          SectionCard(
            title: 'Red Flags',
            children: const [
              Bullet(
                'You were BCC’d — legitimate invitations don’t hide recipients.',
              ),
              Bullet('Vague emotional subject line — curiosity bait.'),
              Bullet('Generic invitation wording — common scam template.'),
              Bullet(
                'Push to open an attachment — #1 malware delivery method.',
              ),
              Bullet(
                'Sender identity mismatch — even familiar names can be compromised.',
              ),
              Bullet('Missing event details — no who, what, when, or where.'),
            ],
          ),

          SectionCard(
            title: 'Why This Is Phishing',
            children: const [
              Text(
                'This email relies on emotional manipulation and curiosity. '
                'Attackers often use vague invitations to trick victims into opening '
                'malicious attachments.',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
