import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:morzelingo/pages/profile/context/profile_context.dart';
import 'package:morzelingo/settings_context.dart';

import '../../../storage_context.dart';
part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState>{
  ProfileBloc() : super(ProfileInitial()) {
    on<GetProfileDataEvent>((event, emit) async {
      var data = await ProfileContext().getProfileData();
      emit(ProfileDataState(username: data["username"], email: data["email"], coins: data["coins"], lessondone_en: data["lessondone_en"], lessondone_ru: data["lessondone_ru"], level: data["level"], needxp: data["needxp"], referral: data["referral"], streak: data["streak"], xp: data["xp"]));
    });
    on<GetStatsEvent>((event, emit) async {
      var data = await ProfileContext().getStats();
      emit(StatsState(stats: data));
    });
    on<LogoutEvent>((event, emit) async {
      await StorageService.clearAll();
      await SettingsService.setDefault();
      emit(LogoutState());
    });
  }
}