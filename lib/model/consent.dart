import 'package:flutter/foundation.dart';

/// Separate, individually withdrawable consent flags (GDPR / EU 2019/1150).
/// Each purpose is its own opt-in — the app never bundles them into one "accept
/// all". Screens listen to these so a withdrawn consent takes effect instantly
/// (e.g. turning off ads hides sponsored placements live).
///
/// Defaults are ON in this prototype so a presenter sees the full experience;
/// the point being demonstrated is that every one is transparent and can be
/// switched off at any time from Profile → Privacy.
final ValueNotifier<bool> personalizationConsent = ValueNotifier<bool>(true);
final ValueNotifier<bool> adsConsent = ValueNotifier<bool>(true);
final ValueNotifier<bool> locationConsent = ValueNotifier<bool>(true);

/// Per-placement dismissal for the two floating sponsor ads. A fan can hide each
/// one (with a confirm so it isn't lost by accident); session-scoped.
final ValueNotifier<bool> pizzaHutAdVisible = ValueNotifier<bool>(true);
final ValueNotifier<bool> mcdonaldsAdVisible = ValueNotifier<bool>(true);
