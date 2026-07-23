import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Real finger-scratch card (ported from the original EMBA prototype),
/// restyled to the Schalke design. Swipe to erase the cover; the reward
/// underneath is revealed once ~45% is scratched.
class ScratchCard extends StatefulWidget {
  final Widget reward;
  final double height;
  final VoidCallback onRevealed;
  const ScratchCard({super.key, required this.reward, required this.onRevealed, this.height = 200});

  @override
  State<ScratchCard> createState() => _ScratchCardState();
}

class _ScratchCardState extends State<ScratchCard> {
  final List<Offset> _points = [];
  final Set<int> _grid = {};
  static const int _g = 20; // grid resolution
  bool _revealed = false;
  Size _size = Size.zero;

  void _add(Offset p) {
    if (_revealed || _size == Size.zero) return;
    _points.add(p);
    final cx = (p.dx / _size.width * _g).floor().clamp(0, _g - 1);
    final cy = (p.dy / _size.height * _g).floor().clamp(0, _g - 1);
    _grid.add(cy * _g + cx);
    if (_grid.length / (_g * _g) > 0.45) {
      _revealed = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => widget.onRevealed());
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: LayoutBuilder(
        builder: (context, c) {
          _size = Size(c.maxWidth, widget.height);
          return ClipRRect(
            borderRadius: BorderRadius.circular(AppRadii.card),
            child: Stack(
              children: [
                Positioned.fill(child: widget.reward),
                if (!_revealed)
                  Positioned.fill(
                    child: GestureDetector(
                      onPanStart: (d) => _add(d.localPosition),
                      onPanUpdate: (d) => _add(d.localPosition),
                      child: CustomPaint(painter: _ScratchPainter(List.of(_points))),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ScratchPainter extends CustomPainter {
  final List<Offset> points;
  _ScratchPainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.saveLayer(rect, Paint());
    final cover = Paint()
      ..shader = const LinearGradient(colors: [Color(0xFFB0B8C4), Color(0xFF8A94A6)]).createShader(rect);
    canvas.drawRect(rect, cover);
    final tp = TextPainter(
      text: const TextSpan(
        text: 'Swipe to scratch  🪙',
        style: TextStyle(fontFamily: 'Urbanist', color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: size.width);
    tp.paint(canvas, Offset((size.width - tp.width) / 2, (size.height - tp.height) / 2));
    final erase = Paint()
      ..blendMode = BlendMode.clear
      ..style = PaintingStyle.fill;
    for (final p in points) {
      canvas.drawCircle(p, 26, erase);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _ScratchPainter old) => old.points.length != points.length;
}
