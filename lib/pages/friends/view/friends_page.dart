import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:morzelingo/core/api/api_client.dart';
import 'package:morzelingo/pages/friends/bloc/friends_bloc.dart';
import 'package:morzelingo/pages/friends/repository/friends_repository.dart';

import '../../../app_theme.dart';
import '../../../ui/app_ui.dart';

class FriendsPage extends StatefulWidget {
  const FriendsPage({super.key});

  @override
  State<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  bool isAdd = false;
  String? code;

  Future<void> deleteDialog(FriendsBloc bloc, String username) async {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AppConfirmationDialog(
          title: 'Удалить друга?',
          message: 'Пользователь $username будет удалён из вашего списка друзей.',
          confirmLabel: 'Да, удалить',
          cancelLabel: 'Не удалять',
          destructive: true,
          onConfirm: () async {
            Navigator.of(dialogContext).pop();
            bloc.add(DeleteFriendEvent(username: username));
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => FriendsBloc(repository: FriendsRepository(ApiClient()))..add(GetFriendsEvent()),
      child: BlocListener<FriendsBloc, FriendsState>(
        listener: (context, state) {
          if (state.success != null) {
            Fluttertoast.showToast(
              msg: state.message ?? "",
              backgroundColor: state.success! ? AppTheme.success : AppTheme.error,
              textColor: Colors.white,
            );
          }
        },
        child: BlocBuilder<FriendsBloc, FriendsState>(
          builder: (context, state) {
            return AppPageScaffold(
              appBar: AppBar(title: const Text("Друзья")),
              padding: AppSpacing.pageDense,
              child: Column(
                children: [
                  AppPrimaryButton(
                    onPressed: () {
                      setState(() {
                        isAdd = !isAdd;
                      });
                    },
                    child: Text(!isAdd ? "Добавить друга" : "Скрыть"),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    child: isAdd
                        ? AppSurfaceCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Имя пользователя друга'),
                                const SizedBox(height: AppSpacing.sm),
                                TextField(
                                  onChanged: (value) {
                                    setState(() {
                                      code = value;
                                    });
                                  },
                                  decoration: const InputDecoration(
                                    labelText: "Имя пользователя друга",
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.md),
                                AppPrimaryButton(
                                  onPressed: () {
                                    context.read<FriendsBloc>().add(AddFriendEvent(code: code ?? ""));
                                    context.read<FriendsBloc>().add(GetFriendsEvent());
                                  },
                                  child: const Text('Добавить в друзья'),
                                ),
                              ],
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Expanded(
                    child: state.friends.isNotEmpty
                        ? ListView.separated(
                            itemCount: state.friends.length,
                            separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
                            itemBuilder: (context, index) {
                              final item = state.friends[index];
                              return AppListCard(
                                title: "$item",
                                subtitle: "Вы с $item друзья",
                                leading: Container(
                                  height: 44,
                                  width: 44,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                    borderRadius: AppRadii.md,
                                  ),
                                  child: Icon(
                                    Icons.people_alt_rounded,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                                footer: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Text("Общая серия - ${item["streak"]}", style: Theme.of(context).textTheme.bodyLarge),
                                    // const SizedBox(height: AppSpacing.xs),
                                    // Text("Серия друга - ${item["individual_streak"]}", style: Theme.of(context).textTheme.bodyMedium),
                                    // const SizedBox(height: AppSpacing.xs),
                                    // Text("Последняя активность - ${item["last_active"]}", style: Theme.of(context).textTheme.bodyMedium),
                                    // const SizedBox(height: AppSpacing.md),
                                    AppDangerButton(
                                      onPressed: () {
                                        deleteDialog(context.read<FriendsBloc>(), item);
                                      },
                                      child: const Text('Удалить друга'),
                                    ),
                                  ],
                                ),
                              );
                            },
                          )
                        : const AppEmptyState(
                            icon: Icons.people_outline_rounded,
                            title: 'У вас нет друзей',
                            subtitle: 'Добавьте друга по коду, и он появится в этом списке.',
                          ),
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
