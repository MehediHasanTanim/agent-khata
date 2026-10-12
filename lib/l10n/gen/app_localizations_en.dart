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

  @override
  String get next => 'Next';

  @override
  String get back => 'Back';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get saveAnyway => 'Save anyway';

  @override
  String get undo => 'Undo';

  @override
  String get comingSoon => 'Coming soon';

  @override
  String get navHome => 'Home';

  @override
  String get navHistory => 'History';

  @override
  String get navCloseDay => 'Close day';

  @override
  String get navReports => 'Reports';

  @override
  String get navSettings => 'Settings';

  @override
  String get onbWelcomeTitle => 'Welcome to Agent Khata';

  @override
  String get onbWelcomeBody => 'Set up your cash book in about two minutes.';

  @override
  String get onbQuickStart => 'Quick start with defaults';

  @override
  String get onbStepByStep => 'Set up step by step';

  @override
  String get onbProvidersTitle => 'Which wallets do you run?';

  @override
  String get onbProvidersSubtitle =>
      'Pick all that apply. You can add more later.';

  @override
  String get onbOperatorsTitle => 'Flexiload operators';

  @override
  String get onbBalancesTitle => 'Opening balances';

  @override
  String get onbBalancesSubtitle => 'Enter what you have right now.';

  @override
  String get onbCashLabel => 'Cash in drawer';

  @override
  String get onbRatesTitle => 'Commission rates';

  @override
  String get onbRatesNotice =>
      'These are sample rates only. Please check them with your provider.';

  @override
  String get onbShopTitle => 'Shop name';

  @override
  String get onbShopHint => 'e.g. Rahim Telecom';

  @override
  String get onbFinish => 'Finish setup';

  @override
  String get onbSaving => 'Setting up…';

  @override
  String get onbError => 'Could not finish setup. Please try again.';

  @override
  String get amountInvalid => 'Enter a valid amount';

  @override
  String get rateModePerThousand => 'Per ৳1,000';

  @override
  String get rateModePercent => 'Percent (%)';

  @override
  String get rateModeFixed => 'Fixed ৳';

  @override
  String get rateValue => 'Value';

  @override
  String get rateInvalid => 'Invalid rate';

  @override
  String get rateTooHigh => 'This looks too high';

  @override
  String get rateSaved => 'Rate saved';

  @override
  String get rateEffectiveNote => 'A new rate applies to new entries only.';

  @override
  String get commissionRates => 'Commission rates';

  @override
  String get txnCashOut => 'Cash out';

  @override
  String get txnCashIn => 'Cash in';

  @override
  String get txnFlexiload => 'Flexiload';

  @override
  String get txnFloatPurchase => 'Buy float';

  @override
  String get txnExpense => 'Expense';

  @override
  String get txnOther => 'Other';

  @override
  String get entryWallet => 'Wallet';

  @override
  String get entryPaidFrom => 'Paid from';

  @override
  String get entryCategory => 'Category';

  @override
  String get entryNewCategory => 'New category';

  @override
  String get entryCategoryName => 'Category name';

  @override
  String get entryMoreDetails => 'More details (optional)';

  @override
  String get entryCustomerNumber => 'Customer number';

  @override
  String get entryNote => 'Note';

  @override
  String get entryTrxId => 'TrxID';

  @override
  String entryCommission(String amount) {
    return 'Commission: $amount';
  }

  @override
  String entryRepeatLast(String amount) {
    return 'Last: $amount';
  }

  @override
  String get entryNoWallet => 'Add a wallet first';

  @override
  String get entrySaved => 'Saved';

  @override
  String get entryUndone => 'Entry undone';

  @override
  String get entrySaveFailed => 'Could not save. Please try again.';

  @override
  String warnNegative(String account) {
    return '$account will go below zero';
  }

  @override
  String get warnLargeTitle => 'Large amount';

  @override
  String warnLargeBody(String amount) {
    return '$amount is a large amount. Save it?';
  }

  @override
  String get warnDuplicateTitle => 'Possible duplicate';

  @override
  String get warnDuplicateBody =>
      'A similar entry was saved a moment ago. Save again?';

  @override
  String get homeCash => 'Cash';

  @override
  String get homeFlexiloadTotal => 'Flexiload';

  @override
  String get homeLow => 'Low';

  @override
  String get homeTapToReveal => 'Tap to show';

  @override
  String get homeToday => 'Today';

  @override
  String get homeTodayEntries => 'Entries';

  @override
  String get homeTodayCashIn => 'Cash in';

  @override
  String get homeTodayCashOut => 'Cash out';

  @override
  String get homeTodayCommission => 'Commission';

  @override
  String get homeRecent => 'Last 5 entries';

  @override
  String get homeNoEntries => 'No entries yet. Tap a button above to start.';

  @override
  String get maskBalances => 'Hide balances until tapped';

  @override
  String get largeAmountWarning => 'Warn for amounts of';

  @override
  String get catRent => 'Rent';

  @override
  String get catElectricity => 'Electricity';

  @override
  String get catTransport => 'Transport';

  @override
  String get catStaffPay => 'Staff pay';

  @override
  String get catTea => 'Tea & snacks';

  @override
  String get catOther => 'Other';
}
