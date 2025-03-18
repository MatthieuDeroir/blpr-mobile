import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mood_tracker/core/theme/app_colors.dart';
import 'package:mood_tracker/presentation/bloc/auth/auth_bloc.dart';
import 'package:mood_tracker/presentation/bloc/auth/auth_event.dart';
import 'package:mood_tracker/presentation/bloc/auth/auth_state.dart';
import 'package:mood_tracker/presentation/pages/home/dashboard_page.dart';
import 'package:mood_tracker/presentation/pages/mood/mood_entries_page.dart';
import 'package:mood_tracker/presentation/pages/scale/scales_page.dart';
import 'package:mood_tracker/presentation/widgets/common/app_drawer.dart';

import '../../widgets/common/app_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  final List<Widget> _pages = [
    const DashboardPage(),
    const MoodEntriesPage(),
    const ScalesPage(),
  ];

  final List<String> _pageTitles = [
    'Dashboard',
    'Mood Log',
    'Scales',
  ];

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is LogoutSuccess || state is Unauthenticated) {
          Navigator.of(context).pushReplacementNamed('/login');
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_pageTitles[_currentIndex]),
          actions: [
            if (_currentIndex == 1)
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  Navigator.of(context).pushNamed('/mood/add');
                },
              ),
            if (_currentIndex == 2)
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  Navigator.of(context).pushNamed('/scale/add');
                },
              ),
          ],
        ),
        drawer: const AppDrawer(),
        body: _pages[_currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textSecondary,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.analytics_outlined),
              activeIcon: Icon(Icons.analytics),
              label: 'Mood Log',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.scale_outlined),
              activeIcon: Icon(Icons.scale),
              label: 'Scales',
            ),
          ],
        ),
        floatingActionButton: _currentIndex == 1
            ? FloatingActionButton(
          onPressed: () {
            Navigator.of(context).pushNamed('/mood/add');
          },
          backgroundColor: AppColors.primary,
          child: const Icon(Icons.add),
        )
            : null,
      ),
    );
  }
}