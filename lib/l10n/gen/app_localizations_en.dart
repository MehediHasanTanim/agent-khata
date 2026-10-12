// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Agent Khata';

  @override
  String get homeTitle => 'Home';

  @override
  String get homePlaceholder => 'Your cash book will appear here.';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get languageBangla => 'বাংলা';

  @override
  String get languageEnglish => 'English';

  @override
  String get digitStyle => 'Digit style';

  @override
  String get digitsBangla => 'Bangla digits (০-৯)';

  @override
  String get digitsLatin => 'English digits (0-9)';

  @override
  String get digitGrouping => 'Bangladeshi digit grouping (1,00,000)';

  @override
  String get theme => 'Theme';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeHighContrast => 'High contrast';

  @override
  String get lockNow => 'Lock now';

  @override
  String get sampleAmount => 'Sample amount';

  @override
  String get pinSetupTitle => 'Set a PIN';

  @override
  String get pinSetupSubtitle =>
      'Choose a 4 to 6 digit PIN to protect your books.';

  @override
  String get pinConfirmTitle => 'Confirm your PIN';

  @override
  String get pinConfirmSubtitle => 'Enter the same PIN again.';

  @override
  String get pinMismatch => 'PINs did not match. Try again.';

  @override
  String get pinUnlockTitle => 'Enter PIN';

  @override
  String get pinUnlockSubtitle => 'Enter your PIN to open the cash book.';

  @override
  String pinWrong(String remaining) {
    return 'Wrong PIN. $remaining attempts before a delay.';
  }

  @override
  String pinLockedOut(String seconds) {
    return 'Too many attempts. Try again in $seconds seconds.';
  }

  @override
  String get pinDelete => 'Delete';

  @override
  String get keypadClear => 'Clear';

  @override
  String get diagnostics => 'Diagnostics';

  @override
  String get diagEncryption => 'Database encryption';

  @override
  String diagEncrypted(String version) {
    return 'Encrypted (SQLCipher $version)';
  }

  @override
  String get diagNotEncrypted => 'NOT encrypted';

  @override
  String get diagJournal => 'Journal mode';

  @override
  String get diagSchema => 'Schema version';

  @override
  String get diagWriteBench => 'Write speed';

  @override
  String get diagRunBench => 'Run write test';

  @override
  String diagBenchResult(String ms) {
    return '1,000 inserts in $ms ms';
  }

  @override
  String get diagColdStart => 'Cold start to first frame';

  @override
  String diagMs(String ms) {
    return '$ms ms';
  }

  @override
  String get autoLock => 'Auto-lock after';

  @override
  String get autoLockImmediately => 'Immediately';

  @override
  String autoLockSeconds(String seconds) {
    return '$seconds seconds';
  }
}
