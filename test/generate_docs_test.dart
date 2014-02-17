
import 'dart:io';
import 'package:bot_io/bot_io.dart';
import 'package:unittest/unittest.dart';

import 'package:path/path.dart' as p;
import 'package:hop_docgen/src/generate_json.dart';

void main() {
  test('basics', () {
    _expectProjectRoot();

    return TempDir.then((dir) {
      _debugPrint(dir.path);

      return generateDocJson(p.current, dir.path, stdErrWriter: _debugPrint,
          stdOutWriter: _debugPrint).then((_) {
        var items = dir.listSync();

        _expectContainsFSE(items, dir.path, 'index.json', FileSystemEntityType.FILE);
        _expectContainsFSE(items, dir.path, 'index.txt', FileSystemEntityType.FILE);
        _expectContainsFSE(items, dir.path, 'library_list.json', FileSystemEntityType.FILE);
        _expectContainsFSE(items, dir.path, 'hop_docgen', FileSystemEntityType.DIRECTORY);
      });

    });

  });

}

void _expectContainsFSE(List<FileSystemEntity> entities, String basePath,
    String path, FileSystemEntityType type) {
  var newPath = p.join(basePath, path);
  var matches = entities.where((fse) => fse.path == newPath).toList();
  expect(matches, hasLength(1), reason: 'Could not find path: $newPath');
  expect(FileSystemEntity.typeSync(newPath), type);
}

void _debugPrint(String input) {
  // print(input);
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
