import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import 'login_screen.dart';
import '../l10n/strings.dart';

/// First-run tour — App-Store-quality slides: a bold headline, a real-looking
/// phone mock of the app, on a branded Schalke-blue halftone background. Fully
/// self-contained (no bundled photos) so it always renders crisply.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  static const _count = 4;

  void _next() {
    if (_page < _count - 1) {
      _controller.nextPage(duration: const Duration(milliseconds: 320), curve: Curves.easeOut);
    } else {
      _goLogin();
    }
  }

  void _goLogin() =>
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));

  Widget _slide(int i) {
    switch (i) {
      case 0:
        return _Slide(
          line1: 'DEIN SPIEL.',
          line2: 'DEINE',
          line3: 'PUNKTE.',
          sub: 'Sammeln. Einlösen. Gewinnen.',
          mock: const _HomeMock(),
        );
      case 1:
        return _Slide(
          line1: 'PUNKTE',
          line2: 'SAMMELN',
          sub: 'Bei jedem Spiel, Tipp und Einkauf.',
          mock: const _CollectMock(),
        );
      case 2:
        return _Slide(
          line1: 'PRÄMIEN',
          line2: 'EINLÖSEN',
          sub: 'Gutscheine, Tickets & Fanshop.',
          mock: const _RedeemMock(),
        );
      default:
        return _Slide(
          line1: 'GROSS',
          line2: 'GEWINNEN',
          sub: 'Tombola: VIP-Tickets & signierte Trikots.',
          mock: const _TombolaMock(),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF0055AA), Color(0xFF001B44)]),
        ),
        child: Stack(
          children: [
            // Halftone dot texture + soft rings (the Sorare-style backdrop).
            Positioned.fill(child: CustomPaint(painter: _HalftonePainter())),
            Positioned(top: -70, right: -60, child: _ring(240)),
            Positioned(bottom: 120, left: -80, child: _ring(220)),
            // Content
            SafeArea(
              child: Column(
                children: [
                  // Skip (top-right)
                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 8, 20, 0),
                      child: GestureDetector(
                        onTap: _goLogin,
                        child: Text(tr('Skip'), style: AppText.body2.copyWith(color: Colors.white70, fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ),
                  Expanded(
                    child: PageView.builder(
                      controller: _controller,
                      onPageChanged: (i) => setState(() => _page = i),
                      itemCount: _count,
                      itemBuilder: (_, i) => _slide(i),
                    ),
                  ),
                  // Dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (var i = 0; i < _count; i++)
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          width: i == _page ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: i == _page ? AppColors.gold : Colors.white24,
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  // Gold CTA (high contrast on blue)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
                    child: Tappable(
                      scale: 0.98,
                      onTap: _next,
                      child: Container(
                        width: double.infinity,
                        height: 54,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: AppColors.goldGradient),
                          borderRadius: BorderRadius.circular(999),
                          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 16, offset: const Offset(0, 8))],
                        ),
                        child: Text(_page == _count - 1 ? tr('Get Started') : tr('Continue'),
                            style: AppText.label2.copyWith(color: AppColors.brandDarkest, fontWeight: FontWeight.w800)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _ring(double s) => Container(
        width: s, height: s,
        decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.05)),
      );
}

/// One tour slide: bold headline block + a scaled phone mock.
class _Slide extends StatelessWidget {
  final String line1;
  final String line2;
  final String? line3;
  final String sub;
  final Widget mock;
  const _Slide({required this.line1, required this.line2, this.line3, required this.sub, required this.mock});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 6, 28, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(line1, style: _headStyle),
          Text(line2, style: _headStyle),
          if (line3 != null) Text(line3!, style: _headStyle),
          const SizedBox(height: 10),
          Row(children: [
            Container(width: 22, height: 3, color: AppColors.gold),
            const SizedBox(width: 8),
            Flexible(child: Text(sub, style: AppText.body2.copyWith(color: Colors.white70))),
          ]),
          // Phone mock, scaled to fit the remaining space.
          Expanded(
            child: Center(
              child: FittedBox(
                fit: BoxFit.contain,
                child: _PhoneFrame(child: mock),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static const _headStyle = TextStyle(
    fontFamily: 'Urbanist', color: Colors.white, fontSize: 40, height: 1.02, fontWeight: FontWeight.w800, letterSpacing: -0.5,
  );
}

/// A realistic phone bezel (notch + shadow) wrapping a fixed-size screen.
class _PhoneFrame extends StatelessWidget {
  final Widget child;
  const _PhoneFrame({required this.child});
  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: -0.04,
      child: Container(
        width: 236,
        height: 472,
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(
          color: const Color(0xFF0B0F14),
          borderRadius: BorderRadius.circular(38),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.35), blurRadius: 30, offset: const Offset(0, 18))],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(31),
          child: Stack(children: [
            Positioned.fill(child: Container(color: const Color(0xFFF5F6F8), child: child)),
            // Notch
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                width: 88, height: 22,
                decoration: const BoxDecoration(color: Color(0xFF0B0F14), borderRadius: BorderRadius.vertical(bottom: Radius.circular(14))),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

// ── Screen mocks (compact, on-brand renderings of real screens) ──────────────

const _blue = [Color(0xFF0055AA), Color(0xFF001B44)];

class _HomeMock extends StatelessWidget {
  const _HomeMock();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 34, 14, 14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: const [
          Svg('logo_s04', size: 20),
          Icon(Icons.notifications_none_rounded, size: 18, color: Color(0xFF667085)),
        ]),
        const SizedBox(height: 10),
        Text('Moin, Max 👋', style: TextStyle(fontFamily: 'Urbanist', fontSize: 15, fontWeight: FontWeight.w800, color: const Color(0xFF101828))),
        const SizedBox(height: 10),
        // Points card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(gradient: const LinearGradient(colors: _blue), borderRadius: BorderRadius.circular(14)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('S04 Fan Points', style: TextStyle(fontFamily: 'Urbanist', fontSize: 9, color: Colors.white70)),
            const SizedBox(height: 4),
            Text('4.820', style: TextStyle(fontFamily: 'Urbanist', fontSize: 30, height: 1, fontWeight: FontWeight.w800, color: Colors.white)),
            const SizedBox(height: 3),
            Text('≈ €48,20 in Gutscheinen', style: TextStyle(fontFamily: 'Urbanist', fontSize: 9, color: Colors.white70)),
          ]),
        ),
        const SizedBox(height: 12),
        Row(children: const [
          _MiniIcon(Icons.bolt_rounded, 'Sammeln', Color(0xFF1B7A3D)),
          _MiniIcon(Icons.card_giftcard_rounded, 'Einlösen', Color(0xFF0A2A5E)),
          _MiniIcon(Icons.emoji_events_rounded, 'Gewinne', Color(0xFF6A1B9A)),
          _MiniIcon(Icons.percent_rounded, 'Vorteile', Color(0xFFEF6C00)),
        ]),
        const Spacer(),
        _MiniPromo('Spieltag', 'S04 vs BVB · Tippen +50', const [Color(0xFFC62828), Color(0xFF7F1414)]),
      ]),
    );
  }
}

class _CollectMock extends StatelessWidget {
  const _CollectMock();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 34, 14, 14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Punkte sammeln', style: TextStyle(fontFamily: 'Urbanist', fontSize: 15, fontWeight: FontWeight.w800, color: const Color(0xFF101828))),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE4E7EC))),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text('Diese Woche', style: TextStyle(fontFamily: 'Urbanist', fontSize: 9, color: const Color(0xFF667085))),
              const Spacer(),
              _pill('🔥 5 Tage', const Color(0x1AEF6C00), const Color(0xFFEF6C00)),
            ]),
            const SizedBox(height: 6),
            Text('320 / 500 Pkt', style: TextStyle(fontFamily: 'Urbanist', fontSize: 20, fontWeight: FontWeight.w800, color: const Color(0xFF101828))),
            const SizedBox(height: 8),
            ClipRRect(borderRadius: BorderRadius.circular(4), child: const LinearProgressIndicator(value: 0.64, minHeight: 7, backgroundColor: Color(0xFFEAECF0), valueColor: AlwaysStoppedAnimation(Color(0xFF0055AA)))),
          ]),
        ),
        const SizedBox(height: 12),
        Row(children: const [
          _GameTile(Icons.casino_rounded, 'Glücksrad', '+50', Color(0xFF6A1B9A)),
          _GameTile(Icons.style_rounded, 'Rubbeln', '+30', Color(0xFFB8860B)),
          _GameTile(Icons.sports_soccer_rounded, 'Tippen', '+50', Color(0xFF1B7A3D)),
        ]),
        const Spacer(),
        _MiniPromo('Spieler des Monats', 'Stimme ab · +50', const [Color(0xFF0A2A5E), Color(0xFF000D22)]),
      ]),
    );
  }
}

class _RedeemMock extends StatelessWidget {
  const _RedeemMock();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 34, 14, 14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Einlösen', style: TextStyle(fontFamily: 'Urbanist', fontSize: 15, fontWeight: FontWeight.w800, color: const Color(0xFF101828))),
        const SizedBox(height: 10),
        _dealCard('Heimtrikot 25/26', 'Fanshop · -15%', '3.800', const Color(0xFF0A2A5E), Icons.checkroom_rounded),
        const SizedBox(height: 10),
        _dealCard('VELTINS Gutschein', 'Sponsor · Code', '1.050', const Color(0xFF00623A), Icons.sports_bar_rounded),
        const SizedBox(height: 10),
        _dealCard('Heimspiel-Ticket', 'Tickets · Presale', '4.500', const Color(0xFF1565C0), Icons.confirmation_number_rounded),
        const Spacer(),
        _MiniPromo('Meine Gutscheine', '2 bereit zum Einlösen', const [Color(0xFF6A1B9A), Color(0xFF311B92)]),
      ]),
    );
  }
}

class _TombolaMock extends StatelessWidget {
  const _TombolaMock();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 34, 14, 14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Tombola', style: TextStyle(fontFamily: 'Urbanist', fontSize: 15, fontWeight: FontWeight.w800, color: const Color(0xFF101828))),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF0A2A5E), Color(0xFF000D22)]), borderRadius: BorderRadius.circular(16)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _pill('Los des Monats', const Color(0x33FFB800), AppColors.gold),
            const SizedBox(height: 12),
            const Icon(Icons.emoji_events_rounded, color: AppColors.gold, size: 30),
            const SizedBox(height: 8),
            Text('2× VIP-Tickets — vs BVB', style: TextStyle(fontFamily: 'Urbanist', fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white)),
            const SizedBox(height: 12),
            Row(children: const [
              _CountBox('03', 'T'), SizedBox(width: 6), _CountBox('06', 'Std'), SizedBox(width: 6), _CountBox('12', 'Min'),
            ]),
            const SizedBox(height: 12),
            Container(
              width: double.infinity, height: 34, alignment: Alignment.center,
              decoration: BoxDecoration(gradient: const LinearGradient(colors: AppColors.goldGradient), borderRadius: BorderRadius.circular(999)),
              child: Text('Teilnehmen · gratis mit Super Fan', style: TextStyle(fontFamily: 'Urbanist', fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.brandDarkest)),
            ),
          ]),
        ),
        const Spacer(),
        _MiniPromo('8 Freilose / Monat', 'mit deiner Mitgliedschaft', const [Color(0xFF00623A), Color(0xFF00351F)]),
      ]),
    );
  }
}

// ── Small shared mock pieces ────────────────────────────────────────────────

class _MiniIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _MiniIcon(this.icon, this.label, this.color);
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(children: [
        Container(width: 34, height: 34, decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: color, size: 17)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontFamily: 'Urbanist', fontSize: 8.5, fontWeight: FontWeight.w700, color: const Color(0xFF344054))),
      ]),
    );
  }
}

class _GameTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String reward;
  final Color color;
  const _GameTile(this.icon, this.label, this.reward, this.color);
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 3),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE4E7EC))),
        child: Column(children: [
          Container(width: 30, height: 30, decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(9)), child: Icon(icon, color: color, size: 15)),
          const SizedBox(height: 5),
          Text(label, style: TextStyle(fontFamily: 'Urbanist', fontSize: 8, fontWeight: FontWeight.w700, color: const Color(0xFF344054))),
          const SizedBox(height: 3),
          _pill(reward, const Color(0xFFE6FAEC), const Color(0xFF12B76A)),
        ]),
      ),
    );
  }
}

class _CountBox extends StatelessWidget {
  final String v;
  final String u;
  const _CountBox(this.v, this.u);
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 7),
        decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.22), borderRadius: BorderRadius.circular(9)),
        child: Column(children: [
          Text(v, style: TextStyle(fontFamily: 'Urbanist', fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white)),
          Text(u, style: TextStyle(fontFamily: 'Urbanist', fontSize: 7, color: Colors.white70)),
        ]),
      ),
    );
  }
}

class _MiniPromo extends StatelessWidget {
  final String title;
  final String sub;
  final List<Color> gradient;
  const _MiniPromo(this.title, this.sub, this.gradient);
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(gradient: LinearGradient(colors: gradient), borderRadius: BorderRadius.circular(12)),
      child: Row(children: [
        Container(width: 30, height: 30, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.16), borderRadius: BorderRadius.circular(9)), child: const Icon(Icons.local_fire_department_rounded, color: AppColors.gold, size: 16)),
        const SizedBox(width: 9),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: TextStyle(fontFamily: 'Urbanist', fontSize: 10.5, fontWeight: FontWeight.w800, color: Colors.white)),
          Text(sub, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontFamily: 'Urbanist', fontSize: 8.5, color: Colors.white70)),
        ])),
      ]),
    );
  }
}

Widget _pill(String text, Color bg, Color fg) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Text(text, style: TextStyle(fontFamily: 'Urbanist', fontSize: 8, fontWeight: FontWeight.w800, color: fg)),
    );

Widget _dealCard(String title, String meta, String pts, Color color, IconData icon) => Container(
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE4E7EC))),
      child: Row(children: [
        Container(width: 36, height: 36, decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(9)), child: Icon(icon, color: color, size: 18)),
        const SizedBox(width: 9),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontFamily: 'Urbanist', fontSize: 11, fontWeight: FontWeight.w800, color: const Color(0xFF101828))),
          Text(meta, style: TextStyle(fontFamily: 'Urbanist', fontSize: 8.5, color: const Color(0xFF667085))),
        ])),
        Row(children: [
          const Icon(Icons.hexagon_rounded, size: 11, color: Color(0xFF0055AA)),
          const SizedBox(width: 3),
          Text(pts, style: TextStyle(fontFamily: 'Urbanist', fontSize: 11, fontWeight: FontWeight.w800, color: const Color(0xFF0055AA))),
        ]),
      ]),
    );

/// Halftone dot texture — a faint grid of dots, denser toward the top-left,
/// giving the branded backdrop depth without any image asset.
class _HalftonePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.06);
    const gap = 22.0;
    for (double y = 0; y < size.height; y += gap) {
      for (double x = 0; x < size.width; x += gap) {
        // Fade dots out toward the bottom-right for a subtle gradient feel.
        final t = 1 - ((x / size.width) * 0.5 + (y / size.height) * 0.5);
        final r = 1.6 * t.clamp(0.15, 1.0);
        canvas.drawCircle(Offset(x, y), r, paint);
      }
    }
    // A couple of thin connector lines (top-left accent), Sorare-style.
    final line = Paint()
      ..color = Colors.white.withValues(alpha: 0.10)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    final path = Path()
      ..moveTo(size.width * 0.12, size.height * 0.34)
      ..lineTo(size.width * 0.12, size.height * 0.44)
      ..arcToPoint(Offset(size.width * 0.18, size.height * 0.50), radius: const Radius.circular(20))
      ..lineTo(size.width * 0.42, size.height * 0.50);
    canvas.drawPath(path, line);
    canvas.drawCircle(Offset(size.width * 0.12, size.height * 0.34), 3, Paint()..color = AppColors.gold.withValues(alpha: 0.8));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
