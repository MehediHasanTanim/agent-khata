import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_bn.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('bn'),
    Locale('en'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Agent Khata'**
  String get appName;

  /// No description provided for @homeTitle.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homeTitle;

  /// No description provided for @homePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Your cash book will appear here.'**
  String get homePlaceholder;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageBangla.
  ///
  /// In en, this message translates to:
  /// **'বাংলা'**
  String get languageBangla;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @digitStyle.
  ///
  /// In en, this message translates to:
  /// **'Digit style'**
  String get digitStyle;

  /// No description provided for @digitsBangla.
  ///
  /// In en, this message translates to:
  /// **'Bangla digits (০-৯)'**
  String get digitsBangla;

  /// No description provided for @digitsLatin.
  ///
  /// In en, this message translates to:
  /// **'English digits (0-9)'**
  String get digitsLatin;

  /// No description provided for @digitGrouping.
  ///
  /// In en, this message translates to:
  /// **'Bangladeshi digit grouping (1,00,000)'**
  String get digitGrouping;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @themeHighContrast.
  ///
  /// In en, this message translates to:
  /// **'High contrast'**
  String get themeHighContrast;

  /// No description provided for @lockNow.
  ///
  /// In en, this message translates to:
  /// **'Lock now'**
  String get lockNow;

  /// No description provided for @sampleAmount.
  ///
  /// In en, this message translates to:
  /// **'Sample amount'**
  String get sampleAmount;

  /// No description provided for @pinSetupTitle.
  ///
  /// In en, this message translates to:
  /// **'Set a PIN'**
  String get pinSetupTitle;

  /// No description provided for @pinSetupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a 4 to 6 digit PIN to protect your books.'**
  String get pinSetupSubtitle;

  /// No description provided for @pinConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm your PIN'**
  String get pinConfirmTitle;

  /// No description provided for @pinConfirmSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter the same PIN again.'**
  String get pinConfirmSubtitle;

  /// No description provided for @pinMismatch.
  ///
  /// In en, this message translates to:
  /// **'PINs did not match. Try again.'**
  String get pinMismatch;

  /// No description provided for @pinUnlockTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter PIN'**
  String get pinUnlockTitle;

  /// No description provided for @pinUnlockSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your PIN to open the cash book.'**
  String get pinUnlockSubtitle;

  /// No description provided for @pinWrong.
  ///
  /// In en, this message translates to:
  /// **'Wrong PIN. {remaining} attempts before a delay.'**
  String pinWrong(String remaining);

  /// No description provided for @pinLockedOut.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Try again in {seconds} seconds.'**
  String pinLockedOut(String seconds);

  /// No description provided for @pinDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get pinDelete;

  /// No description provided for @keypadClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get keypadClear;

  /// No description provided for @diagnostics.
  ///
  /// In en, this message translates to:
  /// **'Diagnostics'**
  String get diagnostics;

  /// No description provided for @diagEncryption.
  ///
  /// In en, this message translates to:
  /// **'Database encryption'**
  String get diagEncryption;

  /// No description provided for @diagEncrypted.
  ///
  /// In en, this message translates to:
  /// **'Encrypted (SQLCipher {version})'**
  String diagEncrypted(String version);

  /// No description provided for @diagNotEncrypted.
  ///
  /// In en, this message translates to:
  /// **'NOT encrypted'**
  String get diagNotEncrypted;

  /// No description provided for @diagJournal.
  ///
  /// In en, this message translates to:
  /// **'Journal mode'**
  String get diagJournal;

  /// No description provided for @diagSchema.
  ///
  /// In en, this message translates to:
  /// **'Schema version'**
  String get diagSchema;

  /// No description provided for @diagWriteBench.
  ///
  /// In en, this message translates to:
  /// **'Write speed'**
  String get diagWriteBench;

  /// No description provided for @diagRunBench.
  ///
  /// In en, this message translates to:
  /// **'Run write test'**
  String get diagRunBench;

  /// No description provided for @diagBenchResult.
  ///
  /// In en, this message translates to:
  /// **'1,000 inserts in {ms} ms'**
  String diagBenchResult(String ms);

  /// No description provided for @diagColdStart.
  ///
  /// In en, this message translates to:
  /// **'Cold start to first frame'**
  String get diagColdStart;

  /// No description provided for @diagMs.
  ///
  /// In en, this message translates to:
  /// **'{ms} ms'**
  String diagMs(String ms);

  /// No description provided for @autoLock.
  ///
  /// In en, this message translates to:
  /// **'Auto-lock after'**
  String get autoLock;

  /// No description provided for @autoLockImmediately.
  ///
  /// In en, this message translates to:
  /// **'Immediately'**
  String get autoLockImmediately;

  /// No description provided for @autoLockSeconds.
  ///
  /// In en, this message translates to:
  /// **'{seconds} seconds'**
  String autoLockSeconds(String seconds);

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @saveAnyway.
  ///
  /// In en, this message translates to:
  /// **'Save anyway'**
  String get saveAnyway;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get comingSoon;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get navHistory;

  /// No description provided for @navCloseDay.
  ///
  /// In en, this message translates to:
  /// **'Close day'**
  String get navCloseDay;

  /// No description provided for @navReports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get navReports;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @onbWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Agent Khata'**
  String get onbWelcomeTitle;

  /// No description provided for @onbWelcomeBody.
  ///
  /// In en, this message translates to:
  /// **'Set up your cash book in about two minutes.'**
  String get onbWelcomeBody;

  /// No description provided for @onbQuickStart.
  ///
  /// In en, this message translates to:
  /// **'Quick start with defaults'**
  String get onbQuickStart;

  /// No description provided for @onbStepByStep.
  ///
  /// In en, this message translates to:
  /// **'Set up step by step'**
  String get onbStepByStep;

  /// No description provided for @onbProvidersTitle.
  ///
  /// In en, this message translates to:
  /// **'Which wallets do you run?'**
  String get onbProvidersTitle;

  /// No description provided for @onbProvidersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pick all that apply. You can add more later.'**
  String get onbProvidersSubtitle;

  /// No description provided for @onbOperatorsTitle.
  ///
  /// In en, this message translates to:
  /// **'Flexiload operators'**
  String get onbOperatorsTitle;

  /// No description provided for @onbBalancesTitle.
  ///
  /// In en, this message translates to:
  /// **'Opening balances'**
  String get onbBalancesTitle;

  /// No description provided for @onbBalancesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter what you have right now.'**
  String get onbBalancesSubtitle;

  /// No description provided for @onbCashLabel.
  ///
  /// In en, this message translates to:
  /// **'Cash in drawer'**
  String get onbCashLabel;

  /// No description provided for @onbRatesTitle.
  ///
  /// In en, this message translates to:
  /// **'Commission rates'**
  String get onbRatesTitle;

  /// No description provided for @onbRatesNotice.
  ///
  /// In en, this message translates to:
  /// **'These are sample rates only. Please check them with your provider.'**
  String get onbRatesNotice;

  /// No description provided for @onbShopTitle.
  ///
  /// In en, this message translates to:
  /// **'Shop name'**
  String get onbShopTitle;

  /// No description provided for @onbShopHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Rahim Telecom'**
  String get onbShopHint;

  /// No description provided for @onbFinish.
  ///
  /// In en, this message translates to:
  /// **'Finish setup'**
  String get onbFinish;

  /// No description provided for @onbSaving.
  ///
  /// In en, this message translates to:
  /// **'Setting up…'**
  String get onbSaving;

  /// No description provided for @onbError.
  ///
  /// In en, this message translates to:
  /// **'Could not finish setup. Please try again.'**
  String get onbError;

  /// No description provided for @amountInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid amount'**
  String get amountInvalid;

  /// No description provided for @rateModePerThousand.
  ///
  /// In en, this message translates to:
  /// **'Per ৳1,000'**
  String get rateModePerThousand;

  /// No description provided for @rateModePercent.
  ///
  /// In en, this message translates to:
  /// **'Percent (%)'**
  String get rateModePercent;

  /// No description provided for @rateModeFixed.
  ///
  /// In en, this message translates to:
  /// **'Fixed ৳'**
  String get rateModeFixed;

  /// No description provided for @rateValue.
  ///
  /// In en, this message translates to:
  /// **'Value'**
  String get rateValue;

  /// No description provided for @rateInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid rate'**
  String get rateInvalid;

  /// No description provided for @rateTooHigh.
  ///
  /// In en, this message translates to:
  /// **'This looks too high'**
  String get rateTooHigh;

  /// No description provided for @rateSaved.
  ///
  /// In en, this message translates to:
  /// **'Rate saved'**
  String get rateSaved;

  /// No description provided for @rateEffectiveNote.
  ///
  /// In en, this message translates to:
  /// **'A new rate applies to new entries only.'**
  String get rateEffectiveNote;

  /// No description provided for @commissionRates.
  ///
  /// In en, this message translates to:
  /// **'Commission rates'**
  String get commissionRates;

  /// No description provided for @txnCashOut.
  ///
  /// In en, this message translates to:
  /// **'Cash out'**
  String get txnCashOut;

  /// No description provided for @txnCashIn.
  ///
  /// In en, this message translates to:
  /// **'Cash in'**
  String get txnCashIn;

  /// No description provided for @txnFlexiload.
  ///
  /// In en, this message translates to:
  /// **'Flexiload'**
  String get txnFlexiload;

  /// No description provided for @txnFloatPurchase.
  ///
  /// In en, this message translates to:
  /// **'Buy float'**
  String get txnFloatPurchase;

  /// No description provided for @txnExpense.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get txnExpense;

  /// No description provided for @txnOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get txnOther;

  /// No description provided for @entryWallet.
  ///
  /// In en, this message translates to:
  /// **'Wallet'**
  String get entryWallet;

  /// No description provided for @entryPaidFrom.
  ///
  /// In en, this message translates to:
  /// **'Paid from'**
  String get entryPaidFrom;

  /// No description provided for @entryCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get entryCategory;

  /// No description provided for @entryNewCategory.
  ///
  /// In en, this message translates to:
  /// **'New category'**
  String get entryNewCategory;

  /// No description provided for @entryCategoryName.
  ///
  /// In en, this message translates to:
  /// **'Category name'**
  String get entryCategoryName;

  /// No description provided for @entryMoreDetails.
  ///
  /// In en, this message translates to:
  /// **'More details (optional)'**
  String get entryMoreDetails;

  /// No description provided for @entryCustomerNumber.
  ///
  /// In en, this message translates to:
  /// **'Customer number'**
  String get entryCustomerNumber;

  /// No description provided for @entryNote.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get entryNote;

  /// No description provided for @entryTrxId.
  ///
  /// In en, this message translates to:
  /// **'TrxID'**
  String get entryTrxId;

  /// No description provided for @entryCommission.
  ///
  /// In en, this message translates to:
  /// **'Commission: {amount}'**
  String entryCommission(String amount);

  /// No description provided for @entryRepeatLast.
  ///
  /// In en, this message translates to:
  /// **'Last: {amount}'**
  String entryRepeatLast(String amount);

  /// No description provided for @entryNoWallet.
  ///
  /// In en, this message translates to:
  /// **'Add a wallet first'**
  String get entryNoWallet;

  /// No description provided for @entrySaved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get entrySaved;

  /// No description provided for @entryUndone.
  ///
  /// In en, this message translates to:
  /// **'Entry undone'**
  String get entryUndone;

  /// No description provided for @entrySaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save. Please try again.'**
  String get entrySaveFailed;

  /// No description provided for @warnNegative.
  ///
  /// In en, this message translates to:
  /// **'{account} will go below zero'**
  String warnNegative(String account);

  /// No description provided for @warnLargeTitle.
  ///
  /// In en, this message translates to:
  /// **'Large amount'**
  String get warnLargeTitle;

  /// No description provided for @warnLargeBody.
  ///
  /// In en, this message translates to:
  /// **'{amount} is a large amount. Save it?'**
  String warnLargeBody(String amount);

  /// No description provided for @warnDuplicateTitle.
  ///
  /// In en, this message translates to:
  /// **'Possible duplicate'**
  String get warnDuplicateTitle;

  /// No description provided for @warnDuplicateBody.
  ///
  /// In en, this message translates to:
  /// **'A similar entry was saved a moment ago. Save again?'**
  String get warnDuplicateBody;

  /// No description provided for @homeCash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get homeCash;

  /// No description provided for @homeFlexiloadTotal.
  ///
  /// In en, this message translates to:
  /// **'Flexiload'**
  String get homeFlexiloadTotal;

  /// No description provided for @homeLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get homeLow;

  /// No description provided for @homeTapToReveal.
  ///
  /// In en, this message translates to:
  /// **'Tap to show'**
  String get homeTapToReveal;

  /// No description provided for @homeToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get homeToday;

  /// No description provided for @homeTodayEntries.
  ///
  /// In en, this message translates to:
  /// **'Entries'**
  String get homeTodayEntries;

  /// No description provided for @homeTodayCashIn.
  ///
  /// In en, this message translates to:
  /// **'Cash in'**
  String get homeTodayCashIn;

  /// No description provided for @homeTodayCashOut.
  ///
  /// In en, this message translates to:
  /// **'Cash out'**
  String get homeTodayCashOut;

  /// No description provided for @homeTodayCommission.
  ///
  /// In en, this message translates to:
  /// **'Commission'**
  String get homeTodayCommission;

  /// No description provided for @homeRecent.
  ///
  /// In en, this message translates to:
  /// **'Last 5 entries'**
  String get homeRecent;

  /// No description provided for @homeNoEntries.
  ///
  /// In en, this message translates to:
  /// **'No entries yet. Tap a button above to start.'**
  String get homeNoEntries;

  /// No description provided for @maskBalances.
  ///
  /// In en, this message translates to:
  /// **'Hide balances until tapped'**
  String get maskBalances;

  /// No description provided for @largeAmountWarning.
  ///
  /// In en, this message translates to:
  /// **'Warn for amounts of'**
  String get largeAmountWarning;

  /// No description provided for @catRent.
  ///
  /// In en, this message translates to:
  /// **'Rent'**
  String get catRent;

  /// No description provided for @catElectricity.
  ///
  /// In en, this message translates to:
  /// **'Electricity'**
  String get catElectricity;

  /// No description provided for @catTransport.
  ///
  /// In en, this message translates to:
  /// **'Transport'**
  String get catTransport;

  /// No description provided for @catStaffPay.
  ///
  /// In en, this message translates to:
  /// **'Staff pay'**
  String get catStaffPay;

  /// No description provided for @catTea.
  ///
  /// In en, this message translates to:
  /// **'Tea & snacks'**
  String get catTea;

  /// No description provided for @catOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get catOther;

  /// No description provided for @histToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get histToday;

  /// No description provided for @histYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get histYesterday;

  /// No description provided for @histWeek.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get histWeek;

  /// No description provided for @histMonth.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get histMonth;

  /// No description provided for @histAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get histAll;

  /// No description provided for @histSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search amount, number, note, TrxID'**
  String get histSearchHint;

  /// No description provided for @histEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing found'**
  String get histEmpty;

  /// No description provided for @histCount.
  ///
  /// In en, this message translates to:
  /// **'{count} entries'**
  String histCount(String count);

  /// No description provided for @histTotal.
  ///
  /// In en, this message translates to:
  /// **'Total {amount}'**
  String histTotal(String amount);

  /// No description provided for @histLoadMore.
  ///
  /// In en, this message translates to:
  /// **'Load more'**
  String get histLoadMore;

  /// No description provided for @histAccountFilter.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get histAccountFilter;

  /// No description provided for @histAllAccounts.
  ///
  /// In en, this message translates to:
  /// **'All accounts'**
  String get histAllAccounts;

  /// No description provided for @histClearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear filters'**
  String get histClearFilters;

  /// No description provided for @labelVoided.
  ///
  /// In en, this message translates to:
  /// **'Voided'**
  String get labelVoided;

  /// No description provided for @labelLocked.
  ///
  /// In en, this message translates to:
  /// **'Closed day'**
  String get labelLocked;

  /// No description provided for @detailTitle.
  ///
  /// In en, this message translates to:
  /// **'Entry details'**
  String get detailTitle;

  /// No description provided for @detailAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get detailAmount;

  /// No description provided for @detailCharge.
  ///
  /// In en, this message translates to:
  /// **'Charge'**
  String get detailCharge;

  /// No description provided for @detailCommission.
  ///
  /// In en, this message translates to:
  /// **'Commission'**
  String get detailCommission;

  /// No description provided for @detailRule.
  ///
  /// In en, this message translates to:
  /// **'Rate used: {rule}'**
  String detailRule(String rule);

  /// No description provided for @detailWhen.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get detailWhen;

  /// No description provided for @detailRecorded.
  ///
  /// In en, this message translates to:
  /// **'Recorded at'**
  String get detailRecorded;

  /// No description provided for @detailBy.
  ///
  /// In en, this message translates to:
  /// **'Entered by'**
  String get detailBy;

  /// No description provided for @detailAccounts.
  ///
  /// In en, this message translates to:
  /// **'Accounts'**
  String get detailAccounts;

  /// No description provided for @detailAudit.
  ///
  /// In en, this message translates to:
  /// **'Change history'**
  String get detailAudit;

  /// No description provided for @detailReplaces.
  ///
  /// In en, this message translates to:
  /// **'This entry replaces an earlier one'**
  String get detailReplaces;

  /// No description provided for @detailReplacedBy.
  ///
  /// In en, this message translates to:
  /// **'Replaced by a newer entry'**
  String get detailReplacedBy;

  /// No description provided for @detailVoid.
  ///
  /// In en, this message translates to:
  /// **'Void entry'**
  String get detailVoid;

  /// No description provided for @detailEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get detailEdit;

  /// No description provided for @detailVoidReason.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get detailVoidReason;

  /// No description provided for @detailVoidConfirm.
  ///
  /// In en, this message translates to:
  /// **'Void'**
  String get detailVoidConfirm;

  /// No description provided for @detailVoidedBecause.
  ///
  /// In en, this message translates to:
  /// **'Voided: {reason}'**
  String detailVoidedBecause(String reason);

  /// No description provided for @detailLockedHint.
  ///
  /// In en, this message translates to:
  /// **'This day is closed, so the entry cannot be changed.'**
  String get detailLockedHint;

  /// No description provided for @detailActionFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not complete this action.'**
  String get detailActionFailed;

  /// No description provided for @ledgerTitle.
  ///
  /// In en, this message translates to:
  /// **'{account} statement'**
  String ledgerTitle(String account);

  /// No description provided for @ledgerDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get ledgerDate;

  /// No description provided for @ledgerIn.
  ///
  /// In en, this message translates to:
  /// **'In'**
  String get ledgerIn;

  /// No description provided for @ledgerOut.
  ///
  /// In en, this message translates to:
  /// **'Out'**
  String get ledgerOut;

  /// No description provided for @ledgerBalance.
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get ledgerBalance;

  /// No description provided for @ledgerAdjust.
  ///
  /// In en, this message translates to:
  /// **'Adjust balance'**
  String get ledgerAdjust;

  /// No description provided for @ledgerEmpty.
  ///
  /// In en, this message translates to:
  /// **'No entries in this period'**
  String get ledgerEmpty;

  /// No description provided for @adjTitle.
  ///
  /// In en, this message translates to:
  /// **'Adjust balance'**
  String get adjTitle;

  /// No description provided for @adjIncrease.
  ///
  /// In en, this message translates to:
  /// **'Increase'**
  String get adjIncrease;

  /// No description provided for @adjDecrease.
  ///
  /// In en, this message translates to:
  /// **'Decrease'**
  String get adjDecrease;

  /// No description provided for @adjReason.
  ///
  /// In en, this message translates to:
  /// **'Reason (required)'**
  String get adjReason;

  /// No description provided for @adjCurrent.
  ///
  /// In en, this message translates to:
  /// **'Current balance: {amount}'**
  String adjCurrent(String amount);

  /// No description provided for @adjNew.
  ///
  /// In en, this message translates to:
  /// **'New balance: {amount}'**
  String adjNew(String amount);

  /// No description provided for @lowTitle.
  ///
  /// In en, this message translates to:
  /// **'Low balance alerts'**
  String get lowTitle;

  /// No description provided for @lowSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Warn me when an account falls to this amount. Leave empty for no alert.'**
  String get lowSubtitle;

  /// No description provided for @lowBanner.
  ///
  /// In en, this message translates to:
  /// **'Low balance: {accounts}'**
  String lowBanner(String accounts);

  /// No description provided for @rememberCustomers.
  ///
  /// In en, this message translates to:
  /// **'Remember customers'**
  String get rememberCustomers;

  /// No description provided for @rememberCustomersHint.
  ///
  /// In en, this message translates to:
  /// **'Suggest numbers and names you typed before. Stored only on this phone.'**
  String get rememberCustomersHint;

  /// No description provided for @entryCustomerName.
  ///
  /// In en, this message translates to:
  /// **'Customer name'**
  String get entryCustomerName;

  /// No description provided for @entryOperator.
  ///
  /// In en, this message translates to:
  /// **'Operator'**
  String get entryOperator;

  /// No description provided for @entryMargin.
  ///
  /// In en, this message translates to:
  /// **'Margin: {amount}'**
  String entryMargin(String amount);

  /// No description provided for @entryPaidAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount paid (if different)'**
  String get entryPaidAmount;

  /// No description provided for @entryEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit entry'**
  String get entryEditTitle;

  /// No description provided for @entryNoOperator.
  ///
  /// In en, this message translates to:
  /// **'Add a flexiload operator first'**
  String get entryNoOperator;

  /// No description provided for @cdTitle.
  ///
  /// In en, this message translates to:
  /// **'Close the day'**
  String get cdTitle;

  /// No description provided for @cdIntro.
  ///
  /// In en, this message translates to:
  /// **'Count your cash and wallet balances. We will show where any gap may be.'**
  String get cdIntro;

  /// No description provided for @cdExpected.
  ///
  /// In en, this message translates to:
  /// **'Expected'**
  String get cdExpected;

  /// No description provided for @cdActual.
  ///
  /// In en, this message translates to:
  /// **'Actual'**
  String get cdActual;

  /// No description provided for @cdBlankHint.
  ///
  /// In en, this message translates to:
  /// **'Leave empty if it matches'**
  String get cdBlankHint;

  /// No description provided for @cdCashCounter.
  ///
  /// In en, this message translates to:
  /// **'Count notes'**
  String get cdCashCounter;

  /// No description provided for @cdCashCounterTitle.
  ///
  /// In en, this message translates to:
  /// **'Cash counter'**
  String get cdCashCounterTitle;

  /// No description provided for @cdCounterTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get cdCounterTotal;

  /// No description provided for @cdCounterUse.
  ///
  /// In en, this message translates to:
  /// **'Use this total'**
  String get cdCounterUse;

  /// No description provided for @cdCoins.
  ///
  /// In en, this message translates to:
  /// **'Coins'**
  String get cdCoins;

  /// No description provided for @cdReview.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get cdReview;

  /// No description provided for @cdMatches.
  ///
  /// In en, this message translates to:
  /// **'Matches'**
  String get cdMatches;

  /// No description provided for @cdShort.
  ///
  /// In en, this message translates to:
  /// **'Short by {amount}'**
  String cdShort(String amount);

  /// No description provided for @cdExcess.
  ///
  /// In en, this message translates to:
  /// **'Excess of {amount}'**
  String cdExcess(String amount);

  /// No description provided for @cdReason.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get cdReason;

  /// No description provided for @cdReasonNote.
  ///
  /// In en, this message translates to:
  /// **'Note (optional)'**
  String get cdReasonNote;

  /// No description provided for @cdReasonShortage.
  ///
  /// In en, this message translates to:
  /// **'Shortage'**
  String get cdReasonShortage;

  /// No description provided for @cdReasonExcess.
  ///
  /// In en, this message translates to:
  /// **'Excess'**
  String get cdReasonExcess;

  /// No description provided for @cdReasonProvider.
  ///
  /// In en, this message translates to:
  /// **'Provider charge'**
  String get cdReasonProvider;

  /// No description provided for @cdReasonCounting.
  ///
  /// In en, this message translates to:
  /// **'Counting error'**
  String get cdReasonCounting;

  /// No description provided for @cdReasonTolerance.
  ///
  /// In en, this message translates to:
  /// **'Small difference'**
  String get cdReasonTolerance;

  /// No description provided for @cdReasonOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get cdReasonOther;

  /// No description provided for @cdFindGap.
  ///
  /// In en, this message translates to:
  /// **'Where could it be?'**
  String get cdFindGap;

  /// No description provided for @cdAddMissing.
  ///
  /// In en, this message translates to:
  /// **'Add a missing entry'**
  String get cdAddMissing;

  /// No description provided for @cdClose.
  ///
  /// In en, this message translates to:
  /// **'Close the day'**
  String get cdClose;

  /// No description provided for @cdClosedOk.
  ///
  /// In en, this message translates to:
  /// **'Day closed'**
  String get cdClosedOk;

  /// No description provided for @cdTolerance.
  ///
  /// In en, this message translates to:
  /// **'Differences up to {amount} are written off automatically'**
  String cdTolerance(String amount);

  /// No description provided for @cdMissingReason.
  ///
  /// In en, this message translates to:
  /// **'Choose a reason for each difference'**
  String get cdMissingReason;

  /// No description provided for @cdAlreadyClosed.
  ///
  /// In en, this message translates to:
  /// **'This day is already closed'**
  String get cdAlreadyClosed;

  /// No description provided for @cdFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not close the day. Please try again.'**
  String get cdFailed;

  /// No description provided for @cdReopen.
  ///
  /// In en, this message translates to:
  /// **'Reopen'**
  String get cdReopen;

  /// No description provided for @cdReopenTitle.
  ///
  /// In en, this message translates to:
  /// **'Reopen this day?'**
  String get cdReopenTitle;

  /// No description provided for @cdReopenBody.
  ///
  /// In en, this message translates to:
  /// **'Adjustments from the close will be cancelled. Give a reason.'**
  String get cdReopenBody;

  /// No description provided for @cdReopened.
  ///
  /// In en, this message translates to:
  /// **'Day reopened'**
  String get cdReopened;

  /// No description provided for @cdLaterClosed.
  ///
  /// In en, this message translates to:
  /// **'Only the most recent closed day can be reopened'**
  String get cdLaterClosed;

  /// No description provided for @cdRecentDays.
  ///
  /// In en, this message translates to:
  /// **'Recent days'**
  String get cdRecentDays;

  /// No description provided for @cdNoDays.
  ///
  /// In en, this message translates to:
  /// **'No days closed yet'**
  String get cdNoDays;

  /// No description provided for @cdStatusClosed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get cdStatusClosed;

  /// No description provided for @cdStatusReopened.
  ///
  /// In en, this message translates to:
  /// **'Reopened'**
  String get cdStatusReopened;

  /// No description provided for @cdStatusOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get cdStatusOpen;

  /// No description provided for @cdPickDay.
  ///
  /// In en, this message translates to:
  /// **'Which day?'**
  String get cdPickDay;

  /// No description provided for @cdYesterdayOpen.
  ///
  /// In en, this message translates to:
  /// **'Yesterday\'s accounts are not closed'**
  String get cdYesterdayOpen;

  /// No description provided for @cdDifference.
  ///
  /// In en, this message translates to:
  /// **'Difference {amount}'**
  String cdDifference(String amount);

  /// No description provided for @sugSameSame.
  ///
  /// In en, this message translates to:
  /// **'An entry of {amount} is the same size as the gap. A similar entry may be missing.'**
  String sugSameSame(String amount);

  /// No description provided for @sugSameOpposite.
  ///
  /// In en, this message translates to:
  /// **'An entry of {amount} equals the gap. It may be recorded twice or may not have happened.'**
  String sugSameOpposite(String amount);

  /// No description provided for @sugFlipped.
  ///
  /// In en, this message translates to:
  /// **'The {amount} entry may be recorded in the wrong direction (in vs out).'**
  String sugFlipped(String amount);

  /// No description provided for @sugEntryDouble.
  ///
  /// In en, this message translates to:
  /// **'An entry of {amount} is double the gap. The amount may be typed wrong.'**
  String sugEntryDouble(String amount);

  /// No description provided for @sugGapDouble.
  ///
  /// In en, this message translates to:
  /// **'The gap is double the entry of {amount}. It may have been counted twice.'**
  String sugGapDouble(String amount);

  /// No description provided for @sugDuplicate.
  ///
  /// In en, this message translates to:
  /// **'Two entries of {amount} were saved within minutes. One may be a duplicate.'**
  String sugDuplicate(String amount);

  /// No description provided for @sugTranspose.
  ///
  /// In en, this message translates to:
  /// **'{amount} may have been typed instead of {alt} (digits swapped).'**
  String sugTranspose(String amount, String alt);

  /// No description provided for @sugCross.
  ///
  /// In en, this message translates to:
  /// **'{other} is off by the opposite amount. The entry may be on the wrong wallet.'**
  String sugCross(String other);

  /// No description provided for @sumTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily summary'**
  String get sumTitle;

  /// No description provided for @sumEntries.
  ///
  /// In en, this message translates to:
  /// **'Entries'**
  String get sumEntries;

  /// No description provided for @sumCashInVolume.
  ///
  /// In en, this message translates to:
  /// **'Cash in total'**
  String get sumCashInVolume;

  /// No description provided for @sumCashOutVolume.
  ///
  /// In en, this message translates to:
  /// **'Cash out total'**
  String get sumCashOutVolume;

  /// No description provided for @sumCommission.
  ///
  /// In en, this message translates to:
  /// **'Commission'**
  String get sumCommission;

  /// No description provided for @sumMargin.
  ///
  /// In en, this message translates to:
  /// **'Flexiload margin'**
  String get sumMargin;

  /// No description provided for @sumExpenses.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get sumExpenses;

  /// No description provided for @sumNet.
  ///
  /// In en, this message translates to:
  /// **'Net profit'**
  String get sumNet;

  /// No description provided for @sumVariance.
  ///
  /// In en, this message translates to:
  /// **'Difference'**
  String get sumVariance;

  /// No description provided for @sumNotClosed.
  ///
  /// In en, this message translates to:
  /// **'Not closed yet'**
  String get sumNotClosed;

  /// No description provided for @sumOpening.
  ///
  /// In en, this message translates to:
  /// **'Opening'**
  String get sumOpening;

  /// No description provided for @sumIn.
  ///
  /// In en, this message translates to:
  /// **'In'**
  String get sumIn;

  /// No description provided for @sumOut.
  ///
  /// In en, this message translates to:
  /// **'Out'**
  String get sumOut;

  /// No description provided for @sumShareImage.
  ///
  /// In en, this message translates to:
  /// **'Share image'**
  String get sumShareImage;

  /// No description provided for @sumSharePdf.
  ///
  /// In en, this message translates to:
  /// **'Share PDF'**
  String get sumSharePdf;

  /// No description provided for @sumShareFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not share the summary'**
  String get sumShareFailed;

  /// No description provided for @notifCloseTitle.
  ///
  /// In en, this message translates to:
  /// **'Time to close the day'**
  String get notifCloseTitle;

  /// No description provided for @notifCloseBody.
  ///
  /// In en, this message translates to:
  /// **'Count your cash and wallets to close today\'s accounts.'**
  String get notifCloseBody;

  /// No description provided for @notifLowTitle.
  ///
  /// In en, this message translates to:
  /// **'Low balance'**
  String get notifLowTitle;

  /// No description provided for @notifLowBody.
  ///
  /// In en, this message translates to:
  /// **'{account} is running low.'**
  String notifLowBody(String account);

  /// No description provided for @settingsReminder.
  ///
  /// In en, this message translates to:
  /// **'Day-close reminder'**
  String get settingsReminder;

  /// No description provided for @settingsReminderTime.
  ///
  /// In en, this message translates to:
  /// **'Reminder time'**
  String get settingsReminderTime;

  /// No description provided for @settingsTolerance.
  ///
  /// In en, this message translates to:
  /// **'Ignore differences up to'**
  String get settingsTolerance;

  /// No description provided for @entryDayClosed.
  ///
  /// In en, this message translates to:
  /// **'This day is closed. Reopen it from Close day to add entries.'**
  String get entryDayClosed;

  /// No description provided for @bkTitle.
  ///
  /// In en, this message translates to:
  /// **'Backup and restore'**
  String get bkTitle;

  /// No description provided for @bkLast.
  ///
  /// In en, this message translates to:
  /// **'Last backup: {date}'**
  String bkLast(String date);

  /// No description provided for @bkNever.
  ///
  /// In en, this message translates to:
  /// **'No backup yet'**
  String get bkNever;

  /// No description provided for @bkNow.
  ///
  /// In en, this message translates to:
  /// **'Back up now'**
  String get bkNow;

  /// No description provided for @bkRestore.
  ///
  /// In en, this message translates to:
  /// **'Restore from a backup file'**
  String get bkRestore;

  /// No description provided for @bkPassphrase.
  ///
  /// In en, this message translates to:
  /// **'Backup passphrase'**
  String get bkPassphrase;

  /// No description provided for @bkPassphraseConfirm.
  ///
  /// In en, this message translates to:
  /// **'Repeat passphrase'**
  String get bkPassphraseConfirm;

  /// No description provided for @bkPassphraseWarn.
  ///
  /// In en, this message translates to:
  /// **'If you forget this passphrase, the backup cannot be opened. It cannot be recovered.'**
  String get bkPassphraseWarn;

  /// No description provided for @bkMismatch.
  ///
  /// In en, this message translates to:
  /// **'The passphrases do not match'**
  String get bkMismatch;

  /// No description provided for @bkTooShort.
  ///
  /// In en, this message translates to:
  /// **'Use at least 6 characters'**
  String get bkTooShort;

  /// No description provided for @bkCreating.
  ///
  /// In en, this message translates to:
  /// **'Creating backup…'**
  String get bkCreating;

  /// No description provided for @bkShareText.
  ///
  /// In en, this message translates to:
  /// **'Agent Khata backup'**
  String get bkShareText;

  /// No description provided for @bkDone.
  ///
  /// In en, this message translates to:
  /// **'Backup created'**
  String get bkDone;

  /// No description provided for @bkFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not create the backup'**
  String get bkFailed;

  /// No description provided for @bkRestoreInfo.
  ///
  /// In en, this message translates to:
  /// **'Backup made on {date}'**
  String bkRestoreInfo(String date);

  /// No description provided for @bkRestoreConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Replace the data on this phone?'**
  String get bkRestoreConfirmTitle;

  /// No description provided for @bkRestoreConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'All current data will be replaced by this backup. A copy of the current data is kept on the phone.'**
  String get bkRestoreConfirmBody;

  /// No description provided for @bkRestoreWorking.
  ///
  /// In en, this message translates to:
  /// **'Restoring…'**
  String get bkRestoreWorking;

  /// No description provided for @bkRestoreDone.
  ///
  /// In en, this message translates to:
  /// **'Restore is ready. Close and reopen the app to finish.'**
  String get bkRestoreDone;

  /// No description provided for @bkCloseApp.
  ///
  /// In en, this message translates to:
  /// **'Close app'**
  String get bkCloseApp;

  /// No description provided for @bkWrongPassphrase.
  ///
  /// In en, this message translates to:
  /// **'Wrong passphrase, or the file was changed'**
  String get bkWrongPassphrase;

  /// No description provided for @bkNewerSchema.
  ///
  /// In en, this message translates to:
  /// **'This backup is from a newer version of the app. Please update the app first.'**
  String get bkNewerSchema;

  /// No description provided for @bkBadFile.
  ///
  /// In en, this message translates to:
  /// **'This is not a valid backup file'**
  String get bkBadFile;

  /// No description provided for @bkCorrupt.
  ///
  /// In en, this message translates to:
  /// **'This backup is damaged and cannot be restored'**
  String get bkCorrupt;

  /// No description provided for @bkStaleBanner.
  ///
  /// In en, this message translates to:
  /// **'Back up your data to keep it safe'**
  String get bkStaleBanner;

  /// No description provided for @onbRestore.
  ///
  /// In en, this message translates to:
  /// **'Restore from a backup'**
  String get onbRestore;

  /// No description provided for @bkWhyTitle.
  ///
  /// In en, this message translates to:
  /// **'Keep your books safe'**
  String get bkWhyTitle;

  /// No description provided for @bkWhyBody.
  ///
  /// In en, this message translates to:
  /// **'If this phone is lost or broken, a backup is the only way to get your records back. Save the file somewhere safe, like Google Drive.'**
  String get bkWhyBody;

  /// No description provided for @bioToggle.
  ///
  /// In en, this message translates to:
  /// **'Unlock with fingerprint'**
  String get bioToggle;

  /// No description provided for @bioReason.
  ///
  /// In en, this message translates to:
  /// **'Unlock Agent Khata'**
  String get bioReason;

  /// No description provided for @bioUse.
  ///
  /// In en, this message translates to:
  /// **'Use fingerprint'**
  String get bioUse;

  /// No description provided for @bioUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Fingerprint is not set up on this phone'**
  String get bioUnavailable;

  /// No description provided for @secureToggle.
  ///
  /// In en, this message translates to:
  /// **'Hide app preview and block screenshots'**
  String get secureToggle;

  /// No description provided for @textSize.
  ///
  /// In en, this message translates to:
  /// **'Text size'**
  String get textSize;

  /// No description provided for @textSizeNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get textSizeNormal;

  /// No description provided for @textSizeLarge.
  ///
  /// In en, this message translates to:
  /// **'Large'**
  String get textSizeLarge;

  /// No description provided for @textSizeXL.
  ///
  /// In en, this message translates to:
  /// **'Extra large'**
  String get textSizeXL;

  /// No description provided for @shopName.
  ///
  /// In en, this message translates to:
  /// **'Shop name'**
  String get shopName;

  /// No description provided for @shopNameNone.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get shopNameNone;

  /// No description provided for @rolloverHour.
  ///
  /// In en, this message translates to:
  /// **'Business day starts at'**
  String get rolloverHour;

  /// No description provided for @rolloverHint.
  ///
  /// In en, this message translates to:
  /// **'Sales after midnight but before this time count for the previous day.'**
  String get rolloverHint;

  /// No description provided for @categoriesTitle.
  ///
  /// In en, this message translates to:
  /// **'Expense categories'**
  String get categoriesTitle;

  /// No description provided for @categoryAdd.
  ///
  /// In en, this message translates to:
  /// **'Add category'**
  String get categoryAdd;

  /// No description provided for @categoryRename.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get categoryRename;

  /// No description provided for @categoryRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get categoryRemove;

  /// No description provided for @aboutTitle.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get aboutTitle;

  /// No description provided for @aboutVersion.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String aboutVersion(String version);

  /// No description provided for @aboutDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'Agent Khata is a record-keeping tool. It does not move money and is not an app of bKash, Nagad, Rocket, Upay or any mobile operator, and is not affiliated with them.'**
  String get aboutDisclaimer;

  /// No description provided for @aboutPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Your records stay on this phone. Nothing is sent anywhere unless you share a backup or report yourself.'**
  String get aboutPrivacy;

  /// No description provided for @analyticsToggle.
  ///
  /// In en, this message translates to:
  /// **'Share anonymous usage counts'**
  String get analyticsToggle;

  /// No description provided for @analyticsHint.
  ///
  /// In en, this message translates to:
  /// **'Only counts like \"entries saved\". Never amounts, numbers or names. Included only if you share a diagnostics report.'**
  String get analyticsHint;

  /// No description provided for @diagIntegrity.
  ///
  /// In en, this message translates to:
  /// **'Books check'**
  String get diagIntegrity;

  /// No description provided for @diagRunCheck.
  ///
  /// In en, this message translates to:
  /// **'Run check'**
  String get diagRunCheck;

  /// No description provided for @diagVerified.
  ///
  /// In en, this message translates to:
  /// **'Books verified: every entry balances'**
  String get diagVerified;

  /// No description provided for @diagProblem.
  ///
  /// In en, this message translates to:
  /// **'A problem was found in the books. Please back up and contact support.'**
  String get diagProblem;

  /// No description provided for @diagShareReport.
  ///
  /// In en, this message translates to:
  /// **'Share diagnostics report'**
  String get diagShareReport;

  /// No description provided for @diagDbSize.
  ///
  /// In en, this message translates to:
  /// **'Database size'**
  String get diagDbSize;

  /// No description provided for @diagEntries.
  ///
  /// In en, this message translates to:
  /// **'Entries'**
  String get diagEntries;

  /// No description provided for @txnDueGiven.
  ///
  /// In en, this message translates to:
  /// **'Credit given'**
  String get txnDueGiven;

  /// No description provided for @txnDueSettled.
  ///
  /// In en, this message translates to:
  /// **'Due received'**
  String get txnDueSettled;

  /// No description provided for @txnDueTaken.
  ///
  /// In en, this message translates to:
  /// **'Money held'**
  String get txnDueTaken;

  /// No description provided for @txnDuePaid.
  ///
  /// In en, this message translates to:
  /// **'Money returned'**
  String get txnDuePaid;

  /// No description provided for @txnCommissionReceived.
  ///
  /// In en, this message translates to:
  /// **'Commission received'**
  String get txnCommissionReceived;

  /// No description provided for @duesTitle.
  ///
  /// In en, this message translates to:
  /// **'Baki (dues)'**
  String get duesTitle;

  /// No description provided for @duesTheyOwe.
  ///
  /// In en, this message translates to:
  /// **'They owe me'**
  String get duesTheyOwe;

  /// No description provided for @duesIOwe.
  ///
  /// In en, this message translates to:
  /// **'I owe them'**
  String get duesIOwe;

  /// No description provided for @duesTotalTheyOwe.
  ///
  /// In en, this message translates to:
  /// **'Total to collect'**
  String get duesTotalTheyOwe;

  /// No description provided for @duesTotalIOwe.
  ///
  /// In en, this message translates to:
  /// **'Total I owe'**
  String get duesTotalIOwe;

  /// No description provided for @duesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No open dues'**
  String get duesEmpty;

  /// No description provided for @duesSearch.
  ///
  /// In en, this message translates to:
  /// **'Search name or number'**
  String get duesSearch;

  /// No description provided for @duesAdd.
  ///
  /// In en, this message translates to:
  /// **'Add baki'**
  String get duesAdd;

  /// No description provided for @duesNewTitle.
  ///
  /// In en, this message translates to:
  /// **'New baki'**
  String get duesNewTitle;

  /// No description provided for @duesDirection.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get duesDirection;

  /// No description provided for @duesName.
  ///
  /// In en, this message translates to:
  /// **'Customer name'**
  String get duesName;

  /// No description provided for @duesPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get duesPhone;

  /// No description provided for @duesNeedNameOrPhone.
  ///
  /// In en, this message translates to:
  /// **'Enter a name or a phone number'**
  String get duesNeedNameOrPhone;

  /// No description provided for @duesGaveFrom.
  ///
  /// In en, this message translates to:
  /// **'Given from'**
  String get duesGaveFrom;

  /// No description provided for @duesReceivedIn.
  ///
  /// In en, this message translates to:
  /// **'Kept in'**
  String get duesReceivedIn;

  /// No description provided for @duesNote.
  ///
  /// In en, this message translates to:
  /// **'What for (optional)'**
  String get duesNote;

  /// No description provided for @duesSaved.
  ///
  /// In en, this message translates to:
  /// **'Baki saved'**
  String get duesSaved;

  /// No description provided for @duesRemaining.
  ///
  /// In en, this message translates to:
  /// **'Remaining {amount}'**
  String duesRemaining(String amount);

  /// No description provided for @duesOriginal.
  ///
  /// In en, this message translates to:
  /// **'Original {amount}'**
  String duesOriginal(String amount);

  /// No description provided for @duesSettle.
  ///
  /// In en, this message translates to:
  /// **'Record payment'**
  String get duesSettle;

  /// No description provided for @duesSettleReturn.
  ///
  /// In en, this message translates to:
  /// **'Return money'**
  String get duesSettleReturn;

  /// No description provided for @duesSettleAll.
  ///
  /// In en, this message translates to:
  /// **'Full amount'**
  String get duesSettleAll;

  /// No description provided for @duesSettleTo.
  ///
  /// In en, this message translates to:
  /// **'Received in'**
  String get duesSettleTo;

  /// No description provided for @duesSettleFrom.
  ///
  /// In en, this message translates to:
  /// **'Paid from'**
  String get duesSettleFrom;

  /// No description provided for @duesOverSettle.
  ///
  /// In en, this message translates to:
  /// **'More than the amount due'**
  String get duesOverSettle;

  /// No description provided for @duesPayments.
  ///
  /// In en, this message translates to:
  /// **'Payments'**
  String get duesPayments;

  /// No description provided for @duesNoPayments.
  ///
  /// In en, this message translates to:
  /// **'No payments yet'**
  String get duesNoPayments;

  /// No description provided for @duesCall.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get duesCall;

  /// No description provided for @duesSms.
  ///
  /// In en, this message translates to:
  /// **'SMS'**
  String get duesSms;

  /// No description provided for @duesSettled.
  ///
  /// In en, this message translates to:
  /// **'Payment recorded'**
  String get duesSettled;

  /// No description provided for @duesFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save. Please try again.'**
  String get duesFailed;

  /// No description provided for @repTitle.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get repTitle;

  /// No description provided for @repWeek.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get repWeek;

  /// No description provided for @repMonth.
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get repMonth;

  /// No description provided for @repPrev.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get repPrev;

  /// No description provided for @repNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get repNext;

  /// No description provided for @repNetPerDay.
  ///
  /// In en, this message translates to:
  /// **'Net profit per day'**
  String get repNetPerDay;

  /// No description provided for @repByType.
  ///
  /// In en, this message translates to:
  /// **'By type'**
  String get repByType;

  /// No description provided for @repNoData.
  ///
  /// In en, this message translates to:
  /// **'No entries in this period'**
  String get repNoData;

  /// No description provided for @repVarianceTitle.
  ///
  /// In en, this message translates to:
  /// **'Day-close differences'**
  String get repVarianceTitle;

  /// No description provided for @repVarianceNone.
  ///
  /// In en, this message translates to:
  /// **'No closed days yet'**
  String get repVarianceNone;

  /// No description provided for @repVarianceHint.
  ///
  /// In en, this message translates to:
  /// **'Bars show how far the count was from the books each day'**
  String get repVarianceHint;

  /// No description provided for @repCommissionTitle.
  ///
  /// In en, this message translates to:
  /// **'Commission: expected vs received'**
  String get repCommissionTitle;

  /// No description provided for @repExpected.
  ///
  /// In en, this message translates to:
  /// **'Expected'**
  String get repExpected;

  /// No description provided for @repReceived.
  ///
  /// In en, this message translates to:
  /// **'Received'**
  String get repReceived;

  /// No description provided for @repPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get repPending;

  /// No description provided for @repRecordCommission.
  ///
  /// In en, this message translates to:
  /// **'Record commission received'**
  String get repRecordCommission;

  /// No description provided for @repExportCsv.
  ///
  /// In en, this message translates to:
  /// **'Export CSV'**
  String get repExportCsv;

  /// No description provided for @repExporting.
  ///
  /// In en, this message translates to:
  /// **'Preparing…'**
  String get repExporting;

  /// No description provided for @repExportFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not export'**
  String get repExportFailed;

  /// No description provided for @repStatementPdf.
  ///
  /// In en, this message translates to:
  /// **'Statement PDF'**
  String get repStatementPdf;

  /// No description provided for @repStatementTitle.
  ///
  /// In en, this message translates to:
  /// **'{account} statement'**
  String repStatementTitle(String account);

  /// No description provided for @repStatementPeriod.
  ///
  /// In en, this message translates to:
  /// **'{from} to {to}'**
  String repStatementPeriod(String from, String to);

  /// No description provided for @repPage.
  ///
  /// In en, this message translates to:
  /// **'Page {n} of {total}'**
  String repPage(String n, String total);

  /// No description provided for @ledgerDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get ledgerDescription;

  /// No description provided for @staffTitle.
  ///
  /// In en, this message translates to:
  /// **'Staff'**
  String get staffTitle;

  /// No description provided for @staffAdd.
  ///
  /// In en, this message translates to:
  /// **'Add staff'**
  String get staffAdd;

  /// No description provided for @staffName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get staffName;

  /// No description provided for @staffPin.
  ///
  /// In en, this message translates to:
  /// **'PIN (4 to 6 digits)'**
  String get staffPin;

  /// No description provided for @staffCanSeeProfit.
  ///
  /// In en, this message translates to:
  /// **'Can see profit and reports'**
  String get staffCanSeeProfit;

  /// No description provided for @staffCanCloseDay.
  ///
  /// In en, this message translates to:
  /// **'Can close the day'**
  String get staffCanCloseDay;

  /// No description provided for @roleOwner.
  ///
  /// In en, this message translates to:
  /// **'Owner'**
  String get roleOwner;

  /// No description provided for @roleStaff.
  ///
  /// In en, this message translates to:
  /// **'Staff'**
  String get roleStaff;

  /// No description provided for @staffInactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get staffInactive;

  /// No description provided for @staffResetPin.
  ///
  /// In en, this message translates to:
  /// **'Reset PIN'**
  String get staffResetPin;

  /// No description provided for @staffDeactivate.
  ///
  /// In en, this message translates to:
  /// **'Deactivate'**
  String get staffDeactivate;

  /// No description provided for @staffActivate.
  ///
  /// In en, this message translates to:
  /// **'Activate'**
  String get staffActivate;

  /// No description provided for @staffSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get staffSaved;

  /// No description provided for @staffPinInUse.
  ///
  /// In en, this message translates to:
  /// **'This PIN is already used. Choose another.'**
  String get staffPinInUse;

  /// No description provided for @staffBadPin.
  ///
  /// In en, this message translates to:
  /// **'The PIN must be 4 to 6 digits'**
  String get staffBadPin;

  /// No description provided for @staffNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a name'**
  String get staffNameRequired;

  /// No description provided for @staffEmpty.
  ///
  /// In en, this message translates to:
  /// **'No staff yet. Add the people who work at your counter.'**
  String get staffEmpty;

  /// No description provided for @staffInfo.
  ///
  /// In en, this message translates to:
  /// **'Each staff member signs in with their own PIN. They can add entries and see only their own entries.'**
  String get staffInfo;

  /// No description provided for @whoAreYou.
  ///
  /// In en, this message translates to:
  /// **'Who is using the app?'**
  String get whoAreYou;

  /// No description provided for @signedInAs.
  ///
  /// In en, this message translates to:
  /// **'Signed in as {name}'**
  String signedInAs(String name);

  /// No description provided for @switchUser.
  ///
  /// In en, this message translates to:
  /// **'Switch user'**
  String get switchUser;

  /// No description provided for @permDenied.
  ///
  /// In en, this message translates to:
  /// **'You do not have permission to do this'**
  String get permDenied;

  /// No description provided for @shiftCurrent.
  ///
  /// In en, this message translates to:
  /// **'Shift: {name}'**
  String shiftCurrent(String name);

  /// No description provided for @shiftSince.
  ///
  /// In en, this message translates to:
  /// **'since {time}'**
  String shiftSince(String time);

  /// No description provided for @shiftHandover.
  ///
  /// In en, this message translates to:
  /// **'Hand over'**
  String get shiftHandover;

  /// No description provided for @shiftHandoverTitle.
  ///
  /// In en, this message translates to:
  /// **'Shift handover'**
  String get shiftHandoverTitle;

  /// No description provided for @shiftHandoverIntro.
  ///
  /// In en, this message translates to:
  /// **'Count the cash and wallets before handing over. Any difference is recorded against this shift.'**
  String get shiftHandoverIntro;

  /// No description provided for @shiftDone.
  ///
  /// In en, this message translates to:
  /// **'Handover recorded'**
  String get shiftDone;

  /// No description provided for @shiftNoOpen.
  ///
  /// In en, this message translates to:
  /// **'No shift is open'**
  String get shiftNoOpen;

  /// No description provided for @shiftRecent.
  ///
  /// In en, this message translates to:
  /// **'Recent shifts'**
  String get shiftRecent;

  /// No description provided for @shiftNone.
  ///
  /// In en, this message translates to:
  /// **'No shifts yet'**
  String get shiftNone;

  /// No description provided for @shiftOpenNow.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get shiftOpenNow;

  /// No description provided for @shiftOperatorVariance.
  ///
  /// In en, this message translates to:
  /// **'Differences by operator'**
  String get shiftOperatorVariance;

  /// No description provided for @shiftShortage.
  ///
  /// In en, this message translates to:
  /// **'Short {amount}'**
  String shiftShortage(String amount);

  /// No description provided for @shiftSummaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Shift summary'**
  String get shiftSummaryTitle;

  /// No description provided for @shiftDifference.
  ///
  /// In en, this message translates to:
  /// **'Difference {amount}'**
  String shiftDifference(String amount);

  /// No description provided for @closeDayNoPermission.
  ///
  /// In en, this message translates to:
  /// **'Day close is done by the owner or by staff the owner allowed.'**
  String get closeDayNoPermission;

  /// No description provided for @reasonRequiredHere.
  ///
  /// In en, this message translates to:
  /// **'Choose a reason for each difference'**
  String get reasonRequiredHere;

  /// No description provided for @bulkTitle.
  ///
  /// In en, this message translates to:
  /// **'Bulk flexiload'**
  String get bulkTitle;

  /// No description provided for @bulkNumber.
  ///
  /// In en, this message translates to:
  /// **'Number (optional)'**
  String get bulkNumber;

  /// No description provided for @bulkAmount.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get bulkAmount;

  /// No description provided for @bulkAddRow.
  ///
  /// In en, this message translates to:
  /// **'Add row'**
  String get bulkAddRow;

  /// No description provided for @bulkPaste.
  ///
  /// In en, this message translates to:
  /// **'Paste list'**
  String get bulkPaste;

  /// No description provided for @bulkPasteHint.
  ///
  /// In en, this message translates to:
  /// **'One load per line: number and amount, like 01712345678 100'**
  String get bulkPasteHint;

  /// No description provided for @bulkPasteApply.
  ///
  /// In en, this message translates to:
  /// **'Add to list'**
  String get bulkPasteApply;

  /// No description provided for @bulkRejected.
  ///
  /// In en, this message translates to:
  /// **'{count} lines skipped'**
  String bulkRejected(String count);

  /// No description provided for @bulkTotal.
  ///
  /// In en, this message translates to:
  /// **'{count} loads · {price}'**
  String bulkTotal(String count, String price);

  /// No description provided for @bulkMargin.
  ///
  /// In en, this message translates to:
  /// **'Margin {amount}'**
  String bulkMargin(String amount);

  /// No description provided for @bulkSaveAll.
  ///
  /// In en, this message translates to:
  /// **'Save all ({count})'**
  String bulkSaveAll(String count);

  /// No description provided for @bulkSaved.
  ///
  /// In en, this message translates to:
  /// **'{count} loads saved'**
  String bulkSaved(String count);

  /// No description provided for @bulkDuplicate.
  ///
  /// In en, this message translates to:
  /// **'Same number and amount twice'**
  String get bulkDuplicate;

  /// No description provided for @bulkBadNumber.
  ///
  /// In en, this message translates to:
  /// **'Check the number'**
  String get bulkBadNumber;

  /// No description provided for @bulkLowBalance.
  ///
  /// In en, this message translates to:
  /// **'{account} balance is not enough for these loads'**
  String bulkLowBalance(String account);

  /// No description provided for @bulkEmpty.
  ///
  /// In en, this message translates to:
  /// **'Add at least one load'**
  String get bulkEmpty;

  /// No description provided for @regularsTitle.
  ///
  /// In en, this message translates to:
  /// **'Regulars'**
  String get regularsTitle;

  /// No description provided for @regularsUses.
  ///
  /// In en, this message translates to:
  /// **'{count} times'**
  String regularsUses(String count);

  /// No description provided for @rateModeTiered.
  ///
  /// In en, this message translates to:
  /// **'By amount (tiers)'**
  String get rateModeTiered;

  /// No description provided for @tierUpTo.
  ///
  /// In en, this message translates to:
  /// **'Up to'**
  String get tierUpTo;

  /// No description provided for @tierAbove.
  ///
  /// In en, this message translates to:
  /// **'Above'**
  String get tierAbove;

  /// No description provided for @tierAdd.
  ///
  /// In en, this message translates to:
  /// **'Add tier'**
  String get tierAdd;

  /// No description provided for @tierOrderProblem.
  ///
  /// In en, this message translates to:
  /// **'Amounts must increase from one tier to the next'**
  String get tierOrderProblem;

  /// No description provided for @recTitle.
  ///
  /// In en, this message translates to:
  /// **'Recurring expenses'**
  String get recTitle;

  /// No description provided for @recAdd.
  ///
  /// In en, this message translates to:
  /// **'Add recurring expense'**
  String get recAdd;

  /// No description provided for @recAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get recAmount;

  /// No description provided for @recFrequency.
  ///
  /// In en, this message translates to:
  /// **'Repeats'**
  String get recFrequency;

  /// No description provided for @recMonthly.
  ///
  /// In en, this message translates to:
  /// **'Every month'**
  String get recMonthly;

  /// No description provided for @recWeekly.
  ///
  /// In en, this message translates to:
  /// **'Every week'**
  String get recWeekly;

  /// No description provided for @recDayOfMonth.
  ///
  /// In en, this message translates to:
  /// **'Day of the month'**
  String get recDayOfMonth;

  /// No description provided for @recWeekday.
  ///
  /// In en, this message translates to:
  /// **'Day of the week'**
  String get recWeekday;

  /// No description provided for @recNextDue.
  ///
  /// In en, this message translates to:
  /// **'Next: {date}'**
  String recNextDue(String date);

  /// No description provided for @recDueBanner.
  ///
  /// In en, this message translates to:
  /// **'{count} recurring expenses are due'**
  String recDueBanner(String count);

  /// No description provided for @recRecord.
  ///
  /// In en, this message translates to:
  /// **'Record'**
  String get recRecord;

  /// No description provided for @recSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get recSkip;

  /// No description provided for @recRecorded.
  ///
  /// In en, this message translates to:
  /// **'Expense recorded'**
  String get recRecorded;

  /// No description provided for @recEmpty.
  ///
  /// In en, this message translates to:
  /// **'No recurring expenses yet. Add rent, internet and other regular costs.'**
  String get recEmpty;

  /// No description provided for @recNotifTitle.
  ///
  /// In en, this message translates to:
  /// **'Expense due'**
  String get recNotifTitle;

  /// No description provided for @recNotifBody.
  ///
  /// In en, this message translates to:
  /// **'{label}: {amount} is due today'**
  String recNotifBody(String label, String amount);

  /// No description provided for @recPaused.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get recPaused;

  /// No description provided for @recDueNow.
  ///
  /// In en, this message translates to:
  /// **'Due'**
  String get recDueNow;

  /// No description provided for @recNeedCategory.
  ///
  /// In en, this message translates to:
  /// **'Add an expense category first'**
  String get recNeedCategory;

  /// No description provided for @recEvery31.
  ///
  /// In en, this message translates to:
  /// **'Months with fewer days use the last day'**
  String get recEvery31;

  /// No description provided for @wdMon.
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get wdMon;

  /// No description provided for @wdTue.
  ///
  /// In en, this message translates to:
  /// **'Tuesday'**
  String get wdTue;

  /// No description provided for @wdWed.
  ///
  /// In en, this message translates to:
  /// **'Wednesday'**
  String get wdWed;

  /// No description provided for @wdThu.
  ///
  /// In en, this message translates to:
  /// **'Thursday'**
  String get wdThu;

  /// No description provided for @wdFri.
  ///
  /// In en, this message translates to:
  /// **'Friday'**
  String get wdFri;

  /// No description provided for @wdSat.
  ///
  /// In en, this message translates to:
  /// **'Saturday'**
  String get wdSat;

  /// No description provided for @wdSun.
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
  String get wdSun;

  /// No description provided for @sheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily sheet'**
  String get sheetTitle;

  /// No description provided for @sheetPrint.
  ///
  /// In en, this message translates to:
  /// **'Print sheet'**
  String get sheetPrint;

  /// No description provided for @sheetShare.
  ///
  /// In en, this message translates to:
  /// **'Share sheet as PDF'**
  String get sheetShare;

  /// No description provided for @sheetPreparedBy.
  ///
  /// In en, this message translates to:
  /// **'Prepared by'**
  String get sheetPreparedBy;

  /// No description provided for @sheetCheckedBy.
  ///
  /// In en, this message translates to:
  /// **'Checked by'**
  String get sheetCheckedBy;

  /// No description provided for @sheetParticulars.
  ///
  /// In en, this message translates to:
  /// **'Particulars'**
  String get sheetParticulars;

  /// No description provided for @sheetTime.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get sheetTime;

  /// No description provided for @sheetAccounts.
  ///
  /// In en, this message translates to:
  /// **'Accounts'**
  String get sheetAccounts;

  /// No description provided for @sheetSummary.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get sheetSummary;

  /// No description provided for @sheetFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not prepare the sheet'**
  String get sheetFailed;

  /// No description provided for @insTitle.
  ///
  /// In en, this message translates to:
  /// **'Insights'**
  String get insTitle;

  /// No description provided for @insNotEnough.
  ///
  /// In en, this message translates to:
  /// **'Not enough entries yet to show patterns (at least 10 needed).'**
  String get insNotEnough;

  /// No description provided for @insAvgSize.
  ///
  /// In en, this message translates to:
  /// **'Average entry'**
  String get insAvgSize;

  /// No description provided for @insEntries.
  ///
  /// In en, this message translates to:
  /// **'{count} entries'**
  String insEntries(String count);

  /// No description provided for @insBusiestHour.
  ///
  /// In en, this message translates to:
  /// **'Busiest hour'**
  String get insBusiestHour;

  /// No description provided for @insBestHour.
  ///
  /// In en, this message translates to:
  /// **'Most profitable hour'**
  String get insBestHour;

  /// No description provided for @insBestWeekday.
  ///
  /// In en, this message translates to:
  /// **'Best weekday'**
  String get insBestWeekday;

  /// No description provided for @insPerDay.
  ///
  /// In en, this message translates to:
  /// **'{amount} per day'**
  String insPerDay(String amount);

  /// No description provided for @insHourChart.
  ///
  /// In en, this message translates to:
  /// **'Entries by hour of day'**
  String get insHourChart;

  /// No description provided for @insWeekdayChart.
  ///
  /// In en, this message translates to:
  /// **'Average profit by weekday'**
  String get insWeekdayChart;

  /// No description provided for @insByType.
  ///
  /// In en, this message translates to:
  /// **'Average size by type'**
  String get insByType;

  /// No description provided for @wdMonShort.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get wdMonShort;

  /// No description provided for @wdTueShort.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get wdTueShort;

  /// No description provided for @wdWedShort.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get wdWedShort;

  /// No description provided for @wdThuShort.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get wdThuShort;

  /// No description provided for @wdFriShort.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get wdFriShort;

  /// No description provided for @wdSatShort.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get wdSatShort;

  /// No description provided for @wdSunShort.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get wdSunShort;

  /// No description provided for @repVarianceByAccount.
  ///
  /// In en, this message translates to:
  /// **'By account (last 30 closed days)'**
  String get repVarianceByAccount;

  /// No description provided for @repVarianceByWeekday.
  ///
  /// In en, this message translates to:
  /// **'Differences by weekday'**
  String get repVarianceByWeekday;

  /// No description provided for @repVarianceWeekdayHint.
  ///
  /// In en, this message translates to:
  /// **'Average difference per closed day, last 90 closed days'**
  String get repVarianceWeekdayHint;

  /// No description provided for @repVarianceWorst.
  ///
  /// In en, this message translates to:
  /// **'Short most often on {day}: {short} of {total} closed days'**
  String repVarianceWorst(String day, String short, String total);

  /// No description provided for @repVarianceNoPattern.
  ///
  /// In en, this message translates to:
  /// **'No weekday stands out yet'**
  String get repVarianceNoPattern;

  /// No description provided for @repVarianceShortOver.
  ///
  /// In en, this message translates to:
  /// **'Short {amount} on {days} days'**
  String repVarianceShortOver(String amount, String days);

  /// No description provided for @repVarianceExcessOver.
  ///
  /// In en, this message translates to:
  /// **'Excess {amount}'**
  String repVarianceExcessOver(String amount);

  /// No description provided for @repVarianceAllGood.
  ///
  /// In en, this message translates to:
  /// **'No differences'**
  String get repVarianceAllGood;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['bn', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'bn':
      return AppLocalizationsBn();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
