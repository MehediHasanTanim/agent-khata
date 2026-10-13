import '../../core/ledger/transaction_type.dart';
import '../../core/money/money.dart';
import '../../core/money/money_formatter.dart';
import '../closeday/day_close_service.dart';
import 'daily_sheet_queries.dart';

/// All the words on the printed sheet, so the builder stays free of
/// Flutter and localization.
class SheetLabels {
  const SheetLabels({
    required this.title,
    required this.status,
    required this.time,
    required this.particulars,
    required this.moneyIn,
    required this.moneyOut,
    required this.balance,
    required this.opening,
    required this.closing,
    required this.walletsHeading,
    required this.expected,
    required this.actual,
    required this.difference,
    required this.summaryHeading,
    required this.entries,
    required this.cashInTotal,
    required this.cashOutTotal,
    required this.commission,
    required this.margin,
    required this.expenses,
    required this.netProfit,
    required this.preparedBy,
    required this.checkedBy,
    required this.voided,
    required this.typeLabel,
    required this.pageOf,
    required this.numberText,
  });

  final String title;
  final String status;
  final String time;
  final String particulars;
  final String moneyIn;
  final String moneyOut;
  final String balance;
  final String opening;
  final String closing;
  final String walletsHeading;
  final String expected;
  final String actual;
  final String difference;
  final String summaryHeading;
  final String entries;
  final String cashInTotal;
  final String cashOutTotal;
  final String commission;
  final String margin;
  final String expenses;
  final String netProfit;
  final String preparedBy;
  final String checkedBy;
  final String voided;
  final String Function(TransactionType) typeLabel;
  final String Function(int page, int total) pageOf;

  /// Formats a plain integer (entry counts) in the user's digit style.
  final String Function(int) numberText;
}

class SheetRow {
  const SheetRow(this.cells, {this.isVoid = false, this.isBold = false});

  final List<String> cells;
  final bool isVoid;
  final bool isBold;
}

/// What one printed page contains. A page may hold part of the cash ledger,
/// and the last page also holds the wallets table, the summary and the
/// signature lines.
class SheetPage {
  const SheetPage({
    required this.title,
    required this.status,
    required this.ledgerHeader,
    required this.ledgerRows,
    required this.footer,
    this.walletsHeading,
    this.walletHeader = const [],
    this.walletRows = const [],
    this.summaryHeading,
    this.summary = const [],
    this.signatures = const [],
  });

  final String title;
  final String status;
  final List<String> ledgerHeader;
  final List<SheetRow> ledgerRows;
  final String footer;

  final String? walletsHeading;
  final List<String> walletHeader;
  final List<SheetRow> walletRows;
  final String? summaryHeading;
  final List<(String, String)> summary;
  final List<String> signatures;

  bool get hasFinalSection => summaryHeading != null;
}

class DailySheetBuilder {
  const DailySheetBuilder({this.rowsFirstPage = 27, this.rowsOtherPage = 27});

  /// Row slots on the first page after the title block and table header.
  /// The renderer draws the same title block on every page, so both defaults
  /// match.
  final int rowsFirstPage;

  /// Row slots on later pages.
  final int rowsOtherPage;

  /// Builds the pages. [money] should show no currency symbol (the column
  /// headings carry the unit). [showProfit] hides commission, margin and net
  /// profit for users who may not see them.
  List<SheetPage> build({
    required DailySummaryData summary,
    required CashSheetData? cash,
    required MoneyFormatter money,
    required String Function(DateTime) timeText,
    required String dateText,
    required String shopName,
    required SheetLabels labels,
    required bool showProfit,
  }) {
    final title = shopName.trim().isEmpty
        ? '${labels.title} · $dateText'
        : '${shopName.trim()} · $dateText';

    // --- cash ledger rows (opening, entries, closing totals) -------------
    final rows = <SheetRow>[];
    if (cash != null) {
      var inSum = Money.zero;
      var outSum = Money.zero;
      rows.add(
        SheetRow([
          '',
          labels.opening,
          '',
          '',
          money.format(cash.opening),
        ], isBold: true),
      );
      for (final l in cash.lines) {
        if (!l.isVoid) {
          if (l.delta.isPositive) inSum += l.delta;
          if (l.delta.isNegative) outSum += l.delta.abs();
        }
        final particulars = [
          labels.typeLabel(l.type),
          if (l.counterparty != null) l.counterparty!,
          if (l.customerNumber != null) l.customerNumber!,
          if (l.note != null) l.note!,
          if (l.isVoid) labels.voided,
        ].join(' · ');
        rows.add(
          SheetRow([
            timeText(l.occurredAt),
            particulars,
            l.delta.isPositive ? money.format(l.delta) : '',
            l.delta.isNegative ? money.format(l.delta.abs()) : '',
            l.isVoid ? '' : money.format(l.balance),
          ], isVoid: l.isVoid),
        );
      }
      rows.add(
        SheetRow([
          '',
          labels.closing,
          money.format(inSum),
          money.format(outSum),
          money.format(cash.closing),
        ], isBold: true),
      );
    }

    // --- wallets and operators ------------------------------------------
    final walletRows = [
      for (final a in summary.accounts)
        SheetRow([
          a.label,
          money.format(a.opening),
          money.format(a.moneyIn),
          money.format(a.moneyOut),
          money.format(a.expected),
          a.actual == null ? '-' : money.format(a.actual!),
        ]),
    ];

    // --- day summary ------------------------------------------------------
    final summaryLines = <(String, String)>[
      (labels.entries, labels.numberText(summary.count)),
      (labels.cashInTotal, money.format(summary.cashInVolume)),
      (labels.cashOutTotal, money.format(summary.cashOutVolume)),
      if (showProfit) ...[
        (labels.commission, money.format(summary.commission)),
        (labels.margin, money.format(summary.flexiloadMargin)),
      ],
      (labels.expenses, money.format(summary.expenses)),
      if (showProfit) (labels.netProfit, money.format(summary.netProfit)),
      if (summary.totalVariance != null)
        (labels.difference, money.format(summary.totalVariance!)),
    ];

    // --- pagination -------------------------------------------------------
    final chunks = <List<SheetRow>>[];
    var i = 0;
    var capacity = rowsFirstPage;
    while (i < rows.length) {
      final end = i + capacity > rows.length ? rows.length : i + capacity;
      chunks.add(rows.sublist(i, end));
      i = end;
      capacity = rowsOtherPage;
    }
    if (chunks.isEmpty) chunks.add(const []);

    // Slots the final section needs: wallets (heading + header + rows),
    // summary (heading + lines) and the signature block.
    final finalSlots = 2 + walletRows.length + 1 + summaryLines.length + 4;
    final lastCapacity = chunks.length == 1 ? rowsFirstPage : rowsOtherPage;
    final fitsOnLast = chunks.last.length + finalSlots <= lastCapacity;
    final total = fitsOnLast ? chunks.length : chunks.length + 1;

    final walletHeader = [
      labels.walletsHeading,
      labels.opening,
      labels.moneyIn,
      labels.moneyOut,
      labels.expected,
      labels.actual,
    ];
    final ledgerHeader = [
      labels.time,
      labels.particulars,
      labels.moneyIn,
      labels.moneyOut,
      labels.balance,
    ];

    SheetPage page(int index, List<SheetRow> ledger, {required bool fin}) =>
        SheetPage(
          title: title,
          status: labels.status,
          ledgerHeader: ledgerHeader,
          ledgerRows: ledger,
          footer: labels.pageOf(index + 1, total),
          walletsHeading: fin ? labels.walletsHeading : null,
          walletHeader: fin ? walletHeader : const [],
          walletRows: fin ? walletRows : const [],
          summaryHeading: fin ? labels.summaryHeading : null,
          summary: fin ? summaryLines : const [],
          signatures: fin ? [labels.preparedBy, labels.checkedBy] : const [],
        );

    final pages = <SheetPage>[];
    for (var c = 0; c < chunks.length; c++) {
      pages.add(page(c, chunks[c], fin: fitsOnLast && c == chunks.length - 1));
    }
    if (!fitsOnLast) pages.add(page(chunks.length, const [], fin: true));
    return pages;
  }
}
