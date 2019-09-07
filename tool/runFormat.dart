import 'dart:async';
import 'dart:convert';
import 'dart:io';

StreamController<String> formatStdOut = new StreamController();
StreamController<String> formatStdErr = new StreamController();

Completer outc = new Completer();
Completer errc = new Completer();
Completer donec = new Completer();
Completer<int> procExitCode = new Completer();
Completer<int> formatExitCode = new Completer();

RegExp failureRegex = new RegExp(r'.dart');

String formatExecutable = 'pub';
List<String> formatArgs = new List()
  ..add('run')
  ..add('dart_style:format')
  ..add('-n')
  ..add('example/')
  ..add('lib/')
  ..add('test/')
  ..add('tool/');

void startFormat() async {
  return Process.start(formatExecutable, formatArgs).then((process) {
    process.stdout.transform(utf8.decoder).transform(new LineSplitter()).listen(
        (line) {
      formatStdOut.add(line);
      if (failureRegex.hasMatch(line) && !formatExitCode.isCompleted) {
        formatExitCode.complete(1);
      }
    }, onDone: outc.complete);
    process.stderr.transform(utf8.decoder).transform(new LineSplitter()).listen(
        (line) {
      formatStdOut.add(line);
      if (failureRegex.hasMatch(line) && !formatExitCode.isCompleted) {
        formatExitCode.complete(1);
      }
    }, onDone: errc.complete);
    process.exitCode.then(procExitCode.complete);
    Future.wait([outc.future, errc.future, process.exitCode]).then((_) {
      if (!formatExitCode.isCompleted) {
        formatExitCode.complete(0);
      }
      donec.complete();
    });
  });
}

void main() async {
  print('Starting Format...');
  print('::: Running $formatExecutable ${formatArgs.join(' ')}');

  String indentLine(String line) => '    ${line}';
  formatStdOut.stream.listen((line) {
    print(indentLine(line));
  });

  formatStdErr.stream.listen((line) {
    print(indentLine(line));
  });

  startFormat();

  await donec.future;
  int procExit = await procExitCode.future;
  int formatExit = await formatExitCode.future;

  if (procExit <= 0 && formatExit <= 0) {
    print('Format Check Succeeded!');
    exit(0);
  }
  print('Format Check failed!');
  if (formatExit > 0) {
    exit(formatExit);
  }
  exit(procExit);
}
