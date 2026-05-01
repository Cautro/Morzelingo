import 'package:morzelingo/core/api/api_client.dart';
import 'package:morzelingo/core/api/response_model.dart';

typedef GetHandler =
    Future<ResponseModel> Function({
      required bool jwt,
      required String endpoint,
    });
typedef PostHandler =
    Future<ResponseModel> Function({
      required bool jwt,
      required String endpoint,
      dynamic body,
    });
typedef StatusChecker = bool Function(int statusCode);

class ApiRequest {
  ApiRequest({
    required this.jwt,
    required this.endpoint,
    this.body,
  });

  final bool jwt;
  final String endpoint;
  final dynamic body;
}

class FakeApiClient extends ApiClient {
  FakeApiClient({
    this.getHandler,
    this.postHandler,
    this.statusChecker,
  });

  final GetHandler? getHandler;
  final PostHandler? postHandler;
  final StatusChecker? statusChecker;
  final List<ApiRequest> getRequests = <ApiRequest>[];
  final List<ApiRequest> postRequests = <ApiRequest>[];

  @override
  Future<ResponseModel> get({
    required bool jwt,
    required String endpoint,
  }) async {
    getRequests.add(ApiRequest(jwt: jwt, endpoint: endpoint));

    if (getHandler == null) {
      throw UnimplementedError('getHandler is not configured');
    }

    return getHandler!(jwt: jwt, endpoint: endpoint);
  }

  @override
  Future<ResponseModel> post({
    required bool jwt,
    required String endpoint,
    dynamic body,
  }) async {
    postRequests.add(ApiRequest(jwt: jwt, endpoint: endpoint, body: body));

    if (postHandler == null) {
      throw UnimplementedError('postHandler is not configured');
    }

    return postHandler!(jwt: jwt, endpoint: endpoint, body: body);
  }

  @override
  bool checkResponseStatus(int code) {
    return statusChecker?.call(code) ?? super.checkResponseStatus(code);
  }
}
