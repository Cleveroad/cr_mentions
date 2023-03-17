import 'package:cr_mentions/scr/constants.dart';
import 'package:cr_mentions/scr/models/mention_model.dart';
import 'package:flutter/material.dart';

typedef MentionWidgetBuilder = Widget Function(MentionModel mention);

/// Highlight mentions in text with custom mention widget.
///
/// Use this widget if you want the mention to look different than just the
/// text, which is highlighted in a different color.
class MentionWidget extends StatefulWidget {
  /// Highlight mentions in text with custom mention widget.
  ///
  /// Displays [text] which contains mentions using [mentionWidgetBuilder]
  /// to construct a mention.
  const MentionWidget(
    this.text, {
    required this.mentions,
    required this.mentionWidgetBuilder,
    this.textStyle,
    this.paddingText,
    Key? key,
  }) : super(key: key);

  /// Text with mentions
  final String text;

  /// Style of plaint text
  final TextStyle? textStyle;

  /// The distance you want to set between the text and the mention
  final EdgeInsets? paddingText;

  /// A list of [MentionModel], to highlight them in the text
  final List<MentionModel> mentions;

  /// Set desired widget to highlight mentions
  final MentionWidgetBuilder mentionWidgetBuilder;

  @override
  State<MentionWidget> createState() => _MentionWidgetState();
}

class _MentionWidgetState extends State<MentionWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _generateRows(context),
    );
  }

  List<Widget> _generateRows(BuildContext context) {
    final widgets = <Widget>[];

    /// Distribute the text into paragraphs, so as to preserve the structure of the text
    final texts = widget.text.split('\n');

    if (widget.mentions.isNotEmpty) {
      widgets.addAll(_getRows(texts));
    } else {
      /// If there are no mentions in the text
      widgets.add(_getTextWidget(widget.text));
    }

    return widgets;
  }

  List<Widget> _getRows(List<String> texts) {
    final widgets = <Widget>[];

    /// Sorting mentions in order
    widget.mentions.sort(MentionModel.sortMentionsByLocationStart);

    for (final text in texts) {
      /// Divide the text by spaces to check each word
      final partOfText = text.trim().split(' ');

      /// Get all mentions
      final mentions = widget.mentions.map((e) => e.mentionName).toList();
      var row = <Widget>[];

      for (final part in partOfText) {
        final word = part.replaceAll(RegExp(kOnlyLetterPattern), '');

        /// If the word is in mentions, it will be displayed as a mention,
        /// otherwise it will be a plain text
        if (mentions.contains(word)) {
          row.add(
            widget.mentionWidgetBuilder(
              widget.mentions
                  .firstWhere((mention) => mention.mentionName == word),
            ),
          );

          ///Check if there are more characters after the mention
          if (part.length > word.length + 1) {
            final lastSymbols = part.split(word).last;
            row.add(_getTextWidget(lastSymbols));
          }
        } else {
          row.add(_getTextWidget('$part '));
        }
      }
      widgets.add(Wrap(children: row));
    }
    return widgets;
  }

  Widget _getTextWidget(String text) => Padding(
        padding: widget.paddingText ?? EdgeInsets.zero,
        child: Text(
          text,
          style: widget.textStyle,
          overflow: TextOverflow.clip,
        ),
      );
}
