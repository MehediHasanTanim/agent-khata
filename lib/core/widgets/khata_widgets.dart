import 'dart:async';

import 'package:flutter/material.dart';

import '../theme/app_tokens.dart';

enum BannerTone { warning, info }

/// Inline notice from the design system: tinted fill, matching border, icon,
/// text and an optional chevron when it can be tapped.
class NoticeBanner extends StatelessWidget {
  const NoticeBanner({
    super.key,
    required this.icon,
    required this.text,
    this.tone = BannerTone.warning,
    this.onTap,
    this.margin = const EdgeInsets.fromLTRB(12, 8, 12, 0),
  });

  final IconData icon;
  final String text;
  final BannerTone tone;
  final VoidCallback? onTap;
  final EdgeInsets margin;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final warn = tone == BannerTone.warning;
    final bg = warn
        ? Color.alphaBlend(
            context.tokens.warning.withValues(alpha: 0.16),
            scheme.surface,
          )
        : scheme.secondaryContainer;
    final border = warn ? context.tokens.warning : scheme.secondary;
    return Padding(
      padding: margin,
      child: Material(
        color: bg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: border, width: 1.5),
        ),
        child: InkWell(
          customBorder: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 52),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                children: [
                  Icon(icon, color: border),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      text,
                      style: Theme.of(context).textTheme.bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                  if (onTap != null) const Icon(Icons.chevron_right),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Round icon bubble tinted by money direction (terracotta out, sage in).
class DirectionBubble extends StatelessWidget {
  const DirectionBubble({
    super.key,
    required this.icon,
    required this.out,
    this.muted = false,
    this.size = 46,
  });

  final IconData icon;
  final bool out;
  final bool muted;
  final double size;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bg = out ? scheme.primaryContainer : scheme.secondaryContainer;
    final fg = out ? context.tokens.cashOut : context.tokens.cashIn;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: bg),
      child: Icon(
        icon,
        size: size * 0.48,
        color: muted ? scheme.onSurfaceVariant : fg,
      ),
    );
  }
}

/// A rounded surface row used for list entries (History, Home recents).
class KhataTile extends StatelessWidget {
  const KhataTile({
    super.key,
    required this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  final Widget leading;
  final Widget title;
  final Widget? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Material(
        color: scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        elevation: 0,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 64),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                children: [
                  leading,
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DefaultTextStyle.merge(
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                          child: title,
                        ),
                        if (subtitle != null)
                          DefaultTextStyle.merge(
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: scheme.onSurfaceVariant),
                            child: subtitle!,
                          ),
                      ],
                    ),
                  ),
                  if (trailing != null) ...[
                    const SizedBox(width: 8),
                    trailing!,
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// "All matches" moment: a check pops in with a soft halo, then closes itself.
Future<void> showSuccessPop(BuildContext context, String text) async {
  final navigator = Navigator.of(context, rootNavigator: true);
  unawaited(
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black38,
      builder: (ctx) => _SuccessPop(text: text),
    ),
  );
  await Future<void>.delayed(const Duration(milliseconds: 1100));
  if (navigator.canPop()) navigator.pop();
}

class _SuccessPop extends StatelessWidget {
  const _SuccessPop({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Dialog(
      backgroundColor: scheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.6, end: 1),
              duration: const Duration(milliseconds: 700),
              curve: Curves.elasticOut,
              builder: (_, v, child) => Transform.scale(scale: v, child: child),
              child: Container(
                width: 104,
                height: 104,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: scheme.secondaryContainer,
                  boxShadow: [
                    BoxShadow(
                      color: scheme.secondary.withValues(alpha: 0.25),
                      spreadRadius: 12,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.check_rounded,
                  size: 56,
                  color: scheme.secondary,
                ),
              ),
            ),
            const SizedBox(height: 28),
            Text(
              text,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    );
  }
}

/// Segmented control in a sand track with a terracotta selected pill.
class PillSegmented<T> extends StatelessWidget {
  const PillSegmented({
    super.key,
    required this.options,
    required this.value,
    required this.onChanged,
  });

  final List<(T, String)> options;
  final T value;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: scheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: [
          for (final (v, label) in options)
            Expanded(
              child: Material(
                color: v == value ? scheme.primary : Colors.transparent,
                shape: const StadiumBorder(),
                child: InkWell(
                  customBorder: const StadiumBorder(),
                  onTap: () => onChanged(v),
                  child: SizedBox(
                    height: 46,
                    child: Center(
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: v == value
                              ? scheme.onPrimary
                              : scheme.onSurface,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Big tinted summary card: caption, hero figure, optional line below.
class HeroCard extends StatelessWidget {
  const HeroCard({
    super.key,
    required this.label,
    required this.value,
    this.footer,
    this.margin = const EdgeInsets.fromLTRB(12, 8, 12, 0),
  });

  final String label;
  final String value;
  final String? footer;
  final EdgeInsets margin;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    return Padding(
      padding: margin,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
        decoration: BoxDecoration(
          color: scheme.secondaryContainer,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: scheme.onSecondaryContainer,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              value,
              style: theme.textTheme.displayMedium?.copyWith(
                color: scheme.onSecondaryContainer,
                fontWeight: FontWeight.w800,
              ),
            ),
            if (footer != null)
              Text(
                footer!,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: scheme.onSecondaryContainer,
                  fontWeight: FontWeight.w700,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Round avatar with the first letter of a name.
class InitialAvatar extends StatelessWidget {
  const InitialAvatar(this.name, {super.key, this.size = 46});

  final String name;
  final double size;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final initial = name.trim().isEmpty
        ? '?'
        : String.fromCharCode(name.trim().runes.first);
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: scheme.primaryContainer,
      ),
      child: Text(
        initial,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w800,
          color: scheme.onPrimaryContainer,
        ),
      ),
    );
  }
}
