import 'dart:math';

import 'package:agentkhata/core/utils/business_calendar.dart';
import 'package:agentkhata/core/utils/uuid_v7.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  dayRangeTests();
  monthRangeTests();
  group('UuidV7Generator', () {
    test('has v7 version and RFC variant bits', () {
      final id = UuidV7Generator(random: Random(1)).next();
      expect(
        id,
        matches(
          RegExp(
            r'^[0-9a-f]{8}-[0-9a-f]{4}-7[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
          ),
        ),
      );
    });

    test('embeds the timestamp in the first 48 bits', () {
      final at = DateTime.utc(2026, 10, 20, 10, 30);
      final id = UuidV7Generator(clock: () => at, random: Random(2)).next();
      final hex = id.replaceAll('-', '').substring(0, 12);
      expect(int.parse(hex, radix: 16), at.millisecondsSinceEpoch);
    });

    test('is strictly increasing even within one millisecond', () {
      final at = DateTime.utc(2026, 10, 20);
      final gen = UuidV7Generator(clock: () => at, random: Random(3));
      final ids = List.generate(5000, (_) => gen.next());
      expect(ids.toSet().length, ids.length);
      for (var i = 1; i < ids.length; i++) {
        expect(ids[i].compareTo(ids[i - 1]), greaterThan(0));
      }
    });

    test('later clock reading sorts after earlier ones', () {
      var now = DateTime.utc(2026, 10, 20);
      final gen = UuidV7Generator(clock: () => now, random: Random(4));
      final a = gen.next();
      now = now.add(const Duration(seconds: 1));
      expect(gen.next().compareTo(a), greaterThan(0));
    });
  });

  group('BusinessCalendar', () {
    test('uses Dhaka time (UTC+6)', () {
      const cal = BusinessCalendar();
      // 2026-10-20 18:30 UTC = 2026-10-21 00:30 Dhaka
      expect(
        cal.businessDateOf(DateTime.utc(2026, 10, 20, 18, 30)),
        '2026-10-21',
      );
      expect(
        cal.businessDateOf(DateTime.utc(2026, 10, 20, 17, 59)),
        '2026-10-20',
      );
    });

    test('rollover hour keeps late-night sales on the previous day', () {
      const cal = BusinessCalendar(rolloverHour: 4);
      // 01:30 Dhaka on the 21st still belongs to the 20th.
      expect(
        cal.businessDateOf(DateTime.utc(2026, 10, 20, 19, 30)),
        '2026-10-20',
      );
      // 04:00 Dhaka on the 21st starts the 21st.
      expect(cal.businessDateOf(DateTime.utc(2026, 10, 20, 22)), '2026-10-21');
    });

    test('works across month and year boundaries', () {
      const cal = BusinessCalendar(rolloverHour: 4);
      expect(cal.businessDateOf(DateTime.utc(2026, 12, 31, 19)), '2026-12-31');
      expect(cal.businessDateOf(DateTime.utc(2026, 12, 31, 22)), '2027-01-01');
    });
  });
}

void dayRangeTests() {
  group('BusinessCalendar.dayRange', () {
    test('midnight rollover: Dhaka day = 18:00 UTC to 18:00 UTC', () {
      const cal = BusinessCalendar();
      final r = cal.dayRange(DateTime.utc(2026, 10, 20, 10)); // 16:00 Dhaka
      expect(r.start, DateTime.utc(2026, 10, 19, 18));
      expect(r.end, DateTime.utc(2026, 10, 20, 18));
    });

    test('4am rollover: day runs 04:00 to 04:00 Dhaka', () {
      const cal = BusinessCalendar(rolloverHour: 4);
      // 01:30 Dhaka on the 21st belongs to business day the 20th.
      final r = cal.dayRange(DateTime.utc(2026, 10, 20, 19, 30));
      expect(r.start, DateTime.utc(2026, 10, 19, 22)); // 04:00 Dhaka on 20th
      expect(r.end, DateTime.utc(2026, 10, 20, 22));
    });

    test('range agrees with businessDateOf', () {
      const cal = BusinessCalendar(rolloverHour: 4);
      final at = DateTime.utc(2026, 12, 31, 21);
      final r = cal.dayRange(at);
      expect(cal.businessDateOf(r.start), cal.businessDateOf(at));
      expect(
        cal.businessDateOf(r.end.subtract(const Duration(milliseconds: 1))),
        cal.businessDateOf(at),
      );
      expect(cal.businessDateOf(r.end), isNot(cal.businessDateOf(at)));
    });
  });
}

void monthRangeTests() {
  group('BusinessCalendar.monthRange', () {
    test('month boundaries follow Dhaka time and the rollover hour', () {
      const cal = BusinessCalendar(rolloverHour: 4);
      final r = cal.monthRange(DateTime.utc(2026, 10, 20, 10));
      // 1 Oct 04:00 Dhaka = 30 Sep 22:00 UTC; 1 Nov 04:00 Dhaka likewise.
      expect(r.start, DateTime.utc(2026, 9, 30, 22));
      expect(r.end, DateTime.utc(2026, 10, 31, 22));
    });

    test('early morning before rollover belongs to the previous month', () {
      const cal = BusinessCalendar(rolloverHour: 4);
      // 02:00 Dhaka on 1 Nov = 20:00 UTC on 31 Oct -> still October.
      final r = cal.monthRange(DateTime.utc(2026, 10, 31, 20));
      expect(r.start, DateTime.utc(2026, 9, 30, 22));
    });

    test('December rolls into January', () {
      const cal = BusinessCalendar();
      final r = cal.monthRange(DateTime.utc(2026, 12, 15));
      expect(r.end, DateTime.utc(2026, 12, 31, 18));
    });
  });
}
