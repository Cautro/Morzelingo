import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:morzelingo/pages/profile/context/profile_context.dart';
part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState>{
  ProfileBloc() : super(ProfileInitial()) {
    on<GetProfileDataEvent>((event, emit) async {
      var _data = await ProfileContext().getProfileData();
      emit(ProfileDataState(username: _data["username"], email: _data["email"], coins: _data["coins"], lessondone_en: _data["lessondone_en"], lessondone_ru: _data["lessondone_ru"], level: _data["level"], needxp: _data["needxp"], referral: _data["referral"], streak: _data["streak"], xp: _data["xp"]));
    });
    on<GetStatsEvent>((event, emit) async {
      var _data = await ProfileContext().getStats();
      emit(StatsState(stats: _data));
    });
  }
}