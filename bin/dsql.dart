import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:dsql/src/internal/constraint.dart';
import 'package:dsql/src/internal/dsql.dart' as d;
import 'package:dsql/src/internal/entities.dart' as e;
import 'package:dsql/src/internal/shared.dart' as s;
import 'package:dsql/src/internal/table.dart';
import 'package:path/path.dart' as p;
import 'package:postgres/postgres.dart' hide Type;
import 'package:strings/strings.dart';

final _regFk1 = RegExp(
    r'^CONSTRAINT\s(\w+)\sFOREIGN\sKEY\s\((\w+)\)\sREFERENCES\s(\w+)\s\((\w+)\)');
final _regFk2 = RegExp(r'REFERENCES\s(\w+)\s?\((\w+)\)');
final _regTb = RegExp(
    r"--\sentity:\s([\w]+)\sCREATE TABLE(?: IF NOT EXISTS)?\s([\w]+)\s\(([\s\w\d\(\)\,\']+)\s\);");

void main(List<String> args) async {
  final parser = ArgParser()
    ..addOption('output',
        abbr: 'o',
        help:
            'Set the output directory, where the dart files will be, if not set, default: lib/generated')
    ..addOption('input',
        abbr: 'i',
        help:
            'Set the input directory, where the sql files are, if not set, default: migrations')
    ..addFlag('migrate',
        abbr: 'm',
        help:
            'Migrate the database based on the sql files and generate the dart files',
        negatable: false)
    ..addFlag('generate',
        abbr: 'g',
        help: 'Generate the dart files from the sql files',
        negatable: false)
    ..addFlag('help',
        abbr: 'h', help: 'Show the help information.', negatable: false);

  final results = parser.parse(args);

  if (results.flag('help')) {
    stdout.writeln('Usage: dart run dsql [options]');
    stdout.writeln();
    stdout.writeln(parser.usage);
    stdout.writeln();
    stdout.writeln('Example:');
    stdout.writeln('  dart run dsql --migrate');
    stdout.writeln(
        '  dart run dsql --generate --input sql/files/location --output dart/files/location');
    exit(0);
  }

  final root = Directory.current;

  Directory input, output;

  if (results.option('input')?.isNotEmpty ?? false) {
    input = Directory(p.normalize(results['input'] as String));
  } else {
    input = Directory(p.join(Directory.current.path, 'migrations'));
  }

  if (results.option('output')?.isNotEmpty ?? false) {
    output = Directory(p.normalize(results['output'] as String));
  } else {
    output = Directory(p.join(Directory.current.path, 'lib', 'generated'));
  }

  if (results.flag('generate') && results.flag('migrate')) {
    stdout.writeln('Cannot generate and migrate at the same time!');
    stdout.writeln();
    stdout.writeln('Please use either --generate or --migrate, not both.');
    stdout.writeln();
    stdout.writeln('See --help for more information.');
    stdout.writeln();
    exit(1);
  }

  if (results.flag('migrate')) {
    return _migrate(root, input, output);
  } else if (results.flag('generate')) {
    return _generate(input, output);
  } else {
    stdout.writeln('Wrong arguments, please see --help!');
    exit(0);
  }
}

void _migrate(Directory root, Directory input, Directory output) async {
  String source;
  final env = File(p.join(root.path, '.env'));
  if (env.existsSync()) {
    final lines = env.readAsLinesSync().where((l) => l.isNotEmpty).toList();
    final index = lines.indexWhere(RegExp(r'^DATABASE_URL=').hasMatch);
    if (index == -1) {
      source = String.fromEnvironment('DATABASE_URL');
    } else {
      final line = lines[index].split('DATABASE_URL=')[1];
      source = line.replaceAll('"', '').trim();
    }
  } else {
    source = String.fromEnvironment('DATABASE_URL');
  }

  if (source.isEmpty) {
    _showUriError('Missing DATABASE_URL environment variable!');
    exit(0);
  }

  final uri = Uri.parse(source);

  final host = uri.host;
  final port = uri.hasPort ? uri.port : 5432;
  if (!uri.hasAuthority || uri.userInfo.isEmpty || uri.pathSegments.isEmpty) {
    _showUriError('Invalid DATABASE_URL!');
    exit(0);
  }
  final user = uri.userInfo.split(':')[0];
  final password = uri.userInfo.split(':')[1];
  final database = uri.pathSegments.first;
  final schema = uri.queryParameters['schema'] ?? 'public';
  final ssl = uri.queryParameters['sslmode'] == 'require';

  if (!input.existsSync()) {
    _showOutputError(p.relative(input.path, from: Directory.current.path));
    exit(0);
  }
  final files = input
      .listSync(recursive: true)
      .where((f) => p.extension(f.path) == '.sql');
  if (files.isEmpty) {
    _showFilesError(p.relative(input.path, from: Directory.current.path));
    exit(0);
  }
  try {
    final conn = await Connection.open(
      Endpoint(
        host: host,
        database: database,
        username: user,
        password: password,
        port: port,
      ),
      settings: ConnectionSettings(
        sslMode: ssl ? SslMode.require : SslMode.disable,
        onOpen: (connection) async {
          await connection.execute('SET search_path TO $schema;');
        },
      ),
    );

    final migrations =
        files.map((file) => File(file.path).readAsLinesSync().join('\n'));

    final newTables = migrations.map(_regTb.allMatches).expand((m) => m).fold(
      <String, String>{},
      (prev, next) {
        final table = next.group(2)!;

        return {...prev, table: next.group(0)!};
      },
    );

    await conn.runTx(
      (tx) async {
        final checkResult = await tx.execute(
          r'SELECT EXISTS(SELECT FROM pg_tables WHERE schemaname = $1 AND tablename = $2);',
          parameters: [schema, '__migrations'],
        );

        final check = checkResult.first.first as bool;

        if (check) {
          final last = await tx.execute(
              'SELECT * FROM __migrations ORDER BY created_at DESC LIMIT 1;');

          if (last.isNotEmpty) {
            final [
              int _,
              Map<String, dynamic> oldTables,
              DateTime _,
            ] = last.first as List;

            if (!_mapEquals(newTables, oldTables)) {
              stdout.writeln('Updating...');

              final tablesResult = await tx.execute(
                r'SELECT tablename FROM pg_tables WHERE schemaname = $1 AND tablename != $2;',
                parameters: [schema, '__migrations'],
              );

              for (final name
                  in tablesResult.map((r) => r.join(', ')).toList()) {
                await tx.execute('DROP TABLE IF EXISTS $name CASCADE;');
              }

              final insertMigration = await tx.execute(
                r'INSERT INTO __migrations (tables) VALUES ($1) RETURNING id;',
                parameters: [jsonEncode(newTables)],
              );

              await tx.execute(migrations.join('\n'),
                  queryMode: QueryMode.simple);

              stdout.writeln(
                  'Updated, the current version is ${insertMigration.first.first as int}!');
            } else {
              stdout.writeln(
                  'Nothing to do, the current version is ${last.first.first as int}!');
            }
          } else {
            stdout.writeln('Updating...');

            final insertMigration = await tx.execute(
              r'INSERT INTO __migrations (schema) VALUES ($1);',
              parameters: [jsonEncode(newTables)],
            );

            await tx.execute(migrations.join('\n'),
                queryMode: QueryMode.simple);

            stdout.writeln(
                'Updated, the current version is ${insertMigration.first.first as int}!');
          }
        } else {
          await tx.execute(
              'CREATE TABLE __migrations (id INTEGER PRIMARY KEY GENERATED ALWAYS AS IDENTITY, tables JSONB NOT NULL, created_at TIMESTAMP NOT NULL DEFAULT NOW());');

          await tx.execute(
            r'INSERT INTO __migrations (tables) VALUES ($1);',
            parameters: [jsonEncode(newTables)],
          );

          await tx.execute(migrations.join('\n'), queryMode: QueryMode.simple);

          stdout.writeln('Created, the current version is 1!');
        }
      },
    );
    await conn.close();
    stdout.writeln('Done!');
    exit(0);
  } on Exception catch (e) {
    _showExceptionError(e);
    exit(0);
  }
}

void _generate(Directory input, Directory output) {
  final entitiesBuffer = StringBuffer();
  final dsqlBuffer = StringBuffer();

  final tables = <Table>[];

  for (final current in input.listSync(recursive: true)) {
    if (p.extension(current.path) != '.sql') continue;

    final file = File(current.path);

    if (!file.existsSync()) continue;

    final content = file.readAsLinesSync().join('\n');

    tables.addAll(
      _regTb.allMatches(content).map(
            (match) => Table(
              entity: match.group(1)!,
              name: match.group(2)!,
              lines: match
                  .group(3)!
                  .split('\n')
                  .map((l) => l.trim())
                  .where((l) => l.isNotEmpty)
                  .toList(),
            ),
          ),
    );
  }

  for (var i = 0; i < tables.length; i++) {
    Table table = tables[i];

    for (final line in table.lines) {
      final match1 = _regFk1.firstMatch(line);
      final match2 = _regFk2.firstMatch(line);

      if (match1 != null) {
        final constraintRef = match1.group(1);
        final colOrigin = match1.group(2)!;
        final tableRef = match1.group(3)!;
        final columnRef = match1.group(4)!;

        final index = tables.indexWhere((t) => t.name == tableRef);
        if (index < 0) continue;

        tables[index] = tables[index].copyWith(
          hasMany: {
            ...tables[index].hasMany,
            Constraint(
              name: constraintRef ?? table.name,
              originColumn: colOrigin,
              referencedColumn: columnRef,
              referencedTable: tableRef,
            ): table,
          },
        );

        tables[i] = tables[i].copyWith(
          hasOne: {
            ...tables[i].hasOne,
            Constraint(
              name: constraintRef ?? tables[i].name,
              originColumn: colOrigin,
              referencedColumn: columnRef,
              referencedTable: tableRef,
            ): tables[index],
          },
        );
      } else if (match2 != null) {
        final columnOrigin = s.fieldName(match2.group(0)!).toSnakeCase();
        final tableRef = match2.group(1)!;
        final columnRef = match2.group(2)!;

        final key = Constraint(
          name: table.name,
          originColumn: columnOrigin,
          referencedColumn: columnRef,
          referencedTable: tableRef,
        );

        final index = tables.indexWhere((t) => t.name == tableRef);
        if (index < 0) continue;
        tables[index] = tables[index].copyWith(
          hasMany: {
            ...tables[index].hasMany,
            key: table,
          },
        );
      }
    }
  }

  dsqlBuffer.writeln(d.builder(tables));

  entitiesBuffer.writeln(e.builder(tables));

  final entitiesFile = File(p.join(output.path, 'entities.dart'));

  if (!entitiesFile.existsSync()) {
    entitiesFile.createSync(recursive: true);
  }

  final dsqlFile = File(p.join(output.path, 'dsql.dart'));

  if (!dsqlFile.existsSync()) {
    dsqlFile.createSync(recursive: true);
  }

  dsqlFile.writeAsStringSync(dsqlBuffer.toString());

  entitiesFile.writeAsStringSync(entitiesBuffer.toString());

  _format(output);

  stdout.writeln(
      'Done, your dart files are in ${p.relative(output.path, from: Directory.current.path)}!');

  exit(0);
}

void _format(Directory output) {
  Process.runSync('dart', ['format', output.path]);
}

void _showUriError(String message) {
  _clearConsole();
  stdout.writeln('-' * 80);
  stdout.writeln('ERROR');
  stdout.writeln('-' * 80);
  stdout.writeln(message);
  stdout.writeln();
  stdout.writeln('e.g. postgresql://username:password@localhost:5432/database');
  stdout.writeln('-' * 80);
}

void _showFilesError(String inputPath) {
  _clearConsole();
  stdout.writeln('-' * 80);
  stdout.writeln('ERROR');
  stdout.writeln('-' * 80);
  stdout.writeln('No files found in `$inputPath` directory!');
  stdout.writeln();
  stdout.writeln('You must to put your .sql files in `$inputPath` directory!');
  stdout.writeln('-' * 80);
  stdout.writeln();
  stdout.write('Press ENTER to reset...');
  stdin.readLineSync();
  _clearConsole();
}

void _showOutputError(String inputPath) {
  _clearConsole();
  stdout.writeln('-' * 80);
  stdout.writeln('ERROR');
  stdout.writeln('-' * 80);
  stdout.writeln('Output directory `$inputPath` is not a valid directory!');
  stdout.writeln();
  stdout.writeln('You must set a valid output directory!');
  stdout.writeln('-' * 80);
  stdout.writeln();
  stdout.write('Press ENTER to reset...');
  stdin.readLineSync();
  _clearConsole();
}

void _showExceptionError(Exception ex) {
  stdout.writeln('-' * 80);
  stdout.writeln('ERROR');
  stdout.writeln('-' * 80);
  stdout.writeln('An unexpected error has occurred!');
  stdout.writeln();
  stdout.writeln(ex.toString());
  stdout.writeln('-' * 80);
}

void _clearConsole() => stdout.write('\x1B[2J\x1B[0;0H');

bool _mapEquals(Map<String, dynamic> m1, Map<String, dynamic> m2) {
  if (m1.length != m2.length) {
    return false;
  }
  for (final key in m1.keys) {
    if (m1[key] != m2[key]) {
      return false;
    }
  }
  return true;
}
