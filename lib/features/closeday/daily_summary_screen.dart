import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

import '../../core/i18n/date_labels.dart';
import '../../core/money/money_formatter.dart';
import '../../core/providers.dart';
import '../../core/theme/app_tokens.dart';
import '../../l10n/gen/app_localizations.dart';
import 'day_close_service.dart';

/// The day's numbers, shareable as an image or PDF (for WhatsApp etc.).
///
/// The sheet is rendered by Flutter itself and captured as a picture, so
/// Bangla text and the taka sign look exactly as on screen. The PDF simply
/// embeds that picture.
class DailySummaryScreen extends ConsumerStatefulWidget {
  const DailySummaryScreen({super.key, required this.businessDate});

  final String businessDate;

  @override
  ConsumerState<DailySummaryScreen> createState() => _DailySummaryScreenState();
}

class _DailySummaryScreenState extends ConsumerState<DailySummaryScreen> {
  final GlobalKey _sheetKey = GlobalKey();
  DailySummaryData? _data;
  bool _sharing = false;

  @override
  void initState() {
    super.initState();
    ref.read(dayCloseServiceProvider).summary(widget.businessDate).then((d) {
      if (mounted) setState(() => _data = d);
    });
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
                (bold ? theme.textTheme.titleLarge : theme.textTheme.bodyLarge)
                    ?.copyWith(
                      color: color,
                      fontWeight: bold ? FontWeight.bold : null,
                    ),
          ),
        ],
      ),
    );

    Widget cell(String t, {bool head = false}) => Expanded(
      child: Text(
        t,
        textAlign: TextAlign.end,
        style: head ? theme.textTheme.labelLarge : theme.textTheme.bodyMedium,
      ),
    );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.sumTitle)),
      body: d == null
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: RepaintBoundary(
                        key: _sheetKey,
                        child: Container(
                          color: theme.colorScheme.surface,
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.appName,
                                style: theme.textTheme.titleMedium,
                              ),
                              Text(
                                dateText,
                                style: theme.textTheme.headlineMedium,
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
                              kv(
                                l10n.sumCommission,
                                money.format(d.commission),
                              ),
                              kv(
                                l10n.sumMargin,
                                money.format(d.flexiloadMargin),
                              ),
                              kv(l10n.sumExpenses, money.format(d.expenses)),
                              const Divider(height: 24),
                              kv(
                                l10n.sumNet,
                                money.format(d.netProfit),
                                bold: true,
                                color: d.netProfit.isNegative
                                    ? tokens.cashOut
                                    : tokens.cashIn,
                              ),
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
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 4,
                                  ),
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
                                      cell(plain.format(a.moneyIn)),
                                      cell(plain.format(a.moneyOut)),
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
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.image_outlined),
                            label: Text(l10n.sumShareImage),
                            onPressed: _sharing
                                ? null
                                : () => _share(pdf: false),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton.icon(
                            icon: const Icon(Icons.picture_as_pdf_outlined),
                            label: Text(l10n.sumSharePdf),
                            onPressed: _sharing
                                ? null
                                : () => _share(pdf: true),
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
