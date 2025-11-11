import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/settings_cubit.dart';
import '../blocs/statistics_cubit.dart';
import '../blocs/theme_cubit.dart';
import '../models/app_settings.dart';
import '../widgets/custom_button.dart';

/// Settings screen with comprehensive configuration options
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: BlocBuilder<SettingsCubit, AppSettings>(
        builder: (context, settings) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Player Name Section
              _buildSectionHeader('Player Profile'),
              _buildPlayerNameField(context, settings),
              const SizedBox(height: 24),

              // Audio & Haptics Section
              _buildSectionHeader('Audio & Haptics'),
              _buildSoundToggle(context, settings),
              const SizedBox(height: 8),
              _buildMusicToggle(context, settings),
              const SizedBox(height: 8),
              _buildVibrationToggle(context, settings),
              const SizedBox(height: 24),

              // Appearance Section
              _buildSectionHeader('Appearance'),
              _buildThemeSelector(context, settings),
              const SizedBox(height: 24),

              // Tutorial Section
              _buildSectionHeader('Help & Tutorial'),
              _buildTutorialButton(context, settings),
              const SizedBox(height: 24),

              // Data Management Section
              _buildSectionHeader('Data Management'),
              _buildResetStatisticsButton(context),
              const SizedBox(height: 24),

              // App Information
              _buildSectionHeader('About'),
              _buildVersionInfo(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          fontFamily: 'Inter',
        ),
      ),
    );
  }

  Widget _buildPlayerNameField(BuildContext context, AppSettings settings) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: TextField(
          controller: TextEditingController(text: settings.playerName),
          decoration: const InputDecoration(
            labelText: 'Player Name',
            border: InputBorder.none,
            icon: Icon(Icons.person),
          ),
          onSubmitted: (value) {
            if (value.isNotEmpty) {
              context.read<SettingsCubit>().updatePlayerName(value);
            }
          },
        ),
      ),
    );
  }

  Widget _buildSoundToggle(BuildContext context, AppSettings settings) {
    return Card(
      child: SwitchListTile(
        title: const Text('Sound Effects'),
        subtitle: const Text('Play sounds during gameplay'),
        secondary: const Icon(Icons.volume_up),
        value: settings.soundEnabled,
        onChanged: (_) {
          context.read<SettingsCubit>().toggleSound();
        },
      ),
    );
  }

  Widget _buildMusicToggle(BuildContext context, AppSettings settings) {
    return Card(
      child: SwitchListTile(
        title: const Text('Background Music'),
        subtitle: const Text('Play music while gaming'),
        secondary: const Icon(Icons.music_note),
        value: settings.musicEnabled,
        onChanged: (_) {
          context.read<SettingsCubit>().toggleMusic();
        },
      ),
    );
  }

  Widget _buildVibrationToggle(BuildContext context, AppSettings settings) {
    return Card(
      child: SwitchListTile(
        title: const Text('Vibration'),
        subtitle: const Text('Haptic feedback for actions'),
        secondary: const Icon(Icons.vibration),
        value: settings.vibrationEnabled,
        onChanged: (_) {
          context.read<SettingsCubit>().toggleVibration();
        },
      ),
    );
  }

  Widget _buildThemeSelector(BuildContext context, AppSettings settings) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.palette),
                SizedBox(width: 12),
                Text(
                  'Theme',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildThemeOption(
                    context,
                    'Light',
                    Icons.light_mode,
                    settings.themeMode == 'light',
                    () {
                      context.read<SettingsCubit>().updateThemeMode('light');
                      context.read<ThemeCubit>().setLightTheme();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildThemeOption(
                    context,
                    'Dark',
                    Icons.dark_mode,
                    settings.themeMode == 'dark',
                    () {
                      context.read<SettingsCubit>().updateThemeMode('dark');
                      context.read<ThemeCubit>().setDarkTheme();
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context,
    String label,
    IconData icon,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.withOpacity(0.2) : Colors.transparent,
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey.withOpacity(0.3),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: isSelected ? Colors.blue : null),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.blue : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTutorialButton(BuildContext context, AppSettings settings) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.school),
        title: const Text('How to Play'),
        subtitle: const Text('View tutorial and game instructions'),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          Navigator.pushNamed(context, '/tutorial');
        },
      ),
    );
  }

  Widget _buildResetStatisticsButton(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.delete_forever, color: Colors.red),
        title: const Text(
          'Reset Statistics',
          style: TextStyle(color: Colors.red),
        ),
        subtitle: const Text('Clear all game statistics and achievements'),
        onTap: () {
          _showResetConfirmationDialog(context);
        },
      ),
    );
  }

  void _showResetConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Reset Statistics'),
          content: const Text(
            'Are you sure you want to reset all statistics and achievements? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                context.read<StatisticsCubit>().resetStatistics();
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Statistics reset successfully'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              child: const Text(
                'Reset',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildVersionInfo() {
    return const Card(
      child: ListTile(
        leading: Icon(Icons.info),
        title: Text('App Version'),
        subtitle: Text('1.0.0'),
      ),
    );
  }
}
