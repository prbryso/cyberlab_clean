import 'package:flutter/material.dart';
import '../phishing_widgets.dart';

class ExampleDeliveryScreen extends StatelessWidget {
  const ExampleDeliveryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Example: Delivery Notification Scam')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SectionCard(
            title: 'Delivery Notification Scam',
            children: [
              KeyValue('Subject', 'Your Package Could Not Be Delivered'),
              KeyValue('From', 'Shipping Updates <notify@delivery-status.com>'),
              KeyValue('To', 'you@example.com'),
              const SizedBox(height: 12),
              const Text(
                '“We attempted to deliver your package but need additional information. '
                'Please confirm your address using the link below.”',
              ),
              const SizedBox(height: 16),
              KeyValue('Link', 'delivery-status.com/confirm'),
            ],
          ),

          SectionCard(
            title: 'Red Flags',
            children: const [
              Bullet('You are not expecting a package.'),
              Bullet('Suspicious domain (delivery-status.com).'),
              Bullet('Urgency designed to make you click.'),
              Bullet('Requests personal information.'),
              Bullet('Generic sender name.'),
            ],
          ),

          SectionCard(
            title: 'Why This Is Phishing',
            children: const [
              Text(
                'Delivery scams are common because people frequently order online. '
                'Attackers use fake delivery notices to steal personal information.',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
