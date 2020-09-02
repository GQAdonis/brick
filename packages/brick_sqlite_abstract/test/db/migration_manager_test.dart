import 'package:test/test.dart';
import 'package:brick_sqlite_abstract/db.dart';

class Migration1 extends Migration {
  const Migration1() : super(version: 1, up: const [InsertTable('demo1')], down: const []);
}

class Migration2 extends Migration {
  const Migration2() : super(version: 2, up: const [InsertTable('demo2')], down: const []);
}

class Migration3 extends Migration {
  const Migration3() : super(version: 3, up: const [InsertTable('demo3')], down: const []);
}

void main() {
  group('MigrationManager', () {
    const m1 = Migration1();
    const m2 = Migration2();
    const m3 = Migration3();
    MigrationManager manager;
    final emptyManager = MigrationManager(<Migration>{});

    setUp(() {
      manager = MigrationManager({m1, m2, m3});
    });

    tearDown(() {
      manager = null;
    });

    test('#migrationsSince', () {
      expect(manager.migrationsSince(1), hasLength(2));
      expect(manager.migrationsSince(1)[0], m2);
      expect(manager.migrationsSince(1)[1], m3);
    });

    test('#migrationsUntil', () {
      expect(manager.migrationByVersion, hasLength(3));
      expect(manager.migrationsUntil(2), contains(1));
      expect(manager.migrationsUntil(2), contains(2));
      expect(manager.migrationsUntil(2).containsKey(3), isFalse);
      expect(manager.migrationsUntil(2)[1], m1);
      expect(manager.migrationsUntil(2)[2], m2);
    });

    test('#migrationsAt', () {
      expect(manager.migrationAt(2), const TypeMatcher<Migration>());
      expect(manager.migrationAt(2), m2);
      expect(manager.migrationAt(1), m1);
    });

    test('#version', () {
      expect(manager.version, 3);

      expect(emptyManager.version, 0);

      manager = MigrationManager({Migration2(), Migration1()});
      // Should sort migrations inserted out of order
      expect(manager.version, 2);
    });

    test('.latestMigrationVersion', () {
      final version = MigrationManager.latestMigrationVersion([Migration2(), Migration1()]);

      expect(version, 2);
    });
  });
}
