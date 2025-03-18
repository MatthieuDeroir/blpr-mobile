import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mood_tracker/core/theme/app_colors.dart';
import 'package:mood_tracker/core/theme/app_text_styles.dart';
import 'package:mood_tracker/presentation/bloc/auth/auth_bloc.dart';
import 'package:mood_tracker/presentation/bloc/auth/auth_event.dart';
import 'package:mood_tracker/presentation/bloc/auth/auth_state.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          final user = state is Authenticated ? state.user : null;

          return Column(
            children: [
              UserAccountsDrawerHeader(
                accountName: Text(
                  user?.username ?? 'Guest',
                  style: AppTextStyles.heading4.copyWith(
                    color: AppColors.textOnPrimary,
                  ),
                ),
                accountEmail: Text(
                  user?.email ?? '',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textOnPrimary,
                  ),
                ),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: AppColors.surface,
                  child: Text(
                    user?.username.isNotEmpty ?? false
                        ? user!.username[0].toUpperCase()
                        : 'G',
                    style: AppTextStyles.heading2.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                ),
              ),

              ListTile(
                leading: const Icon(Icons.dashboard),
                title: const Text('Dashboard'),
                onTap: () {
                  Navigator.of(context).pushReplacementNamed('/home');
                },
              ),

              ListTile(
                leading: const Icon(Icons.analytics),
                title: const Text('Mood Log'),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pushNamed('/mood');
                },
              ),

              ListTile(
                leading: const Icon(Icons.scale),
                title: const Text('Scales'),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pushNamed('/scales');
                },
              ),

              ListTile(
                leading: const Icon(Icons.functions),
                title: const Text('Stability Formulas'),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pushNamed('/formulas');
                },
              ),

              const Divider(),

              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Settings'),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pushNamed('/settings');
                },
              ),

              const Spacer(),

              const Divider(),

              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Logout'),
                onTap: () {
                  Navigator.of(context).pop();
                  context.read<AuthBloc>().add(LogoutEvent());
                },
              ),

              // Display app version at the bottom
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Version 1.0.0',
                  style: AppTextStyles.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}