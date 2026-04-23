import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:morzelingo/core/logger/logger.dart';
import 'package:morzelingo/pages/education/presentation/controller/education_cubit.dart';
import 'package:morzelingo/pages/loading_page.dart';
import 'package:morzelingo/pages/profile/domain/entities/symbol_stats.dart';
import 'package:morzelingo/pages/profile/domain/repositories/profile_repository_interface.dart';
import 'package:morzelingo/pages/profile/presentation/controller/profile_cubit.dart';
import 'package:morzelingo/pages/profile/presentation/controller/profile_state.dart';
import 'package:morzelingo/pages/profile/presentation/view/letters_stats_page.dart';
import '../../../../app_theme.dart';
import '../../../../ui/app_ui.dart';

class ProfilePage extends StatelessWidget {
  final IProfileRepository repository;
  const ProfilePage({super.key, required this.repository});

  void logout(BuildContext context) {
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
            try {
              Navigator.of(dialogContext).pop();
              await context.read<ProfileCubit>().logout();
              if (!context.mounted) return;
              Navigator.pushReplacementNamed(context, "/login");
            } catch (e) {
              AppLogger.e(e.toString());
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProfileCubit(repository: repository)..getData(),
      child: BlocConsumer<ProfileCubit, ProfileState>(
        listener: (context, state) {
          if (state.success != null) {
            Fluttertoast.showToast(
              msg: state.message,
              backgroundColor: state.success == true
                  ? AppTheme.success
                  : AppTheme.error,
              textColor: Colors.white,
            );
          }
        },
        builder: (context, state) {
          return state.isLoading == true ? const LoadingPage() : AppPageScaffold(
            scrollable: true,
            child: RefreshIndicator(
              onRefresh: () => context.read<ProfileCubit>().getData(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
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
                                    Text(state.profile?.username ?? "", style: Theme.of(context).textTheme.headlineMedium),
                                    const SizedBox(height: 4),
                                    Text(state.profile?.email ?? "", style: Theme.of(context).textTheme.bodyMedium),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _ProfileCard(
                      username: state.profile?.username ?? "",
                      email: state.profile?.email ?? "",
                      xp: state.profile?.xp.toString() ?? "0",
                      lessondone: state.lang == "en"
                          ? (state.profile?.lesson_done_en ?? "0").toString()
                          : (state.profile?.lesson_done_ru ?? "0").toString(),
                      coins: state.profile?.coins?.toString() ?? "0",
                      level: state.profile?.level?.toString() ?? "0",
                      streak: state.profile?.streak?.toString() ?? "0",
                      needxp: state.profile?.need_xp?.toString() ?? "0",
                      refferal: state.profile?.referral_code ?? "",
                      stats: state.profile?.symbol_stats ?? [],
                    ),

                    const SizedBox(height: AppSpacing.lg),
                    AppDangerButton(
                      onPressed: () async {
                        logout(context);
                      },
                      child: const Text('Выйти из аккаунта'),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
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
  final List<SymbolStats> stats;

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
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: AppSpacing.sm,
          crossAxisSpacing: AppSpacing.sm,
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
        const SizedBox(height: AppSpacing.sm),
        AppListCard(
          title: 'До повышения уровня',
          subtitle: 'Опыта до повышения: $needxp',
          leading: const Icon(Icons.upgrade_rounded, color: AppTheme.warning),
        ),
        // const SizedBox(height: AppSpacing.md),
        // AppListCard(
        //   title: 'Реферальный код',
        //   subtitle: refferal,
        //   leading: const Icon(Icons.link_rounded),
        // ),
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
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => LettersStatsPage(stats: stats))
            );
          },
          child: const Text('Статистика букв'),
        ),
      ],
    );
  }
}
