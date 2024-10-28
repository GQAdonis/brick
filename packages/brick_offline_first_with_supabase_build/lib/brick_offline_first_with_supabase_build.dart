import 'package:brick_build/builders.dart';
import 'package:brick_offline_first_build/brick_offline_first_build.dart';
import 'package:brick_offline_first_with_supabase/brick_offline_first_with_supabase.dart';
import 'package:brick_offline_first_with_supabase_build/src/offline_first_with_supabase_generator.dart';
import 'package:brick_sqlite_generators/builders.dart';
import 'package:build/build.dart';

final _schemaGenerator = OfflineFirstSchemaGenerator();

/// Generates migrations based off the [schemaGenerator]
class OfflineFirstMigrationBuilder extends NewMigrationBuilder<ConnectOfflineFirstWithSupabase> {
  @override
  final schemaGenerator = _schemaGenerator;
}

/// Generates a schema using the [schemaGenerator]
class OfflineFirstSchemaBuilder extends SchemaBuilder<ConnectOfflineFirstWithSupabase> {
  @override
  final schemaGenerator = _schemaGenerator;
}

final offlineFirstGenerator = const OfflineFirstWithSupabaseGenerator(
  superAdapterName: 'OfflineFirstWithSupabase',
  repositoryName: 'OfflineFirstWithSupabase',
);

/// These functions act as builder factories used by `build.yaml`
Builder offlineFirstAggregateBuilder(options) => AggregateBuilder(
      requiredImports: [
        "import 'package:brick_offline_first/brick_offline_first.dart';",
        "import 'package:brick_core/query.dart';",
        "import 'package:brick_sqlite/db.dart';",
      ],
    );
Builder offlineFirstAdaptersBuilder(options) =>
    AdapterBuilder<ConnectOfflineFirstWithSupabase>(offlineFirstGenerator);
Builder offlineFirstModelDictionaryBuilder(options) =>
    ModelDictionaryBuilder<ConnectOfflineFirstWithSupabase>(
      const OfflineFirstModelDictionaryGenerator('Supabase'),
      expectedImportRemovals: [
        "import 'package:brick_offline_first/brick_offline_first.dart';",
        'import "package:brick_offline_first/brick_offline_first.dart";',
      ],
    );
Builder offlineFirstNewMigrationBuilder(options) => OfflineFirstMigrationBuilder();
Builder offlineFirstSchemaBuilder(options) => OfflineFirstSchemaBuilder();