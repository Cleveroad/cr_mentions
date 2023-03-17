import 'package:cr_mentions/scr/models/mention_model.dart';
import 'package:cr_mentions/scr/widgets/mention_text.dart';
import 'package:cr_mentions/scr/widgets/mention_widget.dart';
import 'package:cr_mentions_example/models/message_model.dart';
import 'package:cr_mentions_example/utils/utils.dart';
import 'package:cr_mentions_example/widgets/card_widget.dart';
import 'package:cr_mentions_example/widgets/click_on_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SavedTextPage extends StatefulWidget {
  const SavedTextPage({Key? key}) : super(key: key);

  @override
  State<SavedTextPage> createState() => _SavedTextPageState();
}

class _SavedTextPageState extends State<SavedTextPage> {
  List<MessageModel> _texts = [];

  @override
  void initState() {
    super.initState();
    _texts = List.from(messages);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.deepOrange,
          title: const Text(
            'All Texts',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
            ),
          ),
        ),
        body: ListView.builder(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 16,
          ),
          itemCount: _texts.length,
          itemBuilder: (_, index) {
            final message = _texts[index];
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CardWidget(
                  title: 'Mention Text',
                  child: Flexible(
                    child: MentionText(
                      message.text,
                      mentions: message.mentions,
                      style: const TextStyle(color: Colors.black),
                      mentionStyle: const TextStyle(color: Colors.deepOrange),
                      onMentionTap: onMentionModel,
                    ),
                  ),
                ),
                CardWidget(
                  title: 'Mention Widget',
                  child: Flexible(
                    child: MentionWidget(
                      message.text,
                      mentions: message.mentions,
                      paddingText: const EdgeInsets.symmetric(vertical: 4),
                      mentionWidgetBuilder: _mentionBuild,
                    ),
                  ),
                ),
              ],
            );
          },
        ));
  }

  Widget _mentionBuild(MentionModel mention) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: Colors.deepOrange.shade100,
      ),
      margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
      padding: const EdgeInsets.all(4),
      child: Text(
        mention.fullMention,
        style: const TextStyle(color: Colors.deepOrange),
      ),
    );
  }

  void onMentionModel(MentionModel? model) {
    if (model != null) {
      showCupertinoDialog(
        context: context,
        builder: (context) => ClickOnDialog(content: model.fullMention),
      );
    }
  }
}
