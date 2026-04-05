import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:morzelingo/pages/hints/view/hints_page.dart';
import 'package:morzelingo/pages/loading_page.dart';
import 'package:morzelingo/pages/profile/bloc/profile_bloc.dart';
import 'package:morzelingo/settings_context.dart';

import '../../../app_theme.dart';
import '../../../ui/app_ui.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? username;
  String? email;
  String? xp;
  String? lessondone_en;
  String? lessondone_ru;
  String? level;
  String? coins;
  String? streak;
  String? needxp;
  String? referral;
  bool isLoading = true;

  void logout(ProfileBloc bloc) async {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AppConfirmationDialog(
          title: 'Выйти из аккаунта?',
          message: 'Вы уверены что хотите выйти из аккаунта.',
          confirmLabel: 'Выйти',
          cancelLabel: 'Остаться',
          destructive: true,
          onConfirm: () async {
            Navigator.of(dialogContext).pop();
            bloc.add(LogoutEvent());
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProfileBloc()..add(GetProfileDataEvent()),
      child: BlocListener<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileDataState) {
            setState(() {
              xp = state.xp;
              referral = state.referral;
              level = state.level;
              lessondone_en = state.lessondone_en;
              lessondone_ru = state.lessondone_ru;
              coins = state.coins;
              streak = state.streak;
              needxp = state.needxp;
              email = state.email;
              username = state.username;
              isLoading = false;
            });
          }
          if (state is LogoutState) {
            Navigator.pushReplacementNamed(context, "/login");
          }
        },
        child: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
            if (isLoading) {
              return const LoadingPage();
            }

            return AppPageScaffold(
              scrollable: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: AppSectionHeader(
                          title: 'Профиль',
                          subtitle: 'Ваши данные, детали обучения и статистика.',
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.pushNamed(context, "/hints");
                        },
                        icon: const Icon(Icons.lightbulb_outline),
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.pushNamed(context, "/settings");
                        },
                        icon: const Icon(Icons.settings_outlined),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppSurfaceCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              height: 64,
                              width: 64,
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                borderRadius: AppRadii.lg,
                              ),
                              child: Icon(
                                Icons.person_rounded,
                                size: 34,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(username ?? "", style: Theme.of(context).textTheme.headlineMedium),
                                  const SizedBox(height: 4),
                                  Text(email ?? "", style: Theme.of(context).textTheme.bodyMedium),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _ProfileCard(
                    username: "$username" ?? "",
                    email: "$email" ?? "",
                    xp: "$xp" ?? "",
                    lessondone: "${SettingsService.getLang() == "en" ? lessondone_en : lessondone_ru}" ?? "",
                    coins: "$coins" ?? "",
                    level: "$level" ?? "",
                    streak: "$streak" ?? "",
                    needxp: "$needxp" ?? "",
                    refferal: "$referral" ?? "",
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppDangerButton(
                    onPressed: () async {
                      logout(context.read<ProfileBloc>());
                    },
                    child: const Text('Выйти из аккаунта'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final String username;
  final String email;
  final String xp;
  final String lessondone;
  final String coins;
  final String level;
  final String streak;
  final String needxp;
  final String refferal;

  const _ProfileCard({
    required this.username,
    required this.email,
    required this.xp,
    required this.lessondone,
    required this.coins,
    required this.level,
    required this.streak,
    required this.needxp,
    required this.refferal,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: AppSpacing.md,
          crossAxisSpacing: AppSpacing.md,
          childAspectRatio: 1.25,
          children: [
            AppStatTile(
              icon: Icons.leaderboard_rounded,
              label: 'Уровень',
              value: level,
            ),
            AppStatTile(
              icon: Icons.star_rounded,
              label: 'Опыт',
              value: xp,
              color: AppTheme.warning,
            ),
            AppStatTile(
              icon: Icons.local_fire_department_rounded,
              label: 'Серия',
              value: streak,
              color: Colors.orange,
            ),
            AppStatTile(
              icon: Icons.done_outline_rounded,
              label: 'Пройдено уроков',
              value: lessondone,
              color: AppTheme.success,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        AppListCard(
          title: 'До повышения уровня',
          subtitle: 'Опыта до повышения: $needxp',
          leading: Icon(Icons.upgrade_rounded, color: AppTheme.warning),
        ),
        const SizedBox(height: AppSpacing.md),
        AppListCard(
          title: 'Реферальный код',
          subtitle: refferal,
          leading: const Icon(Icons.link_rounded),
        ),
        const SizedBox(height: AppSpacing.lg),
        AppPrimaryButton(
          onPressed: () {
            Navigator.pushNamed(context, "/friends");
          },
          child: const Text('Друзья'),
        ),
        const SizedBox(height: AppSpacing.sm),
        AppSecondaryButton(
          onPressed: () {
            Navigator.pushNamed(context, "/lettersstats");
          },
          child: const Text('Статистика букв'),
        ),
      ],
    );
  }
}
