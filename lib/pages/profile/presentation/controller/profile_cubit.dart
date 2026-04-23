import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:morzelingo/core/authorization/authorization.dart';
import 'package:morzelingo/core/exceptions/exceptions.dart';
import 'package:morzelingo/core/logger/logger.dart';
import 'package:morzelingo/pages/profile/domain/repositories/profile_repository_interface.dart';
import 'package:morzelingo/pages/profile/presentation/controller/profile_state.dart';
import 'package:morzelingo/settings_context.dart';
import 'package:morzelingo/storage_context.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final IProfileRepository _repository;
  ProfileCubit({required IProfileRepository repository}) : _repository = repository, super(const ProfileState());

  Future<void> getData() async {
    emit(state.copyWith(isLoading: true));
    try {
      final profileData = await _repository.getData();
      final String lang = await SettingsService.getLang();
      emit(state.copyWith(profile: profileData, lang: lang));
    } on AppException catch (e) {
      AppLogger.e(e.toString());
      emit(state.copyWith(message: e.toString(), success: false));
    } catch (e) {
      emit(state.copyWith(message: "Неизвестная ошибка", success: false));
    } finally {
      emit(state.copyWith(success: null, isLoading: false));
    }
  }

  Future<void> logout() async {
    try {
      await StorageService.clearAll();
      await SettingsService.setDefault();
      await Authorization().deleteToken();
    } on AppException catch (e) {
      AppLogger.e(e.toString());
      emit(state.copyWith(message: e.toString(), success: false));
    } catch (e) {
      emit(state.copyWith(message: "Неизвестная ошибка", success: false));
    } finally {
      emit(state .copyWith(success: null));
    }
  }
}