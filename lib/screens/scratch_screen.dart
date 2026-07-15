import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme.dart';
import '../app_state.dart';
import '../widgets/scratch_card.dart';

class ScratchScreen extends StatefulWidget {
  const ScratchScreen({super.key});
  @override
  State<ScratchScreen> createState() => _ScratchScreenState();
}

class _ScratchScreenState extends State<ScratchScreen> {
  final List<int> rewards = [80, 120, 150, 200];
  final List<int> weights = [30, 34, 22, 14];
  late int _prize;
  bool _claimed = false;

  @override
  void initState() {
    super.initState();
    _prize = _pick();
  }

  int _pick() {
    final total = weights.fold<int>(0, (a, b) => a + b);
    var r = math.Random().nextInt(total);
    for (int i = 0; i < weights.length; i++) {
      if (r < weights[i]) return rewards[i];
      r -= weights[i];
    }
    return rewards.first;
  }

  void _onRevealed() {
    if (_claimed) return;
    _claimed = true;
    appState.addPoints(_prize);
    appState.markScratched();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Freigerubbelt: +$_prize Fan Points 🎉'), backgroundColor: AppColors.navy),
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.ink,
        elevation: 0,
        title: const Text('Scratch Card'),
      ),
      body: ListenableBuilder(
        listenable: appState,
        builder: (context, _) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 6),
              Text('Fan Points: ${_fmt(appState.points)}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.muted, fontWeight: FontWeight.w600)),
              const SizedBox(height: 30),
              const Text('Deine Tageskarte', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              const Text('Rubbel das Feld frei und sichere dir deinen Gewinn.',
                  style: TextStyle(color: AppColors.muted)),
              const SizedBox(height: 20),
              ScratchCard(
                onRevealed: _onRevealed,
                reward: Container(
                  decoration: const BoxDecoration(color: Color(0xFFEAF1FF)),
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('🎁', style: TextStyle(fontSize: 46)),
                      const SizedBox(height: 8),
                      Text('+$_prize Fan Points',
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.navy)),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              if (_claimed)
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.navy,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Weiter', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                ),
            ],
          ),
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
