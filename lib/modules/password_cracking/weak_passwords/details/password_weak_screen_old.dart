import 'package:flutter/material.dart';
import 'package:cyber_lab/theme/spacing.dart';
import '../../widgets/password_strength_lab.dart';
import '../../widgets/passphrase_generator.dart';
import '../../widgets/passphrase_builder.dart';
import '../../widgets/password_guessing_animation.dart';
import '../../widgets/lockout_simulator.dart';
import '../../widgets/password_analyzer.dart';
import '../../widgets/real_world_cases.dart';
import '../../widgets/common_password_mistakes.dart';
import '../../widgets/password_strength_workbench.dart';





class PasswordWeakScreenOld extends StatelessWidget {
  const PasswordWeakScreenOld ({super.key});

  @override
  Widget build(BuildContext context) {
    final spacing = CyberLabSpacing.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Weak Passwords"),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(spacing.xl),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ---------------------------------------------------------
                // INTRO
                // ---------------------------------------------------------
                Text(
                  "Why Some Passwords Fail",
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                SizedBox(height: spacing.md),

                Text(
                  "Weak passwords are easy for attackers to guess using dictionaries, leaked password lists, and brute‑force tools. "
                  "Short passwords are especially vulnerable because computers can try billions of guesses per second.",
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                SizedBox(height: spacing.lg),

                Text(
                  "Attackers don’t sit at a keyboard typing guesses — they use automated tools that can test millions or even billions of passwords every second. "
                  "This means that predictable, common, or short passwords fail almost instantly.",
                  style: Theme.of(context).textTheme.bodyLarge,
                ),

                SizedBox(height: spacing.xl),

                // ---------------------------------------------------------
                // COMMON WEAK PASSWORDS
                // ---------------------------------------------------------
                Text(
                  "Common Weak Passwords",
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                SizedBox(height: spacing.md),

                _WeakPasswordList(),

                SizedBox(height: spacing.lg),

                Text(
                  "These passwords fail because they appear in massive breach databases. "
                  "Attackers try these first because millions of people reuse them.",
                  style: Theme.of(context).textTheme.bodyLarge,
                ),

                SizedBox(height: spacing.xl),

                // ---------------------------------------------------------
                // WHY THEY ARE WEAK
                // ---------------------------------------------------------
                Text(
                  "Why These Passwords Are Weak",
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                SizedBox(height: spacing.md),

                _WeakReasons(),

                SizedBox(height: spacing.xl * 1.5),

                // ---------------------------------------------------------
                // WHY LENGTH MATTERS
                // ---------------------------------------------------------
                Text(
                  "Why Length Matters",
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                SizedBox(height: spacing.md),

                Text(
                  "Password length is the single most important factor in resisting brute‑force attacks. "
                  "Every extra character multiplies the number of possible combinations, making the password exponentially harder to crack.",
                  style: Theme.of(context).textTheme.bodyLarge,
                ),

                SizedBox(height: spacing.lg),

                _LengthTable(),

                // ---------------------------------------------------------
                // PASSPHRASES (NEW SUBSECTION)
                // ---------------------------------------------------------
                SizedBox(height: spacing.xl),

                Text(
                  "Passphrases: Length Made Easy",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                SizedBox(height: spacing.sm),

                Text(
                  "A passphrase is a long password made from multiple words. "
                  "Passphrases are one of the easiest ways to create extremely strong passwords because they combine "
                  "high length with natural memorability.",
                  style: Theme.of(context).textTheme.bodyLarge,
                ),

                SizedBox(height: spacing.md),

                Text(
                  "Examples of strong passphrases:",
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                SizedBox(height: spacing.sm),

                const _LimitedTryBullet("correct horse battery staple"),
                const _LimitedTryBullet("sunset river bicycle cloud"),
                const _LimitedTryBullet("the horse jumped the fence"),

                SizedBox(height: spacing.md),

                Text(
                  "Why passphrases work:",
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                SizedBox(height: spacing.sm),

                const _LimitedTryBullet("They are long — usually 20–30+ characters"),
                const _LimitedTryBullet("They create massive search spaces for attackers"),
                const _LimitedTryBullet("They are easier to remember than complex symbols"),
                const _LimitedTryBullet("They avoid predictable patterns like names or dates"),

                SizedBox(height: spacing.md),

                Text(
                  "Passphrases are now recommended by many security experts because they offer the best balance of "
                  "strength and usability.",
                  style: Theme.of(context).textTheme.bodyLarge,
                ),

                SizedBox(height: spacing.xl),
                PassphraseGenerator(),

                SizedBox(height: spacing.xl),
                const PassphraseBuilder(),


                // ---------------------------------------------------------
                // LIMITED TRIES
                // ---------------------------------------------------------
                SizedBox(height: spacing.xl * 1.5),

                Text(
                  "Limited Tries: Real‑World Protection",
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                SizedBox(height: spacing.md),

                Text(
                  "In the real world, attackers rarely get unlimited attempts to guess a password. "
                  "Most systems include protections that slow down or completely block brute‑force attacks.",
                  style: Theme.of(context).textTheme.bodyLarge,
                ),

                SizedBox(height: spacing.md),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .surfaceVariant
                        .withOpacity(0.4),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Common Limited‑Try Protections:",
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      SizedBox(height: spacing.sm),

                      SizedBox(height: spacing.xl),
                      LockoutSimulator(),


                      const _LimitedTryBullet(
                          "Account lockout after several failed attempts"),
                      const _LimitedTryBullet(
                          "Increasing delay between attempts (cooldown timer)"),
                      const _LimitedTryBullet(
                          "CAPTCHA challenges after repeated failures"),
                      const _LimitedTryBullet(
                          "Temporary IP blocking or rate limiting"),
                      const _LimitedTryBullet(
                          "Multi‑factor authentication required after failures"),

                      SizedBox(height: spacing.lg),

                      SizedBox(height: spacing.xl),
                      PasswordGuessingAnimation(),

                      SizedBox(height: spacing.xl),
                      PasswordAnalyzer(),

                      SizedBox(height: spacing.xl),
                      const RealWorldCases(),

                      SizedBox(height: spacing.xl),
                      const CommonPasswordMistakes(),

                      SizedBox(height: spacing.xl),
                      const PasswordStrengthWorkbench(),


                      // ---------------------------------------------------------
                      // CAPTCHA EXPLANATION
                      // ---------------------------------------------------------
                      Text(
                        "What Is CAPTCHA?",
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      SizedBox(height: spacing.sm),

                      Text(
                        "CAPTCHA is a challenge designed to tell humans and automated bots apart. "
                        "When a system detects repeated failed login attempts, it may require the user to solve a CAPTCHA "
                        "before allowing more tries. This prevents attackers from using automated tools to rapidly test passwords.",
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),

                      SizedBox(height: spacing.md),

                      Text(
                        "Common CAPTCHA types include:",
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      SizedBox(height: spacing.sm),

                      const _LimitedTryBullet(
                          "Selecting images that match a prompt (e.g., 'select all crosswalks')"),
                      const _LimitedTryBullet(
                          "Typing distorted letters or numbers"),
                      const _LimitedTryBullet(
                          "Checking a box labeled 'I'm not a robot'"),
                      const _LimitedTryBullet(
                          "Solving simple logic or pattern puzzles"),
                    ],
                  ),
                ),

                SizedBox(height: spacing.xl),

                // ---------------------------------------------------------
                // CHARSET EXPLANATION
                // ---------------------------------------------------------
                Text(
                  "What Is the “Full Charset”?",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                SizedBox(height: spacing.sm),

                Text(
                  "When attackers brute‑force a password, they try every possible character from a chosen set. "
                  "A “full charset” means the attacker is using all major character groups:",
                  style: Theme.of(context).textTheme.bodyLarge,
                ),

                SizedBox(height: spacing.md),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("• Lowercase letters (a–z)",
                        style: Theme.of(context).textTheme.bodyLarge),
                    Text("• Uppercase letters (A–Z)",
                        style: Theme.of(context).textTheme.bodyLarge),
                    Text("• Numbers (0–9)",
                        style: Theme.of(context).textTheme.bodyLarge),
                    Text("• Common symbols (! @ # \$ % ^ & * …)",
                        style: Theme.of(context).textTheme.bodyLarge),
                  ],
                ),

                SizedBox(height: spacing.xl),

                // ---------------------------------------------------------
                // COMBINATIONS FORMULA
                // ---------------------------------------------------------
                Text(
                  "How Do We Calculate the Number of Combinations?",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),

                SizedBox(height: spacing.sm),

                Text(
                  "When attackers brute‑force a password, they try every possible combination of characters. "
                  "The total number of combinations is calculated using a simple formula:",
                  style: Theme.of(context).textTheme.bodyLarge,
                ),

                SizedBox(height: spacing.md),

                Text(
                  "    (number of possible characters) ^ (password length)",
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontFamily: "monospace",
                        fontWeight: FontWeight.bold,
                      ),
                ),

                SizedBox(height: spacing.md),

                Text(
                  "This means that every extra character multiplies the total search space dramatically.",
                  style: Theme.of(context).textTheme.bodyLarge,
                ),

                SizedBox(height: spacing.md),

                Text(
                  "Example 1:\n"
                  "• Using only lowercase letters (26 characters)\n"
                  "• Password length: 6\n"
                  "• Total combinations: 26^6 = 308,915,776",
                  style: Theme.of(context).textTheme.bodyLarge,
                ),

                SizedBox(height: spacing.md),

                Text(
                  "Example 2:\n"
                  "• Using full charset (~95 characters)\n"
                  "• Password length: 10\n"
                  "• Total combinations: 95^10 ≈ 839 quadrillion",
                  style: Theme.of(context).textTheme.bodyLarge,
                ),

                SizedBox(height: spacing.xl * 1.5),

                // ---------------------------------------------------------
                // INTERACTIVE LAB
                // ---------------------------------------------------------
                Text(
                  "Explore Password Strength",
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),

                SizedBox(height: spacing.md),

                const PasswordStrengthLab(),

                SizedBox(height: spacing.xl * 2),

                // ---------------------------------------------------------
                // RETURN BUTTON
                // ---------------------------------------------------------
                Align(
                  alignment: Alignment.centerLeft,
                  child: FilledButton(
                    onPressed: () {
                      Navigator.pushNamed(context, "/password");
                    },
                    child: const Text("Return to Passwords"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------
// COMMON WEAK PASSWORDS
// ---------------------------------------------------------
class _WeakPasswordList extends StatelessWidget {
  final List<String> weakPasswords = const [
    "123456",
    "password",
    "qwerty",
    "abc123",
    "letmein",
    "iloveyou",
    "admin",
    "welcome",
    "dragon",
    "football",
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: weakPasswords
            .map(
              (pw) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text("• $pw", style: theme.textTheme.bodyLarge),
              ),
            )
            .toList(),
      ),
    );
  }
}

// ---------------------------------------------------------
// WHY THEY ARE WEAK
// ---------------------------------------------------------
class _WeakReasons extends StatelessWidget {
  final List<String> reasons = const [
    "They appear in breach databases used by attackers.",
    "They follow predictable patterns (keyboard order, names, sports).",
    "They are too short to resist brute‑force attacks.",
    "They use common substitutions like 'P@ssw0rd' that tools already know.",
    "Attackers try these passwords first because millions of people reuse them.",
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: reasons
          .map(
            (reason) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("• "),
                  Expanded(
                    child: Text(reason, style: theme.textTheme.bodyLarge),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

// ---------------------------------------------------------
// LENGTH TABLE
// ---------------------------------------------------------
class _LengthTable extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final rows = [
      ["6 characters", "a–z", "308 million", "< 1 second"],
      ["8 characters", "a–z + A–Z + 0–9", "218 trillion", "minutes"],
      ["10 characters", "full charset", "839 quadrillion", "days"],
      ["12 characters", "full charset", "3 sextillion", "centuries"],
      ["16 characters", "full charset", "7.9e28", "longer than the universe"],
    ];

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: theme.colorScheme.surfaceVariant.withOpacity(0.4),
      ),
      child: Table(
        columnWidths: const {
          0: FlexColumnWidth(1.4),
          1: FlexColumnWidth(1.2),
          2: FlexColumnWidth(1.2),
          3: FlexColumnWidth(1.2),
        },
        border: TableBorder.symmetric(
          inside: BorderSide(
            color: theme.colorScheme.outline.withOpacity(0.3),
          ),
        ),
        children: [
          TableRow(
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withOpacity(0.3),
            ),
            children: [
              _headerCell("Length", theme),
              _headerCell("Characters", theme),
              _headerCell("Combinations", theme),
              _headerCell("Crack Time", theme),
            ],
          ),
          for (final row in rows)
            TableRow(
              children: [
                _dataCell(row[0], theme),
                _dataCell(row[1], theme),
                _dataCell(row[2], theme),
                _dataCell(row[3], theme),
              ],
            ),
        ],
      ),
    );
  }

  Widget _headerCell(String text, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Text(
        text,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _dataCell(String text, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Text(text, style: theme.textTheme.bodyMedium),
    );
  }
}

// ---------------------------------------------------------
// BULLET WIDGET (USED FOR MULTIPLE SECTIONS)
// ---------------------------------------------------------
class _LimitedTryBullet extends StatelessWidget {
  final String text;

  const _LimitedTryBullet(this.text);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("• "),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyLarge,
            ),
          ),
        ],
      ),
    );
  }
}
