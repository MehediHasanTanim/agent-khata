import '../money/money.dart';
import 'account_kind.dart';

/// Domain view of an account (no balance; balances are derived).
class Account {
  const Account({
    required this.id,
    required this.kind,
    required this.label,
    this.provider,
    this.number,
    this.opening = Money.zero,
    this.lowAlert,
    this.isActive = true,
    this.sortOrder = 0,
  });

  final String id;
  final AccountKind kind;
  final String label;

  /// `bkash`, `nagad`, `rocket`, `gp`, ... Null for cash and system accounts.
  final String? provider;
  final String? number;
  final Money opening;
  final Money? lowAlert;
  final bool isActive;
  final int sortOrder;
}

/// Account lookup used by posting strategies. Kept as an interface so the
/// domain stays free of database code.
abstract class AccountResolver {
  Account? find(String id);

  /// Id of the hidden counter-account (kind [AccountKind.external]).
  String get externalAccountId;
}

/// Fixed id of the system external account.
const kExternalAccountId = 'sys-external';

class MapAccountResolver implements AccountResolver {
  MapAccountResolver(Iterable<Account> accounts)
    : _byId = {for (final a in accounts) a.id: a};

  final Map<String, Account> _byId;

  @override
  Account? find(String id) => _byId[id];

  @override
  String get externalAccountId => kExternalAccountId;
}
