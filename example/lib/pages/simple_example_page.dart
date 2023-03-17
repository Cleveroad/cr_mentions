import 'package:cr_mentions/cr_mentions.dart';
import 'package:flutter/material.dart';

class SimpleExamplePage extends StatefulWidget {
  const SimpleExamplePage({Key? key}) : super(key: key);

  @override
  State<SimpleExamplePage> createState() => _ShortExamplePageState();
}

class _ShortExamplePageState extends State<SimpleExamplePage> {
  late final _mentionCtr = MentionTextController(lastMention: _lastMention);
  final _lastMention = ValueNotifier<MentionModel?>(null);

  @override
  void dispose() {
    _mentionCtr.dispose();
    _lastMention.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(controller: _mentionCtr),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: ValueListenableBuilder(
                  valueListenable: _mentionCtr,
                  builder: (context, value, child) => MentionText(
                    value.text,
                    mentions: _mentionCtr.mentions,
                    style: const TextStyle(color: Colors.black),
                    mentionStyle: const TextStyle(color: Colors.deepPurple),
                  ),
                ),
              ),
              const Text('Mentions:', style: TextStyle(fontSize: 18)),
              Expanded(
                child: ValueListenableBuilder(
                  valueListenable: _lastMention,
                  builder: (context, lastMention, child) => ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    itemCount: _mentionCtr.mentions.length,
                    itemBuilder: (context, index) => Text(
                      _mentionCtr.mentions[index].mentionName ?? '',
                      style: _mentionCtr.mentions[index] == lastMention
                          ? const TextStyle(color: Colors.red)
                          : null,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
