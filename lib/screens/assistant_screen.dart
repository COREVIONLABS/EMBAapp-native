import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import '../model/fan_model.dart';
import '../l10n/strings.dart';

/// Club AI assistant — answers the everyday fan questions (next match, points,
/// vouchers, tombola, tickets). Prototype: scripted answers to quick-reply
/// chips and a keyword match on typed input, in a clean chat UI.
class AssistantScreen extends StatefulWidget {
  const AssistantScreen({super.key});
  @override
  State<AssistantScreen> createState() => _AssistantScreenState();
}

class _Msg {
  final String text;
  final bool bot;
  const _Msg(this.text, this.bot);
}

class _AssistantScreenState extends State<AssistantScreen> {
  final _ctrl = TextEditingController();
  final _scroll = ScrollController();
  final List<_Msg> _msgs = [
    const _Msg('Moin! I\'m your S04 assistant. Ask me anything — or tap a question below.', true),
  ];

  // (chip label, scripted answer)
  static const _faq = <(String, String)>[
    ('When\'s the next match?', 'Your next match is FC Schalke 04 vs Borussia Dortmund, Sat 15:30 at the VELTINS-Arena. Predict the score on the Home screen for +50 points!'),
    ('How do points work?', '100 points = €1 in rewards. Earn points from check-ins, predictions, votes and daily games, then turn them into vouchers or tombola lots. Nothing is ever cashed out.'),
    ('Where are my vouchers?', 'All your redeemed vouchers live in Wallet → My Vouchers. Show the code at the club shop or counter to redeem.'),
    ('How does the tombola work?', 'Members get free lots each month. Your lots are entered automatically into the next monthly draw — more lots, more chances. 18+, no purchase necessary.'),
    ('How do I get tickets?', 'Redeem points for a ticket voucher on the Redeem tab, or open Tickets from the Home menu. Fan+ members get priority access 48–72h early.'),
  ];

  void _send(String text, {String? answer}) {
    final q = text.trim();
    if (q.isEmpty) return;
    setState(() {
      _msgs.add(_Msg(q, false));
      _msgs.add(_Msg(answer ?? _answerFor(q), true));
      _ctrl.clear();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) _scroll.animateTo(_scroll.position.maxScrollExtent, duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
    });
  }

  String _answerFor(String q) {
    final s = q.toLowerCase();
    for (final f in _faq) {
      final key = f.$1.toLowerCase();
      if (s.contains('match') && key.contains('match')) return f.$2;
      if (s.contains('point') && key.contains('point')) return f.$2;
      if (s.contains('voucher') && key.contains('voucher')) return f.$2;
      if ((s.contains('tombola') || s.contains('lot') || s.contains('raffle')) && key.contains('tombola')) return f.$2;
      if (s.contains('ticket') && key.contains('ticket')) return f.$2;
    }
    if (s.contains('balance') || s.contains('punkte') || s.contains('points')) {
      return 'You have ${FanModel.pointsFormatted} points (≈ ${FanModel.balanceEuro} in rewards).';
    }
    return 'I can help with matches, points, vouchers, the tombola and tickets. Tap one of the questions below, or ask in those words.';
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(children: [
          // Header.
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 4, 12, 4),
            child: Row(children: [
              IconButton(onPressed: () => Navigator.of(context).maybePop(), icon: Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: AppColors.textDarker)),
              Container(width: 34, height: 34, decoration: BoxDecoration(color: AppColors.brandLightest, borderRadius: BorderRadius.circular(11)), child: const Icon(Icons.auto_awesome_rounded, color: AppColors.brandPrimary, size: 18)),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(tr('S04 Assistant'), style: AppText.label2),
                Text(tr('Always here to help'), style: AppText.caption1.copyWith(color: AppColors.textLight)),
              ])),
            ]),
          ),
          const Divider(height: 1),
          // Messages.
          Expanded(
            child: ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              itemCount: _msgs.length,
              itemBuilder: (_, i) => _bubble(_msgs[i]),
            ),
          ),
          // Quick replies.
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _faq.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) => Center(child: Tappable(
                onTap: () => _send(_faq[i].$1, answer: _faq[i].$2),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(999), border: Border.all(color: AppColors.borderLightest)),
                  child: Text(tr(_faq[i].$1), style: AppText.caption1.copyWith(color: AppColors.textNormal, fontWeight: FontWeight.w700)),
                ),
              )),
            ),
          ),
          const SizedBox(height: 8),
          // Input.
          Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 10 + MediaQuery.of(context).padding.bottom),
            child: Row(children: [
              Expanded(child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(color: AppColors.surfaceMinimal, borderRadius: BorderRadius.circular(999)),
                child: TextField(
                  controller: _ctrl,
                  onSubmitted: (v) => _send(v),
                  style: AppText.body2.copyWith(color: AppColors.textDarker),
                  cursorColor: AppColors.brandPrimary,
                  decoration: InputDecoration(isDense: true, border: InputBorder.none, hintText: tr('Ask the assistant…'), hintStyle: AppText.body2.copyWith(color: AppColors.textLight), contentPadding: const EdgeInsets.symmetric(vertical: 13)),
                ),
              )),
              const SizedBox(width: 10),
              Tappable(
                onTap: () => _send(_ctrl.text),
                child: Container(width: 46, height: 46, decoration: const BoxDecoration(color: AppColors.brandPrimary, shape: BoxShape.circle), child: const Icon(Icons.arrow_upward_rounded, color: Colors.white, size: 22)),
              ),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _bubble(_Msg m) {
    return Align(
      alignment: m.bot ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
        decoration: BoxDecoration(
          color: m.bot ? AppColors.surfaceMinimal : AppColors.brandPrimary,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16), topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(m.bot ? 4 : 16), bottomRight: Radius.circular(m.bot ? 16 : 4),
          ),
        ),
        child: Text(tr(m.text), style: AppText.body2.copyWith(color: m.bot ? AppColors.textDarker : Colors.white, height: 1.35)),
      ),
    );
  }
}
