import 'package:advanced_xo_game/blocs/game_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'blocs/theme_cubit.dart';
import 'blocs/game_bloc.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(MultiBlocProvider(
    providers: [
      BlocProvider<ThemeCubit>(create: (_) => ThemeCubit()),
      BlocProvider<GameBloc>(
          create: (_) => GameBloc()..add(const LoadHistory())),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeData>(
      builder: (context, theme) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: ' TicTac by AH',
          theme: theme,
          home: const SplashScreen(),
        );
      },
    );
  }
}
