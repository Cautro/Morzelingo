import 'package:equatable/equatable.dart';
import 'package:morzelingo/pages/profile/domain/entities/profile.dart';

class ProfileState extends Equatable {
  final Profile? profile;
  final bool isLoading;
  final bool? success;
  final String message;

  const ProfileState({this.profile, this.message = '', this.success, this.isLoading = true});

  ProfileState copyWith({Profile? profile, bool? isLoading, bool? success, String? message}) {
    return ProfileState(isLoading: isLoading ?? this.isLoading, success: success ?? this.success, message: message ?? this.message, profile: profile ?? this.profile);
  }

  @override
  List<Object?> get props => [profile, isLoading, success, message];
}