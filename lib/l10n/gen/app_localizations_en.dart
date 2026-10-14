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

  @override
  String get histToday => 'Today';

  @override
  String get histYesterday => 'Yesterday';

  @override
  String get histWeek => 'Week';

  @override
  String get histMonth => 'Month';

  @override
  String get histAll => 'All';

  @override
  String get histSearchHint => 'Search amount, number, note, TrxID';

  @override
  String get histEmpty => 'Nothing found';

  @override
  String histCount(String count) {
    return '$count entries';
  }

  @override
  String histTotal(String amount) {
    return 'Total $amount';
  }

  @override
  String get histLoadMore => 'Load more';

  @override
  String get histAccountFilter => 'Account';

  @override
  String get histAllAccounts => 'All accounts';

  @override
  String get histClearFilters => 'Clear filters';

  @override
  String get labelVoided => 'Voided';

  @override
  String get labelLocked => 'Closed day';

  @override
  String get detailTitle => 'Entry details';

  @override
  String get detailAmount => 'Amount';

  @override
  String get detailCharge => 'Charge';

  @override
  String get detailCommission => 'Commission';

  @override
  String detailRule(String rule) {
    return 'Rate used: $rule';
  }

  @override
  String get detailWhen => 'Time';

  @override
  String get detailRecorded => 'Recorded at';

  @override
  String get detailBy => 'Entered by';

  @override
  String get detailAccounts => 'Accounts';

  @override
  String get detailAudit => 'Change history';

  @override
  String get detailReplaces => 'This entry replaces an earlier one';

  @override
  String get detailReplacedBy => 'Replaced by a newer entry';

  @override
  String get detailVoid => 'Void entry';

  @override
  String get detailEdit => 'Edit';

  @override
  String get detailVoidReason => 'Reason';

  @override
  String get detailVoidConfirm => 'Void';

  @override
  String detailVoidedBecause(String reason) {
    return 'Voided: $reason';
  }

  @override
  String get detailLockedHint =>
      'This day is closed, so the entry cannot be changed.';

  @override
  String get detailActionFailed => 'Could not complete this action.';

  @override
  String ledgerTitle(String account) {
    return '$account statement';
  }

  @override
  String get ledgerDate => 'Date';

  @override
  String get ledgerIn => 'In';

  @override
  String get ledgerOut => 'Out';

  @override
  String get ledgerBalance => 'Balance';

  @override
  String get ledgerAdjust => 'Adjust balance';

  @override
  String get ledgerEmpty => 'No entries in this period';

  @override
  String get adjTitle => 'Adjust balance';

  @override
  String get adjIncrease => 'Increase';

  @override
  String get adjDecrease => 'Decrease';

  @override
  String get adjReason => 'Reason (required)';

  @override
  String adjCurrent(String amount) {
    return 'Current balance: $amount';
  }

  @override
  String adjNew(String amount) {
    return 'New balance: $amount';
  }

  @override
  String get lowTitle => 'Low balance alerts';

  @override
  String get lowSubtitle =>
      'Warn me when an account falls to this amount. Leave empty for no alert.';

  @override
  String lowBanner(String accounts) {
    return 'Low balance: $accounts';
  }

  @override
  String get rememberCustomers => 'Remember customers';

  @override
  String get rememberCustomersHint =>
      'Suggest numbers and names you typed before. Stored only on this phone.';

  @override
  String get entryCustomerName => 'Customer name';

  @override
  String get entryOperator => 'Operator';

  @override
  String entryMargin(String amount) {
    return 'Margin: $amount';
  }

  @override
  String get entryPaidAmount => 'Amount paid (if different)';

  @override
  String get entryEditTitle => 'Edit entry';

  @override
  String get entryNoOperator => 'Add a flexiload operator first';

  @override
  String get cdTitle => 'Close the day';

  @override
  String get cdIntro =>
      'Count your cash and wallet balances. We will show where any gap may be.';

  @override
  String get cdExpected => 'Expected';

  @override
  String get cdActual => 'Actual';

  @override
  String get cdBlankHint => 'Leave empty if it matches';

  @override
  String get cdCashCounter => 'Count notes';

  @override
  String get cdCashCounterTitle => 'Cash counter';

  @override
  String get cdCounterTotal => 'Total';

  @override
  String get cdCounterUse => 'Use this total';

  @override
  String get cdCoins => 'Coins';

  @override
  String get cdReview => 'Review';

  @override
  String get cdMatches => 'Matches';

  @override
  String cdShort(String amount) {
    return 'Short by $amount';
  }

  @override
  String cdExcess(String amount) {
    return 'Excess of $amount';
  }

  @override
  String get cdReason => 'Reason';

  @override
  String get cdReasonNote => 'Note (optional)';

  @override
  String get cdReasonShortage => 'Shortage';

  @override
  String get cdReasonExcess => 'Excess';

  @override
  String get cdReasonProvider => 'Provider charge';

  @override
  String get cdReasonCounting => 'Counting error';

  @override
  String get cdReasonTolerance => 'Small difference';

  @override
  String get cdReasonOther => 'Other';

  @override
  String get cdFindGap => 'Where could it be?';

  @override
  String get cdAddMissing => 'Add a missing entry';

  @override
  String get cdClose => 'Close the day';

  @override
  String get cdClosedOk => 'Day closed';

  @override
  String cdTolerance(String amount) {
    return 'Differences up to $amount are written off automatically';
  }

  @override
  String get cdMissingReason => 'Choose a reason for each difference';

  @override
  String get cdAlreadyClosed => 'This day is already closed';

  @override
  String get cdFailed => 'Could not close the day. Please try again.';

  @override
  String get cdReopen => 'Reopen';

  @override
  String get cdReopenTitle => 'Reopen this day?';

  @override
  String get cdReopenBody =>
      'Adjustments from the close will be cancelled. Give a reason.';

  @override
  String get cdReopened => 'Day reopened';

  @override
  String get cdLaterClosed => 'Only the most recent closed day can be reopened';

  @override
  String get cdRecentDays => 'Recent days';

  @override
  String get cdNoDays => 'No days closed yet';

  @override
  String get cdStatusClosed => 'Closed';

  @override
  String get cdStatusReopened => 'Reopened';

  @override
  String get cdStatusOpen => 'Open';

  @override
  String get cdPickDay => 'Which day?';

  @override
  String get cdYesterdayOpen => 'Yesterday\'s accounts are not closed';

  @override
  String cdDifference(String amount) {
    return 'Difference $amount';
  }

  @override
  String sugSameSame(String amount) {
    return 'An entry of $amount is the same size as the gap. A similar entry may be missing.';
  }

  @override
  String sugSameOpposite(String amount) {
    return 'An entry of $amount equals the gap. It may be recorded twice or may not have happened.';
  }

  @override
  String sugFlipped(String amount) {
    return 'The $amount entry may be recorded in the wrong direction (in vs out).';
  }

  @override
  String sugEntryDouble(String amount) {
    return 'An entry of $amount is double the gap. The amount may be typed wrong.';
  }

  @override
  String sugGapDouble(String amount) {
    return 'The gap is double the entry of $amount. It may have been counted twice.';
  }

  @override
  String sugDuplicate(String amount) {
    return 'Two entries of $amount were saved within minutes. One may be a duplicate.';
  }

  @override
  String sugTranspose(String amount, String alt) {
    return '$amount may have been typed instead of $alt (digits swapped).';
  }

  @override
  String sugCross(String other) {
    return '$other is off by the opposite amount. The entry may be on the wrong wallet.';
  }

  @override
  String get sumTitle => 'Daily summary';

  @override
  String get sumEntries => 'Entries';

  @override
  String get sumCashInVolume => 'Cash in total';

  @override
  String get sumCashOutVolume => 'Cash out total';

  @override
  String get sumCommission => 'Commission';

  @override
  String get sumMargin => 'Flexiload margin';

  @override
  String get sumExpenses => 'Expenses';

  @override
  String get sumNet => 'Net profit';

  @override
  String get sumVariance => 'Difference';

  @override
  String get sumNotClosed => 'Not closed yet';

  @override
  String get sumOpening => 'Opening';

  @override
  String get sumIn => 'In';

  @override
  String get sumOut => 'Out';

  @override
  String get sumShareImage => 'Share image';

  @override
  String get sumSharePdf => 'Share PDF';

  @override
  String get sumShareFailed => 'Could not share the summary';

  @override
  String get notifCloseTitle => 'Time to close the day';

  @override
  String get notifCloseBody =>
      'Count your cash and wallets to close today\'s accounts.';

  @override
  String get notifLowTitle => 'Low balance';

  @override
  String notifLowBody(String account) {
    return '$account is running low.';
  }

  @override
  String get settingsReminder => 'Day-close reminder';

  @override
  String get settingsReminderTime => 'Reminder time';

  @override
  String get settingsTolerance => 'Ignore differences up to';

  @override
  String get entryDayClosed =>
      'This day is closed. Reopen it from Close day to add entries.';

  @override
  String get bkTitle => 'Backup and restore';

  @override
  String bkLast(String date) {
    return 'Last backup: $date';
  }

  @override
  String get bkNever => 'No backup yet';

  @override
  String get bkNow => 'Back up now';

  @override
  String get bkRestore => 'Restore from a backup file';

  @override
  String get bkPassphrase => 'Backup passphrase';

  @override
  String get bkPassphraseConfirm => 'Repeat passphrase';

  @override
  String get bkPassphraseWarn =>
      'If you forget this passphrase, the backup cannot be opened. It cannot be recovered.';

  @override
  String get bkMismatch => 'The passphrases do not match';

  @override
  String get bkTooShort => 'Use at least 6 characters';

  @override
  String get bkCreating => 'Creating backup…';

  @override
  String get bkShareText => 'Agent Khata backup';

  @override
  String get bkDone => 'Backup created';

  @override
  String get bkFailed => 'Could not create the backup';

  @override
  String bkRestoreInfo(String date) {
    return 'Backup made on $date';
  }

  @override
  String get bkRestoreConfirmTitle => 'Replace the data on this phone?';

  @override
  String get bkRestoreConfirmBody =>
      'All current data will be replaced by this backup. A copy of the current data is kept on the phone.';

  @override
  String get bkRestoreWorking => 'Restoring…';

  @override
  String get bkRestoreDone =>
      'Restore is ready. Close and reopen the app to finish.';

  @override
  String get bkCloseApp => 'Close app';

  @override
  String get bkWrongPassphrase => 'Wrong passphrase, or the file was changed';

  @override
  String get bkNewerSchema =>
      'This backup is from a newer version of the app. Please update the app first.';

  @override
  String get bkBadFile => 'This is not a valid backup file';

  @override
  String get bkCorrupt => 'This backup is damaged and cannot be restored';

  @override
  String get bkStaleBanner => 'Back up your data to keep it safe';

  @override
  String get onbRestore => 'Restore from a backup';

  @override
  String get bkWhyTitle => 'Keep your books safe';

  @override
  String get bkWhyBody =>
      'If this phone is lost or broken, a backup is the only way to get your records back. Save the file somewhere safe, like Google Drive.';

  @override
  String get bioToggle => 'Unlock with fingerprint';

  @override
  String get bioReason => 'Unlock Agent Khata';

  @override
  String get bioUse => 'Use fingerprint';

  @override
  String get bioUnavailable => 'Fingerprint is not set up on this phone';

  @override
  String get secureToggle => 'Hide app preview and block screenshots';

  @override
  String get textSize => 'Text size';

  @override
  String get textSizeNormal => 'Normal';

  @override
  String get textSizeLarge => 'Large';

  @override
  String get textSizeXL => 'Extra large';

  @override
  String get shopName => 'Shop name';

  @override
  String get shopNameNone => 'Not set';

  @override
  String get rolloverHour => 'Business day starts at';

  @override
  String get rolloverHint =>
      'Sales after midnight but before this time count for the previous day.';

  @override
  String get categoriesTitle => 'Expense categories';

  @override
  String get categoryAdd => 'Add category';

  @override
  String get categoryRename => 'Rename';

  @override
  String get categoryRemove => 'Remove';

  @override
  String get aboutTitle => 'About';

  @override
  String aboutVersion(String version) {
    return 'Version $version';
  }

  @override
  String get aboutDisclaimer =>
      'Agent Khata is a record-keeping tool. It does not move money and is not an app of bKash, Nagad, Rocket, Upay or any mobile operator, and is not affiliated with them.';

  @override
  String get aboutPrivacy =>
      'Your records stay on this phone. Your business records are never sent anywhere, unless you share a backup or report yourself.';

  @override
  String get analyticsToggle => 'Share anonymous usage counts';

  @override
  String get analyticsHint =>
      'Only counts like \"entries saved\". Never amounts, numbers or names. Included only if you share a diagnostics report.';

  @override
  String get diagIntegrity => 'Books check';

  @override
  String get diagRunCheck => 'Run check';

  @override
  String get diagVerified => 'Books verified: every entry balances';

  @override
  String get diagProblem =>
      'A problem was found in the books. Please back up and contact support.';

  @override
  String get diagShareReport => 'Share diagnostics report';

  @override
  String get diagDbSize => 'Database size';

  @override
  String get diagEntries => 'Entries';

  @override
  String get txnDueGiven => 'Credit given';

  @override
  String get txnDueSettled => 'Due received';

  @override
  String get txnDueTaken => 'Money held';

  @override
  String get txnDuePaid => 'Money returned';

  @override
  String get txnCommissionReceived => 'Commission received';

  @override
  String get duesTitle => 'Baki (dues)';

  @override
  String get duesTheyOwe => 'They owe me';

  @override
  String get duesIOwe => 'I owe them';

  @override
  String get duesTotalTheyOwe => 'Total to collect';

  @override
  String get duesTotalIOwe => 'Total I owe';

  @override
  String get duesEmpty => 'No open dues';

  @override
  String get duesSearch => 'Search name or number';

  @override
  String get duesAdd => 'Add baki';

  @override
  String get duesNewTitle => 'New baki';

  @override
  String get duesDirection => 'Type';

  @override
  String get duesName => 'Customer name';

  @override
  String get duesPhone => 'Phone number';

  @override
  String get duesNeedNameOrPhone => 'Enter a name or a phone number';

  @override
  String get duesGaveFrom => 'Given from';

  @override
  String get duesReceivedIn => 'Kept in';

  @override
  String get duesNote => 'What for (optional)';

  @override
  String get duesSaved => 'Baki saved';

  @override
  String duesRemaining(String amount) {
    return 'Remaining $amount';
  }

  @override
  String duesOriginal(String amount) {
    return 'Original $amount';
  }

  @override
  String get duesSettle => 'Record payment';

  @override
  String get duesSettleReturn => 'Return money';

  @override
  String get duesSettleAll => 'Full amount';

  @override
  String get duesSettleTo => 'Received in';

  @override
  String get duesSettleFrom => 'Paid from';

  @override
  String get duesOverSettle => 'More than the amount due';

  @override
  String get duesPayments => 'Payments';

  @override
  String get duesNoPayments => 'No payments yet';

  @override
  String get duesCall => 'Call';

  @override
  String get duesSms => 'SMS';

  @override
  String get duesSettled => 'Payment recorded';

  @override
  String get duesFailed => 'Could not save. Please try again.';

  @override
  String get repTitle => 'Reports';

  @override
  String get repWeek => 'This week';

  @override
  String get repMonth => 'This month';

  @override
  String get repPrev => 'Previous';

  @override
  String get repNext => 'Next';

  @override
  String get repNetPerDay => 'Net profit per day';

  @override
  String get repByType => 'By type';

  @override
  String get repNoData => 'No entries in this period';

  @override
  String get repVarianceTitle => 'Day-close differences';

  @override
  String get repVarianceNone => 'No closed days yet';

  @override
  String get repVarianceHint =>
      'Bars show how far the count was from the books each day';

  @override
  String get repCommissionTitle => 'Commission: expected vs received';

  @override
  String get repExpected => 'Expected';

  @override
  String get repReceived => 'Received';

  @override
  String get repPending => 'Pending';

  @override
  String get repRecordCommission => 'Record commission received';

  @override
  String get repExportCsv => 'Export CSV';

  @override
  String get repExporting => 'Preparing…';

  @override
  String get repExportFailed => 'Could not export';

  @override
  String get repStatementPdf => 'Statement PDF';

  @override
  String repStatementTitle(String account) {
    return '$account statement';
  }

  @override
  String repStatementPeriod(String from, String to) {
    return '$from to $to';
  }

  @override
  String repPage(String n, String total) {
    return 'Page $n of $total';
  }

  @override
  String get ledgerDescription => 'Description';

  @override
  String get staffTitle => 'Staff';

  @override
  String get staffAdd => 'Add staff';

  @override
  String get staffName => 'Name';

  @override
  String get staffPin => 'PIN (4 to 6 digits)';

  @override
  String get staffCanSeeProfit => 'Can see profit and reports';

  @override
  String get staffCanCloseDay => 'Can close the day';

  @override
  String get roleOwner => 'Owner';

  @override
  String get roleStaff => 'Staff';

  @override
  String get staffInactive => 'Inactive';

  @override
  String get staffResetPin => 'Reset PIN';

  @override
  String get staffDeactivate => 'Deactivate';

  @override
  String get staffActivate => 'Activate';

  @override
  String get staffSaved => 'Saved';

  @override
  String get staffPinInUse => 'This PIN is already used. Choose another.';

  @override
  String get staffBadPin => 'The PIN must be 4 to 6 digits';

  @override
  String get staffNameRequired => 'Enter a name';

  @override
  String get staffEmpty =>
      'No staff yet. Add the people who work at your counter.';

  @override
  String get staffInfo =>
      'Each staff member signs in with their own PIN. They can add entries and see only their own entries.';

  @override
  String get whoAreYou => 'Who is using the app?';

  @override
  String signedInAs(String name) {
    return 'Signed in as $name';
  }

  @override
  String get switchUser => 'Switch user';

  @override
  String get permDenied => 'You do not have permission to do this';

  @override
  String shiftCurrent(String name) {
    return 'Shift: $name';
  }

  @override
  String shiftSince(String time) {
    return 'since $time';
  }

  @override
  String get shiftHandover => 'Hand over';

  @override
  String get shiftHandoverTitle => 'Shift handover';

  @override
  String get shiftHandoverIntro =>
      'Count the cash and wallets before handing over. Any difference is recorded against this shift.';

  @override
  String get shiftDone => 'Handover recorded';

  @override
  String get shiftNoOpen => 'No shift is open';

  @override
  String get shiftRecent => 'Recent shifts';

  @override
  String get shiftNone => 'No shifts yet';

  @override
  String get shiftOpenNow => 'Open';

  @override
  String get shiftOperatorVariance => 'Differences by operator';

  @override
  String shiftShortage(String amount) {
    return 'Short $amount';
  }

  @override
  String get shiftSummaryTitle => 'Shift summary';

  @override
  String shiftDifference(String amount) {
    return 'Difference $amount';
  }

  @override
  String get closeDayNoPermission =>
      'Day close is done by the owner or by staff the owner allowed.';

  @override
  String get reasonRequiredHere => 'Choose a reason for each difference';

  @override
  String get bulkTitle => 'Bulk flexiload';

  @override
  String get bulkNumber => 'Number (optional)';

  @override
  String get bulkAmount => 'Price';

  @override
  String get bulkAddRow => 'Add row';

  @override
  String get bulkPaste => 'Paste list';

  @override
  String get bulkPasteHint =>
      'One load per line: number and amount, like 01712345678 100';

  @override
  String get bulkPasteApply => 'Add to list';

  @override
  String bulkRejected(String count) {
    return '$count lines skipped';
  }

  @override
  String bulkTotal(String count, String price) {
    return '$count loads · $price';
  }

  @override
  String bulkMargin(String amount) {
    return 'Margin $amount';
  }

  @override
  String bulkSaveAll(String count) {
    return 'Save all ($count)';
  }

  @override
  String bulkSaved(String count) {
    return '$count loads saved';
  }

  @override
  String get bulkDuplicate => 'Same number and amount twice';

  @override
  String get bulkBadNumber => 'Check the number';

  @override
  String bulkLowBalance(String account) {
    return '$account balance is not enough for these loads';
  }

  @override
  String get bulkEmpty => 'Add at least one load';

  @override
  String get regularsTitle => 'Regulars';

  @override
  String regularsUses(String count) {
    return '$count times';
  }

  @override
  String get rateModeTiered => 'By amount (tiers)';

  @override
  String get tierUpTo => 'Up to';

  @override
  String get tierAbove => 'Above';

  @override
  String get tierAdd => 'Add tier';

  @override
  String get tierOrderProblem =>
      'Amounts must increase from one tier to the next';

  @override
  String get recTitle => 'Recurring expenses';

  @override
  String get recAdd => 'Add recurring expense';

  @override
  String get recAmount => 'Amount';

  @override
  String get recFrequency => 'Repeats';

  @override
  String get recMonthly => 'Every month';

  @override
  String get recWeekly => 'Every week';

  @override
  String get recDayOfMonth => 'Day of the month';

  @override
  String get recWeekday => 'Day of the week';

  @override
  String recNextDue(String date) {
    return 'Next: $date';
  }

  @override
  String recDueBanner(String count) {
    return '$count recurring expenses are due';
  }

  @override
  String get recRecord => 'Record';

  @override
  String get recSkip => 'Skip';

  @override
  String get recRecorded => 'Expense recorded';

  @override
  String get recEmpty =>
      'No recurring expenses yet. Add rent, internet and other regular costs.';

  @override
  String get recNotifTitle => 'Expense due';

  @override
  String recNotifBody(String label, String amount) {
    return '$label: $amount is due today';
  }

  @override
  String get recPaused => 'Paused';

  @override
  String get recDueNow => 'Due';

  @override
  String get recNeedCategory => 'Add an expense category first';

  @override
  String get recEvery31 => 'Months with fewer days use the last day';

  @override
  String get wdMon => 'Monday';

  @override
  String get wdTue => 'Tuesday';

  @override
  String get wdWed => 'Wednesday';

  @override
  String get wdThu => 'Thursday';

  @override
  String get wdFri => 'Friday';

  @override
  String get wdSat => 'Saturday';

  @override
  String get wdSun => 'Sunday';

  @override
  String get sheetTitle => 'Daily sheet';

  @override
  String get sheetPrint => 'Print sheet';

  @override
  String get sheetShare => 'Share sheet as PDF';

  @override
  String get sheetPreparedBy => 'Prepared by';

  @override
  String get sheetCheckedBy => 'Checked by';

  @override
  String get sheetParticulars => 'Particulars';

  @override
  String get sheetTime => 'Time';

  @override
  String get sheetAccounts => 'Accounts';

  @override
  String get sheetSummary => 'Summary';

  @override
  String get sheetFailed => 'Could not prepare the sheet';

  @override
  String get insTitle => 'Insights';

  @override
  String get insNotEnough =>
      'Not enough entries yet to show patterns (at least 10 needed).';

  @override
  String get insAvgSize => 'Average entry';

  @override
  String insEntries(String count) {
    return '$count entries';
  }

  @override
  String get insBusiestHour => 'Busiest hour';

  @override
  String get insBestHour => 'Most profitable hour';

  @override
  String get insBestWeekday => 'Best weekday';

  @override
  String insPerDay(String amount) {
    return '$amount per day';
  }

  @override
  String get insHourChart => 'Entries by hour of day';

  @override
  String get insWeekdayChart => 'Average profit by weekday';

  @override
  String get insByType => 'Average size by type';

  @override
  String get wdMonShort => 'Mon';

  @override
  String get wdTueShort => 'Tue';

  @override
  String get wdWedShort => 'Wed';

  @override
  String get wdThuShort => 'Thu';

  @override
  String get wdFriShort => 'Fri';

  @override
  String get wdSatShort => 'Sat';

  @override
  String get wdSunShort => 'Sun';

  @override
  String get repVarianceByAccount => 'By account (last 30 closed days)';

  @override
  String get repVarianceByWeekday => 'Differences by weekday';

  @override
  String get repVarianceWeekdayHint =>
      'Average difference per closed day, last 90 closed days';

  @override
  String repVarianceWorst(String day, String short, String total) {
    return 'Short most often on $day: $short of $total closed days';
  }

  @override
  String get repVarianceNoPattern => 'No weekday stands out yet';

  @override
  String repVarianceShortOver(String amount, String days) {
    return 'Short $amount on $days days';
  }

  @override
  String repVarianceExcessOver(String amount) {
    return 'Excess $amount';
  }

  @override
  String get repVarianceAllGood => 'No differences';

  @override
  String get adLabel => 'Advertisement';

  @override
  String get adPrivacyOptions => 'Ad privacy options';

  @override
  String get aboutAds =>
      'This app shows ads from Google AdMob. Ads are not personalized, and your business records are never used for ads.';

  @override
  String get entryAmount => 'Amount';

  @override
  String get entryWalletLabel => 'Wallet';
}
