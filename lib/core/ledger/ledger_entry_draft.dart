/// One signed posting to an account. Entries of a transaction sum to zero.
class LedgerEntryDraft {
  const LedgerEntryDraft({required this.accountId, required this.deltaPaisa});

  final String accountId;
  final int deltaPaisa;

  @override
  String toString() => 'LedgerEntryDraft($accountId, $deltaPaisa)';
}
