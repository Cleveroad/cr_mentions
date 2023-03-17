/// Stores all data related to a mention
class MentionModel {
  /// Stores all data related to a mention
  const MentionModel({
    required this.tagType,
    this.id,
    this.mentionName,
    this.locationStart,
    this.locationEnd,
  });

  final int? id;

  /// Contains name of mention without tag
  final String? mentionName;

  /// Related to [tag] from [MentionTextController]
  final String tagType;

  /// Beginning position of the mention in the text
  final int? locationStart;

  /// End position of the mention in the text
  final int? locationEnd;

  /// Mention name with tag
  String get fullMention => '$tagType$mentionName';

  /// Compare two mention models by position
  static int sortMentionsByLocationStart(MentionModel a, MentionModel b) {
    final aStart = a.locationStart;
    final bStart = b.locationStart;

    if (aStart != null && bStart != null) {
      return aStart.compareTo(bStart);
    }
    if (aStart != null) {
      return 1;
    }
    if (bStart != null) {
      return -1;
    }

    return 0;
  }
}
