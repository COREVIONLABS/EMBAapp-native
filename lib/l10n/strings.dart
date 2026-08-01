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
  'Daily Spin': 'Glücksrad',
  'Content': 'Inhalte',
  'Renews: 28 May 2026': 'Verlängert: 28. Mai 2026',
  'Dark Mode': 'Dunkelmodus',
  'Get Started': 'Los geht’s',
  '@maxmuster · Member #0042': '@maxmuster · Mitglied #0042',
  'Your plan': 'Dein Tarif',
  'Invite friends': 'Freunde einladen',
  'Earn +200 pts each': '+200 Pkt. pro Freund',
  'Share invite link': 'Einladungslink teilen',
  'Give 200, get 200': 'Gib 200, hol 200',
  'You both earn 200 Fan Points when a friend joins with your code.':
      'Ihr bekommt beide 200 Fan-Punkte, wenn ein Freund mit deinem Code beitritt.',
  'Your invite code': 'Dein Einladungscode',
  'Share your code': 'Code teilen',
  'Send your invite link to friends': 'Sende deinen Einladungslink an Freunde',
  'They join S04': 'Freund tritt S04 bei',
  'Your friend signs up with your code': 'Dein Freund registriert sich mit deinem Code',
  'You both earn': 'Ihr bekommt beide',
  '+200 Fan Points each, instantly': '+200 Fan-Punkte pro Person, sofort',
  'Earn Points Everywhere': 'Überall Punkte sammeln',
  'Shop at sponsors, spin daily, complete missions, and earn 3x Points on matchday with Stadium Boost.':
      'Kaufe bei Sponsoren, dreh täglich am Rad, erfülle Missionen und sammle am Spieltag 3× Punkte mit dem Stadion-Boost.',
  'Redeem for Merch & Rewards': 'Für Merch & Prämien einlösen',
  'Use Fan Points for exclusive jerseys, scarves, signed memorabilia, and partner discounts.':
      'Nutze Fan-Punkte für exklusive Trikots, Schals, signierte Erinnerungsstücke und Partner-Rabatte.',
  'Win Exclusive Rewards': 'Exklusive Prämien gewinnen',
  "Enter VIP raffles, scratch cards, and daily spins. Meet the players, win signed gear, and unlock experiences money can't buy.":
      'Nimm an VIP-Verlosungen, Rubbellosen und täglichen Drehs teil. Triff die Spieler, gewinne signierte Fanartikel und schalte unbezahlbare Erlebnisse frei.',
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

  // ── Settings toggles ───────────────────────────────────────
  'Matchday reminders': 'Spieltags-Erinnerungen',
  'Kickoff & lineup alerts': 'Anpfiff- & Aufstellungs-Hinweise',
  'Points & rewards': 'Punkte & Prämien',
  'When you earn or can redeem': 'Wenn du sammelst oder einlösen kannst',
  'Deadlines and results': 'Fristen und Ergebnisse',
  'Daily games': 'Tägliche Spiele',
  'Spin & scratch reminders': 'Dreh- & Rubbel-Erinnerungen',
  'Newsletter': 'Newsletter',
  'Exclusive offers': 'Exklusive Angebote',
  'Personalised offers': 'Personalisierte Angebote',
  'Use my activity to tailor rewards': 'Meine Aktivität für passende Prämien nutzen',
  'Share with club partners': 'Mit Vereinspartnern teilen',
  'Sponsors & official partners': 'Sponsoren & offizielle Partner',
  'Analytics': 'Analyse',
  'Help improve the app': 'Hilf, die App zu verbessern',
  'Third-party marketing': 'Marketing von Dritten',
  'Use biometric login': 'Biometrische Anmeldung verwenden',
  'You can change these choices at any time. See our Privacy Policy for details on how your data is processed.':
      'Du kannst diese Einstellungen jederzeit ändern. Details zur Verarbeitung deiner Daten findest du in unserer Datenschutzerklärung.',

  // ── Wallet / card detail ───────────────────────────────────
  'Virtual': 'Virtuell',
  'Upgrade to Physical Card': 'Auf physische Karte upgraden',
  'Visa ending in 4242': 'Visa endet auf 4242',
  'We never store your bank login. Connection is read-only.':
      'Wir speichern deine Bank-Zugangsdaten nie. Die Verbindung ist nur lesend.',
  '(Sponsors Only)': '(Nur Sponsoren)',

  // ── Redeem / rewards ───────────────────────────────────────
  'Ways to redeem': 'Einlöse-Möglichkeiten',
  '2,450 pts available (≈ €24.50)': '2.450 Pkt. verfügbar (≈ 24,50 €)',
  'Your loyalty. Your rewards.': 'Deine Treue. Deine Prämien.',
  'You won 100 Points!': 'Du hast 100 Punkte gewonnen!',

  // ── Subscription / plans ───────────────────────────────────
  'Upgrade Plan': 'Tarif upgraden',
  'What\'s included': 'Enthalten',
  'Your benefits': 'Deine Vorteile',
  '€9.99 / month': '9,99 € / Monat',
  '€9.99/mo': '9,99 €/Mon.',
  'You\'re a Superfan!': 'Du bist jetzt Superfan!',
  'Your plan is active. Enjoy 3× points and exclusive perks.':
      'Dein Tarif ist aktiv. Genieße 3× Punkte und exklusive Vorteile.',

  // ── Cart / checkout / orders ───────────────────────────────
  'Your cart is empty': 'Dein Warenkorb ist leer',
  'Your order #S04-24815 is on its way. You can track it under My Orders.':
      'Deine Bestellung #S04-24815 ist unterwegs. Du kannst sie unter „Meine Bestellungen" verfolgen.',

  // ── Auth misc ──────────────────────────────────────────────
  'or': 'oder',

  // ── Data rows: dates ───────────────────────────────────────
  'Today': 'Heute',
  'Yesterday': 'Gestern',
  'Saturday': 'Samstag',
  'Thursday': 'Donnerstag',

  // ── Data rows: transactions & missions ─────────────────────
  'Adidas Store Purchase': 'Adidas-Shop-Einkauf',
  'Daily Spin Win': 'Glücksrad-Gewinn',
  'Mission Complete: Spend €200': 'Mission erfüllt: 200 € ausgeben',
  'Match Prediction (Correct)': 'Spieltipp (richtig)',
  'Redeemed: Home Jersey': 'Eingelöst: Heimtrikot',
  'Attend 3 home games': '3 Heimspiele besuchen',
  'Share on social': 'In sozialen Medien teilen',
  'Refer 5 friends': '5 Freunde werben',
  '2 / 3 attended': '2 / 3 besucht',
  '2 / 5 referred': '2 / 5 geworben',

  // ── Ticket card CTA ────────────────────────────────────────
  'Earn 100 pts': '100 Pkt. sammeln',

  // ── Home non-matchday state ────────────────────────────────
  'Non-Matchday': 'Kein Spieltag',
  'Weekly Challenge': 'Wochen-Challenge',
  'Spend €50 this week': 'Gib diese Woche 50 € aus',
  'Community Goal': 'Gemeinschaftsziel',
  '€32,000 left to unlock Community Bonus': 'Noch 32.000 € bis zum Community-Bonus',
  '36% collective': '36 % gemeinsam',

  // ── Wallet tiers ───────────────────────────────────────────
  'Free': 'Basis',
  'Supporter': 'Supporter',
  'No active card yet': 'Noch keine aktive Karte',
  'Activate S04 Card': 'S04-Karte aktivieren',

  // ── Fan+ pitch alignment (tiers, value-back, card) ─────────
  'Fan+ Premium': 'Fan+ Premium',
  'Current Plan': 'Aktueller Tarif',
  'Upgrade to': 'Upgrade auf',
  'Upgrade to Fan+ Premium': 'Auf Fan+ Premium upgraden',
  '€9.00 / month': '9,00 € / Monat',
  '€9.00/mo': '9,00 €/Mon.',
  "You're a Fan+ member!": 'Du bist jetzt Fan+ Mitglied!',
  'Every membership pays for itself — you get at least 100% of your fee back in Fan Points.':
      'Jede Mitgliedschaft zahlt sich aus — du bekommst mindestens 100 % deines Beitrags als Fan-Punkte zurück.',
  'Your membership pays for itself — get 100% of your fee back in Fan Points.':
      'Deine Mitgliedschaft zahlt sich aus — 100 % deines Beitrags zurück als Fan-Punkte.',
  'You have earned back €11.20 in points this month — your membership pays for itself.':
      'Du hast diesen Monat 11,20 € in Punkten zurückbekommen — deine Mitgliedschaft zahlt sich aus.',
  'Branded VISA card — with Fan+ Premium': 'Gebrandete VISA-Karte — mit Fan+ Premium',
  'Unlock the branded VISA card with Fan+ Premium': 'Gebrandete VISA-Karte mit Fan+ Premium freischalten',
  'Powered by Fan+': 'Powered by Fan+',

  // ── Exclusive Content ──────────────────────────────────────
  'Exclusive Content': 'Exklusive Inhalte',
  'Fan+ Exclusive': 'Fan+ Exklusiv',
  'Latest clips': 'Neueste Clips',
  'Now playing': 'Läuft jetzt',
  'See Fan+ Plans': 'Fan+ Tarife ansehen',
  'This clip is Fan+ exclusive': 'Dieser Clip ist Fan+ exklusiv',
  'Unlock all locker-room clips, interviews and behind-the-scenes videos with Fan+.':
      'Schalte alle Kabinen-Clips, Interviews und Behind-the-Scenes-Videos mit Fan+ frei.',
  'Inside the dressing room — Bayern win': 'In der Kabine — Sieg gegen Bayern',
  'Behind the scenes · Fan+': 'Behind the Scenes · Fan+',
  'Interview': 'Interview',
  'Training · Fan+': 'Training · Fan+',
  'Feature': 'Feature',

  // ── Streaks / sponsor challenges / raffles ─────────────────
  '5-day streak': '5-Tage-Serie',
  '· keep it going for +10 pts': '· dranbleiben für +10 Pkt.',
  'Sponsored by': 'Präsentiert von',
  'Shop at Veltins on matchday': 'Am Spieltag bei Veltins einkaufen',
  'Voucher': 'Gutschein',
  'Win a €10 Veltins voucher': 'Gewinne einen 10-€-Veltins-Gutschein',
  'Raffle': 'Verlosung',
  'Enter': 'Teilnehmen',

  // ── New experiences ────────────────────────────────────────
  'Train with the Pros': 'Mit den Profis trainieren',
  'Fans vs Pros Match': 'Fans gegen Profis',
  'On the Team Photo': 'Aufs Mannschaftsfoto',
  'Win 2 VIP Tickets — vs Bayern': 'Gewinne 2 VIP-Tickets — gegen Bayern',
  'Win a Signed Home Shirt': 'Gewinne ein signiertes Heimtrikot',

  // ── Plan perks / benefits ──────────────────────────────────
  'Daily games & challenges': 'Tägliche Spiele & Challenges',
  'Fan Points & partner offers': 'Fan-Punkte & Partner-Angebote',
  'Club news & matchday info': 'Vereins-News & Spieltags-Infos',
  '2× Fan Points boost': '2× Fan-Punkte-Boost',
  'Exclusive content & clips': 'Exklusive Inhalte & Clips',
  'Bigger raffles & better rewards': 'Größere Verlosungen & bessere Prämien',
  '100% of your fee back in points': '100 % deines Beitrags zurück als Punkte',
  'Everything in Fan+': 'Alles aus Fan+',
  '3× Fan Points (max boost)': '3× Fan-Punkte (max. Boost)',
  "Money-can't-buy experiences": 'Unbezahlbare Erlebnisse',
  'VIP draws & premium raffles': 'VIP-Ziehungen & Premium-Verlosungen',
  'Branded VISA fan card & wallet': 'Gebrandete VISA-Fankarte & Wallet',
  // Fan+ non-subscriber VIP list
  'Exclusive content & locker-room clips': 'Exklusive Inhalte & Kabinen-Clips',
  'Chances to Win a Signed Jersey': 'Chance auf ein signiertes Trikot',
  'Points Multiplier & bigger raffles': 'Punkte-Multiplikator & größere Verlosungen',

  // ── Exclusive content clip titles ──────────────────────────
  'Matchday walkout — pitchside cam': 'Einlauf am Spieltag — Pitchside-Cam',
  'Training ground: set-piece session': 'Trainingsplatz: Standard-Training',
  'Academy talent — first team debut': 'Nachwuchstalent — Profidebüt',
  "Coach mic'd up vs Dortmund": 'Trainer verkabelt gegen Dortmund',

  // ── Wallet season-1 (card deferred to season 2) ────────────
  'Raffle Tickets': 'Lose',
  'Points Activity': 'Punkte-Aktivität',
  'S04 FAN CARD': 'S04 FAN-KARTE',
  'YOUR NAME': 'DEIN NAME',
  'Coming Season 2': 'Kommt in Saison 2',
  'Earn points on every spend with the branded S04 fan card — launching next season.':
      'Sammle Punkte bei jedem Einkauf mit der gebrandeten S04-Fankarte — Start nächste Saison.',
  'Join the waitlist': 'Auf die Warteliste',
  'Branded VISA fan card (from Season 2)': 'Gebrandete VISA-Fankarte (ab Saison 2)',
  'Home Jersey 25/26': 'Heimtrikot 25/26',
  'Season 2': 'Saison 2',
  'Veltins matchday combo': 'Veltins Spieltags-Kombi',
  'Museum Tour ticket': 'Museumstour-Ticket',
  'Daily Spin reward': 'Glücksrad-Gewinn',
  'Today · 14:30': 'Heute · 14:30',
  'Mon 12 Feb': 'Mo 12. Feb',
  'Sun 11 Feb': 'So 11. Feb',

  // ── Navigation restructure & Home conversion CTA ───────────
  'S04 Fan Card': 'S04 Fankarte',
  'Points on every spend — join the waitlist': 'Punkte bei jedem Einkauf — jetzt vormerken',
  'Become a Fan+ member': 'Werde Fan+ Mitglied',
  'Get 100% of your fee back in points': '100 % deines Beitrags zurück als Punkte',
  'Upgrade': 'Upgrade',
  'Meet the Players & VIP experiences': 'Spieler treffen & VIP-Erlebnisse',

  // ── P0: Final tier model (Free Fan / Fan Member / Super Fan / Ultra) ──
  'Membership Plans': 'Mitgliedschaften',
  'Every membership pays for itself — Fan Member gets €6+ back a month, Super Fan €14+.':
      'Jede Mitgliedschaft zahlt sich aus — Fan Member bekommt 6 €+ pro Monat zurück, Super Fan 14 €+.',
  'Your membership pays for itself — Fan Member gets €6+ back a month, Super Fan €14+.':
      'Deine Mitgliedschaft zahlt sich aus — Fan Member bekommt 6 €+ pro Monat zurück, Super Fan 14 €+.',
  'Free Fan': 'Free Fan',
  'Fan Member': 'Fan Member',
  'Super Fan': 'Super Fan',
  'Ultra': 'Ultra',
  "I'm in": 'Ich bin dabei',
  'I save': 'Ich spare',
  "I'm first in line": 'Ich bin zuerst dran',
  'Most popular': 'Am beliebtesten',
  'Priority': 'Priorität',
  'Full app access & club news': 'Voller App-Zugang & Vereins-News',
  'Daily games & 1 free spin': 'Tägliche Spiele & 1 Gratis-Dreh',
  'Earn Fan Points · 100 pts = €1': 'Fan-Punkte sammeln · 100 Pkt. = 1 €',
  'Public raffles & supporter streak': 'Öffentliche Verlosungen & Supporter-Serie',
  'Guaranteed €6+ back every month': 'Garantiert 6 €+ zurück pro Monat',
  '24h ticket presale + discounts': '24h Ticket-Vorverkauf + Rabatte',
  'Sponsor vouchers & offers': 'Sponsor-Gutscheine & Angebote',
  '+1 VIP raffle ticket / month': '+1 VIP-Los / Monat',
  'Streak protection · 2 spins · +50% points': 'Serien-Schutz · 2 Drehs · +50 % Punkte',
  'Priority access to top matches (48–72h)': 'Vorrang-Zugang zu Top-Spielen (48–72 Std.)',
  'Best seats first + matchday upgrades': 'Beste Plätze zuerst + Spieltags-Upgrades',
  'Monthly exclusive FOMO drop': 'Monatlicher exklusiver FOMO-Drop',
  'Superfan Elite badge + name on the big screen': 'Superfan-Elite-Abzeichen + Name auf der Videowand',
  'Guaranteed €14+ back · ad-free · +3 VIP raffles': 'Garantiert 14 €+ zurück · werbefrei · +3 VIP-Verlosungen',
  'Points are never cashed out — they unlock discounts, access and sponsor rewards.':
      'Punkte werden nie ausgezahlt — sie schalten Rabatte, Zugang und Sponsor-Prämien frei.',
  'The maximum — exclusive drops, top priority, concierge':
      'Das Maximum — exklusive Drops, höchste Priorität, Concierge',

  // ── P0: Fan+ (Membership) tab repositioning ──────────────────
  'Membership': 'Mitgliedschaft',
  'Priority access to what fans want most': 'Vorrang bei dem, was Fans am meisten wollen',
  'Best seats first, exclusive drops, and rewards that pay you back':
      'Beste Plätze zuerst, exklusive Drops und Prämien, die sich auszahlen',
  'Membership · unlocks priority, access & perks': 'Mitgliedschaft · schaltet Vorrang, Zugang & Vorteile frei',
  'Priority Access': 'Vorrang-Zugang',
  'Best Seats': 'Beste Plätze',
  '+3 VIP Draws': '+3 VIP-Ziehungen',
  "You're a Super Fan!": 'Du bist jetzt Super Fan!',
  'Become a member': 'Werde Mitglied',
  'See membership plans': 'Mitgliedschaften ansehen',
  'Your plan is active. Enjoy priority access and exclusive perks.':
      'Dein Tarif ist aktiv. Genieße Vorrang-Zugang und exklusive Vorteile.',

  // ── P1: Leaderboard (Top Supporters) ─────────────────────────
  'Top Supporters': 'Top-Supporter',
  'This Season': 'Diese Saison',
  'Hall of Fame': 'Hall of Fame',
  'Ranked by points earned this season — never by points bought. Resets 30 June.':
      'Sortiert nach diese Saison verdienten Punkten — nie nach gekauften Punkten. Reset am 30. Juni.',
  'You': 'Du',
  "You're #5 this season — earned points only": 'Du bist #5 diese Saison — nur verdiente Punkte',
  "See where you rank this season": 'Sieh, wo du diese Saison stehst',
  'Season 24/25': 'Saison 24/25',
  'Season 23/24': 'Saison 23/24',
  'Season 22/23': 'Saison 22/23',
  '512,900 pts earned': '512.900 Pkt. verdient',
  '498,140 pts earned': '498.140 Pkt. verdient',
  '451,720 pts earned': '451.720 Pkt. verdient',

  // ── P1: Fan Profile (visibility layer) ───────────────────────
  'Fan Profile': 'Fan-Profil',
  'Share profile': 'Profil teilen',
  'Verified Supporter · Member #0042': 'Verifizierter Supporter · Mitglied #0042',
  'Your Impact': 'Dein Impact',
  'Games attended': 'Besuchte Spiele',
  'Day streak': 'Tage-Serie',
  'Points this season': 'Punkte diese Saison',
  'Prediction accuracy': 'Tipp-Trefferquote',
  'Friends referred': 'Geworbene Freunde',
  'Supporter rank': 'Supporter-Rang',
  'Badges': 'Abzeichen',
  'Verified': 'Verifiziert',
  'On Fire': 'In Form',
  'Season Ticket': 'Dauerkarte',
  'Founding Fan': 'Gründungs-Fan',

  // ── P1: FOMO Drop (monthly Super Fan drop) ───────────────────
  "This Month's Drop": 'Der Drop des Monats',
  'Claim your drop': 'Drop sichern',
  'Unlock with Super Fan': 'Mit Super Fan freischalten',
  'Super Fan only': 'Nur Super Fan',
  'Only 50 made': 'Nur 50 Stück',
  'Signed Retro Shirt — April Drop': 'Signiertes Retro-Trikot — April-Drop',
  'A limited signed 1997 UEFA Cup retro shirt — dropped once, never restocked.':
      'Ein limitiertes signiertes 1997er UEFA-Cup-Retro-Trikot — einmal gedroppt, nie nachproduziert.',
  'Drop closes in': 'Drop endet in',
  'Days': 'Tage',
  'Hrs': 'Std.',
  'Min': 'Min.',
  'Sec': 'Sek.',
  'This drop is reserved for Super Fan members. One exclusive drop lands every month.':
      'Dieser Drop ist Super-Fan-Mitgliedern vorbehalten. Jeden Monat kommt ein exklusiver Drop.',
  "You're eligible. Claim before the timer runs out — first come, first served.":
      'Du bist berechtigt. Sichere ihn, bevor die Zeit abläuft — wer zuerst kommt, mahlt zuerst.',
  'Past drops': 'Vergangene Drops',
  'January': 'Januar',
  'February': 'Februar',
  'March': 'März',
  'Away-day travel mug': 'Auswärts-Thermobecher',
  'Matchday scarf — numbered': 'Spieltags-Schal — nummeriert',
  'Training-worn gloves': 'Trainings-getragene Handschuhe',
  'Claimed by 50 fans': 'Von 50 Fans gesichert',
  'Sold out in 3h': 'In 3 Std. ausverkauft',
  'Sold out in 1h': 'In 1 Std. ausverkauft',
  'Signed retro shirt · closes in 2 days': 'Signiertes Retro-Trikot · endet in 2 Tagen',

  // ── P1: Redeem hub (category grid) ───────────────────────────
  'Fanshop': 'Fanshop',
  'Jerseys, scarves & more': 'Trikots, Schals & mehr',
  'Matchday & presale access': 'Spieltag & Vorverkaufs-Zugang',
  'Sponsors': 'Sponsoren',
  'Partner vouchers & offers': 'Partner-Gutscheine & Angebote',
  'Stadium tours, VIP, players': 'Stadiontouren, VIP, Spieler',
  'Food & Drink': 'Essen & Trinken',
  'Matchday combos & kiosks': 'Spieltags-Kombis & Kioske',
  'Extra Raffle Tickets': 'Extra-Lose',
  'Boost your odds on draws': 'Erhöhe deine Gewinnchancen',
  'Donations': 'Spenden',
  'Give points to club causes': 'Punkte für Vereins-Projekte spenden',
  'Available to redeem': 'Verfügbar zum Einlösen',
  'Where to redeem': 'Wo einlösen',

  // ── P1: Streak protection ────────────────────────────────────
  'Protected': 'Geschützt',

  // ── P2: Buy points (top-up) ──────────────────────────────────
  'Buy Points': 'Punkte kaufen',
  'Pay': 'Zahlen',
  '100 points = €1. Bought points unlock rewards but never affect the Top Supporter leaderboard.':
      '100 Punkte = 1 €. Gekaufte Punkte schalten Prämien frei, zählen aber nie fürs Top-Supporter-Ranking.',
  'Choose a package': 'Paket wählen',
  "You'll receive": 'Du erhältst',
  'bonus': 'Bonus',
  'Top up points': 'Punkte aufladen',
  'Buy a package · 100 pts = €1': 'Paket kaufen · 100 Pkt. = 1 €',

  // ── P2: Voucher (QR + Entertainer PIN) ───────────────────────
  'Your Voucher': 'Dein Gutschein',
  'Mark as used': 'Als eingelöst markieren',
  'Powered by': 'Präsentiert von',
  'Free Veltins 0.5L': 'Gratis Veltins 0,5 L',
  'Scan at the kiosk': 'Am Kiosk scannen',
  'Valid until 30 Apr 2026': 'Gültig bis 30. Apr. 2026',
  'Staff redemption': 'Einlösung durch Personal',
  'Kiosk staff enter the Entertainer PIN to confirm': 'Kiosk-Personal bestätigt mit der Entertainer-PIN',
  'Screenshots won\'t work — the code is single-use and confirmed by staff PIN.':
      'Screenshots funktionieren nicht — der Code ist einmalig und wird per Personal-PIN bestätigt.',

  // ── P2: Matchday Live ────────────────────────────────────────
  'Matchday Live': 'Spieltag Live',
  'Live': 'Live',
  'LIVE · 67’': 'LIVE · 67’',
  'Schalke': 'Schalke',
  'Dortmund': 'Dortmund',
  'Who scores next?': 'Wer trifft als Nächstes?',
  'member': 'Mitglied',
  'Closes in 00:24': 'Endet in 00:24',
  'No goal': 'Kein Tor',
  'Vote for MVP': 'MVP wählen',
  'Voting opens after the final whistle': 'Abstimmung öffnet nach dem Schlusspfiff',

  // ── P2: Season Collection (stickers) ─────────────────────────
  'Season Collection': 'Saison-Sammlung',
  'Collection': 'Sammlung',
  'Open a sticker pack · 200 pts': 'Sticker-Pack öffnen · 200 Pkt.',
  'Team 25/26': 'Team 25/26',
  'Complete the set to win 2 VIP tickets': 'Sammle alle und gewinne 2 VIP-Tickets',
  'Your stickers': 'Deine Sticker',
  'Missing': 'Fehlt',

  // ── P2: Rewarded ads / welcome bonus / live earn ─────────────
  'Welcome bonus: +500 points to start — annual members get +1,500.':
      'Willkommensbonus: +500 Punkte zum Start — Jahresmitglieder erhalten +1.500.',
  'Watch a Short Ad': 'Kurzen Werbeclip ansehen',
  'A quick sponsor clip': 'Ein kurzer Sponsor-Clip',
  'Live Predictions': 'Live-Tipps',
  'Predict during matchday': 'Am Spieltag live tippen',

  // ── P2: Free trial ───────────────────────────────────────────
  'Try Super Fan free': 'Super Fan gratis testen',
  'Free for the next top match — priority seats included': 'Gratis fürs nächste Top-Spiel — Vorrang-Plätze inklusive',

  // ── Points hub (RevPoints-style rebuild) ─────────────────────
  'Search rewards & sponsors': 'Prämien & Sponsoren suchen',
  '1 pt per €1 spent': '1 Pkt. pro 1 € ausgegeben',
  'Earn': 'Verdienen',
  'More': 'Mehr',
  'Earn points when Schalke wins': 'Punkte sammeln, wenn Schalke gewinnt',
  'Redeem for discounts': 'Für Rabatte einlösen',
  'Top Sponsors': 'Top-Sponsoren',
  'Redeem your points': 'Punkte einlösen',
  'Challenges': 'Challenges',
  '2 active · earn up to +800 pts': '2 aktiv · bis zu +800 Pkt. verdienen',
  'Transactions': 'Transaktionen',
  'adidas Store Purchase': 'adidas-Store-Einkauf',
  'Today · 09:12': 'Heute · 09:12',
  'Season ranking — earned points only': 'Saison-Ranking — nur verdiente Punkte',
  'Super Fan exclusive': 'Super-Fan-exklusiv',
  'Collect player stickers': 'Spieler-Sticker sammeln',

  // ── Earn / Redeem screens aligned to hub style ───────────────
  'How you can redeem': 'So kannst du einlösen',
  'Featured rewards': 'Ausgewählte Belohnungen',
  'From': 'Ab',
  'Groceries': 'Lebensmittel',
  'Fashion': 'Mode',
  // Membership (Revolut-style tabbed upgrade screen)
  'Show all': 'Alle',
  'benefits': 'Vorteile anzeigen',
  'Become a': 'Werde',
  'Save every month': 'Spare jeden Monat',
  'First in line': 'Immer zuerst dran',
  'The maximum': 'Das Maximum',
  'partner perks included': 'Partner-Vorteile enthalten',
  'Everything in Super Fan': 'Alles aus Super Fan',
  'Top priority + personal concierge': 'Höchste Priorität + persönlicher Concierge',
  'Exclusive drops & money-can’t-buy days': 'Exklusive Drops & unbezahlbare Erlebnistage',
  'Member': 'Member',
  'Super': 'Super',
  'Free for every fan': 'Kostenlos für jeden Fan',
  'Your current plan': 'Dein aktueller Tarif',
  // All-benefits sub-page (Figma 2194:11585 / 12047)
  'Benefits': 'Vorteile',
  'Partner offers': 'Partner-Angebote',
  'In your membership': 'In deiner Mitgliedschaft',
  'Claim': 'Einlösen',
  '15% off': '15% Rabatt',
  '10% off': '10% Rabatt',
  'Bonus': 'Bonus',
  'Priority ticket access': 'Vorrang-Ticketzugang',
  '48–72h before public sale': '48–72 Std. vor dem freien Verkauf',
  'Best seats first': 'Beste Plätze zuerst',
  'Matchday seat upgrades': 'Spieltags-Platz-Upgrades',
  'Monthly FOMO drop': 'Monatlicher FOMO-Drop',
  '1 exclusive item / month': '1 exklusives Stück / Monat',
  'Free spins': 'Gratis-Drehs',
  '2 / day': '2 / Tag',
  'Ad-free experience': 'Werbefrei',
  'Guaranteed value back': 'Garantierter Gegenwert zurück',
  '€14+ / month': '14 €+ / Monat',
  'Streak protection': 'Serien-Schutz',
  // Home/Points design elements (featured cards, big promo)
  'Partner offer': 'Partner-Angebot',
  'Highlights': 'Highlights',
  'VIP': 'VIP',
  // Home: greeting + next-match card
  'Moin': 'Moin',
  'Bundesliga · Matchday 34': 'Bundesliga · 34. Spieltag',
  'Sat 15:30': 'Sa 15:30',
  'Kickoff in': 'Anpfiff in',
  'Keep it going for +10 pts': 'Dranbleiben für +10 Pkt.',
  '1 / 2 complete': '1 / 2 erledigt',
  'On matchday combos — pay with points': 'Auf Spieltags-Kombis — mit Punkten zahlen',
  'points back on every Fanshop order': 'Punkte zurück bei jeder Fanshop-Bestellung',
  '+100 points per home match': '+100 Punkte pro Heimspiel',
  '1 point per €1 spent': '1 Punkt pro 1 € Umsatz',
  '+15 points per sponsor clip': '+15 Punkte pro Sponsor-Clip',
  '+50 points on matchday': '+50 Punkte am Spieltag',
  '+25 points per share': '+25 Punkte pro Teilen',
  '+200 points per friend': '+200 Punkte pro Freund',
  '+10 points every day': '+10 Punkte jeden Tag',
  '+50 points, one-off': '+50 Punkte, einmalig',

  // ── Consistency + empty states + notifications ───────────────
  'Fan Level': 'Fan-Level',
  'Browse the Fanshop and add your favourite gear to get started.':
      'Stöbere im Fanshop und leg deine Lieblingsteile in den Warenkorb.',
  'Go to Fanshop': 'Zum Fanshop',
  "You're all caught up": 'Alles gelesen',
  'No new notifications. Matchday reminders and rewards will show up here.':
      'Keine neuen Mitteilungen. Spieltags-Erinnerungen und Prämien erscheinen hier.',
  'Clear all': 'Alle löschen',
  'Matchday reminder': 'Spieltags-Erinnerung',
  'Kickoff vs Bayern in 2 hours. Predict the score for +50 pts!':
      'Anpfiff gegen Bayern in 2 Stunden. Tippe das Ergebnis für +50 Pkt.!',
  'You earned points': 'Du hast Punkte erhalten',
  '+120 Fan Points for your stadium check-in.': '+120 Fan-Punkte für deinen Stadion-Check-in.',
  'Reward available': 'Prämie verfügbar',
  'You can now redeem the Home Jersey 24/25.': 'Du kannst jetzt das Heimtrikot 24/25 einlösen.',
  'Daily spin ready': 'Glücksrad bereit',
  'Your free spin is waiting — win up to 250 pts.': 'Dein Gratis-Dreh wartet — gewinne bis zu 250 Pkt.',
  'Superfan perk': 'Superfan-Vorteil',
  'Meet & greet raffle entries are open this week.': 'Meet-&-Greet-Verlosung läuft diese Woche.',
  'Now': 'Jetzt',
  '1h ago': 'vor 1 Std.',
  '3h ago': 'vor 3 Std.',
  '2d ago': 'vor 2 Tagen',
};
