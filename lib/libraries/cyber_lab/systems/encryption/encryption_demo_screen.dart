import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';

class EncryptionDemoScreen extends StatefulWidget {
  const EncryptionDemoScreen({super.key});

  @override
  State<EncryptionDemoScreen> createState() => _EncryptionDemoScreenState();
}

class _EncryptionDemoScreenState extends State<EncryptionDemoScreen> {
  final TextEditingController _controller = TextEditingController();
  String _mode = 'AES';
  String _ciphertext = '';

  // Simple AES-like XOR demo (not real AES, but perfect for teaching)
  String _simpleAesEncrypt(String text, int key) {
    final bytes = utf8.encode(text);
    final encrypted = bytes.map((b) => b ^ key).toList();
    return base64.encode(encrypted);
  }

  // Simple RSA-like demo (not real RSA, but conceptually accurate)
  Map<String, int> _generateFakeRsaKeys() {
    final rand = Random();
    final privateKey = rand.nextInt(5000) + 2000;
    final publicKey = privateKey + 17; // simple relationship
    return {'public': publicKey, 'private': privateKey};
  }

  String _simpleRsaEncrypt(String text, int publicKey) {
    final bytes = utf8.encode(text);
    final encrypted = bytes.map((b) => (b * publicKey) % 256).toList();
    return base64.encode(encrypted);
  }

  void _encrypt() {
    final message = _controller.text.trim();
    if (message.isEmpty) return;

    if (_mode == 'AES') {
      final key = 42; // teaching key
      final result = _simpleAesEncrypt(message, key);
      setState(() => _ciphertext = result);
    } else {
      final keys = _generateFakeRsaKeys();
      final result = _simpleRsaEncrypt(message, keys['public']!);
      setState(() => _ciphertext = result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Encryption Demo')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text(
              'Try It Yourself',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 12),

            Text(
              'Type a message and watch it turn into ciphertext. '
              'This demo uses simple teaching algorithms to show how encryption transforms data.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),

            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Enter a message',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),

            Text(
              'Choose Encryption Mode',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),

            DropdownButton<String>(
              value: _mode,
              items: const [
                DropdownMenuItem(value: 'AES', child: Text('AES (Symmetric)')),
                DropdownMenuItem(value: 'RSA', child: Text('RSA (Asymmetric)')),
              ],
              onChanged: (value) {
                setState(() => _mode = value!);
              },
            ),
            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: _encrypt,
              child: const Text('Encrypt Message'),
            ),
            const SizedBox(height: 24),

            Text(
              'Ciphertext',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(8),
              ),
              child: SelectableText(
                _ciphertext.isEmpty
                    ? 'Your encrypted text will appear here.'
                    : _ciphertext,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
