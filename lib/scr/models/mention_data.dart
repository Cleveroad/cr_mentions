/// If you want any model to be dedicated to mentions, you have to wrap it in
/// [MentionData].
class MentionData<T extends Object?> {
  final int? id;
  final String? mentionName;
  final T? data;

  /// If you want any model to be dedicated to mentions, you have to wrap it in
  /// [MentionData].
  ///
  /// Parameters:
  /// - `mentionName` - the name by which the search will take place.
  /// - `data` - your model.
  MentionData({
    required this.id,
    required this.mentionName,
    this.data,
  });
}
