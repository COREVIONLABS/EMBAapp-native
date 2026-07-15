import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme.dart';
import '../app_state.dart';
import '../widgets/wheel.dart';

class SpinScreen extends StatefulWidget {
  const SpinScreen({super.key});
  @override
  State<SpinScreen> createState() => _SpinScreenState();
}

class _SpinScreenState extends State<SpinScreen> with SingleTickerProviderStateMixin {
  // Prize per segment (points). Demo-safe: no zero.
  final List<int> prizes = [50, 100, 20, 200, 10, 500, 30, 150];
  // Relative weights (higher = more likely). Big prizes rarer.
  final List<int> weights = [22, 16, 24, 6, 24, 2, 22, 8];

  late final AnimationController _ctrl;
  double _rotation = 0;
  Animation<double> _anim = const AlwaysStoppedAnimation<double>(0);
  bool _spinning = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 4200));
    _ctrl.addStatusListener((s) {
      if (s == AnimationStatus.completed) _onDone();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  int _pickIndex() {
    final total = weights.fold<int>(0, (a, b) => a + b);
    var r = math.Random().nextInt(total);
    for (int i = 0; i < weights.length; i++) {
      if (r < weights[i]) return i;
      r -= weights[i];
    }
    return 0;
  }

  int _selected = 0;

  void _spin() {
    if (_spinning || appState.spunToday) return;
    setState(() => _spinning = true);
    final n = prizes.length;
    final sweep = 2 * math.pi / n;
    _selected = _pickIndex();
    // orientation (mod 2pi) that puts segment center at top (3pi/2)
    double target = (3 * math.pi / 2 - (_selected * sweep + sweep / 2)) % (2 * math.pi);
    if (target < 0) target += 2 * math.pi;
    final curMod = _rotation % (2 * math.pi);
    double delta = (target - curMod) % (2 * math.pi);
    if (delta < 0) delta += 2 * math.pi;
    final finalRot = _rotation + 2 * math.pi * 6 + delta;
    _anim = Tween<double>(begin: _rotation, end: finalRot)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _rotation = finalRot;
    _ctrl
      ..reset()
      ..forward();
  }

  void _onDone() {
    _spinning = false;
    final prize = prizes[_selected];
    appState.addPoints(prize);
    appState.markSpun();
    _showReward(prize);
  }

  void _showReward(int prize) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(26),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🎉', style: TextStyle(fontSize: 52)),
              const SizedBox(height: 8),
              const Text('Gewonnen!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              Text('+$prize Fan Points',
                  style: const TextStyle(fontSize: 18, color: AppColors.blue, fontWeight: FontWeight.w700)),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: AppColors.navy),
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Super!'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final done = appState.spunToday;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.ink,
        elevation: 0,
        title: const Text('Daily Spin'),
      ),
      body: ListenableBuilder(
        listenable: appState,
        builder: (context, _) => Column(
          children: [
            const SizedBox(height: 8),
            Text('Fan Points: ${_fmt(appState.points)}',
                style: const TextStyle(color: AppColors.muted, fontWeight: FontWeight.w600)),
            const Spacer(),
            SizedBox(
              width: 300,
              height: 320,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  AnimatedBuilder(
                    animation: _ctrl,
                    builder: (context, child) => Transform.rotate(
                      angle: _spinning || _ctrl.isAnimating ? _anim.value : _rotation,
                      child: child,
                    ),
                    child: SizedBox(
                      width: 280, height: 280,
                      child: CustomPaint(painter: WheelPainter(prizes)),
                    ),
                  ),
                  // fixed pointer at top
                  Positioned(
                    top: 8,
                    child: Transform.rotate(
                      angle: math.pi,
                      child: const Icon(Icons.arrow_drop_up, size: 56, color: AppColors.gold),
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: done ? AppColors.muted : AppColors.navy,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                      onPressed: (_spinning || done) ? null : _spin,
                      child: Text(done ? 'Heute bereits gedreht' : 'Jetzt drehen',
                          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                    ),
                  ),
                  if (done)
                    TextButton(
                      onPressed: () => appState.resetDaily(),
                      child: const Text('Für Demo zurücksetzen'),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _fmt(int n) {
    final s = n.toString();
    final b = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) b.write('.');
      b.write(s[i]);
    }
    return b.toString();
  }
}
