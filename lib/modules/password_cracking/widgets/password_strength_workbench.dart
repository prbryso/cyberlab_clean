import 'dart:math';
import 'package:flutter/material.dart';

class PasswordStrengthWorkbench extends StatefulWidget {
  const PasswordStrengthWorkbench({super.key});

  @override
  State<PasswordStrengthWorkbench> createState() =>
      _PasswordStrengthWorkbenchState();
}

class _PasswordStrengthWorkbenchState extends State<PasswordStrengthWorkbench> {
  String password = "";

  // Character set detection
  bool get hasLower => RegExp(r'[a-z]').hasMatch(password);
  bool get hasUpper => RegExp(r'[A-Z]').hasMatch(password);
  bool get hasNumber => RegExp(r'[0-9]').hasMatch(password);
  bool get hasSymbol =>
      RegExp(r'[!@#\$%^&*()_\-+=\[\]{};:"\\|,.<>/?]').hasMatch(password);
  bool get hasSpace => password.contains(" ");

  int get charsetSize {
    int size = 0;
    if (hasLower) size += 26;
    if (hasUpper) size += 26;
    if (hasNumber) size += 10;
    if (hasSymbol) size += 33;
    if (hasSpace) size += 1;
    return size == 0 ? 1 : size;
  }

  // Entropy calculation
  double get entropyBits {
    if (password.isEmpty) return 0;
    return password.length * (log(charsetSize) / log(2));
  }

  // Crack time for different attack models
  String formatTime(double seconds) {
    if (seconds < 0.001) return "< 0.001 sec";
    if (seconds < 1) return "${seconds.toStringAsFixed(3)} sec";
    if (seconds < 60) return "${seconds.toStringAsFixed(1)} sec";
    if (seconds < 3600) return "${(seconds / 60).toStringAsFixed(1)} min";
    if (seconds < 86400) return "${(seconds / 3600).toStringAsFixed(1)} hr";
    if (seconds < 31536000) return "${(seconds / 86400).toStringAsFixed(1)} days";
    return "${(seconds / 31536000).toStringAsFixed(1)} yrs";
  }

  double get guesses => pow(2, entropyBits).toDouble();

  String get onlineTime => formatTime(guesses / 1);          // 1 guess/sec
  String get offlineTime => formatTime(guesses / 1e10);      // 10B/sec
  String get gpuTime => formatTime(guesses / 1e12);          // 1T/sec

  // Strength label
  String get strengthLabel {
    if (password.contains(" ")) return "Passphrase";
    if (entropyBits < 30) return "Weak";
    if (entropyBits < 60) return "Medium";
    return "Strong";
  }

  // Pattern detection
  List<String> get patterns {
    final List<String> list = [];

    if (RegExp(r'(1234|abcd|qwerty)').hasMatch(password.toLowerCase())) {
      list.add("Common sequence (1234, abcd, qwerty)");
    }

    if (RegExp(r'(password|letmein|dragon)').hasMatch(password.toLowerCase())) {
      list.add("Contains a common weak word");
    }

    if (RegExp(r'(19|20)\d{2}').hasMatch(password)) {
      list.add("Contains a year");
    }

    if (RegExp(r'(.)\1\1').hasMatch(password)) {
      list.add("Repeated characters");
    }

    if (password.length < 10) {
      list.add("Short length (< 10 chars)");
    }

    return list;
  }

  // Recommendations
  List<String> get recommendations {
    final List<String> list = [];

    if (password.length < 12) {
      list.add("Add more length — length increases security fastest.");
    }

    if (!hasSymbol) {
      list.add("Add a symbol to expand the character set.");
    }

    if (!hasUpper) {
      list.add("Add uppercase letters for more entropy.");
    }

    if (password.contains(" ")) {
      list.add("Passphrases are strong — consider adding a 5th word.");
    }

    if (patterns.isNotEmpty) {
      list.add("Avoid predictable patterns.");
    }

    return list;
  }

  // Strength bar fill (0–1)
  double get strengthPercent {
    if (entropyBits >= 80) return 1.0;
    return entropyBits / 80;
  }

  Widget checkRow(String label, bool active, ThemeData theme) {
    return Row(
      children: [
        Icon(
          active ? Icons.check_circle : Icons.cancel,
          color: active
              ? theme.colorScheme.primary
              : theme.colorScheme.error.withOpacity(0.7),
          size: 20,
        ),
        const SizedBox(width: 8),
        Text(label, style: theme.textTheme.bodyLarge),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Password Strength Workbench",
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 16),

        TextField(
          onChanged: (v) => setState(() => password = v),
          decoration: const InputDecoration(
            labelText: "Type any password...",
            border: OutlineInputBorder(),
          ),
        ),

        const SizedBox(height: 24),

        // ENTROPY BAR
        Container(
          height: 14,
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceVariant.withOpacity(0.4),
            borderRadius: BorderRadius.circular(8),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: strengthPercent,
            child: Container(
              decoration: BoxDecoration(
                color: password.contains(" ")
                    ? Colors.blue
                    : entropyBits < 30
                        ? Colors.red
                        : entropyBits < 60
                            ? Colors.orange
                            : Colors.green,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),

        const SizedBox(height: 24),

      if (password.isEmpty)
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceVariant.withOpacity(0.4),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "🔍 Waiting for input…",
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Type a password above to see entropy, crack times, patterns, and recommendations.",
                style: theme.textTheme.bodyLarge,
              ),
            ],
          ),
        ),



        if (password.isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // CHARSET PANEL
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceVariant.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Character Set Breakdown",
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        )),
                    const SizedBox(height: 12),
                    checkRow("Lowercase (a–z)", hasLower, theme),
                    checkRow("Uppercase (A–Z)", hasUpper, theme),
                    checkRow("Numbers (0–9)", hasNumber, theme),
                    checkRow("Symbols", hasSymbol, theme),
                    checkRow("Spaces", hasSpace, theme),
                    const SizedBox(height: 12),
                    Text("Charset size: $charsetSize",
                        style: theme.textTheme.bodyLarge),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ENTROPY PANEL
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceVariant.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Entropy Analysis",
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        )),
                    const SizedBox(height: 12),
                    Text("Entropy: ${entropyBits.toStringAsFixed(1)} bits",
                        style: theme.textTheme.bodyLarge),
                    const SizedBox(height: 8),
                    Text(
                      "Formula: entropy = length × log₂(charset)\n"
                      "→ ${password.length} × log₂($charsetSize)",
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontFamily: "monospace",
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ATTACK MODEL PANEL
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceVariant.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Crack Time (Different Attack Models)",
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        )),
                    const SizedBox(height: 12),
                    Text("Online attack (1/sec): $onlineTime",
                        style: theme.textTheme.bodyLarge),
                    Text("Offline attack (10B/sec): $offlineTime",
                        style: theme.textTheme.bodyLarge),
                    Text("GPU cluster (1T/sec): $gpuTime",
                        style: theme.textTheme.bodyLarge),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // PATTERN PANEL
              if (patterns.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceVariant.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Detected Patterns",
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          )),
                      const SizedBox(height: 12),
                      for (final p in patterns)
                        Text("• $p", style: theme.textTheme.bodyLarge),
                    ],
                  ),
                ),

              const SizedBox(height: 24),

              // RECOMMENDATIONS PANEL
              if (recommendations.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceVariant.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Recommendations",
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          )),
                      const SizedBox(height: 12),
                      for (final r in recommendations)
                        Text("• $r", style: theme.textTheme.bodyLarge),
                    ],
                  ),
                ),
            ],
          ),
      ],
    );
  }
}
