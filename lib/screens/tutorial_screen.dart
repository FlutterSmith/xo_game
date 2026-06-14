import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:advanced_xo_game/widgets/common/common.dart';
import 'package:advanced_xo_game/blocs/settings_cubit.dart';

/// Tutorial / onboarding screen explaining game rules and features.
///
/// Neon-arcade redesign: a swipeable [PageView] of glassy slides, each with a
/// big themed icon, a tight headline and one punchy line of copy. An animated
/// dot indicator tracks progress, and neon CTAs drive Skip / Next / Get Started.
class TutorialScreen extends StatefulWidget {
  const TutorialScreen({super.key});

  @override
  State<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen> {
  int _currentPage = 0;
  final PageController _pageController = PageController();

  static const List<_TutorialPage> _pages = [
    _TutorialPage(
      title: 'Welcome to XO',
      description:
          'A modern Tic Tac Toe with multiple boards, smart AI and full stat tracking.',
      icon: Icons.videogame_asset_rounded,
      gradient: AppColors.heroGradient,
      accent: AppColors.violet,
    ),
    _TutorialPage(
      title: 'How to Play',
      description:
          'Take turns placing X or O. Line up enough marks in a row, column or diagonal to win.',
      icon: Icons.sports_esports_rounded,
      gradient: AppColors.winGradient,
      accent: AppColors.teal,
    ),
    _TutorialPage(
      title: 'Pick a Board',
      description:
          'Choose 3x3, 4x4 or 5x5. Bigger boards mean more space and a longer line to win.',
      icon: Icons.grid_on_rounded,
      gradient: AppColors.primaryGradient,
      accent: AppColors.pink,
    ),
    _TutorialPage(
      title: 'Game Modes',
      description:
          'Duel a friend in PvP or challenge the AI across Easy, Medium, Hard and Impossible.',
      icon: Icons.psychology_rounded,
      gradient: AppColors.coolGradient,
      accent: AppColors.cyan,
    ),
    _TutorialPage(
      title: 'Undo & Redo',
      description:
          'Slipped up? Step back with undo, then redo to replay the move you took back.',
      icon: Icons.undo_rounded,
      gradient: AppColors.drawGradient,
      accent: AppColors.amber,
    ),
    _TutorialPage(
      title: 'Track Progress',
      description:
          'Climb the stats, unlock achievements and rewatch your best games as replays.',
      icon: Icons.insights_rounded,
      gradient: AppColors.primaryGradient,
      accent: AppColors.violet,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  bool get _isLastPage => _currentPage >= _pages.length - 1;

  void _goNext() {
    if (_isLastPage) {
      _finish();
      return;
    }
    _pageController.nextPage(
      duration: AppMotion.normal,
      curve: AppMotion.emphasized,
    );
  }

  void _finish() {
    // Mark the tutorial as seen, then leave exactly as the original did.
    context.read<SettingsCubit>().completeTutorial();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final page = _pages[_currentPage];

    return AppScaffold(
      title: 'How to Play',
      showBack: true,
      actions: [
        if (!_isLastPage)
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: Center(
              child: Pressable(
                onTap: _finish,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  child: Text(
                    'Skip',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: AppColors.violet,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
              ),
            ),
          ),
      ],
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) => setState(() => _currentPage = index),
              itemCount: _pages.length,
              itemBuilder: (context, index) => _PageView(page: _pages[index]),
            ),
          ),
          _buildPageIndicator(),
          AppSpacing.vLg,
          _buildNavigationButtons(page),
        ],
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_pages.length, (index) {
        final active = _currentPage == index;
        return AnimatedContainer(
          duration: AppMotion.normal,
          curve: AppMotion.emphasized,
          margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xxs),
          width: active ? 26 : 8,
          height: 8,
          decoration: BoxDecoration(
            gradient: active
                ? const LinearGradient(colors: AppColors.primaryGradient)
                : null,
            color: active
                ? null
                : AppPalette.of(context).textMuted.withValues(alpha: 0.35),
            borderRadius: AppRadius.rPill,
            boxShadow: active
                ? [
                    BoxShadow(
                      color: AppColors.violet.withValues(alpha: 0.5),
                      blurRadius: 12,
                    ),
                  ]
                : null,
          ),
        );
      }),
    );
  }

  Widget _buildNavigationButtons(_TutorialPage page) {
    return Padding(
      padding: AppSpacing.page,
      child: Row(
        children: [
          if (_currentPage > 0) ...[
            Expanded(
              child: NeonButton(
                label: 'Back',
                icon: Icons.arrow_back_rounded,
                variant: NeonButtonVariant.ghost,
                onTap: () => _pageController.previousPage(
                  duration: AppMotion.normal,
                  curve: AppMotion.emphasized,
                ),
              ),
            ),
            AppSpacing.hMd,
          ],
          Expanded(
            child: NeonButton(
              label: _isLastPage ? 'Get Started' : 'Next',
              icon: _isLastPage
                  ? Icons.rocket_launch_rounded
                  : Icons.arrow_forward_rounded,
              variant: _isLastPage
                  ? NeonButtonVariant.success
                  : NeonButtonVariant.primary,
              onTap: _goNext,
            ),
          ),
        ],
      ),
    );
  }
}

/// A single onboarding slide: large glowing icon orb above a glass copy card.
class _PageView extends StatelessWidget {
  final _TutorialPage page;

  const _PageView({required this.page});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: AppSpacing.page,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            FadeSlideIn(
              key: ValueKey('icon-${page.title}'),
              beginOffset: const Offset(0, -0.15),
              child: _IconOrb(page: page),
            ),
            AppSpacing.vXl,
            FadeSlideIn(
              key: ValueKey('card-${page.title}'),
              delay: AppMotion.stagger(1),
              child: GlassPanel(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.xl,
                ),
                glowColor: page.accent,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      page.title,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    AppSpacing.vSm,
                    Container(
                      width: 48,
                      height: 4,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: page.gradient),
                        borderRadius: AppRadius.rPill,
                      ),
                    ),
                    AppSpacing.vMd,
                    Text(
                      page.description,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        height: 1.5,
                        color: AppPalette.of(context).textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A glowing circular orb housing the page icon, with a gradient ring.
class _IconOrb extends StatelessWidget {
  final _TutorialPage page;

  const _IconOrb({required this.page});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      height: 160,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: SweepGradient(
          colors: [...page.gradient, page.gradient.first],
        ),
        boxShadow: [
          BoxShadow(
            color: page.accent.withValues(alpha: 0.55),
            blurRadius: 48,
            spreadRadius: 4,
          ),
        ],
      ),
      padding: const EdgeInsets.all(5),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppPalette.of(context).surface,
        ),
        child: Center(
          child: Icon(
            page.icon,
            size: 72,
            color: page.accent,
          ),
        ),
      ),
    );
  }
}

class _TutorialPage {
  final String title;
  final String description;
  final IconData icon;
  final List<Color> gradient;
  final Color accent;

  const _TutorialPage({
    required this.title,
    required this.description,
    required this.icon,
    required this.gradient,
    required this.accent,
  });
}
