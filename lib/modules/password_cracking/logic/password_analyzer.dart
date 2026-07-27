class PasswordAnalysisResult {
  final int strengthScore; // 0–100
  final String crackTime;
  final String likelyAttack;

  PasswordAnalysisResult({
    required this.strengthScore,
    required this.crackTime,
    required this.likelyAttack,
  });
}

class PasswordAnalyzer {
  static PasswordAnalysisResult analyze(String password) {
    if (password.isEmpty) {
      return PasswordAnalysisResult(
        strengthScore: 0,
        crackTime: "Instant",
        likelyAttack: "N/A",
      );
    }

    int score = 0;

    // Length
    score += (password.length * 5).clamp(0, 40);

    // Character variety
    if (RegExp(r'[A-Z]').hasMatch(password)) score += 10;
    if (RegExp(r'[a-z]').hasMatch(password)) score += 10;
    if (RegExp(r'[0-9]').hasMatch(password)) score += 10;
    if (RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(password)) score += 10;

    // Estimate crack time (simple model)
    String crackTime;
    String attack;

    if (score < 30) {
      crackTime = "Instant to seconds";
      attack = "Dictionary attack";
    } else if (score < 60) {
      crackTime = "Minutes to hours";
      attack = "Hybrid attack";
    } else if (score < 80) {
      crackTime = "Days to weeks";
      attack = "Brute force";
    } else {
      crackTime = "Years to centuries";
      attack = "Brute force (very slow)";
    }

    return PasswordAnalysisResult(
      strengthScore: score.clamp(0, 100),
      crackTime: crackTime,
      likelyAttack: attack,
    );
  }
}
