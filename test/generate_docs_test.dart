
import 'dart:io';
import 'package:bot_io/bot_io.dart';
import 'package:unittest/unittest.dart';

import 'package:path/path.dart' as p;
import 'package:hop_docgen/src/generate_json.dart';

void main() {
  test('basics', () {
    _expectProjectRoot();

    return TempDir.then((dir) {
      print(dir.path);

      return generateDocJson(p.current, dir.path, stdErrWriter: print,
          stdOutWriter: print).then((_) {
        print(dir.listSync().length);

      });

    });

  });

}

void _stdOutLogger(String input) {
  print(input);
}

void _expectProjectRoot() {
  var currentDir = Directory.current;

  var contents = currentDir.listSync();

  expect(contents, contains(predicate((fse) =>
      fse is Directory && p.basename(fse.path) == 'test')));
  expect(contents, contains(predicate((fse) =>
      fse is Directory && p.basename(fse.path) == 'lib')));
  expect(contents, contains(predicate((fse) =>
      fse is File && p.basename(fse.path) == 'pubspec.yaml')));
}
