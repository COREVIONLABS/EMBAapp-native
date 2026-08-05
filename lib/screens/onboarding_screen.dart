import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import 'login_screen.dart';
import '../l10n/strings.dart';

/// First-run tour — App-Store-quality slides (Socios/Sorare style): a bold
/// uppercase headline with a coloured accent dot, a diagonal black/blue split
/// backdrop, and a large phone mock of the real app that bleeds off the bottom.
/// Fully self-contained (no bundled photos) so it always renders crisply.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _Tour {
  final String headline; // may contain \n
  final String sub;
  final Color accent;
  final Widget mock;
  const _Tour(this.headline, this.sub, this.accent, this.mock);
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  static const _tours = <_Tour>[
    _Tour('DEIN SPIEL.\nDEINE\nPUNKTE', 'Sammeln. Einlösen. Gewinnen.', AppColors.gold, _HomeMock()),
    _Tour('PUNKTE\nSAMMELN', 'Bei jedem Spiel, Tipp und Einkauf.', Color(0xFF1DBF73), _CollectMock()),
    _Tour('PRÄMIEN\nEINLÖSEN', 'Gutscheine, Tickets & Fanshop.', Color(0xFF3D7BFF), _RedeemMock()),
    _Tour('GROSS\nGEWINNEN', 'Tombola: VIP-Tickets & signierte Trikots.', Color(0xFFE91E63), _TombolaMock()),
  ];

  void _next() {
    if (_page < _tours.length - 1) {
      _controller.nextPage(duration: const Duration(milliseconds: 320), curve: Curves.easeOut);
    } else {
      _goLogin();
    }
  }

  void _goLogin() =>
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));

  @override
  Widget build(BuildContext context) {
    final accent = _tours[_page].accent;
    return Scaffold(
      backgroundColor: const Color(0xFF0B0F14),
      body: Stack(
        children: [
          // Diagonal black/blue split backdrop (repaints as the accent changes).
          Positioned.fill(child: CustomPaint(painter: _DiagonalPainter(accent))),
          // Slides (headline + bleeding phone), swipeable.
          PageView.builder(
            controller: _controller,
            onPageChanged: (i) => setState(() => _page = i),
            itemCount: _tours.length,
            itemBuilder: (_, i) => _Slide(t: _tours[i]),
          ),
          // Skip (top-right)
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 8, 20, 0),
                child: GestureDetector(
                  onTap: _goLogin,
                  child: Text(tr('Skip'), style: AppText.body2.copyWith(color: Colors.white70, fontWeight: FontWeight.w700)),
                ),
              ),
            ),
          ),
          // Bottom CTA over a scrim so it stays readable above the phone bleed.
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: EdgeInsets.fromLTRB(24, 40, 24, 20 + MediaQuery.of(context).padding.bottom),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter, end: Alignment.bottomCenter,
                  colors: [Color(0x00000000), Color(0xCC000B18), Color(0xFF000B18)],
                ),
              ),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  for (var i = 0; i < _tours.length; i++)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: i == _page ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: i == _page ? accent : Colors.white24,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                ]),
                const SizedBox(height: 18),
                Tappable(
                  scale: 0.98,
                  onTap: _next,
                  child: Container(
                    width: double.infinity,
                    height: 54,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(999),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 18, offset: const Offset(0, 8))],
                    ),
                    child: Text(_page == _tours.length - 1 ? tr('Get Started') : tr('Continue'),
                        style: AppText.label2.copyWith(color: const Color(0xFF0B0F14), fontWeight: FontWeight.w800)),
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

/// One tour slide: a big uppercase headline with a coloured accent dot, and a
/// large phone mock that bleeds off the bottom edge.
class _Slide extends StatelessWidget {
  final _Tour t;
  const _Slide({required this.t});

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: Stack(
        children: [
          // Phone mock — large, centred, pushed down so it runs off the bottom.
          Align(
            alignment: Alignment.bottomCenter,
            child: Transform.translate(
              offset: const Offset(0, 72),
              child: _PhoneFrame(mock: t.mock),
            ),
          ),
          // Headline block, top-left.
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(26, 40, 26, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text.rich(
                    TextSpan(children: [
                      TextSpan(text: t.headline, style: _headStyle),
                      TextSpan(text: '.', style: _headStyle.copyWith(color: t.accent)),
                    ]),
                  ),
                  const SizedBox(height: 12),
                  Row(children: [
                    Container(width: 22, height: 3, color: t.accent),
                    const SizedBox(width: 8),
                    Flexible(child: Text(t.sub, style: AppText.body2.copyWith(color: Colors.white70))),
                  ]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static const _headStyle = TextStyle(
    fontFamily: 'Urbanist', color: Colors.white, fontSize: 46, height: 0.98, fontWeight: FontWeight.w800, letterSpacing: -1.0,
  );
}

/// The phone mock the tour shows — a real slice of the app. A fixed-size frame
/// so the internal mock keeps its proportions; the parent bleeds it off-screen.
class _PhoneFrame extends StatelessWidget {
  final Widget mock;
  const _PhoneFrame({required this.mock});
  @override
  Widget build(BuildContext context) {
    // Scale down on very narrow screens so the frame never exceeds the width.
    final w = MediaQuery.of(context).size.width;
    final scale = (w / 360).clamp(0.72, 1.0);
    return Transform.scale(
      scale: scale,
      alignment: Alignment.bottomCenter,
      child: Container(
        width: 300,
        height: 600,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFF05070A),
          borderRadius: BorderRadius.circular(46),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 40, offset: const Offset(0, 16))],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(38),
          child: Stack(children: [
            Positioned.fill(child: Container(color: const Color(0xFFF5F6F8), child: mock)),
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                width: 110, height: 26,
                decoration: const BoxDecoration(color: Color(0xFF05070A), borderRadius: BorderRadius.vertical(bottom: Radius.circular(16))),
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
      padding: const EdgeInsets.fromLTRB(16, 40, 16, 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: const [
          Svg('logo_s04', size: 22),
          Icon(Icons.notifications_none_rounded, size: 20, color: Color(0xFF667085)),
        ]),
        const SizedBox(height: 12),
        Text('Moin, Max 👋', style: TextStyle(fontFamily: 'Urbanist', fontSize: 17, fontWeight: FontWeight.w800, color: const Color(0xFF101828))),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(gradient: const LinearGradient(colors: _blue), borderRadius: BorderRadius.circular(16)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('S04 Fan Points', style: TextStyle(fontFamily: 'Urbanist', fontSize: 10, color: Colors.white70)),
            const SizedBox(height: 4),
            Text('4.820', style: TextStyle(fontFamily: 'Urbanist', fontSize: 34, height: 1, fontWeight: FontWeight.w800, color: Colors.white)),
            const SizedBox(height: 4),
            Text('≈ €48,20 in Gutscheinen', style: TextStyle(fontFamily: 'Urbanist', fontSize: 10, color: Colors.white70)),
          ]),
        ),
        const SizedBox(height: 14),
        Row(children: const [
          _MiniIcon(Icons.bolt_rounded, 'Sammeln', Color(0xFF1B7A3D)),
          _MiniIcon(Icons.card_giftcard_rounded, 'Einlösen', Color(0xFF0A2A5E)),
          _MiniIcon(Icons.emoji_events_rounded, 'Gewinne', Color(0xFF6A1B9A)),
          _MiniIcon(Icons.percent_rounded, 'Vorteile', Color(0xFFEF6C00)),
        ]),
        const SizedBox(height: 14),
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
      padding: const EdgeInsets.fromLTRB(16, 40, 16, 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Punkte sammeln', style: TextStyle(fontFamily: 'Urbanist', fontSize: 17, fontWeight: FontWeight.w800, color: const Color(0xFF101828))),
        const SizedBox(height: 14),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE4E7EC))),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text('Diese Woche', style: TextStyle(fontFamily: 'Urbanist', fontSize: 10, color: const Color(0xFF667085))),
              const Spacer(),
              _pill('🔥 5 Tage', const Color(0x1AEF6C00), const Color(0xFFEF6C00)),
            ]),
            const SizedBox(height: 6),
            Text('320 / 500 Pkt', style: TextStyle(fontFamily: 'Urbanist', fontSize: 22, fontWeight: FontWeight.w800, color: const Color(0xFF101828))),
            const SizedBox(height: 9),
            ClipRRect(borderRadius: BorderRadius.circular(4), child: const LinearProgressIndicator(value: 0.64, minHeight: 8, backgroundColor: Color(0xFFEAECF0), valueColor: AlwaysStoppedAnimation(Color(0xFF0055AA)))),
          ]),
        ),
        const SizedBox(height: 14),
        Row(children: const [
          _GameTile(Icons.casino_rounded, 'Glücksrad', '+50', Color(0xFF6A1B9A)),
          _GameTile(Icons.style_rounded, 'Rubbeln', '+30', Color(0xFFB8860B)),
          _GameTile(Icons.sports_soccer_rounded, 'Tippen', '+50', Color(0xFF1B7A3D)),
        ]),
        const SizedBox(height: 14),
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
      padding: const EdgeInsets.fromLTRB(16, 40, 16, 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Einlösen', style: TextStyle(fontFamily: 'Urbanist', fontSize: 17, fontWeight: FontWeight.w800, color: const Color(0xFF101828))),
        const SizedBox(height: 12),
        _dealCard('Heimtrikot 25/26', 'Fanshop · -15%', '3.800', const Color(0xFF0A2A5E), Icons.checkroom_rounded),
        const SizedBox(height: 11),
        _dealCard('VELTINS Gutschein', 'Sponsor · Code', '1.050', const Color(0xFF00623A), Icons.sports_bar_rounded),
        const SizedBox(height: 11),
        _dealCard('Heimspiel-Ticket', 'Tickets · Presale', '4.500', const Color(0xFF1565C0), Icons.confirmation_number_rounded),
        const SizedBox(height: 14),
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
      padding: const EdgeInsets.fromLTRB(16, 40, 16, 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Tombola', style: TextStyle(fontFamily: 'Urbanist', fontSize: 17, fontWeight: FontWeight.w800, color: const Color(0xFF101828))),
        const SizedBox(height: 14),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF0A2A5E), Color(0xFF000D22)]), borderRadius: BorderRadius.circular(18)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _pill('Los des Monats', const Color(0x33FFB800), AppColors.gold),
            const SizedBox(height: 14),
            const Icon(Icons.emoji_events_rounded, color: AppColors.gold, size: 34),
            const SizedBox(height: 10),
            Text('2× VIP-Tickets — vs BVB', style: TextStyle(fontFamily: 'Urbanist', fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
            const SizedBox(height: 14),
            Row(children: const [
              _CountBox('03', 'T'), SizedBox(width: 7), _CountBox('06', 'Std'), SizedBox(width: 7), _CountBox('12', 'Min'),
            ]),
            const SizedBox(height: 14),
            Container(
              width: double.infinity, height: 38, alignment: Alignment.center,
              decoration: BoxDecoration(gradient: const LinearGradient(colors: AppColors.goldGradient), borderRadius: BorderRadius.circular(999)),
              child: Text('Teilnehmen · gratis mit Super Fan', style: TextStyle(fontFamily: 'Urbanist', fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.brandDarkest)),
            ),
          ]),
        ),
        const SizedBox(height: 14),
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
        Container(width: 38, height: 38, decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(11)), child: Icon(icon, color: color, size: 19)),
        const SizedBox(height: 5),
        Text(label, style: TextStyle(fontFamily: 'Urbanist', fontSize: 9.5, fontWeight: FontWeight.w700, color: const Color(0xFF344054))),
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
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(13), border: Border.all(color: const Color(0xFFE4E7EC))),
        child: Column(children: [
          Container(width: 34, height: 34, decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: color, size: 17)),
          const SizedBox(height: 6),
          Text(label, style: TextStyle(fontFamily: 'Urbanist', fontSize: 9, fontWeight: FontWeight.w700, color: const Color(0xFF344054))),
          const SizedBox(height: 4),
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
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.22), borderRadius: BorderRadius.circular(10)),
        child: Column(children: [
          Text(v, style: TextStyle(fontFamily: 'Urbanist', fontSize: 17, fontWeight: FontWeight.w800, color: Colors.white)),
          Text(u, style: TextStyle(fontFamily: 'Urbanist', fontSize: 8, color: Colors.white70)),
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(gradient: LinearGradient(colors: gradient), borderRadius: BorderRadius.circular(13)),
      child: Row(children: [
        Container(width: 34, height: 34, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.16), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.local_fire_department_rounded, color: AppColors.gold, size: 18)),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: TextStyle(fontFamily: 'Urbanist', fontSize: 11.5, fontWeight: FontWeight.w800, color: Colors.white)),
          Text(sub, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontFamily: 'Urbanist', fontSize: 9.5, color: Colors.white70)),
        ])),
      ]),
    );
  }
}

Widget _pill(String text, Color bg, Color fg) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Text(text, style: TextStyle(fontFamily: 'Urbanist', fontSize: 9, fontWeight: FontWeight.w800, color: fg)),
    );

Widget _dealCard(String title, String meta, String pts, Color color, IconData icon) => Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(13), border: Border.all(color: const Color(0xFFE4E7EC))),
      child: Row(children: [
        Container(width: 40, height: 40, decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(11)), child: Icon(icon, color: color, size: 20)),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontFamily: 'Urbanist', fontSize: 12, fontWeight: FontWeight.w800, color: const Color(0xFF101828))),
          Text(meta, style: TextStyle(fontFamily: 'Urbanist', fontSize: 9.5, color: const Color(0xFF667085))),
        ])),
        Row(children: [
          const Icon(Icons.hexagon_rounded, size: 12, color: Color(0xFF0055AA)),
          const SizedBox(width: 3),
          Text(pts, style: TextStyle(fontFamily: 'Urbanist', fontSize: 12, fontWeight: FontWeight.w800, color: const Color(0xFF0055AA))),
        ]),
      ]),
    );

/// Diagonal black/blue split backdrop (Socios-style) with a subtle darker-blue
/// facet and a thin accent line + node.
class _DiagonalPainter extends CustomPainter {
  final Color accent;
  const _DiagonalPainter(this.accent);
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    // Base black.
    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFF0B0F14));
    // Main blue diagonal wedge from the lower-left.
    final blue = Paint()..color = const Color(0xFF123AA0);
    canvas.drawPath(
      Path()
        ..moveTo(0, h * 0.42)
        ..lineTo(w, h * 0.66)
        ..lineTo(w, h)
        ..lineTo(0, h)
        ..close(),
      blue,
    );
    // Darker facet for depth (lower-right).
    final dark = Paint()..color = const Color(0xFF0A2A5E);
    canvas.drawPath(
      Path()
        ..moveTo(w, h * 0.66)
        ..lineTo(w, h)
        ..lineTo(w * 0.52, h)
        ..close(),
      dark,
    );
    // Thin accent connector line with a node (top-left).
    final line = Paint()
      ..color = Colors.white.withValues(alpha: 0.14)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.10, h * 0.30)
        ..lineTo(w * 0.10, h * 0.40)
        ..arcToPoint(Offset(w * 0.16, h * 0.46), radius: const Radius.circular(22))
        ..lineTo(w * 0.40, h * 0.46),
      line,
    );
    canvas.drawCircle(Offset(w * 0.10, h * 0.30), 3.2, Paint()..color = accent);
  }

  @override
  bool shouldRepaint(covariant _DiagonalPainter oldDelegate) => oldDelegate.accent != accent;
}
