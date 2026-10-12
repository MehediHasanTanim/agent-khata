import '../../core/ledger/account_kind.dart';
import '../../core/ledger/transaction_type.dart';
import '../commission/commission_rule.dart';

/// A starting-point rate. These are **sample values, not official rates**:
/// providers change them and they differ by agent tier, so the user must
/// confirm them during setup.
class SampleRate {
  const SampleRate(this.type, this.mode, this.value);

  final TransactionType type;
  final CommissionMode mode;

  /// Hundredths of the displayed unit; see `RateCodec`.
  final int value;
}

class ProviderInfo {
  const ProviderInfo({
    required this.id,
    required this.nameEn,
    required this.nameBn,
    required this.kind,
    required this.sampleRates,
  });

  /// Stable id stored in `account.provider` and `commission_rule.provider`.
  final String id;
  final String nameEn;
  final String nameBn;
  final AccountKind kind;
  final List<SampleRate> sampleRates;

  String name(String languageCode) => languageCode == 'bn' ? nameBn : nameEn;

  /// Transaction types that earn commission through this provider.
  List<TransactionType> get rateTypes => kind == AccountKind.wallet
      ? const [TransactionType.cashOut, TransactionType.cashIn]
      : const [TransactionType.flexiload];
}

const _walletRates = [
  SampleRate(TransactionType.cashOut, CommissionMode.perThousand, 400),
];
const _loadRates = [
  SampleRate(TransactionType.flexiload, CommissionMode.percent, 250),
];

class ProviderCatalog {
  const ProviderCatalog._();

  static const wallets = [
    ProviderInfo(
      id: 'bkash',
      nameEn: 'bKash',
      nameBn: 'বিকাশ',
      kind: AccountKind.wallet,
      sampleRates: _walletRates,
    ),
    ProviderInfo(
      id: 'nagad',
      nameEn: 'Nagad',
      nameBn: 'নগদ',
      kind: AccountKind.wallet,
      sampleRates: _walletRates,
    ),
    ProviderInfo(
      id: 'rocket',
      nameEn: 'Rocket',
      nameBn: 'রকেট',
      kind: AccountKind.wallet,
      sampleRates: _walletRates,
    ),
    ProviderInfo(
      id: 'upay',
      nameEn: 'Upay',
      nameBn: 'উপায়',
      kind: AccountKind.wallet,
      sampleRates: _walletRates,
    ),
  ];

  static const operators = [
    ProviderInfo(
      id: 'gp',
      nameEn: 'Grameenphone',
      nameBn: 'গ্রামীণফোন',
      kind: AccountKind.load,
      sampleRates: _loadRates,
    ),
    ProviderInfo(
      id: 'robi',
      nameEn: 'Robi',
      nameBn: 'রবি',
      kind: AccountKind.load,
      sampleRates: _loadRates,
    ),
    ProviderInfo(
      id: 'banglalink',
      nameEn: 'Banglalink',
      nameBn: 'বাংলালিংক',
      kind: AccountKind.load,
      sampleRates: _loadRates,
    ),
    ProviderInfo(
      id: 'airtel',
      nameEn: 'Airtel',
      nameBn: 'এয়ারটেল',
      kind: AccountKind.load,
      sampleRates: _loadRates,
    ),
    ProviderInfo(
      id: 'teletalk',
      nameEn: 'Teletalk',
      nameBn: 'টেলিটক',
      kind: AccountKind.load,
      sampleRates: _loadRates,
    ),
  ];

  static const all = [...wallets, ...operators];

  static ProviderInfo? byId(String id) {
    for (final p in all) {
      if (p.id == id) return p;
    }
    return null;
  }

  /// Providers pre-selected by "quick start".
  static const quickStartIds = ['bkash', 'nagad'];
}
