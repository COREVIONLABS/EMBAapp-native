import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import '../widgets/sub_scaffold.dart';
import '../l10n/strings.dart';

/// Entertainer-PIN redemption — the staff-side confirmation flow a kiosk/steward
/// runs to mark a voucher used. Three animated steps: enter the 4-digit PIN on a
/// live keypad (with a running clock so it's clearly a supervised, in-person
/// action) → confirming → success with the code and a frozen timestamp.
/// Prototype: any 4 digits are accepted.
class RedeemPinScreen extends StatefulWidget {
  final String title;
  final String sponsor;
  final String code;
  const RedeemPinScreen({
    super.key,
    this.title = 'Free Veltins 0.5L',
    this.sponsor = 'Veltins',
    this.code = 'S04-VEL-9F3K',
  });

  @override
  State<RedeemPinScreen> createState() => _RedeemPinScreenState();
}

enum _Step { pin, confirming, done }

class _RedeemPinScreenState extends State<RedeemPinScreen> {
  _Step _step = _Step.pin;
  String _pin = '';
  Timer? _clock;
  DateTime _now = DateTime.now();
  DateTime? _redeemedAt;

  @override
  void initState() {
    super.initState();
    _clock = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && _step == _Step.pin) setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _clock?.cancel();
    super.dispose();
  }

  void _tap(String d) {
    if (_pin.length >= 4) return;
    setState(() => _pin += d);
    if (_pin.length == 4) _submit();
  }

  void _back() {
    if (_pin.isEmpty) return;
    setState(() => _pin = _pin.substring(0, _pin.length - 1));
  }

  Future<void> _submit() async {
    setState(() => _step = _Step.confirming);
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    setState(() {
      _redeemedAt = DateTime.now();
      _step = _Step.done;
    });
  }

  String _two(int n) => n.toString().padLeft(2, '0');
  String _clockStr(DateTime t) => '${_two(t.hour)}:${_two(t.minute)}:${_two(t.second)}';
  String _dateStr(DateTime t) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${t.day} ${months[t.month - 1]} ${t.year}';
  }

  @override
  Widget build(BuildContext context) {
    return SubScaffold(
      title: tr('Redeem Voucher'),
      bottomBar: _step == _Step.done
          ? PrimaryButton(tr('Done'), onTap: () => Navigator.of(context).pop(true))
          : null,
      children: [
        // Voucher summary (constant across steps)
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: AppColors.surfaceMinimal, borderRadius: BorderRadius.circular(AppRadii.tile)),
          child: Row(children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(color: AppColors.brandLightest, borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.confirmation_number_rounded, color: AppColors.brandPrimary, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(tr(widget.title), style: AppText.body2.copyWith(color: AppColors.textDarker, fontWeight: FontWeight.w700)),
              Text('${tr('Powered by')} ${widget.sponsor}', style: AppText.body3Regular),
            ])),
          ]),
        ),
        const SizedBox(height: 24),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 260),
          transitionBuilder: (child, anim) => FadeTransition(
            opacity: anim,
            child: SlideTransition(position: Tween(begin: const Offset(0, 0.04), end: Offset.zero).animate(anim), child: child),
          ),
          child: _body(),
        ),
      ],
    );
  }

  Widget _body() {
    switch (_step) {
      case _Step.pin:
        return _pinStep();
      case _Step.confirming:
        return _confirmingStep();
      case _Step.done:
        return _doneStep();
    }
  }

  // ── Step 1: keypad ──────────────────────────────────────────────
  Widget _pinStep() {
    return Column(key: const ValueKey('pin'), children: [
      // Live clock
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(width: 8, height: 8, decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.success)),
        const SizedBox(width: 8),
        Text('${tr('Live')} · ${_clockStr(_now)}', style: AppText.body3.copyWith(color: AppColors.textLight, fontWeight: FontWeight.w700, letterSpacing: 1)),
      ]),
      const SizedBox(height: 20),
      Text(tr('Staff: enter the 4-digit Entertainer PIN'), textAlign: TextAlign.center, style: AppText.label2.copyWith(color: AppColors.textDarker)),
      const SizedBox(height: 6),
      Text(tr('Hand the phone to the kiosk staff to confirm this voucher in person.'), textAlign: TextAlign.center, style: AppText.body3Regular),
      const SizedBox(height: 24),
      // PIN dots
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        for (var i = 0; i < 4; i++) ...[
          AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 16, height: 16,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: i < _pin.length ? AppColors.brandPrimary : Colors.transparent,
              border: Border.all(color: i < _pin.length ? AppColors.brandPrimary : AppColors.textLight, width: 2),
            ),
          ),
          if (i < 3) const SizedBox(width: 18),
        ],
      ]),
      const SizedBox(height: 28),
      _Keypad(onDigit: _tap, onBackspace: _back),
    ]);
  }

  // ── Step 2: confirming ─────────────────────────────────────────
  Widget _confirmingStep() {
    return Column(key: const ValueKey('confirming'), children: [
      const SizedBox(height: 20),
      const SizedBox(
        width: 54, height: 54,
        child: CircularProgressIndicator(strokeWidth: 3, valueColor: AlwaysStoppedAnimation(AppColors.brandPrimary)),
      ),
      const SizedBox(height: 20),
      Text(tr('Confirming with the kiosk…'), style: AppText.label2.copyWith(color: AppColors.textDarker)),
      const SizedBox(height: 6),
      Text(tr('Verifying the Entertainer PIN.'), style: AppText.body3Regular),
      const SizedBox(height: 20),
    ]);
  }

  // ── Step 3: success ────────────────────────────────────────────
  Widget _doneStep() {
    final at = _redeemedAt ?? DateTime.now();
    return Column(key: const ValueKey('done'), children: [
      const SizedBox(height: 12),
      TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 520),
        curve: Curves.elasticOut,
        builder: (_, v, __) => Transform.scale(
          scale: v,
          child: Container(
            width: 84, height: 84,
            decoration: BoxDecoration(color: AppColors.successBg, shape: BoxShape.circle),
            child: const Icon(Icons.check_rounded, color: AppColors.success, size: 46),
          ),
        ),
      ),
      const SizedBox(height: 18),
      Text(tr('Voucher redeemed'), style: AppText.h4.copyWith(color: AppColors.textDarker)),
      const SizedBox(height: 6),
      Text(tr('Confirmed by staff — enjoy!'), textAlign: TextAlign.center, style: AppText.body1.copyWith(color: AppColors.textLight)),
      const SizedBox(height: 22),
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadii.card), border: Border.all(color: AppColors.borderLightest)),
        child: Column(children: [
          _row(tr('Voucher'), tr(widget.title)),
          const Divider(height: 22),
          _row(tr('Code'), widget.code, mono: true),
          const Divider(height: 22),
          _row(tr('Redeemed at'), '${_clockStr(at)} · ${_dateStr(at)}'),
        ]),
      ),
      const SizedBox(height: 14),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.verified_rounded, size: 14, color: AppColors.success),
        const SizedBox(width: 6),
        Text(tr('Single-use — this code is now spent.'), style: AppText.caption1.copyWith(color: AppColors.textLight)),
      ]),
    ]);
  }

  Widget _row(String label, String value, {bool mono = false}) {
    return Row(children: [
      Text(label, style: AppText.body3Regular),
      const Spacer(),
      Flexible(child: Text(
        value,
        textAlign: TextAlign.right,
        overflow: TextOverflow.ellipsis,
        style: mono
            ? TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.w800, letterSpacing: 1.5, color: AppColors.textDarker)
            : AppText.body2.copyWith(color: AppColors.textDarker, fontWeight: FontWeight.w700),
      )),
    ]);
  }
}

class _Keypad extends StatelessWidget {
  final ValueChanged<String> onDigit;
  final VoidCallback onBackspace;
  const _Keypad({required this.onDigit, required this.onBackspace});

  @override
  Widget build(BuildContext context) {
    final keys = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '', '0', '⌫'];
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.7,
      children: [
        for (final k in keys)
          if (k.isEmpty)
            const SizedBox()
          else
            Tappable(
              onTap: () => k == '⌫' ? onBackspace() : onDigit(k),
              child: Container(
                decoration: BoxDecoration(
                  color: k == '⌫' ? Colors.transparent : AppColors.surfaceMinimal,
                  borderRadius: BorderRadius.circular(AppRadii.tile),
                ),
                alignment: Alignment.center,
                child: k == '⌫'
                    ? Icon(Icons.backspace_outlined, color: AppColors.textNormal, size: 22)
                    : Text(k, style: AppText.h4.copyWith(color: AppColors.textDarker, fontWeight: FontWeight.w700, fontSize: 24)),
              ),
            ),
      ],
    );
  }
}
