import 'package:cr_mentions/scr/models/mention_model.dart';

class MessageModel {
  MessageModel({
    required this.text,
    required this.mentions,
  });

  final String text;
  final List<MentionModel> mentions;
}
