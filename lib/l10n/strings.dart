import 'package:flutter/widgets.dart';

enum AppLocale { de, en }

/// Global, app-wide language switch. Toggling this and rebuilding from the
/// root (see [SchalkeApp]) re-runs every `tr(...)` call, so the whole UI
/// switches language live. Default is German (the club's home market).
final ValueNotifier<AppLocale> localeNotifier = ValueNotifier<AppLocale>(AppLocale.de);

Locale get currentLocale => localeNotifier.value == AppLocale.de ? const Locale('de') : const Locale('en');

/// Translate an English source string to the active language.
/// Returns the English source unchanged when the language is English or no
/// German translation exists yet (graceful fallback).
String tr(String en) {
  if (localeNotifier.value == AppLocale.en) return en;
  return _de[en] ?? en;
}

/// Translate with a placeholder, e.g. `trp('{n} deals available', n: '8')`.
String trp(String en, {String? n, String? a, String? b}) {
  var s = tr(en);
  if (n != null) s = s.replaceAll('{n}', n);
  if (a != null) s = s.replaceAll('{a}', a);
  if (b != null) s = s.replaceAll('{b}', b);
  return s;
}

/// English source → German. Keep keys identical to the literal in the widget.
const Map<String, String> _de = {
  // ── Navigation ─────────────────────────────────────────────
  'Home': 'Start',
  'Shop': 'Shop',
  'Wallet': 'Wallet',
  'Points': 'Punkte',
  'Profile': 'Profil',

  // ── Common actions / labels ────────────────────────────────
  'Log In': 'Anmelden',
  'Log Out': 'Abmelden',
  'Sign Up': 'Registrieren',
  'Redeem': 'Einlösen',
  'Redeem Points': 'Punkte einlösen',
  'See All': 'Alle ansehen',
  'Done': 'Fertig',
  'Continue': 'Weiter',
  'Cancel': 'Abbrechen',
  'Save': 'Speichern',
  'Edit Profile': 'Profil bearbeiten',
  'Search': 'Suche',
  'Buy Now': 'Jetzt kaufen',
  'Add to Cart': 'In den Warenkorb',
  'Checkout': 'Zur Kasse',
  'Home Match': 'Heimspiel',
  'Away Match': 'Auswärtsspiel',
  'Featured': 'Empfohlen',
  'Active': 'Aktiv',
  'Locked': 'Gesperrt',
  'Exclusive': 'Exklusiv',
  'FREE': 'GRATIS',
  'Current': 'Aktuell',

  // ── Home ───────────────────────────────────────────────────
  'S04 Fan Points': 'S04 Fan-Punkte',
  'Until Kickoff': 'Bis Anpfiff',
  'Predict Score': 'Ergebnis tippen',
  'Daily Spin': 'Tägliches Glücksrad',
  'Scratch Card': 'Rubbellos',
  'Predictions': 'Tippspiel',
  'Rewards': 'Prämien',
  'Active Missions': 'Aktive Missionen',
  'Explore': 'Entdecken',
  'Tickets': 'Tickets',
  'Experiences': 'Erlebnisse',
  'Deals': 'Angebote',
  'Specials': 'Specials',
  'News': 'News',
  'Awards': 'Auszeichnungen',
  'Upcoming Experiences': 'Kommende Erlebnisse',
  'Club News': 'Vereins-News',
  'Exclusive Reward': 'Exklusive Prämie',
  'Meet the Players': 'Triff die Spieler',
  'Spend €200 this week': 'Gib diese Woche 200 € aus',
  'Invite a friend': 'Lade einen Freund ein',
  'Predict 2 matches': 'Tippe 2 Spiele',
  'Not started': 'Nicht begonnen',
  '3x Stadium Boost': '3x Stadion-Boost',

  // ── Points / Loyalty ───────────────────────────────────────
  'Use your points': 'Nutze deine Punkte',
  'Points are ready to use': 'Punkte sind einsatzbereit',
  'Earn more points': 'Mehr Punkte sammeln',
  'See all the ways to collect Fan Points': 'Alle Wege zum Sammeln von Fan-Punkten',
  'History': 'Verlauf',
  'Missions': 'Missionen',
  'Earn Points': 'Punkte sammeln',
  'Your Balance': 'Dein Guthaben',
  'Ways to Earn': 'So sammelst du',
  'Attend a Match': 'Besuche ein Spiel',
  'Earn points for each home match': 'Punkte für jedes Heimspiel',
  'Fanshop Purchase': 'Fanshop-Einkauf',
  'Share on Social': 'In sozialen Medien teilen',
  'Share Schalke content': 'Schalke-Inhalte teilen',
  'Refer a Friend': 'Freund werben',
  'Invite friends to join': 'Lade Freunde ein',
  'Daily Check-in': 'Täglicher Check-in',
  'Open the app every day': 'Öffne die App täglich',
  'Complete Profile': 'Profil vervollständigen',
  'Fill in all profile fields': 'Fülle alle Profilfelder aus',
  'Loyalty Tiers': 'Treuestufen',
  'Your Current Tier': 'Deine aktuelle Stufe',
  'View Points History': 'Punkteverlauf ansehen',
  'Points History': 'Punkteverlauf',
  'Free for every fan — your tier rises automatically as you collect Fan Points.':
      'Kostenlos für jeden Fan — deine Stufe steigt automatisch, während du Fan-Punkte sammelst.',

  // ── Loyalty tier names (kept as proper nouns, not translated) ──

  // ── Deals ──────────────────────────────────────────────────
  'Deals Hub': 'Angebote',
  'Search deals...': 'Angebote suchen...',
  'All Deals': 'Alle Angebote',
  'Food': 'Essen',
  'Events': 'Events',
  'Shopping': 'Shopping',
  'Travel': 'Reisen',
  'Health & Wellness': 'Gesundheit & Wellness',
  'Partner Brands': 'Partner-Marken',
  'Featured Deals': 'Empfohlene Angebote',
  'How it works': 'So funktioniert’s',
  'Activate Deal': 'Angebot aktivieren',
  'Matchday Specials': 'Spieltags-Specials',
  'deals available': 'Angebote verfügbar',

  // ── Tickets ────────────────────────────────────────────────
  'My Tickets': 'Meine Tickets',
  'Buy Ticket': 'Ticket kaufen',
  'Show this QR code at the turnstile': 'Zeige diesen QR-Code am Drehkreuz',
  'Block': 'Block',
  'Row': 'Reihe',
  'Seat': 'Platz',
  'All': 'Alle',
  'Away': 'Auswärts',

  // ── Experiences ────────────────────────────────────────────
  'Upcoming': 'Demnächst',
  'My Bookings': 'Meine Buchungen',
  'Book Experience': 'Erlebnis buchen',
  'Enter Raffle': 'An Verlosung teilnehmen',
  'VIP Experiences': 'VIP-Erlebnisse',

  // ── Fanshop ────────────────────────────────────────────────
  'Fan Shop': 'Fanshop',
  'Your Cart': 'Dein Warenkorb',
  'Cart': 'Warenkorb',
  'Subtotal': 'Zwischensumme',
  'Order Confirmed': 'Bestellung bestätigt',

  // ── Fan+ ───────────────────────────────────────────────────
  'Unlock VIP Fan Experiences': 'VIP-Fan-Erlebnisse freischalten',
  'Exclusive raffles, boosts, and rewards': 'Exklusive Verlosungen, Boosts und Prämien',
  'Paid membership · separate from your points tier':
      'Bezahlte Mitgliedschaft · unabhängig von deiner Punktestufe',
  'Extra Spin': 'Extra-Dreh',
  'Extra Scratch Card': 'Extra-Rubbellos',
  'Upgrade to Fan+ Now': 'Jetzt auf Fan+ upgraden',
  '…and much more!': '…und vieles mehr!',
  'Manage Subscription': 'Abo verwalten',
  'Signed Match Ball': 'Signierter Spielball',
  '1 Left': 'Noch 1',
  'Limited': 'Limitiert',

  // ── Achievements ───────────────────────────────────────────
  'Achievements': 'Erfolge',
  'Unlocked': 'Freigeschaltet',
  'Total': 'Gesamt',
  'Progress': 'Fortschritt',
  'Achievement': 'Erfolg',

  // ── Auth ───────────────────────────────────────────────────
  'Welcome back': 'Willkommen zurück',
  'Log in to your S04 fan account': 'Melde dich in deinem S04-Fankonto an',
  'Email': 'E-Mail',
  'Password': 'Passwort',
  'Forgot password?': 'Passwort vergessen?',
  'Continue with Face ID': 'Mit Face ID fortfahren',
  "Don't have an account? ": 'Noch kein Konto? ',
  'Remember your password? ': 'Passwort wieder eingefallen? ',
  'Reset your password': 'Passwort zurücksetzen',
  "Enter the email associated with your account and we'll send a reset link":
      'Gib die E-Mail deines Kontos ein und wir senden dir einen Link zum Zurücksetzen',
  'Send Reset Link': 'Link senden',
  'Reset link sent — check your inbox.': 'Link gesendet — prüfe dein Postfach.',

  // ── Search ─────────────────────────────────────────────────
  'Search the app...': 'App durchsuchen...',
  'Recent': 'Zuletzt',
  'Trending': 'Im Trend',

  // ── Profile / Settings ─────────────────────────────────────
  'Account': 'Konto',
  'Settings': 'Einstellungen',
  'Privacy': 'Datenschutz',
  'App': 'App',
  'Fan+ Membership': 'Fan+ Mitgliedschaft',
  'Membership Plan': 'Mitgliedschaftstarif',
  'Bank Account': 'Bankkonto',
  'Connected': 'Verbunden',
  'Payment Methods': 'Zahlungsmethoden',
  'Manage Card': 'Karte verwalten',
  'Notification Preferences': 'Benachrichtigungen',
  'Update Password': 'Passwort ändern',
  'Biometric Login': 'Biometrische Anmeldung',
  'Device Management': 'Geräteverwaltung',
  'Language': 'Sprache',
  'Data Sharing Preferences': 'Datenfreigabe',
  'Marketing Consent': 'Marketing-Einwilligung',
  'Privacy Policy': 'Datenschutzerklärung',
  'About Us': 'Über uns',
  'Terms & Conditions': 'AGB',
  'Notifications': 'Benachrichtigungen',
  'Push notifications': 'Push-Benachrichtigungen',
  'Data Sharing': 'Datenfreigabe',
  'Devices': 'Geräte',
  'Enable Face ID / Fingerprint': 'Face ID / Fingerabdruck aktivieren',
  'Log in securely without typing your password every time.':
      'Melde dich sicher an, ohne jedes Mal dein Passwort einzugeben.',
  'Manage Cards': 'Karten verwalten',
  'Default': 'Standard',
  'Change': 'Ändern',
  'Save Changes': 'Änderungen speichern',
  'Last updated: 22 July 2026': 'Zuletzt aktualisiert: 22. Juli 2026',

  // ── Wallet / cards ─────────────────────────────────────────
  'Fan Points': 'Fan-Punkte',
  '12 Raffle Tickets': '12 Lose',
  'S04 FAN VIRTUAL CARD': 'S04 FAN VIRTUELLE KARTE',
  'Recent Transactions': 'Letzte Transaktionen',
  'Connect Bank Account': 'Bankkonto verbinden',
  'Credit Card': 'Kreditkarte',
  'Add New Card': 'Neue Karte hinzufügen',
  '+ Add New Card': '+ Neue Karte hinzufügen',
  'Card Number': 'Kartennummer',
  'Cardholder Name': 'Karteninhaber',
  'Expiry': 'Gültig bis',
  'MM/YY': 'MM/JJ',
  'Save Card': 'Karte speichern',
  'Payment Method': 'Zahlungsmethode',
  'Payment method': 'Zahlungsmethode',
  'Schalker · 12,450 pts': 'Schalker · 12.450 Pkt.',

  // ── Home extras ────────────────────────────────────────────
  'Matchday': 'Spieltag',
  'Königsblau secures vital home win against Bayern':
      'Königsblau sichert sich wichtigen Heimsieg gegen Bayern',
  'Exclusive post-match meet & greet with the team':
      'Exklusives Meet & Greet mit dem Team nach dem Spiel',
  'Ends in 4:12:30': 'Endet in 4:12:30',

  // ── Fanshop / checkout ─────────────────────────────────────
  'Search products…': 'Produkte suchen…',
  'Featured Rewards': 'Empfohlene Prämien',
  'Select Size': 'Größe wählen',
  'Continue Shopping': 'Weiter einkaufen',
  'Order Summary': 'Bestellübersicht',
  'Shipping Address': 'Lieferadresse',
  'Order Confirmed!': 'Bestellung bestätigt!',
  'Pay with Fan Points — use points at checkout!':
      'Mit Fan-Punkten zahlen — an der Kasse einlösen!',
  'Kurt-Schumacher-Str. 2, 45897 Gelsenkirchen': 'Kurt-Schumacher-Str. 2, 45897 Gelsenkirchen',

  // ── Experiences / deals detail ─────────────────────────────
  'About this experience': 'Über dieses Erlebnis',
  'Booking Confirmed!': 'Buchung bestätigt!',
  'An exclusive FC Schalke 04 experience for Fan+ members. Limited spots available — redeem your Fan Points to secure your place and create memories money can’t buy.':
      'Ein exklusives FC-Schalke-04-Erlebnis für Fan+ Mitglieder. Begrenzte Plätze — löse deine Fan-Punkte ein, sichere dir deinen Platz und schaffe unbezahlbare Erinnerungen.',
  'How to earn': 'So verdienst du',
  'Description': 'Beschreibung',
  'Earn 2× Fan Points on this deal': 'Verdiene 2× Fan-Punkte mit diesem Angebot',
  'Activate this partner deal and pay with your connected S04 card or app to automatically apply the offer and earn bonus Fan Points. Valid at all participating locations until the end of the season.':
      'Aktiviere dieses Partner-Angebot und zahle mit deiner verknüpften S04-Karte oder App, um den Rabatt automatisch anzuwenden und Bonus-Fan-Punkte zu sammeln. Gültig an allen teilnehmenden Standorten bis Saisonende.',
  'Sat, Apr 5 · 15:30 · Only on gameday': 'Sa, 5. Apr · 15:30 · Nur am Spieltag',

  // ── Tickets ────────────────────────────────────────────────
  '2 upcoming · tap to show QR': '2 anstehend · tippen für QR',
  'No tickets yet.': 'Noch keine Tickets.',

  // ── News ───────────────────────────────────────────────────
  'No articles in this category yet.': 'Noch keine Artikel in dieser Kategorie.',

  // ── Gamification ───────────────────────────────────────────
  'Spin Now': 'Jetzt drehen',
  'SPIN': 'DREHEN',
  'Spin the wheel to win rewards!': 'Dreh am Rad und gewinne!',
  '1 Spin Left': 'Noch 1 Dreh',
  'Daily Card Scratch': 'Tägliches Rubbellos',
  'Scratch the card to win rewards!': 'Rubbel die Karte frei und gewinne!',
  'Scratch at least 40% of the card to reveal your reward':
      'Rubbel mind. 40 % frei, um deine Prämie zu sehen',
  '1 Scratch Left': 'Noch 1 Rubbellos',
  'Reward: +250 Fan Points': 'Prämie: +250 Fan-Punkte',
  'Claim +50 Points': '+50 Punkte einlösen',
  '+50 Points': '+50 Punkte',
  'Submit Prediction': 'Tipp abgeben',
  'Earn up to +75 pts for correct prediction!': 'Bis zu +75 Pkt. für richtige Tipps!',

  // ── Subscription / membership ──────────────────────────────
  'Fan+ Plans': 'Fan+ Tarife',
  '/ month': '/ Monat',
  'BEST VALUE': 'BESTER WERT',
  'POPULAR': 'BELIEBT',
  'Next billing: 15 May 2026': 'Nächste Abrechnung: 15. Mai 2026',

  // ── Auth extras ────────────────────────────────────────────
  'Create Account': 'Konto erstellen',
  'Create account': 'Konto erstellen',
  'Join the S04 fan community': 'Werde Teil der S04-Fangemeinde',
  'Full name': 'Vollständiger Name',
  'Phone': 'Telefon',
  'I agree to the Terms of Service and Privacy Policy':
      'Ich akzeptiere die AGB und die Datenschutzerklärung',
  'Skip': 'Überspringen',
  'Favourite section': 'Lieblingsblock',
  'Physical + Virtual': 'Physisch + Virtuell',
  'Superfan': 'Superfan',

  // ── Category / tab chips ───────────────────────────────────
  'Stadium': 'Stadion',
  'Players': 'Spieler',
  'Family': 'Familie',
  'Team': 'Team',
  'Insides': 'Einblicke',
  'Internationals': 'International',
  'Next': 'Nächste',
  'Health': 'Gesundheit',
};
