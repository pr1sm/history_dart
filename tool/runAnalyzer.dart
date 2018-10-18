import 'dart:async';
import 'dart:convert';
import 'dart:io';

StreamController<String> analyzerStdOut = new StreamController();
StreamController<String> analyzerStdErr = new StreamController();

Completer outc = new Completer();
Completer errc = new Completer();
Completer donec = new Completer();
Completer<int> procExitCode = new Completer();

String analyzerExecutable = 'dartanalyzer';
List<String> analyzerArgs = new List()..add('.');

void startAnalyzer() async {
  Process.start(analyzerExecutable, analyzerArgs).then((process) {
    process.stdout
        .transform(utf8.decoder)
        .transform(new LineSplitter())
        .listen(analyzerStdOut.add, onDone: outc.complete);
    process.stderr
        .transform(utf8.decoder)
        .transform(new LineSplitter())
        .listen(analyzerStdErr.add, onDone: errc.complete);
    process.exitCode.then(procExitCode.complete);
    Future.wait([outc.future, errc.future, process.exitCode])
        .then((_) => donec.complete());
  });
}

void main() async {
  print('Starting Analyzer...');
  print('::: Running $analyzerExecutable ${analyzerArgs.join(' ')}');

  String indentLine(String line) => '    ${line}';
  analyzerStdOut.stream.listen((line) {
    print(indentLine(line));
  });

  analyzerStdErr.stream.listen((line) {
    print(indentLine(line));
  });

  startAnalyzer();

  await donec.future;
  int exitCode = await procExitCode.future;

  if (exitCode <= 0) {
    print('Analyzer Succeeded!');
    exit(0);
  }
  print('Analyzer failed!');
  exit(exitCode);
}
