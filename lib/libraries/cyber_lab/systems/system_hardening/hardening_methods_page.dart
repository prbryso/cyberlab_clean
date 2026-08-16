import 'package:flutter/material.dart';

class HardeningMethodsPage extends StatelessWidget {
  const HardeningMethodsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text("Hardening Methods")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Hardening Methods",
              style: text.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            _section(
              text,
              "Account Hardening",
              "Disable unused accounts, enforce strong passwords, and use least privilege.",
            ),

            _section(
              text,
              "Service Hardening",
              "Disable unnecessary services and daemons to reduce entry points.",
            ),

            _section(
              text,
              "Network Hardening",
              "Use firewalls, close unused ports, and segment networks.",
            ),

            _section(
              text,
              "OS Hardening",
              "Apply secure configurations, remove bloatware, and enable protections like ASLR.",
            ),

            _section(
              text,
              "Application Hardening",
              "Restrict macros, sandbox apps, and enforce secure defaults.",
            ),

            _section(
              text,
              "Physical Hardening",
              "Secure devices, BIOS/UEFI, and boot configurations.",
            ),

            const SizedBox(height: 32),
            Center(
              child: TextButton(
                onPressed: () => Navigator.pushNamed(context, "/hardening"),
                child: const Text("← Back to System Hardening Overview"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _section(TextTheme text, String title, String body) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: text.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(body, style: text.bodyLarge),
        ],
      ),
    );
  }
}
