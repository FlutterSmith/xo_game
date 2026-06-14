import 'dart:async';
import 'package:flutter/material.dart';
import 'package:advanced_xo_game/widgets/common/common.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // Gentle breathing glow for the logo — calm, not a slot machine.
  late final AnimationController _glowController;
  late final Animation<double> _glow;

  double _progress = 0.0;

  @override
  void initState() {
    super.initState();

    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    )..repeat(reverse: true);

    _glow = Tween<double>(begin: 0.35, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: AppMotion.emphasized),
    );

    // Simulate loading progress (unchanged cadence).
    _simulateLoading();

    // Navigate after splash (unchanged timing & destination).
    Timer(const Duration(milliseconds: 3500), () {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/menu');
      }
    });
  }

  void _simulateLoading() {
    Timer.periodic(const Duration(milliseconds: 30), (timer) {
      if (mounted) {
        setState(() {
          _progress += 0.01;
          if (_progress >= 1.0) {
            _progress = 1.0;
            timer.cancel();
          }
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = AppPalette.of(context);

    return AppScaffold(
      body: Center(
        child: Padding(
          padding: AppSpacing.page,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Brand logo: glassy ring with the XO mark + tasteful glow ──
              FadeSlideIn(
                duration: AppMotion.slow,
                beginOffset: const Offset(0, 0.04),
                child: _BrandLogo(glow: _glow),
              ),

              AppSpacing.vXl,

              // ── Wordmark ──
              FadeSlideIn(
                delay: AppMotion.stagger(1),
                child: ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: AppColors.heroGradient,
                  ).createShader(bounds),
                  child: Text(
                    'XO GAME',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.displaySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 8,
                    ),
                  ),
                ),
              ),

              AppSpacing.vSm,

              // ── Author credit ──
              FadeSlideIn(
                delay: AppMotion.stagger(2),
                child: Text(
                  'by Ahmed Hamdy',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: palette.textMuted,
                    letterSpacing: 2,
                  ),
                ),
              ),

              AppSpacing.vXl,
              AppSpacing.vMd,

              // ── Loading indicator ──
              FadeSlideIn(
                delay: AppMotion.stagger(3),
                child: _LoadingBar(progress: _progress),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Calm, premium XO logo: a glass disc carrying overlapping X and O marks,
/// wrapped in a soft brand glow that gently breathes.
class _BrandLogo extends StatelessWidget {
  final Animation<double> glow;
  const _BrandLogo({required this.glow});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: glow,
      builder: (context, child) {
        final g = glow.value;
        return Container(
          width: 184,
          height: 184,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.pink.withValues(alpha: 0.28 * g),
                blurRadius: 48,
                spreadRadius: 6,
              ),
              BoxShadow(
                color: AppColors.teal.withValues(alpha: 0.22 * g),
                blurRadius: 48,
                spreadRadius: 6,
              ),
            ],
          ),
          child: child,
        );
      },
      child: GlassPanel(
        borderRadius: AppRadius.rPill,
        padding: const EdgeInsets.all(AppSpacing.lg),
        glowColor: AppColors.violet,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.violet.withValues(alpha: 0.22),
            AppColors.pink.withValues(alpha: 0.18),
          ],
        ),
        child: SizedBox(
          width: 120,
          height: 120,
          child: Stack(
            alignment: Alignment.center,
            children: const [
              Align(
                alignment: Alignment(-0.5, -0.45),
                child: AnimatedMark(mark: 'X', markSize: 84),
              ),
              Align(
                alignment: Alignment(0.5, 0.45),
                child: AnimatedMark(mark: 'O', markSize: 84),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Slim glass progress track with a brand-gradient fill and percentage label.
class _LoadingBar extends StatelessWidget {
  final double progress;
  const _LoadingBar({required this.progress});

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final theme = Theme.of(context);
    final pct = (progress * 100).clamp(0, 100).round();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 260,
          child: ClipRRect(
            borderRadius: AppRadius.rPill,
            child: Container(
              height: 8,
              decoration: BoxDecoration(
                color: palette.surface2.withValues(alpha: 0.6),
                borderRadius: AppRadius.rPill,
                border: Border.all(color: palette.border),
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: progress.clamp(0.0, 1.0),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: AppRadius.rPill,
                      gradient: const LinearGradient(
                        colors: AppColors.heroGradient,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.pink.withValues(alpha: 0.5),
                          blurRadius: 12,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        AppSpacing.vSm,
        Text(
          'Loading  $pct%',
          style: theme.textTheme.labelMedium?.copyWith(
            color: palette.textMuted,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }
}
