import 'package:flutter/cupertino.dart';
import 'package:morzelingo/core/authorization/authorization.dart';
import 'package:morzelingo/core/logger/logger.dart';
import 'package:morzelingo/pages/profile/domain/repositories/profile_repository_interface.dart';
import 'package:morzelingo/pages/profile/presentation/controller/profile_state.dart';
import 'package:morzelingo/settings_context.dart';
import 'package:morzelingo/storage_context.dart';

class ProfileController extends ChangeNotifier {
  final IProfileRepository _repository;
  ProfileState _state = const ProfileState();

  ProfileController({required IProfileRepository repository}) : _repository = repository;

  ProfileState get state => _state;

  Future<void> getData() async {
    _state = _state.copyWith(isLoading: true);
    notifyListeners();
    try {
      final profileData = await _repository.getData();
      final String lang = await SettingsService.getLang();
      _state = _state.copyWith(profile: profileData, lang: lang);
      notifyListeners();
    } catch (e) {
      AppLogger.e(e.toString());
      _state = _state.copyWith(message: e.toString(), success: false);
      notifyListeners();
    } finally {
      _state = _state.copyWith(success: null, isLoading: false);
      notifyListeners();
    }
  }

  Future<void> logout() async {
    try {
      await StorageService.clearAll();
      await SettingsService.setDefault();
      await Authorization().deleteToken();
    } catch (e) {
      AppLogger .e(e.toString());
      _state = _state .copyWith(success: false, message: e.toString());
      notifyListeners();
    } finally {
      _state = _state .copyWith(success: null);
      notifyListeners();
    }
  }
}