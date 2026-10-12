import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/ledger/account.dart';
import '../../core/ledger/account_kind.dart';
import '../../core/ledger/transaction_type.dart';
import '../../core/money/money.dart';
import '../../core/providers.dart';
import '../transactions/quick_amounts.dart';

/// Expense category accounts.
final expenseAccountsProvider = StreamProvider<List<Account>>(
  (ref) =>
      ref.watch(accountRepositoryProvider).watchByKind(AccountKind.expense),
);

class QuickAmounts {
  const QuickAmounts({required this.chips, this.last});

  final List<Money> chips;
  final Money? last;
}

/// Chips learned from the user's own habits, topped up with defaults.
final quickAmountsProvider = FutureProvider.autoDispose
    .family<QuickAmounts, TransactionType>((ref, type) async {
      final q = ref.watch(transactionQueriesProvider);
      final learned = await q.frequentAmounts(type);
      final last = await q.lastAmount(type);
      return QuickAmounts(chips: mergeQuickAmounts(learned), last: last);
    });
