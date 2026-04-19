import '../entities/profile.dart';

abstract class IProfileRepository {
  Future<Profile> getData();
}