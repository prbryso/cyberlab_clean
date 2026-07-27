import 'package:flutter/material.dart';

class RealExamplesPage extends StatelessWidget {
  const RealExamplesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text("Real-World Examples")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TITLE
            Text(
              "Real-World Vulnerability Examples",
              style: text.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            Text(
              "These famous vulnerabilities show how a single flaw can lead to "
              "global damage. Each example highlights what went wrong, why it "
              "worked, and what defenders learned from it.",
              style: text.bodyLarge,
            ),

            const SizedBox(height: 32),

            // ETERNALBLUE
            _sectionHeader("1. EternalBlue — Windows SMB Vulnerability"),
            Text(
              "In 2017, a flaw in Windows’ SMBv1 file-sharing protocol allowed "
              "attackers to send a specially crafted packet and execute code "
              "remotely — no login required.",
              style: text.bodyLarge,
            ),
            const SizedBox(height: 12),
            _bullet("SMBv1 was old and insecure"),
            _bullet("Millions of systems were unpatched"),
            _bullet("The exploit required no authentication"),
            const SizedBox(height: 12),
            Text(
              "Impact: WannaCry ransomware used EternalBlue to spread across the "
              "world in hours, hitting hospitals, shipping companies, and "
              "governments.",
              style: text.bodyLarge,
            ),
            const SizedBox(height: 12),
            _takeaway(
              "A single unpatched OS vulnerability can cause global damage.",
            ),

            const SizedBox(height: 32),

            // LOG4SHELL
            _sectionHeader(
              "2. Log4Shell — A Tiny Logging Library Breaks the Internet",
            ),
            Text(
              "Log4j, a popular Java logging library, allowed attackers to trigger "
              "remote code execution by sending a malicious string that the logger "
              "would process.",
              style: text.bodyLarge,
            ),
            const SizedBox(height: 12),
            _bullet("Log4j was used in millions of applications"),
            _bullet("The vulnerability was trivial to exploit"),
            _bullet("Many apps didn’t know they were using Log4j"),
            const SizedBox(height: 12),
            Text(
              "Impact: Companies scrambled to find and patch every system using "
              "the library — a massive global effort.",
              style: text.bodyLarge,
            ),
            const SizedBox(height: 12),
            _takeaway(
              "Application vulnerabilities can hide deep inside dependencies.",
            ),

            const SizedBox(height: 32),

            // DIRTY COW
            _sectionHeader("3. Dirty COW — Linux Kernel Race Condition"),
            Text(
              "A flaw in how Linux handled memory copy-on-write allowed attackers "
              "to overwrite read-only files and escalate to root.",
              style: text.bodyLarge,
            ),
            const SizedBox(height: 12),
            _bullet("The bug existed for nearly a decade"),
            _bullet("It affected almost every Linux distribution"),
            _bullet("Exploits were reliable and fast"),
            const SizedBox(height: 12),
            Text(
              "Impact: Attackers could turn a normal user account into full "
              "system control.",
              style: text.bodyLarge,
            ),
            const SizedBox(height: 12),
            _takeaway(
              "Privilege escalation flaws turn small breaches into total compromise.",
            ),

            const SizedBox(height: 32),

            // FOLLINA
            _sectionHeader("4. Follina — Microsoft Office Zero-Click Exploit"),
            Text(
              "Attackers discovered that opening a Word document could trigger the "
              "Microsoft Support Diagnostic Tool (MSDT) and run arbitrary code.",
              style: text.bodyLarge,
            ),
            const SizedBox(height: 12),
            _bullet("MSDT was never meant to be invoked this way"),
            _bullet("Office automatically fetched remote templates"),
            _bullet("No macros were required"),
            const SizedBox(height: 12),
            Text(
              "Impact: Used heavily in phishing campaigns because victims didn’t "
              "need to enable anything.",
              style: text.bodyLarge,
            ),
            const SizedBox(height: 12),
            _takeaway(
              "Attackers love features that behave in unexpected ways.",
            ),

            const SizedBox(height: 32),

            // HEARTBLEED
            _sectionHeader(
              "5. Heartbleed — The Bug That Leaked the Internet’s Secrets",
            ),
            Text(
              "A flaw in OpenSSL’s heartbeat feature allowed attackers to read "
              "chunks of server memory — including passwords, cookies, and "
              "private keys.",
              style: text.bodyLarge,
            ),
            const SizedBox(height: 12),
            _bullet("A simple bounds-checking mistake"),
            _bullet("OpenSSL was used everywhere"),
            _bullet("No logs or traces were left"),
            const SizedBox(height: 12),
            Text(
              "Impact: Millions of websites had to regenerate certificates and "
              "reset passwords.",
              style: text.bodyLarge,
            ),
            const SizedBox(height: 12),
            _takeaway(
              "Tiny mistakes in security-critical code can have massive consequences.",
            ),

            const SizedBox(height: 48),

            // BACK BUTTON
            Center(
              child: TextButton(
                onPressed: () => Navigator.pushNamed(context, "/os-holes"),
                child: const Text("← Back to OS & Application Holes Overview"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Reusable section header
  Widget _sectionHeader(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
      ),
    );
  }

  // Bullet point widget
  Widget _bullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("• "),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  // Takeaway highlight
  Widget _takeaway(String text) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        "Takeaway: $text",
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }
}
