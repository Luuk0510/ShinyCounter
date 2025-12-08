import 'dart:io';

Future<void> main() async {
  final result = await Process.run('flutter', ['test', '--coverage']);
  stdout.write(result.stdout);
  stderr.write(result.stderr);
  if (result.exitCode != 0) {
    exit(result.exitCode);
  }

  final viewer = await Process.start('dart', [
    'run',
    'tools/lcov_viewer.dart',
    'coverage/lcov.info',
  ]);
  final outFile = File('coverage/coverage.html').openWrite();
  await viewer.stdout.pipe(outFile);
  await viewer.stderr.transform(SystemEncoding().decoder).forEach(stderr.write);
  final exitCode = await viewer.exitCode;
  if (exitCode != 0) {
    stderr.writeln('lcov_viewer failed with exit code $exitCode');
    exit(exitCode);
  }
  stdout.writeln('Coverage written to coverage/coverage.html');
}
