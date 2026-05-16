import 'dart:async';
import 'package:flutter/material.dart';

class PasswordGuessingAnimation extends StatefulWidget {
  const PasswordGuessingAnimation({super.key});

  @override
  State<PasswordGuessingAnimation> createState() =>
      _PasswordGuessingAnimationState();
}

class _PasswordGuessingAnimationState extends State<PasswordGuessingAnimation>
    with SingleTickerProviderStateMixin {
  late Timer _timer;
  late AnimationController _progressController;

  final List<String> _guesses = [
    "apple123",
    "qwerty!",
    "password1",
    "letmein!",
    "sunshine2024",
    "dragon99",
    "iloveyou",
    "football7",
    "welcome123",
    "ninja!42",
    "trustno1",
    "admin2024",
  ];

  int _currentIndex = 0;
  double _opacity = 1.0;

  @override
  void initState() {
    super.initState();

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();

    _timer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      setState(() => _opacity = 0.3);

      Future.delayed(const Duration(milliseconds: 150), () {
        if (!mounted) return;
        setState(() {
          _opacity = 1.0;
          _currentIndex = (_currentIndex + 1) % _guesses.length;
        });
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Guessing passwords...",
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),

          // Password field
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: theme.colorScheme.onPrimaryContainer.withOpacity(0.4),
              ),
            ),
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 150),
              opacity: _opacity,
              child: Text(
                _guesses[_currentIndex],
                style: TextStyle(
                  fontFamily: "monospace",
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onPrimaryContainer, // HIGH CONTRAST
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Progress bar
          AnimatedBuilder(
            animation: _progressController,
            builder: (context, child) {
              return Container(
                height: 8,
                width: 350 * _progressController.value,
                decoration: BoxDecoration(
                  color: Colors.greenAccent.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            },
          ),

          const SizedBox(height: 12),

          Text(
            "Weak passwords can be guessed in seconds.",
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onPrimaryContainer.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}
