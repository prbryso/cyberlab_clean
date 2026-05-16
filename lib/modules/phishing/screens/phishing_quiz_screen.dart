import 'package:flutter/material.dart';
import '../phishing_widgets.dart';

class PhishingQuizScreen extends StatefulWidget {
  const PhishingQuizScreen({super.key});

  @override
  State<PhishingQuizScreen> createState() => PhishingQuizScreenState();
}

class PhishingQuizScreenState extends State<PhishingQuizScreen> {
  int score = 0;
  int answered = 0;

  void answer(bool correct) {
    setState(() {
      answered++;
      if (correct) score++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Phishing Quiz')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          QuizQuestion(
            question: 'Is an unexpected attachment a red flag?',
            correctAnswer: true,
            onAnswer: answer,
          ),
          QuizQuestion(
            question:
                'Should you trust an email just because you know the sender?',
            correctAnswer: false,
            onAnswer: answer,
          ),
          QuizQuestion(
            question: 'Is being BCC’d suspicious?',
            correctAnswer: true,
            onAnswer: answer,
          ),

          const SizedBox(height: 24),
          Text(
            'Score: $score / $answered',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ],
      ),
    );
  }
}

class QuizQuestion extends StatelessWidget {
  final String question;
  final bool correctAnswer;
  final void Function(bool correct) onAnswer;

  const QuizQuestion({
    required this.question,
    required this.correctAnswer,
    required this.onAnswer,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(question, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () => onAnswer(correctAnswer == true),
                  child: const Text('Yes'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () => onAnswer(correctAnswer == false),
                  child: const Text('No'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
