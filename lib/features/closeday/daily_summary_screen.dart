import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/ads/ad_widgets.dart';
import '../../core/ads/ads_service.dart';
import '../../core/ads/interstitial_policy.dart';
import '../../core/i18n/date_labels.dart';
import '../../core/money/money_formatter.dart' show MoneyFormatter;
import '../../core/money/money_formatter.dart';
import '../../core/providers.dart';
import '../../core/security/roles.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/utils/business_calendar.dart';
import '../../l10n/gen/app_localizations.dart';
import '../commission/commission_rates_screen.dart' show transactionTypeLabel;
import '../sheet/daily_sheet_model.dart';
import '../sheet/daily_sheet_queries.dart';
import '../sheet/daily_sheet_renderer.dart';
import 'day_close_service.dart';

/// The day's numbers, shareable as an image or PDF (for WhatsApp etc.).
///
/// The sheet is rendered by Flutter itself and captured as a picture, so
/// Bangla text and the taka sign look exactly as on screen. The PDF simply
/// embeds that picture.
class DailySummaryScreen extends ConsumerStatefulWidget {
  const DailySummaryScreen({
    super.key,
    required this.businessDate,
    this.interstitialOnExit = false,
  });

  final String businessDate;

  /// True right after a close: leaving this screen is a natural break where
  /// an interstitial may be shown (subject to the frequency rules).
  final bool interstitialOnExit;

  @override
  ConsumerState<DailySummaryScreen> createState() => _DailySummaryScreenState();
}

class _DailySummaryScreenState extends ConsumerState<DailySummaryScreen> {
  final GlobalKey _sheetKey = GlobalKey();
  late final AdsService _ads;
  DailySummaryData? _data;
  bool _sharing = false;

  @override
  void initState() {
    super.initState();
    _ads = ref.read(adsServiceProvider);
    ref.read(dayCloseServiceProvider).summary(widget.businessDate).then((d) {
      if (mounted) setState(() => _data = d);
    });
  }

  @override
  void dispose() {
    if (widget.interstitialOnExit) {
      unawaited(_ads.maybeShowInterstitial(AdTrigger.daySummaryExit));
    }
    super.dispose();
  }

  /// The paper-style sheet: cash ledger, wallets, summary, signatures.
  Future<void> _sheet({required bool print, required bool showProfit}) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final d = _data;
    if (d == null) return;
    setState(() => _sharing = true);
    try {
      final prefs = ref.read(preferencesProvider);
      final hour = await ref.read(dayRolloverHourProvider.future);
      final range = BusinessCalendar(rolloverHour: hour)
          .rangeOfDate(widget.businessDate);
      final cash = await DailySheetQueries(ref.read(databaseProvider))
          .cash(range.start, range.end);
      final shop = await ref.read(shopNameProvider.future);
      final dl = DateLabels(
        languageCode: prefs.languageCode,
        digits: prefs.digits,
      );
      final p = widget.businessDate.split('-').map(int.parse).toList();
      final dateText = dl.day(DateTime.utc(p[0], p[1], p[2], 6));

      final labels = SheetLabels(
        title: l10n.sheetTitle,
        status: d.status == 'closed' ? l10n.cdStatusClosed : l10n.sumNotClosed,
        time: l10n.sheetTime,
        particulars: l10n.sheetParticulars,
        moneyIn: l10n.ledgerIn,
        moneyOut: l10n.ledgerOut,
        balance: l10n.ledgerBalance,
        opening: l10n.sumOpening,
        closing: l10n.ledgerBalance,
        walletsHeading: l10n.sheetAccounts,
        expected: l10n.cdExpected,
        actual: l10n.cdActual,
        difference: l10n.sumVariance,
        summaryHeading: l10n.sheetSummary,
        entries: l10n.sumEntries,
        cashInTotal: l10n.sumCashInVolume,
        cashOutTotal: l10n.sumCashOutVolume,
        commission: l10n.sumCommission,
        margin: l10n.sumMargin,
        expenses: l10n.sumExpenses,
        netProfit: l10n.sumNet,
        preparedBy: l10n.sheetPreparedBy,
        checkedBy: l10n.sheetCheckedBy,
        voided: l10n.labelVoided,
        typeLabel: (t) => transactionTypeLabel(l10n, t),
        pageOf: (n, total) => l10n.repPage(
          prefs.digits.localize('$n'),
          prefs.digits.localize('$total'),
        ),
        numberText: (n) => prefs.digits.localize('$n'),
      );
      final pages = const DailySheetBuilder().build(
        summary: d,
        cash: cash,
        money: MoneyFormatter(digits: prefs.digits, showSymbol: false),
        timeText: dl.time,
        dateText: dateText,
        shopName: shop,
        labels: labels,
        showProfit: showProfit,
      );
      final images = await const DailySheetRenderer().render(pages);

      final doc = pw.Document();
      for (final png in images) {
        final image = pw.MemoryImage(png);
        doc.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a4,
            margin: pw.EdgeInsets.zero,
            build: (_) => pw.FullPage(
              ignoreMargins: true,
              child: pw.Image(image, fit: pw.BoxFit.fill),
            ),
          ),
        );
      }
      final bytes = await doc.save();
      final name = 'khata-sheet-${widget.businessDate}.pdf';
      if (print) {
        await Printing.layoutPdf(onLayout: (_) async => bytes, name: name);
      } else {
        final dir = await getTemporaryDirectory();
        final file = File('${dir.path}/$name')..writeAsBytesSync(bytes);
        await SharePlus.instance.share(
          ShareParams(files: [XFile(file.path)], text: l10n.sheetTitle),
        );
      }
    } on Object {
      messenger.showSnackBar(SnackBar(content: Text(l10n.sheetFailed)));
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  Future<Uint8List> _capture() async {
    final boundary =
        _sheetKey.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 3);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    return bytes!.buffer.asUint8List();
  }

  Future<void> _share({required bool pdf}) async {
    final l10n = AppLocalizations.of(context);
    setState(() => _sharing = true);
    try {
      final png = await _capture();
      final dir = await getTemporaryDirectory();
      final base = 'summary-${widget.businessDate}';
      final File file;
      if (pdf) {
        final doc = pw.Document();
        final image = pw.MemoryImage(png);
        doc.addPage(
          pw.Page(
            build: (_) =>
                pw.Center(child: pw.Image(image, fit: pw.BoxFit.contain)),
          ),
        );
        file = File('${dir.path}/$base.pdf')
          ..writeAsBytesSync(await doc.save());
      } else {
        file = File('${dir.path}/$base.png')..writeAsBytesSync(png);
      }
      await SharePlus.instance.share(
        ShareParams(files: [XFile(file.path)], text: l10n.sumTitle),
      );
    } on Object {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l10n.sumShareFailed)));
      }
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final prefs = ref.watch(preferencesProvider);
    final money = MoneyFormatter(digits: prefs.digits);
    final plain = MoneyFormatter(digits: prefs.digits, showSymbol: false);
    final labels = DateLabels(
      languageCode: prefs.languageCode,
      digits: prefs.digits,
    );
    final tokens = context.tokens;
    final d = _data;
    final session = ref.watch(sessionProvider);
    final showProfit =
        session != null && Permissions.can(session, Permission.viewProfit);
    final parts = widget.businessDate.split('-').map(int.parse).toList();
    final dateText = labels.day(DateTime.utc(parts[0], parts[1], parts[2], 6));

    Widget kv(String k, String v, {bool bold = false, Color? color}) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(k, style: theme.textTheme.bodyLarge)),
          Text(
            v,
            style:
                (bold
                        ? theme.textTheme.headlineMedium
                        : theme.textTheme.bodyLarge)
                    ?.copyWith(
                      color: color,
                      fontWeight: bold ? FontWeight.w800 : FontWeight.w700,
                    ),
          ),
        ],
      ),
    );

    Widget cell(String t, {bool head = false, Color? color}) => Expanded(
      child: Text(
        t,
        textAlign: TextAlign.end,
        style: (head ? theme.textTheme.labelLarge : theme.textTheme.bodyMedium)
            ?.copyWith(color: color, fontWeight: FontWeight.w700),
      ),
    );

    return Scaffold(
      bottomNavigationBar: const AdFooter(),
      appBar: AppBar(title: Text(l10n.sumTitle)),
      body: d == null
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: ListView(
                children: [
                  RepaintBoundary(
                    key: _sheetKey,
                    child: Container(
                      color: theme.colorScheme.surface,
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.appName,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            dateText,
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontFamily: 'Caprasimo',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            d.status == 'closed'
                                ? l10n.cdStatusClosed
                                : l10n.sumNotClosed,
                            style: theme.textTheme.bodyMedium,
                          ),
                          const Divider(height: 24),
                          kv(
                            l10n.sumEntries,
                            prefs.digits.localize('${d.count}'),
                          ),
                          kv(
                            l10n.sumCashInVolume,
                            money.format(d.cashInVolume),
                          ),
                          kv(
                            l10n.sumCashOutVolume,
                            money.format(d.cashOutVolume),
                          ),
                          if (showProfit) ...[
                            kv(l10n.sumCommission, money.format(d.commission)),
                            kv(l10n.sumMargin, money.format(d.flexiloadMargin)),
                          ],
                          kv(l10n.sumExpenses, money.format(d.expenses)),
                          if (showProfit) ...[
                            const Divider(height: 24),
                            kv(
                              l10n.sumNet,
                              money.format(d.netProfit),
                              bold: true,
                              color: d.netProfit.isNegative
                                  ? tokens.cashOut
                                  : tokens.cashIn,
                            ),
                          ],
                          if (d.totalVariance != null)
                            kv(
                              l10n.sumVariance,
                              money.format(d.totalVariance!),
                              color: d.totalVariance!.isZero
                                  ? null
                                  : tokens.warning,
                            ),
                          const Divider(height: 24),
                          Row(
                            children: [
                              const Expanded(flex: 2, child: SizedBox()),
                              cell(l10n.sumOpening, head: true),
                              cell(l10n.sumIn, head: true),
                              cell(l10n.sumOut, head: true),
                              cell(l10n.cdExpected, head: true),
                              cell(l10n.cdActual, head: true),
                            ],
                          ),
                          for (final a in d.accounts)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      a.label,
                                      style: theme.textTheme.bodyMedium,
                                    ),
                                  ),
                                  cell(plain.format(a.opening)),
                                  cell(
                                    plain.format(a.moneyIn),
                                    color: tokens.cashIn,
                                  ),
                                  cell(
                                    plain.format(a.moneyOut),
                                    color: tokens.cashOut,
                                  ),
                                  cell(plain.format(a.expected)),
                                  cell(
                                    a.actual == null
                                        ? '-'
                                        : plain.format(a.actual!),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: FilledButton.icon(
                            icon: const Icon(LucideIcons.image),
                            label: Text(l10n.sumShareImage),
                            onPressed: _sharing
                                ? null
                                : () => _share(pdf: false),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton.icon(
                            icon: const Icon(LucideIcons.fileText),
                            label: Text(l10n.sumSharePdf),
                            onPressed: _sharing
                                ? null
                                : () => _share(pdf: true),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: FilledButton.tonalIcon(
                            key: const ValueKey('print-sheet'),
                            icon: const Icon(LucideIcons.printer),
                            label: Text(l10n.sheetPrint),
                            onPressed: _sharing
                                ? null
                                : () => _sheet(
                                    print: true,
                                    showProfit: showProfit,
                                  ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton.tonalIcon(
                            key: const ValueKey('share-sheet'),
                            icon: const Icon(LucideIcons.share),
                            label: Text(l10n.sheetShare),
                            onPressed: _sharing
                                ? null
                                : () => _sheet(
                                    print: false,
                                    showProfit: showProfit,
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
