import 'package:dart_dev/dart_dev.dart';

main(args) async {
  config.analyze
    ..entryPoints = ['lib/', 'tool/', 'test/']
    ..strong = true;

  config.coverage..html = false;

  config.format
    ..paths = ['lib/', 'tool/', 'test/']
    ..exclude = ['test/unit/generated_runner.dart'];

  config.local
    ..taskPaths.add('bin')
    ..commandFilePattern = '([a-zA-Z0-9]+)_task.([a-zA-Z0-9]+)'
    ..executables['go'] = ['go', 'run'];

  config.test
    ..pubServe = true
    ..unitTests = ['test/unit'];

  config.genTestRunner
    ..configs = [
      new TestRunnerConfig(directory: 'test/unit/', env: Environment.both),
    ];

  await dev(args);
}
