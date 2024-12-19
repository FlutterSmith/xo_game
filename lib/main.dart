import 'package:advanced_xo_game/blocs/game_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'blocs/theme_cubit.dart';
import 'blocs/game_bloc.dart';
import 'blocs/settings_cubit.dart';
import 'blocs/statistics_cubit.dart';
import 'screens/splash_screen.dart';
import 'screens/main_menu_screen.dart';
import 'screens/game_setup_screen.dart';
import 'screens/home_screen.dart';
import 'screens/game_result_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/statistics_screen.dart';
import 'screens/achievements_screen.dart';
import 'screens/tutorial_screen.dart';
import 'screens/about_screen.dart';
import 'screens/replay_viewer_screen.dart';
import 'screens/history_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<ThemeCubit>(create: (_) => ThemeCubit()),
        BlocProvider<SettingsCubit>(create: (_) => SettingsCubit()),
        BlocProvider<StatisticsCubit>(create: (_) => StatisticsCubit()),
        BlocProvider<GameBloc>(
          create: (_) => GameBloc()..add(const LoadHistory()),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeData>(
      builder: (context, theme) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'XO Game - Professional Tic Tac Toe',
          theme: theme,
          initialRoute: '/',
          routes: {
            '/': (context) => const SplashScreen(),
            '/menu': (context) => const MainMenuScreen(),
            '/game-setup': (context) => const GameSetupScreen(),
            '/game-play': (context) => const HomeScreen(),
            '/game-result': (context) => const GameResultScreen(),
            '/settings': (context) => const SettingsScreen(),
            '/statistics': (context) => const StatisticsScreen(),
            '/achievements': (context) => const AchievementsScreen(),
            '/tutorial': (context) => const TutorialScreen(),
            '/about': (context) => const AboutScreen(),
            '/replays': (context) => const ReplayViewerScreen(),
            '/replay-viewer': (context) => const ReplayViewerScreen(),
            '/history': (context) => const HistoryScreen(),
          },
        );
      },
    );
  }
}
