// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Bengali Bangla (`bn`).
class AppLocalizationsBn extends AppLocalizations {
  AppLocalizationsBn([String locale = 'bn']) : super(locale);

  @override
  String get appName => 'এজেন্ট খাতা';

  @override
  String get homeTitle => 'হোম';

  @override
  String get homePlaceholder => 'আপনার ক্যাশ বুক এখানে দেখা যাবে।';

  @override
  String get settings => 'সেটিংস';

  @override
  String get language => 'ভাষা';

  @override
  String get languageBangla => 'বাংলা';

  @override
  String get languageEnglish => 'English';

  @override
  String get digitStyle => 'সংখ্যার ধরন';

  @override
  String get digitsBangla => 'বাংলা সংখ্যা (০-৯)';

  @override
  String get digitsLatin => 'ইংরেজি সংখ্যা (0-9)';

  @override
  String get digitGrouping => 'বাংলাদেশি কমা (১,০০,০০০)';

  @override
  String get theme => 'থিম';

  @override
  String get themeLight => 'হালকা';

  @override
  String get themeDark => 'গাঢ়';

  @override
  String get themeHighContrast => 'বেশি কন্ট্রাস্ট';

  @override
  String get lockNow => 'এখনই লক করুন';

  @override
  String get sampleAmount => 'নমুনা পরিমাণ';

  @override
  String get pinSetupTitle => 'পিন সেট করুন';

  @override
  String get pinSetupSubtitle =>
      'আপনার হিসাব সুরক্ষিত রাখতে ৪ থেকে ৬ অঙ্কের পিন দিন।';

  @override
  String get pinConfirmTitle => 'পিন নিশ্চিত করুন';

  @override
  String get pinConfirmSubtitle => 'একই পিন আবার দিন।';

  @override
  String get pinMismatch => 'পিন মেলেনি। আবার চেষ্টা করুন।';

  @override
  String get pinUnlockTitle => 'পিন দিন';

  @override
  String get pinUnlockSubtitle => 'ক্যাশ বুক খুলতে আপনার পিন দিন।';

  @override
  String pinWrong(String remaining) {
    return 'ভুল পিন। বিরতির আগে আর $remaining বার চেষ্টা করা যাবে।';
  }

  @override
  String pinLockedOut(String seconds) {
    return 'অনেকবার ভুল হয়েছে। $seconds সেকেন্ড পর আবার চেষ্টা করুন।';
  }

  @override
  String get pinDelete => 'মুছুন';

  @override
  String get keypadClear => 'পরিষ্কার';

  @override
  String get diagnostics => 'ডায়াগনস্টিক্স';

  @override
  String get diagEncryption => 'ডাটাবেস এনক্রিপশন';

  @override
  String diagEncrypted(String version) {
    return 'এনক্রিপ্টেড (SQLCipher $version)';
  }

  @override
  String get diagNotEncrypted => 'এনক্রিপ্টেড নয়';

  @override
  String get diagJournal => 'জার্নাল মোড';

  @override
  String get diagSchema => 'স্কিমা ভার্সন';

  @override
  String get diagWriteBench => 'লেখার গতি';

  @override
  String get diagRunBench => 'লেখার পরীক্ষা চালান';

  @override
  String diagBenchResult(String ms) {
    return '১,০০০টি এন্ট্রি $ms মিলিসেকেন্ডে';
  }

  @override
  String get diagColdStart => 'চালু হতে প্রথম ফ্রেম পর্যন্ত';

  @override
  String diagMs(String ms) {
    return '$ms মি.সে.';
  }

  @override
  String get autoLock => 'অটো-লক';

  @override
  String get autoLockImmediately => 'সঙ্গে সঙ্গে';

  @override
  String autoLockSeconds(String seconds) {
    return '$seconds সেকেন্ড পর';
  }

  @override
  String get next => 'পরবর্তী';

  @override
  String get back => 'পেছনে';

  @override
  String get save => 'সেভ';

  @override
  String get cancel => 'বাতিল';

  @override
  String get saveAnyway => 'তবুও সেভ করুন';

  @override
  String get undo => 'ফিরিয়ে নিন';

  @override
  String get comingSoon => 'শীঘ্রই আসছে';

  @override
  String get navHome => 'হোম';

  @override
  String get navHistory => 'ইতিহাস';

  @override
  String get navCloseDay => 'দিনের হিসাব';

  @override
  String get navReports => 'রিপোর্ট';

  @override
  String get navSettings => 'সেটিংস';

  @override
  String get onbWelcomeTitle => 'এজেন্ট খাতায় স্বাগতম';

  @override
  String get onbWelcomeBody => 'প্রায় দুই মিনিটে আপনার ক্যাশ বুক সাজিয়ে নিন।';

  @override
  String get onbQuickStart => 'ডিফল্ট দিয়ে দ্রুত শুরু করুন';

  @override
  String get onbStepByStep => 'ধাপে ধাপে সেটআপ করুন';

  @override
  String get onbProvidersTitle => 'আপনি কোন কোন ওয়ালেট চালান?';

  @override
  String get onbProvidersSubtitle =>
      'যেগুলো আছে বেছে নিন। পরে আরও যোগ করা যাবে।';

  @override
  String get onbOperatorsTitle => 'ফ্লেক্সিলোড অপারেটর';

  @override
  String get onbBalancesTitle => 'শুরুর ব্যালেন্স';

  @override
  String get onbBalancesSubtitle => 'এখন যা আছে তা লিখুন।';

  @override
  String get onbCashLabel => 'ড্রয়ারে নগদ টাকা';

  @override
  String get onbRatesTitle => 'কমিশন রেট';

  @override
  String get onbRatesNotice =>
      'এগুলো শুধু নমুনা রেট। আপনার প্রোভাইডারের কাছ থেকে যাচাই করে নিন।';

  @override
  String get onbShopTitle => 'দোকানের নাম';

  @override
  String get onbShopHint => 'যেমন: রহিম টেলিকম';

  @override
  String get onbFinish => 'সেটআপ শেষ করুন';

  @override
  String get onbSaving => 'সেটআপ হচ্ছে…';

  @override
  String get onbError => 'সেটআপ শেষ করা যায়নি। আবার চেষ্টা করুন।';

  @override
  String get amountInvalid => 'সঠিক পরিমাণ লিখুন';

  @override
  String get rateModePerThousand => 'প্রতি ১,০০০ টাকায়';

  @override
  String get rateModePercent => 'শতকরা (%)';

  @override
  String get rateModeFixed => 'নির্দিষ্ট ৳';

  @override
  String get rateValue => 'মান';

  @override
  String get rateInvalid => 'রেট সঠিক নয়';

  @override
  String get rateTooHigh => 'এটি অনেক বেশি মনে হচ্ছে';

  @override
  String get rateSaved => 'রেট সেভ হয়েছে';

  @override
  String get rateEffectiveNote => 'নতুন রেট শুধু নতুন এন্ট্রিতে প্রযোজ্য হবে।';

  @override
  String get commissionRates => 'কমিশন রেট';

  @override
  String get txnCashOut => 'ক্যাশ আউট';

  @override
  String get txnCashIn => 'ক্যাশ ইন';

  @override
  String get txnFlexiload => 'ফ্লেক্সিলোড';

  @override
  String get txnFloatPurchase => 'ফ্লোট কেনা';

  @override
  String get txnExpense => 'খরচ';

  @override
  String get txnOther => 'অন্যান্য';

  @override
  String get entryWallet => 'ওয়ালেট';

  @override
  String get entryPaidFrom => 'কোথা থেকে দিলেন';

  @override
  String get entryCategory => 'খাত';

  @override
  String get entryNewCategory => 'নতুন খাত';

  @override
  String get entryCategoryName => 'খাতের নাম';

  @override
  String get entryMoreDetails => 'আরও তথ্য (ঐচ্ছিক)';

  @override
  String get entryCustomerNumber => 'গ্রাহকের নম্বর';

  @override
  String get entryNote => 'নোট';

  @override
  String get entryTrxId => 'ট্রানজেকশন আইডি';

  @override
  String entryCommission(String amount) {
    return 'কমিশন: $amount';
  }

  @override
  String entryRepeatLast(String amount) {
    return 'শেষবার: $amount';
  }

  @override
  String get entryNoWallet => 'আগে একটি ওয়ালেট যোগ করুন';

  @override
  String get entrySaved => 'সেভ হয়েছে';

  @override
  String get entryUndone => 'এন্ট্রি বাতিল হয়েছে';

  @override
  String get entrySaveFailed => 'সেভ করা যায়নি। আবার চেষ্টা করুন।';

  @override
  String warnNegative(String account) {
    return '$account শূন্যের নিচে চলে যাবে';
  }

  @override
  String get warnLargeTitle => 'বড় অঙ্কের টাকা';

  @override
  String warnLargeBody(String amount) {
    return '$amount একটি বড় অঙ্ক। সেভ করবেন?';
  }

  @override
  String get warnDuplicateTitle => 'একই এন্ট্রি হতে পারে';

  @override
  String get warnDuplicateBody =>
      'এইমাত্র একই রকম এন্ট্রি সেভ হয়েছে। আবার সেভ করবেন?';

  @override
  String get homeCash => 'নগদ';

  @override
  String get homeFlexiloadTotal => 'ফ্লেক্সিলোড';

  @override
  String get homeLow => 'কম';

  @override
  String get homeTapToReveal => 'দেখতে ট্যাপ করুন';

  @override
  String get homeToday => 'আজ';

  @override
  String get homeTodayEntries => 'এন্ট্রি';

  @override
  String get homeTodayCashIn => 'ক্যাশ ইন';

  @override
  String get homeTodayCashOut => 'ক্যাশ আউট';

  @override
  String get homeTodayCommission => 'কমিশন';

  @override
  String get homeRecent => 'শেষ ৫টি এন্ট্রি';

  @override
  String get homeNoEntries =>
      'এখনও কোনো এন্ট্রি নেই। শুরু করতে উপরের বোতামে ট্যাপ করুন।';

  @override
  String get maskBalances => 'ট্যাপ না করা পর্যন্ত ব্যালেন্স লুকান';

  @override
  String get largeAmountWarning => 'এই অঙ্ক থেকে সতর্ক করুন';

  @override
  String get catRent => 'ভাড়া';

  @override
  String get catElectricity => 'বিদ্যুৎ বিল';

  @override
  String get catTransport => 'যাতায়াত';

  @override
  String get catStaffPay => 'কর্মচারীর বেতন';

  @override
  String get catTea => 'চা-নাস্তা';

  @override
  String get catOther => 'অন্যান্য';

  @override
  String get histToday => 'আজ';

  @override
  String get histYesterday => 'গতকাল';

  @override
  String get histWeek => 'সপ্তাহ';

  @override
  String get histMonth => 'মাস';

  @override
  String get histAll => 'সব';

  @override
  String get histSearchHint => 'পরিমাণ, নম্বর, নোট, TrxID দিয়ে খুঁজুন';

  @override
  String get histEmpty => 'কিছু পাওয়া যায়নি';

  @override
  String histCount(String count) {
    return '$countটি এন্ট্রি';
  }

  @override
  String histTotal(String amount) {
    return 'মোট $amount';
  }

  @override
  String get histLoadMore => 'আরও দেখুন';

  @override
  String get histAccountFilter => 'অ্যাকাউন্ট';

  @override
  String get histAllAccounts => 'সব অ্যাকাউন্ট';

  @override
  String get histClearFilters => 'ফিল্টার মুছুন';

  @override
  String get labelVoided => 'বাতিল';

  @override
  String get labelLocked => 'দিন বন্ধ';

  @override
  String get detailTitle => 'এন্ট্রির বিবরণ';

  @override
  String get detailAmount => 'পরিমাণ';

  @override
  String get detailCharge => 'চার্জ';

  @override
  String get detailCommission => 'কমিশন';

  @override
  String detailRule(String rule) {
    return 'ব্যবহৃত রেট: $rule';
  }

  @override
  String get detailWhen => 'সময়';

  @override
  String get detailRecorded => 'এন্ট্রির সময়';

  @override
  String get detailBy => 'যিনি এন্ট্রি করেছেন';

  @override
  String get detailAccounts => 'অ্যাকাউন্ট';

  @override
  String get detailAudit => 'পরিবর্তনের ইতিহাস';

  @override
  String get detailReplaces => 'এই এন্ট্রি আগের একটি এন্ট্রির জায়গায় এসেছে';

  @override
  String get detailReplacedBy => 'নতুন একটি এন্ট্রি দিয়ে বদলানো হয়েছে';

  @override
  String get detailVoid => 'এন্ট্রি বাতিল করুন';

  @override
  String get detailEdit => 'সম্পাদনা';

  @override
  String get detailVoidReason => 'কারণ';

  @override
  String get detailVoidConfirm => 'বাতিল করুন';

  @override
  String detailVoidedBecause(String reason) {
    return 'বাতিল: $reason';
  }

  @override
  String get detailLockedHint =>
      'এই দিনের হিসাব বন্ধ, তাই এন্ট্রি বদলানো যাবে না।';

  @override
  String get detailActionFailed => 'কাজটি সম্পন্ন করা যায়নি।';

  @override
  String ledgerTitle(String account) {
    return '$account এর খতিয়ান';
  }

  @override
  String get ledgerDate => 'তারিখ';

  @override
  String get ledgerIn => 'জমা';

  @override
  String get ledgerOut => 'খরচ';

  @override
  String get ledgerBalance => 'ব্যালেন্স';

  @override
  String get ledgerAdjust => 'ব্যালেন্স সমন্বয়';

  @override
  String get ledgerEmpty => 'এই সময়ে কোনো এন্ট্রি নেই';

  @override
  String get adjTitle => 'ব্যালেন্স সমন্বয়';

  @override
  String get adjIncrease => 'বাড়ান';

  @override
  String get adjDecrease => 'কমান';

  @override
  String get adjReason => 'কারণ (আবশ্যক)';

  @override
  String adjCurrent(String amount) {
    return 'বর্তমান ব্যালেন্স: $amount';
  }

  @override
  String adjNew(String amount) {
    return 'নতুন ব্যালেন্স: $amount';
  }

  @override
  String get lowTitle => 'কম ব্যালেন্সের সতর্কতা';

  @override
  String get lowSubtitle =>
      'অ্যাকাউন্ট এই অঙ্কে নামলে সতর্ক করুন। সতর্কতা না চাইলে খালি রাখুন।';

  @override
  String lowBanner(String accounts) {
    return 'ব্যালেন্স কম: $accounts';
  }

  @override
  String get rememberCustomers => 'গ্রাহক মনে রাখুন';

  @override
  String get rememberCustomersHint =>
      'আগে লেখা নম্বর ও নাম সাজেস্ট করবে। শুধু এই ফোনে থাকবে।';

  @override
  String get entryCustomerName => 'গ্রাহকের নাম';

  @override
  String get entryOperator => 'অপারেটর';

  @override
  String entryMargin(String amount) {
    return 'লাভ: $amount';
  }

  @override
  String get entryPaidAmount => 'যত টাকা দিয়েছেন (আলাদা হলে)';

  @override
  String get entryEditTitle => 'এন্ট্রি সম্পাদনা';

  @override
  String get entryNoOperator => 'আগে একটি ফ্লেক্সিলোড অপারেটর যোগ করুন';

  @override
  String get cdTitle => 'দিনের হিসাব মিলান';

  @override
  String get cdIntro =>
      'নগদ ও ওয়ালেটের ব্যালেন্স গুনে লিখুন। কোথায় গরমিল হতে পারে আমরা দেখিয়ে দেব।';

  @override
  String get cdExpected => 'খাতা অনুযায়ী';

  @override
  String get cdActual => 'গুনে পাওয়া';

  @override
  String get cdBlankHint => 'মিললে খালি রাখুন';

  @override
  String get cdCashCounter => 'নোট গুনুন';

  @override
  String get cdCashCounterTitle => 'ক্যাশ কাউন্টার';

  @override
  String get cdCounterTotal => 'মোট';

  @override
  String get cdCounterUse => 'এই মোট ব্যবহার করুন';

  @override
  String get cdCoins => 'খুচরা';

  @override
  String get cdReview => 'যাচাই করুন';

  @override
  String get cdMatches => 'মিলেছে';

  @override
  String cdShort(String amount) {
    return '$amount কম';
  }

  @override
  String cdExcess(String amount) {
    return '$amount বেশি';
  }

  @override
  String get cdReason => 'কারণ';

  @override
  String get cdReasonNote => 'নোট (ঐচ্ছিক)';

  @override
  String get cdReasonShortage => 'ঘাটতি';

  @override
  String get cdReasonExcess => 'বাড়তি';

  @override
  String get cdReasonProvider => 'প্রোভাইডার চার্জ';

  @override
  String get cdReasonCounting => 'গণনায় ভুল';

  @override
  String get cdReasonTolerance => 'সামান্য পার্থক্য';

  @override
  String get cdReasonOther => 'অন্যান্য';

  @override
  String get cdFindGap => 'কোথায় হতে পারে?';

  @override
  String get cdAddMissing => 'বাদ পড়া এন্ট্রি যোগ করুন';

  @override
  String get cdClose => 'দিন বন্ধ করুন';

  @override
  String get cdClosedOk => 'দিন বন্ধ হয়েছে';

  @override
  String cdTolerance(String amount) {
    return '$amount পর্যন্ত পার্থক্য নিজে থেকে সমন্বয় হবে';
  }

  @override
  String get cdMissingReason => 'প্রতিটি পার্থক্যের জন্য কারণ বেছে নিন';

  @override
  String get cdAlreadyClosed => 'এই দিন আগেই বন্ধ হয়েছে';

  @override
  String get cdFailed => 'দিন বন্ধ করা যায়নি। আবার চেষ্টা করুন।';

  @override
  String get cdReopen => 'আবার খুলুন';

  @override
  String get cdReopenTitle => 'এই দিন আবার খুলবেন?';

  @override
  String get cdReopenBody => 'বন্ধ করার সময়ের সমন্বয় বাতিল হবে। কারণ লিখুন।';

  @override
  String get cdReopened => 'দিন আবার খোলা হয়েছে';

  @override
  String get cdLaterClosed => 'শুধু সবশেষ বন্ধ করা দিনটি আবার খোলা যায়';

  @override
  String get cdRecentDays => 'সাম্প্রতিক দিন';

  @override
  String get cdNoDays => 'এখনও কোনো দিন বন্ধ হয়নি';

  @override
  String get cdStatusClosed => 'বন্ধ';

  @override
  String get cdStatusReopened => 'আবার খোলা';

  @override
  String get cdStatusOpen => 'চলমান';

  @override
  String get cdPickDay => 'কোন দিন?';

  @override
  String get cdYesterdayOpen => 'গতকালের হিসাব মেলানো হয়নি';

  @override
  String cdDifference(String amount) {
    return 'পার্থক্য $amount';
  }

  @override
  String sugSameSame(String amount) {
    return '$amount-এর একটি এন্ট্রি গরমিলের সমান। একই রকম আরেকটি এন্ট্রি বাদ পড়তে পারে।';
  }

  @override
  String sugSameOpposite(String amount) {
    return '$amount-এর একটি এন্ট্রি গরমিলের সমান। এটি দুইবার লেখা হতে পারে বা আসলে হয়নি।';
  }

  @override
  String sugFlipped(String amount) {
    return '$amount-এর এন্ট্রিটি উল্টো দিকে (ইন/আউট) লেখা হতে পারে।';
  }

  @override
  String sugEntryDouble(String amount) {
    return '$amount-এর এন্ট্রি গরমিলের দ্বিগুণ। পরিমাণ ভুল লেখা হতে পারে।';
  }

  @override
  String sugGapDouble(String amount) {
    return 'গরমিল $amount-এর এন্ট্রির দ্বিগুণ। দুইবার ধরা হতে পারে।';
  }

  @override
  String sugDuplicate(String amount) {
    return 'কয়েক মিনিটের মধ্যে $amount-এর দুটি এন্ট্রি আছে। একটি ডুপ্লিকেট হতে পারে।';
  }

  @override
  String sugTranspose(String amount, String alt) {
    return '$alt-এর বদলে $amount লেখা হতে পারে (অঙ্ক উল্টে গেছে)।';
  }

  @override
  String sugCross(String other) {
    return '$other-এ উল্টো পরিমাণ গরমিল। এন্ট্রি ভুল ওয়ালেটে হতে পারে।';
  }

  @override
  String get sumTitle => 'দৈনিক সারাংশ';

  @override
  String get sumEntries => 'এন্ট্রি';

  @override
  String get sumCashInVolume => 'ক্যাশ ইন মোট';

  @override
  String get sumCashOutVolume => 'ক্যাশ আউট মোট';

  @override
  String get sumCommission => 'কমিশন';

  @override
  String get sumMargin => 'ফ্লেক্সিলোড লাভ';

  @override
  String get sumExpenses => 'খরচ';

  @override
  String get sumNet => 'নিট লাভ';

  @override
  String get sumVariance => 'পার্থক্য';

  @override
  String get sumNotClosed => 'এখনও বন্ধ হয়নি';

  @override
  String get sumOpening => 'শুরু';

  @override
  String get sumIn => 'জমা';

  @override
  String get sumOut => 'খরচ';

  @override
  String get sumShareImage => 'ছবি শেয়ার করুন';

  @override
  String get sumSharePdf => 'PDF শেয়ার করুন';

  @override
  String get sumShareFailed => 'সারাংশ শেয়ার করা যায়নি';

  @override
  String get notifCloseTitle => 'দিনের হিসাব মেলানোর সময়';

  @override
  String get notifCloseBody => 'নগদ ও ওয়ালেট গুনে আজকের হিসাব মিলিয়ে নিন।';

  @override
  String get notifLowTitle => 'ব্যালেন্স কম';

  @override
  String notifLowBody(String account) {
    return '$account কমে আসছে।';
  }

  @override
  String get settingsReminder => 'দিনের হিসাব মেলানোর রিমাইন্ডার';

  @override
  String get settingsReminderTime => 'রিমাইন্ডারের সময়';

  @override
  String get settingsTolerance => 'এই অঙ্ক পর্যন্ত পার্থক্য উপেক্ষা করুন';

  @override
  String get entryDayClosed =>
      'এই দিনের হিসাব বন্ধ। এন্ট্রি যোগ করতে ‘দিনের হিসাব’ থেকে আবার খুলুন।';

  @override
  String get bkTitle => 'ব্যাকআপ ও রিস্টোর';

  @override
  String bkLast(String date) {
    return 'শেষ ব্যাকআপ: $date';
  }

  @override
  String get bkNever => 'এখনও ব্যাকআপ নেওয়া হয়নি';

  @override
  String get bkNow => 'এখনই ব্যাকআপ নিন';

  @override
  String get bkRestore => 'ব্যাকআপ ফাইল থেকে রিস্টোর করুন';

  @override
  String get bkPassphrase => 'ব্যাকআপের পাসফ্রেজ';

  @override
  String get bkPassphraseConfirm => 'পাসফ্রেজ আবার লিখুন';

  @override
  String get bkPassphraseWarn =>
      'এই পাসফ্রেজ ভুলে গেলে ব্যাকআপ খোলা যাবে না। এটি ফিরে পাওয়ার কোনো উপায় নেই।';

  @override
  String get bkMismatch => 'পাসফ্রেজ দুটি মেলেনি';

  @override
  String get bkTooShort => 'কমপক্ষে ৬টি অক্ষর দিন';

  @override
  String get bkCreating => 'ব্যাকআপ তৈরি হচ্ছে…';

  @override
  String get bkShareText => 'এজেন্ট খাতা ব্যাকআপ';

  @override
  String get bkDone => 'ব্যাকআপ তৈরি হয়েছে';

  @override
  String get bkFailed => 'ব্যাকআপ তৈরি করা যায়নি';

  @override
  String bkRestoreInfo(String date) {
    return '$date-এ নেওয়া ব্যাকআপ';
  }

  @override
  String get bkRestoreConfirmTitle => 'এই ফোনের ডাটা বদলে ফেলবেন?';

  @override
  String get bkRestoreConfirmBody =>
      'বর্তমান সব ডাটা এই ব্যাকআপ দিয়ে বদলে যাবে। বর্তমান ডাটার একটি কপি ফোনে রাখা হবে।';

  @override
  String get bkRestoreWorking => 'রিস্টোর হচ্ছে…';

  @override
  String get bkRestoreDone =>
      'রিস্টোর প্রস্তুত। শেষ করতে অ্যাপ বন্ধ করে আবার খুলুন।';

  @override
  String get bkCloseApp => 'অ্যাপ বন্ধ করুন';

  @override
  String get bkWrongPassphrase => 'পাসফ্রেজ ভুল, অথবা ফাইল বদলে গেছে';

  @override
  String get bkNewerSchema =>
      'এই ব্যাকআপ অ্যাপের নতুন ভার্সনের। আগে অ্যাপ আপডেট করুন।';

  @override
  String get bkBadFile => 'এটি সঠিক ব্যাকআপ ফাইল নয়';

  @override
  String get bkCorrupt => 'এই ব্যাকআপ নষ্ট, রিস্টোর করা যাবে না';

  @override
  String get bkStaleBanner => 'ডাটা নিরাপদ রাখতে ব্যাকআপ নিন';

  @override
  String get onbRestore => 'ব্যাকআপ থেকে রিস্টোর করুন';

  @override
  String get bkWhyTitle => 'আপনার হিসাব নিরাপদ রাখুন';

  @override
  String get bkWhyBody =>
      'ফোন হারালে বা নষ্ট হলে ব্যাকআপই একমাত্র ভরসা। ফাইলটি Google Drive-এর মতো নিরাপদ জায়গায় রাখুন।';

  @override
  String get bioToggle => 'আঙুলের ছাপ দিয়ে আনলক';

  @override
  String get bioReason => 'এজেন্ট খাতা আনলক করুন';

  @override
  String get bioUse => 'আঙুলের ছাপ ব্যবহার করুন';

  @override
  String get bioUnavailable => 'এই ফোনে আঙুলের ছাপ সেট করা নেই';

  @override
  String get secureToggle => 'অ্যাপের প্রিভিউ লুকান ও স্ক্রিনশট বন্ধ রাখুন';

  @override
  String get textSize => 'লেখার আকার';

  @override
  String get textSizeNormal => 'স্বাভাবিক';

  @override
  String get textSizeLarge => 'বড়';

  @override
  String get textSizeXL => 'আরও বড়';

  @override
  String get shopName => 'দোকানের নাম';

  @override
  String get shopNameNone => 'দেওয়া হয়নি';

  @override
  String get rolloverHour => 'ব্যবসায়িক দিন শুরু হয়';

  @override
  String get rolloverHint =>
      'মধ্যরাতের পর এই সময়ের আগের বিক্রি আগের দিনের হিসাবে ধরা হবে।';

  @override
  String get categoriesTitle => 'খরচের খাত';

  @override
  String get categoryAdd => 'খাত যোগ করুন';

  @override
  String get categoryRename => 'নাম বদলান';

  @override
  String get categoryRemove => 'সরান';

  @override
  String get aboutTitle => 'অ্যাপ সম্পর্কে';

  @override
  String aboutVersion(String version) {
    return 'ভার্সন $version';
  }

  @override
  String get aboutDisclaimer =>
      'এজেন্ট খাতা শুধু হিসাব রাখার অ্যাপ। এটি টাকা লেনদেন করে না এবং বিকাশ, নগদ, রকেট, উপায় বা কোনো মোবাইল অপারেটরের অ্যাপ নয়, তাদের সাথে সম্পর্কিতও নয়।';

  @override
  String get aboutPrivacy =>
      'আপনার হিসাব এই ফোনেই থাকে। আপনি নিজে ব্যাকআপ বা রিপোর্ট শেয়ার না করলে কিছুই কোথাও যায় না।';

  @override
  String get analyticsToggle => 'নাম-পরিচয়হীন ব্যবহারের হিসাব শেয়ার করুন';

  @override
  String get analyticsHint =>
      'শুধু “এন্ট্রি সেভ” এর মতো সংখ্যা। কখনও টাকার অঙ্ক, নম্বর বা নাম নয়। ডায়াগনস্টিক্স রিপোর্ট শেয়ার করলেই কেবল যাবে।';

  @override
  String get diagIntegrity => 'হিসাব যাচাই';

  @override
  String get diagRunCheck => 'যাচাই করুন';

  @override
  String get diagVerified => 'হিসাব যাচাই হয়েছে: সব এন্ট্রি মিলেছে';

  @override
  String get diagProblem =>
      'হিসাবে সমস্যা পাওয়া গেছে। ব্যাকআপ নিয়ে সাপোর্টের সাথে যোগাযোগ করুন।';

  @override
  String get diagShareReport => 'ডায়াগনস্টিক্স রিপোর্ট শেয়ার করুন';

  @override
  String get diagDbSize => 'ডাটাবেসের আকার';

  @override
  String get diagEntries => 'এন্ট্রি';
}
