import 'package:flutter/material.dart';

class RealWorldCryptoFailuresScreen extends StatelessWidget {
  const RealWorldCryptoFailuresScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Real-World Crypto Failures')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // --------------------------------------------------
            // Intro
            // --------------------------------------------------
            Text(
              'When Encryption Fails in the Real World',
              style: theme.textTheme.headlineMedium,
            ),
            const SizedBox(height: 12),
            Text(
              'Cryptography is powerful, but real systems fail for very human reasons: bad randomness, '
              'implementation bugs, design shortcuts, and misunderstood assumptions. These case studies show '
              'how small mistakes can break even strong algorithms—and what we should learn from them.',
              style: theme.textTheme.bodyLarge,
            ),

            const SizedBox(height: 24),

            // --------------------------------------------------
            // Timeline Diagram
            // --------------------------------------------------
            Text(
              'Timeline of Major Crypto Failures',
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            _TimelineDiagram(theme: theme),
            const SizedBox(height: 24),

            // --------------------------------------------------
            // 1. Sony PlayStation 3 ECDSA Disaster
            // --------------------------------------------------
            Text(
              '1. Sony PlayStation 3 ECDSA Disaster (2010)',
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'What happened:\n'
              'Sony used ECDSA (Elliptic Curve Digital Signature Algorithm) to sign PS3 firmware. '
              'ECDSA requires a fresh random number (nonce) for every signature. Sony reused the same nonce.\n\n'
              'What failed:\n'
              'Reusing the nonce made it mathematically possible to recover the private signing key.\n\n'
              'Impact:\n'
              'Attackers could sign their own firmware as if it were official Sony firmware. The PS3’s security model collapsed.\n\n'
              'Takeaway:\n'
              'Perfect math can be destroyed by bad randomness.',
              style: theme.textTheme.bodyLarge,
            ),

            const SizedBox(height: 24),

            // --------------------------------------------------
            // 2. Debian OpenSSL Catastrophe
            // --------------------------------------------------
            Text(
              '2. Debian OpenSSL Catastrophe (2006–2008)',
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'What happened:\n'
              'A Debian developer removed a few lines of code that looked unnecessary. Those lines were actually feeding '
              'entropy into OpenSSL’s random number generator.\n\n'
              'What failed:\n'
              'Keys generated on Debian/Ubuntu for about two years had extremely low entropy—only a tiny keyspace.\n\n'
              'Impact:\n'
              'SSH keys, TLS certificates, and VPN keys were guessable. Attackers could brute-force private keys in minutes.\n\n'
              'Takeaway:\n'
              'Weak randomness breaks encryption, no matter how strong the algorithm.',
              style: theme.textTheme.bodyLarge,
            ),

            const SizedBox(height: 24),

            // --------------------------------------------------
            // 3. Heartbleed
            // --------------------------------------------------
            Text('3. Heartbleed (2014)', style: theme.textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(
              'What happened:\n'
              'A buffer over-read bug in OpenSSL’s heartbeat extension allowed attackers to read chunks of server memory.\n\n'
              'What failed:\n'
              'Not the cryptographic math, but the implementation around it.\n\n'
              'Impact:\n'
              'Attackers could potentially extract private keys, passwords, session cookies, and other sensitive data from RAM.\n\n'
              'Takeaway:\n'
              'Crypto is only as strong as the code that implements it.',
              style: theme.textTheme.bodyLarge,
            ),

            const SizedBox(height: 24),

            // --------------------------------------------------
            // 4. WEP Wi‑Fi Encryption Collapse
            // --------------------------------------------------
            Text(
              '4. WEP Wi‑Fi Encryption Collapse (late 1990s–2004)',
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'What happened:\n'
              'WEP used RC4 with a 24-bit initialization vector (IV). IVs repeated frequently on busy networks.\n\n'
              'What failed:\n'
              'Repeated IVs allowed attackers to use statistical attacks to recover the key.\n\n'
              'Impact:\n'
              'WEP networks could be cracked in minutes. WEP was eventually replaced by WPA and WPA2.\n\n'
              'Takeaway:\n'
              'Small design flaws become catastrophic at scale.',
              style: theme.textTheme.bodyLarge,
            ),

            const SizedBox(height: 24),

            // --------------------------------------------------
            // 5. NTLM Password Hashes
            // --------------------------------------------------
            Text(
              '5. NTLM Password Hashes (Ongoing Legacy Issue)',
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'What happened:\n'
              'Windows NT LAN Manager (NTLM) used unsalted, fast MD4-based hashes for passwords.\n\n'
              'What failed:\n'
              'No salt and a very fast hash function made it easy to use rainbow tables and brute force.\n\n'
              'Impact:\n'
              'Password databases could be cracked quickly, and NTLM remains a target in legacy environments.\n\n'
              'Takeaway:\n'
              'Fast hashing is bad for password storage. Password hashes must be slow and salted.',
              style: theme.textTheme.bodyLarge,
            ),

            const SizedBox(height: 24),

            // --------------------------------------------------
            // 6. WhatsApp Padding Oracle-Style Issue
            // --------------------------------------------------
            Text(
              '6. WhatsApp Message Manipulation (2019)',
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'What happened:\n'
              'Researchers found ways to manipulate certain encrypted WhatsApp messages in group chats.\n\n'
              'What failed:\n'
              'The issue was not the core encryption algorithm, but how message integrity and authentication were handled.\n\n'
              'Impact:\n'
              'Attackers could alter the content of some messages, undermining trust in what was seen on screen.\n\n'
              'Takeaway:\n'
              'Encryption without strong integrity checks is not truly secure.',
              style: theme.textTheme.bodyLarge,
            ),

            const SizedBox(height: 24),

            // --------------------------------------------------
            // 7. Dual_EC_DRBG Backdoor
            // --------------------------------------------------
            Text(
              '7. Dual_EC_DRBG Random Number Generator (2006–2013)',
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'What happened:\n'
              'A NIST-approved random number generator, Dual_EC_DRBG, was later suspected of containing an intentional backdoor.\n\n'
              'What failed:\n'
              'Its design allowed anyone who knew a secret parameter to predict future outputs of the RNG.\n\n'
              'Impact:\n'
              'Systems that used this RNG (including some VPNs and TLS implementations) may have been vulnerable to hidden surveillance.\n\n'
              'Takeaway:\n'
              'Even standardized cryptography can be sabotaged. Trust and transparency in design matter.',
              style: theme.textTheme.bodyLarge,
            ),

            const SizedBox(height: 32),

            // --------------------------------------------------
            // Closing Summary
            // --------------------------------------------------
            Text(
              'What These Failures Teach Us',
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Across all of these cases, the pattern is clear:\n\n'
              '• Strong algorithms can be broken by weak randomness.\n'
              '• Implementation bugs can leak secrets even when the math is sound.\n'
              '• Design shortcuts (like small IVs or fast password hashes) become fatal at scale.\n'
              '• Trust in cryptography depends on open, well-reviewed designs.\n\n'
              'Real-world cryptography is not just about equations—it is about careful engineering, good defaults, and '
              'respecting the details.',
              style: theme.textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}

// --------------------------------------------------
// Simple vertical timeline diagram widget
// --------------------------------------------------
class _TimelineDiagram extends StatelessWidget {
  final ThemeData theme;

  const _TimelineDiagram({required this.theme});

  @override
  Widget build(BuildContext context) {
    final color = theme.colorScheme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _TimelineItem(
          year: '2000s',
          title: 'Debian OpenSSL RNG',
          color: color,
          theme: theme,
          description: 'Weak randomness in key generation.',
        ),
        _TimelineConnector(color: color),
        _TimelineItem(
          year: '2000s',
          title: 'WEP Wi‑Fi Cracked',
          color: color,
          theme: theme,
          description: 'Design flaws in IV handling.',
        ),
        _TimelineConnector(color: color),
        _TimelineItem(
          year: '2010',
          title: 'PS3 ECDSA Failure',
          color: color,
          theme: theme,
          description: 'Nonce reuse exposed private key.',
        ),
        _TimelineConnector(color: color),
        _TimelineItem(
          year: '2014',
          title: 'Heartbleed',
          color: color,
          theme: theme,
          description: 'Implementation bug leaked secrets.',
        ),
        _TimelineConnector(color: color),
        _TimelineItem(
          year: '2010s',
          title: 'Dual_EC_DRBG',
          color: color,
          theme: theme,
          description: 'Suspected backdoor in RNG.',
        ),
        _TimelineConnector(color: color),
        _TimelineItem(
          year: '2019',
          title: 'WhatsApp Message Issues',
          color: color,
          theme: theme,
          description: 'Integrity/authentication weaknesses.',
        ),
      ],
    );
  }
}

class _TimelineItem extends StatelessWidget {
  final String year;
  final String title;
  final String description;
  final Color color;
  final ThemeData theme;

  const _TimelineItem({
    required this.year,
    required this.title,
    required this.description,
    required this.color,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left: year + dot
        Column(
          children: [
            Text(
              year,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
          ],
        ),
        const SizedBox(width: 12),
        // Right: title + description
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(description, style: theme.textTheme.bodyMedium),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ],
    );
  }
}

class _TimelineConnector extends StatelessWidget {
  final Color color;

  const _TimelineConnector({required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 32.0),
      child: Container(width: 2, height: 16, color: color.withOpacity(0.5)),
    );
  }
}
