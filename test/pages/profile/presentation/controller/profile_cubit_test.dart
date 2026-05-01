import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:morzelingo/core/exceptions/exceptions.dart';
import 'package:morzelingo/pages/profile/domain/entities/profile.dart';
import 'package:morzelingo/pages/profile/domain/entities/symbol_stats.dart';
import 'package:morzelingo/pages/profile/domain/repositories/profile_repository_interface.dart';
import 'package:morzelingo/pages/profile/presentation/controller/profile_cubit.dart';
import 'package:morzelingo/pages/profile/presentation/controller/profile_state.dart';

import '../../../../helpers/test_bootstrap.dart';

class FakeProfileRepository implements IProfileRepository {
  Profile? profile;
  Object? error;

  @override
  Future<Profile> getData() async {
    if (error != null) {
      throw error!;
    }
    if (profile == null) {
      throw StateError('profile is not configured');
    }
    return profile!;
  }
}

void main() {
  group('ProfileCubit', () {
    late FakeProfileRepository repository;
    late ProfileCubit cubit;
    late List<ProfileState> states;
    late StreamSubscription<ProfileState> subscription;

    setUp(() {
      initializeTestEnvironment(<String, Object>{'lang': 'en'});
      repository = FakeProfileRepository();
      cubit = ProfileCubit(repository: repository);
      states = <ProfileState>[];
      subscription = cubit.stream.listen(states.add);
    });

    tearDown(() async {
      await subscription.cancel();
      await cubit.close();
    });

    test('should emit loaded states when repository returns profile data', () async {
      repository.profile = const Profile(
        username: 'alice',
        email: 'alice@example.com',
        streak: 5,
        coins: 6,
        level: 7,
        xp: 8,
        lesson_done_en: 2,
        lesson_done_ru: 1,
        referral_code: 'REF',
        referred_by: 'bob',
        referred_count: 3,
        symbol_stats: <SymbolStats>[SymbolStats(symbol: 'A', correct: 1, wrong: 0)],
        need_xp: 30,
      );

      await cubit.getData();
      await settleAsync();

      expect(states, hasLength(2));
      expect(states[0].profile?.username, 'alice');
      expect(states[0].lang, 'en');
      expect(states[0].isLoading, isTrue);
      expect(states[1].profile?.username, 'alice');
      expect(states[1].lang, 'en');
      expect(states[1].isLoading, isFalse);
    });

    test('should emit error states when repository throws AppException', () async {
      repository.error = const ServerException('profile error');

      await cubit.getData();
      await settleAsync();

      expect(states, hasLength(2));
      expect(states[0].success, isFalse);
      expect(states[0].message, 'profile error');
      expect(states[0].isLoading, isTrue);
      expect(states[1].success, isFalse);
      expect(states[1].message, 'profile error');
      expect(states[1].isLoading, isFalse);
    });

    test('should emit error states when repository throws unknown exception', () async {
      repository.error = StateError('boom');

      await cubit.getData();
      await settleAsync();

      expect(states, hasLength(2));
      expect(states[0].success, isFalse);
      expect(states[0].message, isNotEmpty);
      expect(states[0].message, isNot('boom'));
      expect(states[1].success, isFalse);
      expect(states[1].isLoading, isFalse);
    });
  });
}
