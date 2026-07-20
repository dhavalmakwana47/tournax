import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_assets.dart';

// ──────────────────────────────────────────────────────────────────────────────
// SplashPage  – TournaX HYPER-GAMING launch animation  (~4.2 s)
// ──────────────────────────────────────────────────────────────────────────────

class SplashPage extends StatefulWidget {
  const SplashPage({super.key, required this.onComplete});
  final VoidCallback onComplete;

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  // ── Controllers ──────────────────────────────────────────────────────
  late final AnimationController _master;
  late final AnimationController _particleCtrl;
  late final AnimationController _glitchCtrl;
  late final AnimationController _scanCtrl;

  // ── Animations ───────────────────────────────────────────────────────
  late final Animation<double> _particleFade;
  late final Animation<double> _ring1Scale;
  late final Animation<double> _ring1Opacity;
  late final Animation<double> _ring2Scale;
  late final Animation<double> _ring2Opacity;
  late final Animation<double> _ring3Scale;
  late final Animation<double> _ring3Opacity;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _logoPulse;
  late final Animation<double> _glowRadius;
  late final Animation<double> _titleFade;
  late final Animation<double> _titleScale;
  late final Animation<double> _dividerWidth;
  late final Animation<double> _taglineFade;
  late final Animation<Offset> _taglineSlide;
  late final Animation<double> _hudBarLeft;
  late final Animation<double> _hudBarRight;
  late final Animation<double> _shimmer;
  late final Animation<double> _exitFade;
  late final Animation<double> _glitch;
  late final Animation<double> _scanLine;

  // ── Particles ────────────────────────────────────────────────────────
  final List<_Particle> _particles = [];
  final Random _rng = Random(99);

  @override
  void initState() {
    super.initState();
    _generateParticles();

    _master = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4200),
    );
    _particleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5000),
    )..repeat();
    _glitchCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 80),
    )..repeat(reverse: true);
    _scanCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    Animation<double> _t(double from, double to, {Curve curve = Curves.easeInOut}) =>
        CurvedAnimation(parent: _master, curve: Interval(from, to, curve: curve));

    _particleFade = _t(0.00, 0.25, curve: Curves.easeIn);

    _ring1Scale   = Tween<double>(begin: 0.3, end: 1.7).animate(_t(0.25, 0.65, curve: Curves.easeOut));
    _ring1Opacity = Tween<double>(begin: 0.0, end: 0.6).animate(_t(0.25, 0.65));
    _ring2Scale   = Tween<double>(begin: 0.1, end: 2.2).animate(_t(0.35, 0.72, curve: Curves.easeOut));
    _ring2Opacity = Tween<double>(begin: 0.0, end: 0.3).animate(_t(0.35, 0.72));
    _ring3Scale   = Tween<double>(begin: 0.5, end: 1.1).animate(_t(0.45, 0.70, curve: Curves.easeOut));
    _ring3Opacity = Tween<double>(begin: 0.0, end: 0.15).animate(_t(0.45, 0.70));

    _logoScale  = Tween<double>(begin: 0.0, end: 1.0).animate(_t(0.30, 0.58, curve: Curves.elasticOut));
    _logoOpacity = _t(0.30, 0.50, curve: Curves.easeIn);
    _logoPulse  = Tween<double>(begin: 1.0, end: 1.07).animate(_t(0.60, 0.78, curve: Curves.easeInOut));
    _glowRadius = Tween<double>(begin: 0.0, end: 80.0).animate(_t(0.48, 0.76, curve: Curves.easeOut));

    // Title — scale-stamp from large → 1.0 (cinematic impact)
    _titleFade  = _t(0.60, 0.76, curve: Curves.easeOut);
    _titleScale = Tween<double>(begin: 1.4, end: 1.0).animate(_t(0.60, 0.76, curve: Curves.easeOut));

    // HUD divider lines shoot out from center
    _dividerWidth = Tween<double>(begin: 0.0, end: 1.0).animate(_t(0.72, 0.82, curve: Curves.easeOut));

    // HUD bars
    _hudBarLeft  = Tween<double>(begin: 0.0, end: 1.0).animate(_t(0.74, 0.86, curve: Curves.easeOut));
    _hudBarRight = Tween<double>(begin: 0.0, end: 1.0).animate(_t(0.76, 0.88, curve: Curves.easeOut));

    _taglineFade  = _t(0.78, 0.92, curve: Curves.easeOut);
    _taglineSlide = Tween<Offset>(begin: const Offset(0, 0.8), end: Offset.zero)
        .animate(_t(0.78, 0.92, curve: Curves.easeOut));

    _glitch  = _t(0.60, 0.72, curve: Curves.easeInOut);
    _shimmer = _t(0.82, 0.97, curve: Curves.easeInOut);
    _scanLine = Tween<double>(begin: 0.0, end: 1.0).animate(_scanCtrl);

    _exitFade = Tween<double>(begin: 1.0, end: 0.0).animate(_t(0.96, 1.00, curve: Curves.easeIn));

    _master.forward();
    _master.addStatusListener((s) {
      if (s == AnimationStatus.completed) widget.onComplete();
    });
  }

  void _generateParticles() {
    for (int i = 0; i < 80; i++) {
      _particles.add(_Particle(
        x: _rng.nextDouble(),
        y: _rng.nextDouble(),
        size: _rng.nextDouble() * 2.5 + 0.5,
        speed: _rng.nextDouble() * 0.25 + 0.04,
        opacity: _rng.nextDouble() * 0.6 + 0.2,
        hue: [200.0, 240.0, 270.0, 185.0][_rng.nextInt(4)],
      ));
    }
  }

  @override
  void dispose() {
    _master.dispose();
    _particleCtrl.dispose();
    _glitchCtrl.dispose();
    _scanCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return AnimatedBuilder(
      animation: Listenable.merge([_master, _particleCtrl, _glitchCtrl, _scanCtrl]),
      builder: (context, _) {
        return Stack(
          fit: StackFit.expand,
          children: [
            _buildBackground(),

            // Particle field
            Opacity(
              opacity: _particleFade.value,
              child: CustomPaint(
                painter: _ParticlePainter(particles: _particles, progress: _particleCtrl.value),
                child: const SizedBox.expand(),
              ),
            ),

            // Scan line sweep (only during rings phase)
            if (_master.value > 0.25 && _master.value < 0.65)
              _buildScanLine(size),

            // Energy rings
            Center(child: _buildRings()),

            // Logo + glow
            Center(child: _buildLogo()),

            // HUD text block
            Align(alignment: const Alignment(0, 0.45), child: _buildTextBlock(size)),

            // Shimmer
            if (_shimmer.value > 0) _buildShimmer(),

            // Exit
            if (_exitFade.value < 1.0)
              Opacity(
                opacity: 1.0 - _exitFade.value,
                child: Container(color: Colors.black),
              ),
          ],
        );
      },
    );
  }

  // ── Background ──────────────────────────────────────────────────────────────
  Widget _buildBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(0, -0.15),
          radius: 1.4,
          colors: [
            Color(0xFF060B24),
            Color(0xFF030612),
            Color(0xFF000000),
          ],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
    );
  }

  // ── Scan line ───────────────────────────────────────────────────────────────
  Widget _buildScanLine(Size size) {
    final y = _scanLine.value * size.height;
    return Positioned(
      top: y,
      left: 0,
      right: 0,
      child: Container(
        height: 2,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [
            Colors.transparent,
            const Color(0xFF00CFFF).withValues(alpha: 0.15),
            const Color(0xFF00CFFF).withValues(alpha: 0.3),
            const Color(0xFF00CFFF).withValues(alpha: 0.15),
            Colors.transparent,
          ]),
        ),
      ),
    );
  }

  // ── Energy rings ────────────────────────────────────────────────────────────
  Widget _buildRings() {
    return SizedBox(
      width: 360,
      height: 360,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer ring – cyan
          Transform.scale(
            scale: _ring2Scale.value,
            child: Opacity(
              opacity: _ring2Opacity.value,
              child: Container(
                width: 340,
                height: 340,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF00CFFF).withValues(alpha: 0.35), width: 1.0),
                ),
              ),
            ),
          ),
          // Mid ring – purple
          Transform.scale(
            scale: _ring1Scale.value,
            child: Opacity(
              opacity: _ring1Opacity.value,
              child: Container(
                width: 230,
                height: 230,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFA855F7).withValues(alpha: 0.55), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFA855F7).withValues(alpha: 0.2),
                      blurRadius: 18,
                      spreadRadius: 3,
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Inner filled glow disc
          Transform.scale(
            scale: _ring3Scale.value,
            child: Opacity(
              opacity: _ring3Opacity.value,
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF5B8CFF).withValues(alpha: 0.18),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Logo ────────────────────────────────────────────────────────────────────
  Widget _buildLogo() {
    final glow = _glowRadius.value;
    // Glitch offset during title stamp
    final glitchOffset = _glitch.value > 0
        ? (_glitchCtrl.value - 0.5) * _glitch.value * 6.0
        : 0.0;

    return Opacity(
      opacity: _logoOpacity.value,
      child: Transform.translate(
        offset: Offset(glitchOffset, 0),
        child: Transform.scale(
          scale: _logoScale.value * _logoPulse.value,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer glow rings (painted)
              if (glow > 0) ...[
                Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: const Color(0xFF4F79FF).withValues(alpha: 0.4), blurRadius: glow, spreadRadius: glow * 0.3),
                      BoxShadow(color: const Color(0xFFA855F7).withValues(alpha: 0.3), blurRadius: glow * 1.6, spreadRadius: glow * 0.1),
                      BoxShadow(color: const Color(0xFF00CFFF).withValues(alpha: 0.2), blurRadius: glow * 2.2, spreadRadius: 0),
                    ],
                  ),
                ),
              ],
              // Logo
              Image.asset(AppAssets.logo, width: 115, height: 115, fit: BoxFit.contain),
            ],
          ),
        ),
      ),
    );
  }

  // ── Text block ──────────────────────────────────────────────────────────────
  Widget _buildTextBlock(Size size) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── TOURNAX ── stamp animation ─────────────────────────────────────
        Opacity(
          opacity: _titleFade.value,
          child: Transform.scale(
            scale: _titleScale.value,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Neon glow blur layer behind title
                if (_titleFade.value > 0.3)
                  ImageFiltered(
                    imageFilter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                    child: _buildTitleText(opacity: _titleFade.value * 0.6),
                  ),
                // Sharp text on top
                _buildTitleText(opacity: 1.0),
              ],
            ),
          ),
        ),

        const SizedBox(height: 10),

        // ── HUD divider lines ────────────────────────────────────────────
        _buildHudDivider(size),

        const SizedBox(height: 12),

        // ── HUD metadata bars ────────────────────────────────────────────
        _buildHudBars(size),

        const SizedBox(height: 16),

        // ── Tagline ──────────────────────────────────────────────────────
        FadeTransition(
          opacity: _taglineFade,
          child: SlideTransition(
            position: _taglineSlide,
            child: _buildTagline(),
          ),
        ),
      ],
    );
  }

  Widget _buildTitleText({required double opacity}) {
    return ShaderMask(
      shaderCallback: (bounds) => const LinearGradient(
        colors: [
          Color(0xFFFFFFFF),
          Color(0xFFCCE0FF),
          Color(0xFF9FB8FF),
          Color(0xFFCCAAFF),
          Color(0xFF80F0FF),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        stops: [0.0, 0.2, 0.5, 0.75, 1.0],
      ).createShader(bounds),
      child: Opacity(
        opacity: opacity,
        child: Text(
          'TOURNAX',
          style: GoogleFonts.orbitron(
            fontSize: 44,
            fontWeight: FontWeight.w900,
            letterSpacing: 10.0,
            color: Colors.white,
            height: 1.0,
          ),
        ),
      ),
    );
  }

  Widget _buildHudDivider(Size size) {
    final w = (size.width * 0.55) * _dividerWidth.value;
    return SizedBox(
      height: 18,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Main divider
          Container(
            width: w,
            height: 1.0,
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [
                Colors.transparent,
                Color(0xFF4F79FF),
                Color(0xFFA855F7),
                Color(0xFF00CFFF),
                Colors.transparent,
              ]),
            ),
          ),
          // Center diamond
          if (_dividerWidth.value > 0.5)
            Opacity(
              opacity: (_dividerWidth.value - 0.5) * 2,
              child: Transform.rotate(
                angle: pi / 4,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: const Color(0xFF00CFFF),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00CFFF).withValues(alpha: 0.8),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHudBars(Size size) {
    final maxW = size.width * 0.3;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Left bar cluster
        Opacity(
          opacity: _hudBarLeft.value,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _HudBar(width: maxW * 0.6 * _hudBarLeft.value, color: const Color(0xFF4F79FF)),
              const SizedBox(height: 4),
              _HudBar(width: maxW * 0.35 * _hudBarLeft.value, color: const Color(0xFFA855F7).withValues(alpha: 0.7)),
            ],
          ),
        ),
        // Center pip
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Opacity(
            opacity: _hudBarLeft.value,
            child: Container(
              width: 4,
              height: 20,
              decoration: BoxDecoration(
                color: const Color(0xFF00CFFF),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00CFFF).withValues(alpha: 0.7),
                    blurRadius: 8,
                  ),
                ],
              ),
            ),
          ),
        ),
        // Right bar cluster
        Opacity(
          opacity: _hudBarRight.value,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _HudBar(width: maxW * 0.6 * _hudBarRight.value, color: const Color(0xFF00CFFF)),
              const SizedBox(height: 4),
              _HudBar(width: maxW * 0.4 * _hudBarRight.value, color: const Color(0xFFA855F7).withValues(alpha: 0.7)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTagline() {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _NeonTag('COMPETE', const Color(0xFF4F79FF)),
            _NeonDivider(),
            _NeonTag('RANK', const Color(0xFFA855F7)),
            _NeonDivider(),
            _NeonTag('CONQUER', const Color(0xFF00CFFF)),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'ESPORTS TOURNAMENT PLATFORM',
          style: GoogleFonts.rajdhani(
            fontSize: 9,
            fontWeight: FontWeight.w500,
            letterSpacing: 4.0,
            color: const Color(0xFF4A5A7A),
          ),
        ),
      ],
    );
  }

  // ── Shimmer ─────────────────────────────────────────────────────────────────
  Widget _buildShimmer() {
    return IgnorePointer(
      child: Opacity(
        opacity: (sin(_shimmer.value * pi) * 0.4).clamp(0.0, 0.4),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(-1.5 + _shimmer.value * 4, -0.5),
              end: Alignment(-1.0 + _shimmer.value * 4, 0.5),
              colors: [
                Colors.transparent,
                Colors.white.withValues(alpha: 0.05),
                Colors.white.withValues(alpha: 0.12),
                Colors.white.withValues(alpha: 0.05),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Reusable HUD widgets
// ──────────────────────────────────────────────────────────────────────────────

class _HudBar extends StatelessWidget {
  const _HudBar({required this.width, required this.color});
  final double width;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width.clamp(0, double.infinity),
      height: 2,
      decoration: BoxDecoration(
        color: color,
        boxShadow: [BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 6)],
      ),
    );
  }
}

class _NeonTag extends StatelessWidget {
  const _NeonTag(this.text, this.color);
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Neon glow layer
        Text(
          text,
          style: GoogleFonts.orbitron(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 2.5,
            color: color.withValues(alpha: 0.4),
          ),
        ),
        // Sharp text on top
        Text(
          text,
          style: GoogleFonts.orbitron(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 2.5,
            color: color,
            shadows: [
              Shadow(color: color.withValues(alpha: 0.8), blurRadius: 12),
              Shadow(color: color.withValues(alpha: 0.5), blurRadius: 24),
            ],
          ),
        ),
      ],
    );
  }
}

class _NeonDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 1, height: 8,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.transparent, Color(0xFF4F79FF)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              boxShadow: [BoxShadow(color: const Color(0xFF4F79FF).withValues(alpha: 0.5), blurRadius: 4)],
            ),
          ),
          Container(width: 3, height: 3,
            decoration: BoxDecoration(
              color: const Color(0xFF00CFFF),
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: const Color(0xFF00CFFF).withValues(alpha: 0.8), blurRadius: 6)],
            ),
          ),
          Container(width: 1, height: 8,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFA855F7), Colors.transparent],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              boxShadow: [BoxShadow(color: const Color(0xFFA855F7).withValues(alpha: 0.5), blurRadius: 4)],
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Particle model + painter
// ──────────────────────────────────────────────────────────────────────────────

class _Particle {
  const _Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.opacity,
    required this.hue,
  });
  final double x, y, size, speed, opacity, hue;
}

class _ParticlePainter extends CustomPainter {
  const _ParticlePainter({required this.particles, required this.progress});
  final List<_Particle> particles;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final dy = (p.y - progress * p.speed * 3.5) % 1.0;
      final ox = size.width * p.x;
      final oy = size.height * (dy < 0 ? dy + 1.0 : dy);
      final cx = size.width / 2;
      final cy = size.height / 2;
      final nx = ox + (cx - ox) * 0.06 * progress;
      final ny = oy + (cy - oy) * 0.04 * progress;

      final color = HSVColor.fromAHSV(
        p.opacity * (0.5 + 0.5 * sin(progress * 2 * pi + p.x * 7)),
        p.hue,
        0.8,
        1.0,
      ).toColor();

      canvas.drawCircle(
        Offset(nx, ny),
        p.size,
        Paint()
          ..color = color
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, p.size),
      );
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter old) => true;
}
