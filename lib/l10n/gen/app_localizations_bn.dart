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
}
