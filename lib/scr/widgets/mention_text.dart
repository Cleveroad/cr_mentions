import 'package:cr_mentions/scr/models/mention_model.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// Highlight mentions in text.
class MentionText extends StatefulWidget {
  /// Highlight mentions in text.
  ///
  /// Displays [text] which contains mentions.
  const MentionText(
    this.text, {
    required this.mentions,
    this.overflow = TextOverflow.clip,
    this.onMentionTap,
    this.style,
    this.mentionStyle,
    this.maxLines,
    super.key,
  });

  /// Text with mentions
  final String text;

  /// A list of MentionModel, to highlight them in the text
  final List<MentionModel> mentions;

  /// How overflowing text should be handled. By default [TextOverflow.clip]
  final TextOverflow overflow;

  /// Returns the clicked mention model
  final ValueChanged<MentionModel>? onMentionTap;

  /// Style of a plain text
  final TextStyle? style;

  /// Text style of mentions
  final TextStyle? mentionStyle;

  /// Maximum number of lines in the text
  final int? maxLines;

  @override
  State<MentionText> createState() => _MentionTextState();
}

class _MentionTextState extends State<MentionText> {
  final List<TapGestureRecognizer> _recognizers = [];

  @override
  void dispose() {
    for (final recognizer in _recognizers) {
      recognizer.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(children: _generateTextSpans(context)),
      maxLines: widget.maxLines,
      overflow: widget.overflow,
    );
  }

  List<TextSpan> _generateTextSpans(BuildContext context) {
    var currentPos = 0;
    final textSpans = <TextSpan>[];
    final textLength = widget.text.length;

    if (widget.mentions.isNotEmpty) {
      widget.mentions.sort(MentionModel.sortMentionsByLocationStart);

      for (final mention in widget.mentions) {
        var mentionStart = mention.locationStart ?? currentPos;
        var mentionEnd = mention.locationEnd ?? mentionStart;

        /// Protection against QA
        if (mentionStart < currentPos) {
          mentionStart = currentPos;
        }
        if (mentionEnd > textLength) {
          mentionEnd = textLength;
        }

        /// Plain text before the mention
        if (currentPos != mentionStart) {
          final regularText = widget.text.substring(currentPos, mentionStart);
          textSpans.add(TextSpan(text: regularText, style: widget.style));
        }

        /// Mention text
        if (mentionStart != mentionEnd) {
          final mentionText = widget.text.substring(mentionStart, mentionEnd);
          final recognizer = TapGestureRecognizer()
            ..onTap = () => _onTap(mention);
          _recognizers.add(recognizer);

          textSpans.add(
            TextSpan(
              text: mentionText,
              style: widget.mentionStyle ?? widget.style,
              recognizer: recognizer,
            ),
          );
        }

        currentPos = mentionEnd;

        /// Protection against QA
        if (currentPos >= textLength) {
          break;
        }
      }
    }

    /// Rest of the text after last mention
    textSpans.add(
      TextSpan(
        text: widget.text.substring(currentPos, textLength),
        style: widget.style,
      ),
    );

    return textSpans;
  }

  void _onTap(MentionModel mention) => widget.onMentionTap?.call(mention);
}
