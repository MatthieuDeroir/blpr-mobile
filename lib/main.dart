import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mood_tracker/core/theme/app_theme.dart';
import 'package:mood_tracker/di/injection_container.dart' as di;
import 'package:mood_tracker/presentation/bloc/ai/ai_assessment_bloc.dart';
import 'package:mood_tracker/presentation/bloc/auth/auth_bloc.dart';
import 'package:mood_tracker/presentation/bloc/auth/auth_event.dart';
import 'package:mood_tracker/presentation/bloc/auth/auth_state.dart';
import 'package:mood_tracker/presentation/bloc/mood/mood_entries_bloc.dart';
import 'package:mood_tracker/presentation/bloc/mood/mood_entries_event.dart';
import 'package:mood_tracker/presentation/bloc/scale/formula_event.dart';
import 'package:mood_tracker/presentation/bloc/scale/scales_bloc.dart';
import 'package:mood_tracker/presentation/bloc/scale/scales_event.dart';
import 'package:mood_tracker/presentation/bloc/scale/formula_bloc.dart';
import 'package:mood_tracker/presentation/pages/auth/login_page.dart';
import 'package:mood_tracker/presentation/pages/auth/register_page.dart';
import 'package:mood_tracker/presentation/pages/home/dashboard_page.dart';
import 'package:mood_tracker/presentation/pages/home/home_page.dart';
import 'package:mood_tracker/presentation/pages/mood/mood_entries_page.dart';
import 'package:mood_tracker/presentation/pages/mood/mood_entry_detail_page.dart';
import 'package:mood_tracker/presentation/pages/mood/mood_entry_form_page.dart';
import 'package:mood_tracker/presentation/pages/mood/mood_analytics_page.dart';
import 'package:mood_tracker/presentation/pages/scale/scale_detail_page.dart';
import 'package:mood_tracker/presentation/pages/scale/scale_form_page.dart';
import 'package:mood_tracker/presentation/pages/scale/scales_page.dart';
import 'package:mood_tracker/presentation/pages/scale/formulas_page.dart';
import 'package:mood_tracker/presentation/pages/ai/ai_assessment_page.dart';
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
        BlocProvider<MoodEntriesBloc>(
          create: (context) => di.sl<MoodEntriesBloc>()..add(const LoadMoodEntries(limit: 20)),
        ),
        BlocProvider<ScalesBloc>(
          create: (context) => di.sl<ScalesBloc>()..add(LoadScales()),
        ),
        BlocProvider<FormulaBloc>(
          create: (context) => di.sl<FormulaBloc>()..add(const LoadFormulas()),
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
          '/mood/analytics': (context) => const MoodAnalyticsPage(),

          // Scale routes
          '/scales': (context) => const ScalesPage(),
          '/scale/add': (context) => const ScaleFormPage(),
          '/formulas': (context) => const FormulasPage(),

          // AI routes
          '/ai-assessment': (context) => BlocProvider(
            create: (context) => di.sl<AiAssessmentBloc>(),
            child: const AiAssessmentPage(),
          ),
        },
        onGenerateRoute: (settings) {
          if (settings.name?.startsWith('/mood/') ?? false) {
            final segments = settings.name!.split('/');
            if (segments.length >= 3 && segments[2] != 'add' && segments[2] != 'analytics') {
              final id = segments[2];
              return MaterialPageRoute(
                builder: (context) => MoodEntryDetailPage(id: id),
              );
            }
          }

          if (settings.name?.startsWith('/scale/') ?? false) {
            final segments = settings.name!.split('/');
            if (segments.length >= 3 && segments[2] != 'add') {
              final id = segments[2];
              return MaterialPageRoute(
                builder: (context) => ScaleDetailPage(id: id),
              );
            }
          }

          if (settings.name?.startsWith('/formula/') ?? false) {
            final segments = settings.name!.split('/');
            if (segments.length >= 3 && segments[2] != 'add') {
              final id = segments[2];
              // Route to formula edit page
              return MaterialPageRoute(
                builder: (context) => FormulasPage(),
              );
            }
          }

          return null;
        },
      ),
    );
  }
}