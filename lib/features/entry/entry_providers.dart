import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/ledger/account.dart';
import '../../core/ledger/account_kind.dart';
import '../../core/ledger/transaction_type.dart';
import '../../core/money/money.dart';
import '../../core/providers.dart';
import '../../core/security/roles.dart';
import '../transactions/quick_amounts.dart';
import '../transactions/transaction_queries.dart';

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

/// Numbers served repeatedly. Shown only when the agent has opted in to
/// remembering customers; staff see only the numbers they served
/// themselves.
final regularsProvider = FutureProvider.autoDispose
    .family<List<RegularCustomer>, TransactionType?>((ref, type) async {
      if (!ref.watch(preferencesProvider).rememberCustomers) return const [];
      final session = ref.watch(sessionProvider);
      final own =
          session != null &&
              !Permissions.can(session, Permission.viewAllHistory)
          ? session.id
          : null;
      return ref
          .watch(transactionQueriesProvider)
          .regulars(type: type, createdBy: own, limit: 6);
    });
