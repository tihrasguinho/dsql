import 'dart:async';
import 'dart:io';

import 'package:args/args.dart';
import 'package:dsql/src/dsql_gen.dart';
import 'package:path/path.dart' as p;

FutureOr<void> main(List<String> args) async {
  try {
    final parser = ArgParser()
      ..addFlag('help', abbr: 'h', help: 'Show this help message!', negatable: false)
      ..addFlag('generate', abbr: 'g', help: 'Generate the Dart code for the SQL schema!', negatable: false)
      ..addFlag('version', abbr: 'v', help: 'Print the version!', negatable: false)
      ..addOption('output', abbr: 'o', valueHelp: 'Set the output path!');

    final result = parser.parse(args);

    final root = Directory.current;

    final output = result['output'] as String?;

    final generate = result['generate'] as bool? ?? false;

    final version = result['version'] as bool? ?? false;

    final help = result['help'] as bool? ?? false;

    if (help) {
      return showHelp();
    } else if (version) {
      return getVersion('0.0.8+71');
    } else if (generate) {
      if (!root.listSync().any((file) => file.statSync().type == FileSystemEntityType.file && p.basename(file.path) == 'pubspec.yaml')) {
        stdout.writeln('No pubspec.yaml found on this directory!');
        exit(0);
      }

      await DSQLGen.readMigrations(p.join(root.path, 'migrations'), output);
      exit(0);
    } else {
      return showHelp();
    }
  } on Exception catch (e) {
    stdout.writeln('Error: $e');
  }
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
  -g, --generate        Generate the Dart code for the SQL schema!
  -v, --version         Print the version
  -o, --output <path>   Set the output path

Example:
  Example:
    dsql --generate --output /path/to/output  
''');
  exit(0);
}
