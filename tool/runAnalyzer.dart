import 'dart:async';
import 'dart:convert';
import 'dart:io';

StreamController<String> analyzerStdOut = StreamController();
StreamController<String> analyzerStdErr = StreamController();

Completer outc = Completer();
Completer errc = Completer();
Completer donec = Completer();
Completer<int> procExitCode = Completer();

String analyzerExecutable = 'dartanalyzer';
List<String> analyzerArgs = List()..add('.');

void startAnalyzer() async {
  return Process.start(analyzerExecutable, analyzerArgs).then((process) {
    process.stdout
        .transform(utf8.decoder)
        .transform(LineSplitter())
        .listen(analyzerStdOut.add, onDone: outc.complete);
    process.stderr
        .transform(utf8.decoder)
        .transform(LineSplitter())
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
