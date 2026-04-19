import 'package:morzelingo/core/api/api_client.dart';
import 'package:morzelingo/core/api/response_model.dart';
import 'package:morzelingo/core/exceptions/exceptions.dart';
import 'package:morzelingo/pages/profile/data/models/profile_model.dart';
import 'package:morzelingo/pages/profile/domain/entities/profile.dart';
import 'package:morzelingo/pages/profile/domain/repositories/profile_repository_interface.dart';
import '../../../../core/logger/logger.dart';

class ProfileRepository extends IProfileRepository {
  final ApiClient _client;
  ProfileRepository(this._client);

  @override
  Future<Profile> getData() async {
    final ResponseModel profileResponse = await _client.get(jwt: true, endpoint: "/api/profile");
    if (!_client.checkResponseStatus(profileResponse.statusCode)) {
      throw Except("Ошибка при получении данных с сервера");
    }
    AppLogger.d("DATA: ${profileResponse.json}, CODE: ${profileResponse.statusCode}");
    return ProfileModel.fromJson(profileResponse.json).toEntity();
  }

}