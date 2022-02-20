extension StringExtension on String {
  String capitalize() {
    // TODO: Change this to work with sections titles that have spaces in them.
    return '${this[0].toUpperCase()}${this.substring(1)}';
  }
}
