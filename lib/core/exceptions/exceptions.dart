class Except implements Exception {
  final String message;
  Except(this.message);

  @override
  String toString() => message;
}
