RegExp regexpWithTag(String tag) {
  return RegExp(
    r'(^|\s)' + tag + r'([A-z]+)\b',
  );
}
