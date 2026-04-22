import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:morzelingo/core/logger/logger.dart';
import 'package:morzelingo/pages/loading_page.dart';
import 'package:morzelingo/pages/profile/domain/entities/symbol_stats.dart';
import 'package:morzelingo/pages/profile/domain/repositories/profile_repository_interface.dart';
import 'package:morzelingo/pages/profile/presentation/controller/profile_controller.dart';
import 'package:morzelingo/pages/profile/presentation/view/letters_stats_page.dart';
import '../../../../app_theme.dart';
import '../../../../ui/app_ui.dart';

class ProfilePage extends StatefulWidget {
  final IProfileRepository repository;
  const ProfilePage({super.key, required this.repository});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final _controller = ProfileController(repository: widget.repository);

  @override
  void initState() {
    _controller.getData();
    _controller.addListener(_onStateChanged);
    super.initState();
  }

  void _onStateChanged() {
    if (_controller.state.success != null) {
      Fluttertoast.showToast(
        msg: _controller.state.message,
        backgroundColor: _controller.state.success == true
            ? AppTheme.success
            : AppTheme.error,
        textColor: Colors.white,
      );
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onStateChanged);
    _controller.dispose();
    super.dispose();
  }

  void logout() async {
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
              _controller.logout();
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
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, child) {
        return _controller.state.isLoading == true ? const LoadingPage() : AppPageScaffold(
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
                              Text(_controller.state.profile?.username ?? "", style: Theme.of(context).textTheme.headlineMedium),
                              const SizedBox(height: 4),
                              Text(_controller.state.profile?.email ?? "", style: Theme.of(context).textTheme.bodyMedium),
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
                username: _controller.state.profile?.username ?? "",
                email: _controller.state.profile?.email ?? "",
                xp: _controller.state.profile?.xp?.toString() ?? "0",
                lessondone: _controller.state.lang == "en"
                    ? (_controller.state.profile?.lesson_done_en ?? "0").toString()
                    : (_controller.state.profile?.lesson_done_ru ?? "0").toString(),
                coins: _controller.state.profile?.coins?.toString() ?? "0",
                level: _controller.state.profile?.level?.toString() ?? "0",
                streak: _controller.state.profile?.streak?.toString() ?? "0",
                needxp: _controller.state.profile?.need_xp?.toString() ?? "0",
                refferal: _controller.state.profile?.referral_code ?? "",
                stats: _controller.state.profile?.symbol_stats ?? [],
              ),

              const SizedBox(height: AppSpacing.lg),
              AppDangerButton(
                onPressed: () async {
                  logout();
                },
                child: const Text('Выйти из аккаунта'),
              ),
            ],
          ),
        );
      },
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
