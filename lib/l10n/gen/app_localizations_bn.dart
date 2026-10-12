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
}
