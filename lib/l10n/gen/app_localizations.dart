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
