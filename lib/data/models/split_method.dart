enum SplitMethod { equally, fixed, percentage }

extension SplitMethodLabel on SplitMethod {
  String get label {
    switch (this) {
      case SplitMethod.equally:
        return 'Equally';
      case SplitMethod.fixed:
        return 'Fixed';
      case SplitMethod.percentage:
        return 'Percentage';
    }
  }
}
