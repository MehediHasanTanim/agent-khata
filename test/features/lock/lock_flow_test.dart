import 'package:agentkhata/app.dart';
import 'package:agentkhata/core/bootstrap.dart';
import 'package:agentkhata/core/db/app_database.dart';
import 'package:agentkhata/core/providers.dart';
import 'package:agentkhata/core/security/key_value_store.dart';
import 'package:agentkhata/core/security/pin_hasher.dart';
import 'package:agentkhata/core/security/pin_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _pumpApp(WidgetTester tester, {String? existingPin}) async {
  SharedPreferences.setMockInitialValues({
    'pref_language': 'en',
    'onboarding_done': true,
  });
  final prefs = await SharedPreferences.getInstance();
  final store = MemoryKeyValueStore();
  final service = PinService(store: store, hasher: PinHasher(iterations: 10));
  if (existingPin != null) await service.setPin(existingPin);
  final db = AppDatabase.memory();
  addTearDown(db.close);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        databaseProvider.overrideWithValue(db),
        keyValueStoreProvider.overrideWithValue(store),
        pinServiceProvider.overrideWithValue(service),
      ],
      child: KhataApp(
        flavor: Flavor.dev,
        homeBuilder: (_) =>
            const Scaffold(body: Text('Your cash book will appear here.')),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _enter(WidgetTester tester, String pin) async {
  for (final d in pin.split('')) {
    await tester.tap(find.text(d));
    await tester.pump();
  }
  await tester.tap(find.byIcon(Icons.check_rounded));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('first run: set and confirm a PIN, then reach home', (
    tester,
  ) async {
    await _pumpApp(tester);
    expect(find.text('Set a PIN'), findsOneWidget);

    await _enter(tester, '2468');
    expect(find.text('Confirm your PIN'), findsOneWidget);
    await _enter(tester, '2468');

    expect(find.text('Your cash book will appear here.'), findsOneWidget);
  });

  testWidgets('mismatched confirmation restarts setup', (tester) async {
    await _pumpApp(tester);
    await _enter(tester, '2468');
    await _enter(tester, '1111');
    expect(find.text('Set a PIN'), findsOneWidget);
    expect(find.text('PINs did not match. Try again.'), findsOneWidget);
  });

  testWidgets('existing PIN gates the app; wrong then right PIN', (
    tester,
  ) async {
    await _pumpApp(tester, existingPin: '1357');
    expect(find.text('Enter PIN'), findsOneWidget);

    await _enter(tester, '0000');
    expect(find.textContaining('Wrong PIN'), findsOneWidget);
    expect(find.text('Your cash book will appear here.'), findsNothing);

    await _enter(tester, '1357');
    expect(find.text('Your cash book will appear here.'), findsOneWidget);
  });
}
