import 'package:cr_mentions/scr/constants.dart';
import 'package:cr_mentions/scr/models/mention_data.dart';
import 'package:cr_mentions/scr/models/mention_model.dart';
import 'package:cr_mentions/scr/utils/regexp_with_tag.dart';
import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// Controller to track the mentions.
///
/// For showing mentions in the text see [MentionText] or [MentionWidget].
class MentionTextController extends TextEditingController {
  /// Controller to track the mentions.
  ///
  /// Parameters:
  /// - [lastMention] - last editable mention.
  /// - [tag] - is the symbol by which mention will be made.
  /// Default value is '@'. Must contain only one non-whitespace character.
  MentionTextController({
    required this.lastMention,
    this.tag = kAtSymbol,
    super.text,
  }) : assert(
          tag != ' ' && tag.length == 1,
          "The tag can't be a space and have a length greater than 1",
        ) {
    addListener(_textControllerListener);
  }

  /// Last editable mention
  final ValueNotifier<MentionModel?> lastMention;

  /// The tag that will be used to recognize the mentions.
  late final String tag;

  /// A list of all the objects that were selected in the suggestions list.
  /// We need to store these users so that when we send a request we can add
  /// their id to the MentionModel's
  final Set<MentionData> _mentionedObject = {};

  /// The list of currently detected mentions in the text.
  /// Each time the text is changed, this list is generated anew
  List<MentionModel> mentions = [];

  int _previousCursorPos = 0;
  String _previousText = '';

  @override
  void dispose() {
    removeListener(_textControllerListener);
    super.dispose();
  }

  /// Inserts the mention in the place of the current editable mention
  void insertMention(MentionData mentionModel) {
    final start = lastMention.value?.locationStart;
    final end = lastMention.value?.locationEnd;

    if (start != null && end != null) {
      final needAddSpaceAtEnd =
          end >= text.length || text.codeUnitAt(end) != kSpaceUTF16Code;

      final mentionName = mentionModel.mentionName ?? '';
      final mentionText =
          needAddSpaceAtEnd ? '$tag$mentionName ' : '$tag$mentionName';

      final newText = text.replaceRange(
        start,
        end,
        mentionText,
      );

      /// Shift cursor by one symbol after the mention (immediately after
      /// the space symbol, which is sure to be after the mention), so that
      /// suggestions no longer come
      ///
      /// 2 = one [tag] symbol before mention + one space symbol after mention
      final newCursorPos = start + mentionName.length + 2;
      value = value.copyWith(
        text: newText,
        selection: TextSelection.collapsed(offset: newCursorPos),
        composing: TextRange.empty,
      );

      _mentionedObject.add(mentionModel);
    }
  }

  /// If the return value == '', then only the tag was entered,
  /// if the value == null, then there are no suggestions.
  /// Otherwise all matching suggestions will be returned
  String? makeQuerySuggestions(String query) {
    String? searchQuery;
    final queryWithoutTag = query.replaceAll('\n', '');
    final queryLength = queryWithoutTag.length;

    /// if the query has characters in addition to @ symbol
    if (queryLength > 1) {
      final match = regexpWithTag(tag).stringMatch(queryWithoutTag);

      /// if the whole query matches the pattern
      if (match?.length == queryLength) {
        searchQuery = queryWithoutTag.substring(1);
      }
    } else {
      /// if the query is only [tag] symbol, request all suggestions
      searchQuery = '';
    }

    return searchQuery;
  }

  /// Makes the last mention a plain text.
  void replaceLastMentionWithText(String text) {
    final start = lastMention.value?.locationStart;
    final end = lastMention.value?.locationEnd;

    if (start != null && end != null) {
      final newText = this.text.replaceRange(
            start,
            end,
            text,
          );

      value = value.copyWith(
        text: newText,
        selection: TextSelection.collapsed(offset: start + text.length),
        composing: TextRange.empty,
      );
    }
  }

  /// In edit mode of text field with mentions, it is necessary to call this
  /// method during initialization, where to pass a list of previously set
  /// mentions. This will correctly create the set of mentioned users
  /// [_mentionedObject] and the list of current mentions [mentions].
  void prepareForEditingMode(List<MentionModel> mentions) {
    /// Prepare set of mentioned users
    _addMentionedObjectsFromMentionsList(mentions);

    /// Prepare list of current mentions
    this.mentions = mentions.map((mention) {
      /// Mentions' tags is not stored on backend usually, only positions and id.
      /// So we need to add tags to each mention.
      /// We can get them from the set of mentioned objects that we formed earlier
      /// from the text (by position of mentions)
      final mentionName = _mentionedObject
          .firstOrNullWhere((object) => object.id == mention.id)
          ?.mentionName;

      return MentionModel(
        id: mention.id,
        mentionName: mentionName != null ? '$tag$mentionName' : '',
        locationStart: mention.locationStart,
        locationEnd: mention.locationEnd,
        tagType: tag,
      );
    }).toList();
  }

  /// Makes a final list of mentions ready to be sent to the backend.
  /// Adds the id's, remove [tag] symbols and inserts the first mention.
  /// The first mention can be inserted if it is, for example, a reply to a comment(with position offset)
  List<MentionModel>? getMentionsListWithoutTag({
    required bool isTextTrimmed,
    MentionModel? firstMention,
  }) {
    final replyLocationEnd = firstMention?.locationEnd;
    // +1 because we should also consider added space after first mention
    final replyOffset = replyLocationEnd != null ? replyLocationEnd + 1 : 0;
    // if the text is trimmed before sending, the positions of mentions
    // will be shifted. trimOffset is responsible for this
    final trimOffset = isTextTrimmed ? text.trimLeft().length - text.length : 0;

    final mentionsList = <MentionModel>[];
    for (final mention in mentions) {
      final mentionName = mention.mentionName
          ?.replaceAll('\n', '')
          .substring(1); //remove [tag] symbol

      int? id;
      for (final object in _mentionedObject) {
        if (object.mentionName == mentionName) {
          id = object.id;
          break;
        }
      }

      if (id != null) {
        mentionsList.add(
          MentionModel(
            id: id,
            locationStart:
                (mention.locationStart ?? 0) + replyOffset + trimOffset,
            locationEnd: (mention.locationEnd ?? 0) + replyOffset + trimOffset,
            mentionName: mentionName,
            tagType: tag,
          ),
        );
      }
    }

    if (firstMention != null) {
      mentionsList.insert(0, firstMention);
    }

    return mentionsList.isEmpty ? null : mentionsList;
  }

  /// If we add first mention to [getMentionsListWithoutTag],
  /// we should return the correct string already with this mention.
  String getTextWithFirstMention(MentionModel firstMention) =>
      '${firstMention.fullMention} $text';

  /// Is used for editing to prepare set of objects which have been mentioned before
  /// By positions of mentions we can retrieve tags of mentioned objects from text
  void _addMentionedObjectsFromMentionsList(List<MentionModel> mentions) {
    for (final mention in mentions) {
      var mentionName = mention.mentionName;
      if (mentionName == null) {
        final start = mention.locationStart;
        final end = mention.locationEnd;
        if (start != null &&
            end != null &&
            start + 1 <= end &&
            end <= text.length) {
          mentionName = text.substring(start + 1, end);
        }
      }
      if (mentionName != null) {
        _mentionedObject.add(
          MentionData(
            mentionName: mentionName,
            id: mention.id,
          ),
        );
      }
    }
  }

  /// Listens mentioning
  Future<void> _textControllerListener() async {
    final currentText = text;
    final currentTextLength = currentText.length;
    final currentCursorPos = selection.baseOffset;

    /// When we changed cursor position while suggestions is showing we will
    /// hide suggestions
    if (_previousCursorPos != currentCursorPos &&
        _previousText == currentText) {
      lastMention.value = null;
    }

    if (currentText != _previousText) {
      mentions = _getMentionsFromText(currentText);
      MentionModel? targetMention;

      /// Get the currently being edited mention by current cursor position
      targetMention = _tryGetTargetMentionByCursorPos(currentCursorPos);

      /// If we entering a single [tag] symbol (at end or inside the text)
      if (targetMention == null &&
          currentText.isNotEmpty &&
          currentCursorPos > 0) {
        final lastEnteredCodeUnit =
            currentText.codeUnitAt(currentCursorPos - 1);

        // if last entered symbol is [tag]
        if (lastEnteredCodeUnit == tag.codeUnitAt(0)) {
          final int prevEnteredCodeUnit;
          final isSpaceBeforeMentionChecked = currentCursorPos == 1 ||
              (prevEnteredCodeUnit =
                      currentText.codeUnitAt(currentCursorPos - 2)) ==
                  kSpaceUTF16Code ||
              prevEnteredCodeUnit == kNewlineUTF16Code;

          if (isSpaceBeforeMentionChecked) {
            targetMention = MentionModel(
              locationStart: currentCursorPos - 1,
              locationEnd: currentCursorPos,
              mentionName: tag,
              tagType: tag,
            );
          }
        }
      }

      final isMoreThanOneSymbolChanged =
          (_previousText.length - currentTextLength).abs() > 1;

      /// If we pasting text in the middle of text
      if (isMoreThanOneSymbolChanged && currentCursorPos != currentTextLength) {
        targetMention = null;
      }

      /// If we pasting text at end
      if (isMoreThanOneSymbolChanged &&
          currentCursorPos == currentTextLength &&
          targetMention != null) {
        final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
        if (clipboardData == null || clipboardData.text == null) {
          targetMention = null;
        }

        /// If pasting data ends with calculated mention
        final clipboardText = clipboardData?.text;
        final targetMentionTag = targetMention?.mentionName;
        if (clipboardText != null &&
            targetMentionTag != null &&
            !clipboardText.endsWith(targetMentionTag)) {
          targetMention = null;
        }
      }

      lastMention.value = targetMention;

      _previousText = currentText;
    }
    _previousCursorPos = currentCursorPos;
  }

  MentionModel? _tryGetTargetMentionByCursorPos(int currentCursorPos) {
    for (final mention in mentions) {
      final start = mention.locationStart;
      final end = mention.locationEnd;
      if (start != null &&
          end != null &&
          currentCursorPos > start &&
          currentCursorPos <= end) {
        return mention;
      }
    }

    return null;
  }

  List<MentionModel> _getMentionsFromText(String text) =>
      regexpWithTag(tag).allMatches(text).map((e) {
        var start = e.start;
        final end = e.end;
        final text = e.group(0) ?? '';
        var newText = text;
        if (text.startsWith(' ')) {
          start++;
          newText = text.substring(1);
        }

        return MentionModel(
          locationStart: start,
          locationEnd: end,
          mentionName: newText,
          tagType: tag,
        );
      }).toList();
}
