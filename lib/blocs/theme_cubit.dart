import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ThemeCubit extends Cubit<ThemeData> {
  ThemeCubit() : super(_lightTheme);
  static final _lightTheme = ThemeData.light().copyWith(
    primaryColor: Colors.blue,
    appBarTheme: const AppBarTheme(color: Colors.blue),
  );
  static final _darkTheme = ThemeData.dark().copyWith(
    primaryColor: Colors.deepPurple,
    appBarTheme: const AppBarTheme(color: Colors.deepPurple),
  );
  void toggleTheme() =>
      emit(state.brightness == Brightness.dark ? _lightTheme : _darkTheme);
}
