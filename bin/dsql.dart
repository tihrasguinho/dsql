import 'dart:io';

import 'package:args/args.dart';
import 'package:dsql/src/internal/dsql.dart' as d;
import 'package:dsql/src/internal/entities.dart' as e;
import 'package:dsql/src/internal/shared.dart' as s;
import 'package:path/path.dart' as p;

void main(List<String> args) async {
  final parser = ArgParser()
    ..addOption(
      'output',
      abbr: 'o',
      help:
          'Set the output directory, where the dart files will be, if not set, default: lib/generated',
    )
    ..addOption(
      'input',
      abbr: 'i',
      help:
          'Set the input directory, where the sql files are, if not set, default: migrations',
    )
    ..addFlag(
      'generate',
      abbr: 'g',
      help: 'Generate the dart files from the sql files',
      negatable: false,
    )
    ..addFlag(
      'help',
      abbr: 'h',
      help: 'Show the help information.',
      negatable: false,
    );

  final results = parser.parse(args);

  if (results.flag('help')) {
    stdout.writeln('Usage: dart run dsql [options]');
    stdout.writeln();
    stdout.writeln(parser.usage);
    stdout.writeln();
    stdout.writeln('Example:');
    stdout.writeln('  dart run dsql --generate');
    stdout.writeln(
        '  dart run dsql --generate --input sql/files/location --output dart/files/location');
    exit(0);
  }

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

  if (results.flag('generate')) {
    return _generate(input, output);
  } else {
    stdout.writeln('Wrong arguments, please see --help!');
    exit(0);
  }
}

void _generate(Directory input, Directory output) {
  final eb = StringBuffer();
  final db = StringBuffer();
  final tbs = s.extractTables(input);
  db.writeln(d.builder(tbs));
  eb.writeln(e.builder(tbs));
  final ef = File(p.join(output.path, 'entities.dart'));
  if (!ef.existsSync()) {
    ef.createSync(recursive: true);
  }
  final df = File(p.join(output.path, 'dsql.dart'));
  if (!df.existsSync()) {
    df.createSync(recursive: true);
  }
  df.writeAsStringSync(db.toString());
  ef.writeAsStringSync(eb.toString());
  _format(output);
  stdout.writeln(
      'Done, your dart files are in ${p.relative(output.path, from: Directory.current.path)}!');
  exit(0);
}

void _format(Directory output) {
  Process.runSync('dart', ['format', output.path]);
}
