import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mood_tracker/core/theme/app_theme.dart';
import 'package:mood_tracker/di/injection_container.dart' as di;
import 'package:mood_tracker/presentation/bloc/auth/auth_bloc.dart';
import 'package:mood_tracker/presentation/bloc/auth/auth_event.dart';
import 'package:mood_tracker/presentation/bloc/auth/auth_state.dart';
import 'package:mood_tracker/presentation/pages/auth/login_page.dart';
import 'package:mood_tracker/presentation/pages/auth/register_page.dart';
import 'package:mood_tracker/presentation/pages/home/dashboard_page.dart';
import 'package:mood_tracker/presentation/pages/home/home_page.dart';
import 'package:mood_tracker/presentation/pages/mood/mood_entries_page.dart';
import 'package:mood_tracker/presentation/pages/mood/mood_entry_detail_page.dart';
import 'package:mood_tracker/presentation/pages/mood/mood_entry_form_page.dart';
import 'package:mood_tracker/presentation/pages/scale/scale_detail_page.dart';
import 'package:mood_tracker/presentation/pages/scale/scale_form_page.dart';
import 'package:mood_tracker/presentation/pages/scale/scales_page.dart';
import 'package:mood_tracker/presentation/widgets/common/loading_indicator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize Hive for local storage
  await Hive.initFlutter();

  // Initialize dependency injection
  await di.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => di.sl<AuthBloc>()..add(CheckAuthStatusEvent()),
        ),
      ],
      child: MaterialApp(
        title: 'Mood Tracker',
        theme: AppTheme.lightTheme,
        home: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is AuthInitial || state is AuthCheckingStatus) {
              return const Scaffold(
                body: Center(
                  child: LoadingIndicator(),
                ),
              );
            } else if (state is Authenticated) {
              return const HomePage();
            } else {
              return const LoginPage();
            }
          },
        ),
        routes: {
          // Auth routes
          '/login': (context) => const LoginPage(),
          '/register': (context) => const RegisterPage(),

          // Main routes
          '/home': (context) => const HomePage(),
          '/dashboard': (context) => const DashboardPage(),

          // Mood routes
          '/mood': (context) => const MoodEntriesPage(),
          '/mood/add': (context) => const MoodEntryFormPage(),

          // Scale routes
          '/scales': (context) => const ScalesPage(),
          '/scale/add': (context) => const ScaleFormPage(),
        },
        onGenerateRoute: (settings) {
          if (settings.name?.startsWith('/mood/') ?? false) {
            final id = settings.name!.split('/').last;
            if (id != 'add') {
              return MaterialPageRoute(
                builder: (context) => MoodEntryDetailPage(id: id),
              );
            }
          }

          if (settings.name?.startsWith('/scale/') ?? false) {
            final id = settings.name!.split('/').last;
            if (id != 'add') {
              return MaterialPageRoute(
                builder: (context) => ScaleDetailPage(id: id),
              );
            }
          }

          return null;
        },
      ),
    );
  }
}

