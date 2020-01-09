import 'package:test/test.dart';
import '../../lib/db.dart';
import '__mocks__.dart';

void main() {
  group("MigrationCommand", () {
    group("DropColumn", () {
      const m = DropColumn('name', onTable: "demo");

      test("#statement", () {
        expect(m.statement, null);
      });

      test("#forGenerator", () {
        expect(m.forGenerator, 'DropColumn("name", onTable: "demo")');
      });
    });

    group("DropTable", () {
      const m = DropTable('demo');

      test("#statement", () {
        expect(m.statement, "DROP TABLE IF EXISTS `demo`");
      });

      test("#forGenerator", () {
        expect(m.forGenerator, 'DropTable("demo")');
      });
    });

    group("InsertColumn", () {
      test("defaults", () {
        const m = InsertColumn('name', Column.varchar, onTable: 'demo');

        // These expectations can never be removed, otherwise all migrations must be regenerated
        // And some migrations are modified by hand, making regeneration not possible
        expect(m.autoincrement, isFalse);
        expect(m.nullable, isTrue);
        expect(m.unique, isFalse);
      });

      group("#statement", () {
        test("basic", () {
          const m = InsertColumn('name', Column.varchar, onTable: 'demo');
          expect(m.statement, "ALTER TABLE `demo` ADD `name` VARCHAR NULL");
        });

        test("autoincrement:true", () {
          const m = InsertColumn('name', Column.integer, onTable: 'demo', autoincrement: true);
          expect(m.statement, "ALTER TABLE `demo` ADD `name` INTEGER AUTOINCREMENT NULL");
        });

        test("defaultValue:", () {
          const m = InsertColumn('name', Column.integer, onTable: 'demo', defaultValue: 0);
          expect(m.statement, "ALTER TABLE `demo` ADD `name` INTEGER NULL DEFAULT 0");
        });

        test("nullable:", () {
          const m = InsertColumn('name', Column.integer, onTable: 'demo', nullable: false);
          expect(m.statement, "ALTER TABLE `demo` ADD `name` INTEGER NOT NULL");
        });

        test("unique:", () {
          const m = InsertColumn('name', Column.integer, onTable: 'demo', unique: true);
          expect(m.statement, "ALTER TABLE `demo` ADD `name` INTEGER NULL");
        });
      });

      group("#forGenerator", () {
        test("basic", () {
          const m = InsertColumn('name', Column.varchar, onTable: 'demo');
          expect(m.forGenerator, 'InsertColumn("name", Column.varchar, onTable: "demo")');
        });

        test("autoincrement:true", () {
          const m = InsertColumn('name', Column.integer, onTable: 'demo', autoincrement: true);
          expect(m.forGenerator,
              'InsertColumn("name", Column.integer, onTable: "demo", autoincrement: true)');
        });

        test("defaultValue:", () {
          const m = InsertColumn('name', Column.integer, onTable: 'demo', defaultValue: 0);
          expect(m.forGenerator,
              'InsertColumn("name", Column.integer, onTable: "demo", defaultValue: 0)');
        });

        test("nullable:", () {
          const m = InsertColumn('name', Column.integer, onTable: 'demo', nullable: false);
          expect(m.forGenerator,
              'InsertColumn("name", Column.integer, onTable: "demo", nullable: false)');
        });
      });
    });

    group("InsertForeignKey", () {
      const m = InsertForeignKey('demo', 'demo2');
      test("#statement", () {
        expect(m.statement,
            "ALTER TABLE `demo` ADD COLUMN `demo2_brick_id` INTEGER REFERENCES `demo2`(`_brick_id`)");
      });

      test("#forGenerator", () {
        expect(m.forGenerator,
            'InsertForeignKey("demo", "demo2", foreignKeyColumn: "demo2_brick_id")');
      });

      test(".foreignKeyColumnName", () {
        final columnName = InsertForeignKey.foreignKeyColumnName("BigHat");
        expect(columnName, "BigHat_brick_id");

        final prefixedName = InsertForeignKey.foreignKeyColumnName("BigHat", "casual");
        expect(prefixedName, "casual_BigHat_brick_id");
      });
    });

    group("InsertTable", () {
      const m = InsertTable('demo');

      test("#statement", () {
        expect(m.statement,
            "CREATE TABLE IF NOT EXISTS `demo` (`_brick_id` INTEGER PRIMARY KEY AUTOINCREMENT)");
      });

      test("#forGenerator", () {
        expect(m.forGenerator, 'InsertTable("demo")');
      });

      test(".PRIMARY_KEY_COLUMN", () {
        expect(InsertTable.PRIMARY_KEY_COLUMN, "_brick_id");
      });
    });

    group("RenameColumn", () {
      const m = RenameColumn('name', 'first_name', onTable: 'demo');
      test("#statement", () {
        expect(m.statement, null);
      });

      test("#forGenerator", () {
        expect(m.forGenerator, 'RenameColumn("name", "first_name", onTable: "demo")');
      });
    });

    group("RenameTable", () {
      const m = RenameTable('demo', 'demo2');

      test("#statement", () {
        expect(m.statement, "ALTER TABLE `demo` RENAME TO `demo2`");
      });

      test("#forGenerator", () {
        expect(m.forGenerator, 'RenameTable("demo", "demo2")');
      });
    });
  });
}