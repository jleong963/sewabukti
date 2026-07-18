import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sewabukti/src/core/session/inactivity_service.dart';

void main() {
  const Duration timeout = Duration(seconds: 10);

  test('fires onTimeout once after the timeout elapses with no activity', () {
    fakeAsync((FakeAsync async) {
      int fired = 0;
      final InactivityService service = InactivityService(
        timeout: timeout,
        onTimeout: () => fired++,
      )..start();
      expect(service.isArmed, isTrue);

      async.elapse(const Duration(seconds: 9));
      expect(fired, 0);
      async.elapse(const Duration(seconds: 2)); // now past 10s
      expect(fired, 1);

      // Does not fire again on its own.
      async.elapse(const Duration(seconds: 30));
      expect(fired, 1);
    });
  });

  test('recordActivity restarts the countdown', () {
    fakeAsync((FakeAsync async) {
      int fired = 0;
      final InactivityService service = InactivityService(
        timeout: timeout,
        onTimeout: () => fired++,
      )..start();

      async.elapse(const Duration(seconds: 8));
      service.recordActivity(); // reset with 8s elapsed
      async.elapse(const Duration(seconds: 8)); // 16s total, 8s since activity
      expect(fired, 0);
      async.elapse(const Duration(seconds: 3)); // 11s since activity
      expect(fired, 1);
    });
  });

  test('stop cancels a running countdown', () {
    fakeAsync((FakeAsync async) {
      int fired = 0;
      final InactivityService service = InactivityService(
        timeout: timeout,
        onTimeout: () => fired++,
      )..start();

      async.elapse(const Duration(seconds: 5));
      service.stop();
      async.elapse(const Duration(seconds: 30));
      expect(fired, 0);
      expect(service.isArmed, isFalse);
    });
  });

  test('a zero timeout disables the service entirely', () {
    fakeAsync((FakeAsync async) {
      int fired = 0;
      final InactivityService service = InactivityService(
        timeout: Duration.zero,
        onTimeout: () => fired++,
      );

      expect(service.isEnabled, isFalse);
      service.start();
      expect(service.isArmed, isFalse);
      async.elapse(const Duration(seconds: 60));
      expect(fired, 0);
    });
  });

  test('recordActivity before start is ignored (does not arm)', () {
    fakeAsync((FakeAsync async) {
      int fired = 0;
      final InactivityService service = InactivityService(
        timeout: timeout,
        onTimeout: () => fired++,
      );

      service.recordActivity(); // not armed yet
      expect(service.isArmed, isFalse);
      async.elapse(const Duration(seconds: 30));
      expect(fired, 0);
    });
  });

  test('activity after timeout does not re-arm', () {
    fakeAsync((FakeAsync async) {
      int fired = 0;
      final InactivityService service = InactivityService(
        timeout: timeout,
        onTimeout: () => fired++,
      )..start();

      async.elapse(const Duration(seconds: 11)); // fires
      expect(fired, 1);
      service.recordActivity(); // already fired; must stay disarmed
      expect(service.isArmed, isFalse);
      async.elapse(const Duration(seconds: 30));
      expect(fired, 1);
    });
  });
}
