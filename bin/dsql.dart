import 'dart:async';
import 'dart:io';

import 'package:args/args.dart';
import 'package:dsql/src/dsql_gen.dart';
import 'package:path/path.dart' as p;

FutureOr<void> main(List<String> args) async {
  try {
    final parser = ArgParser()
      ..addFlag('help', abbr: 'h', help: 'Show this help message!', negatable: false)
      ..addFlag('version', abbr: 'v', help: 'Print the version!', negatable: false)
      ..addFlag('migrate', abbr: 'm', help: 'Migrate the schema!', negatable: false)
      ..addOption('output', abbr: 'o', valueHelp: 'Set the output path!');

    final result = parser.parse(args);

    final output = result['output'] as String?;

    final version = result['version'] as bool? ?? false;

    final migrate = result['migrate'] as bool? ?? false;

    final help = result['help'] as bool? ?? false;

    if (help) {
      return showHelp();
    } else if (version) {
      return getVersion('0.0.9+7');
    } else if (migrate) {
      await startMigration(output);
    } else {
      return showHelp();
    }
  } on Exception catch (e) {
    stdout.writeln('Error: $e');
  }
}

Future<void> startMigration([String? output]) async {
  stdout.writeln('DSQL CLI - Dart SQL Schema Generator');

  stdout.write('Enter your postgresSQL database URL: ');
  final url = stdin.readLineSync() ?? '';

  if (url.isEmpty) {
    stdout.writeln('URL cannot be empty!');
    exit(0);
  }

  await DSQLGen.readMigrations(
    p.join(Directory.current.path, 'migrations'),
    databaseURL: Uri.parse(url),
    output: output,
  );
}

void getVersion(String version) {
  stdout.writeln('DSQL version: $version');
  exit(0);
}

void showHelp() {
  stdout.writeln(
      '''
DSQL CLI - Dart SQL Schema Generator

Usage: dsql [options]

Options:
  -h, --help            Show this help message
  -m, --migrate         Migrate and generate DSQL classes
  -v, --version         Print the version
  -o, --output <path>   Set the output path

Example:
  dsql --migrate --output /path/to/output  
''');
  exit(0);
}
