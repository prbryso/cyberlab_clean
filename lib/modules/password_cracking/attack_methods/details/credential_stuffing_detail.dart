import 'package:flutter/material.dart';
import 'package:systems_studio/theme/spacing.dart';

class CredentialStuffingDetail extends StatelessWidget {
  const CredentialStuffingDetail({super.key});

  @override
  Widget build(BuildContext context) {
    final spacing = CyberLabSpacing.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Credential Stuffing")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(spacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Credential Stuffing",
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            SizedBox(height: spacing.md),

            Text(
              "If attackers steal your password from one site, they try it on others. "
              "Password reuse makes this attack extremely effective.",
              style: Theme.of(context).textTheme.bodyLarge,
            ),

            SizedBox(height: spacing.xl),

            Text(
              "Why It Works",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: spacing.sm),
            Text(
              "Most people reuse passwords across multiple accounts. "
              "Attackers simply test stolen credentials on banking, email, and shopping sites.",
              style: Theme.of(context).textTheme.bodyMedium,
            ),

            SizedBox(height: spacing.xl),

            Text(
              "How to Protect Yourself",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: spacing.sm),
            Text(
              "• Use unique passwords for every site\n"
              "• Enable two‑factor authentication\n"
              "• Use a password manager to avoid reuse",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
