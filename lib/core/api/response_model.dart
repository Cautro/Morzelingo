class ResponseModel<T> {
  final T json;
  final int statusCode;

  ResponseModel({required this.statusCode, required this.json});
}