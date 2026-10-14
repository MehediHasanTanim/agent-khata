import 'package:flutter/services.dart' show appFlavor;

import 'core/bootstrap.dart';

/// Default entry point. The flavor comes from the build (`--flavor`, or the
/// pubspec `default-flavor`), so IDE "Run" buttons work without extra flags.
/// Anything other than an explicit `prod` flavor runs as dev, which can only
/// use Google test ads.
Future<void> main() =>
    bootstrap(appFlavor == 'prod' ? Flavor.prod : Flavor.dev);
