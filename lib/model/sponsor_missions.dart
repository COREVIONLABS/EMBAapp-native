import 'package:flutter/material.dart';

/// The kind of sponsor-funded action a mission asks the fan to do. Each maps to
/// a lightweight in-app flow (watch a clip, answer a survey, scan a receipt …).
enum MissionKind { watch, survey, quiz, share, receipt }

/// A sponsor-funded fan mission — the club's third revenue stream. A partner
/// pays to activate fans (brand awareness, market research, footfall), the fan
/// earns Fan Points, the club earns sponsor money and first-party data. Every
/// card is co-branded "powered by `sponsor`".
class SponsorMission {
  final String id;
  final String sponsor;
  final IconData sponsorIcon;
  final Color sponsorColor;
  final MissionKind kind;
  final String title;
  final String blurb;
  final int reward; // Fan Points the fan earns
  final String cta;
  bool done;

  SponsorMission({
    required this.id,
    required this.sponsor,
    required this.sponsorIcon,
    required this.sponsorColor,
    required this.kind,
    required this.title,
    required this.blurb,
    required this.reward,
    required this.cta,
    this.done = false,
  });

  IconData get kindIcon => switch (kind) {
        MissionKind.watch => Icons.play_circle_outline_rounded,
        MissionKind.survey => Icons.fact_check_outlined,
        MissionKind.quiz => Icons.quiz_outlined,
        MissionKind.share => Icons.share_outlined,
        MissionKind.receipt => Icons.receipt_long_outlined,
      };

  String get kindLabel => switch (kind) {
        MissionKind.watch => 'Watch',
        MissionKind.survey => 'Survey',
        MissionKind.quiz => 'Quiz',
        MissionKind.share => 'Share',
        MissionKind.receipt => 'Scan receipt',
      };
}

/// In-memory sponsor-mission board (prototype state). Shared app-wide so Home,
/// the Earn hub and the missions screen agree on which are done and the reward.
class SponsorMissionStore extends ChangeNotifier {
  final List<SponsorMission> missions = [
    SponsorMission(
      id: 'veltins_watch',
      sponsor: 'Veltins',
      sponsorIcon: Icons.sports_bar_rounded,
      sponsorColor: const Color(0xFF00623A),
      kind: MissionKind.watch,
      title: 'Watch the matchday film',
      blurb: 'A 30-second Veltins clip on the derby build-up.',
      reward: 50,
      cta: 'Watch & earn',
    ),
    SponsorMission(
      id: 'rewe_receipt',
      sponsor: 'REWE',
      sponsorIcon: Icons.shopping_cart_rounded,
      sponsorColor: const Color(0xFFC8102E),
      kind: MissionKind.receipt,
      title: 'Scan your REWE receipt',
      blurb: 'Shopped at REWE? Scan the receipt to earn.',
      reward: 150,
      cta: 'Scan & earn',
    ),
    SponsorMission(
      id: 'adidas_survey',
      sponsor: 'adidas',
      sponsorIcon: Icons.sports_soccer_rounded,
      sponsorColor: const Color(0xFF111111),
      kind: MissionKind.survey,
      title: 'Which away kit should we make?',
      blurb: 'Three quick questions — help design next season.',
      reward: 80,
      cta: 'Take survey',
    ),
    SponsorMission(
      id: 'vivawest_share',
      sponsor: 'Vivawest',
      sponsorIcon: Icons.apartment_rounded,
      sponsorColor: const Color(0xFF6A1B9A),
      kind: MissionKind.share,
      title: 'Share the derby graphic',
      blurb: 'Spread the blue & white with the Vivawest matchday post.',
      reward: 25,
      cta: 'Share & earn',
    ),
    SponsorMission(
      id: 'ernstings_quiz',
      sponsor: "Ernsting's family",
      sponsorIcon: Icons.checkroom_rounded,
      sponsorColor: const Color(0xFFE30613),
      kind: MissionKind.quiz,
      title: 'Knappen quiz',
      blurb: 'One question. Get it right, earn the points.',
      reward: 40,
      cta: 'Play quiz',
    ),
  ];

  List<SponsorMission> get open => missions.where((m) => !m.done).toList();
  List<SponsorMission> get completed => missions.where((m) => m.done).toList();
  int get openCount => open.length;

  /// Total points a fan can still earn from open sponsor missions.
  int get availablePoints => open.fold(0, (sum, m) => sum + m.reward);

  void complete(SponsorMission m) {
    if (m.done) return;
    m.done = true;
    notifyListeners();
  }
}

final sponsorMissionStore = SponsorMissionStore();
