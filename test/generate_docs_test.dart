library hop_docgen.test;

import 'dart:convert';
import 'dart:io';
import 'package:scheduled_test/scheduled_test.dart';
import 'package:scheduled_test/descriptor.dart' as d;

import 'package:path/path.dart' as p;
import 'package:hop_docgen/src/impl.dart';

void main() {
  setUp(() {
    currentSchedule.timeout = null;

     var tempDir;
     schedule(() {
       return Directory.systemTemp
           .createTemp('hop_docgen-test-')
           .then((dir) {
         tempDir = dir;
         d.defaultRoot = tempDir.path;
       });
     });

     currentSchedule.onComplete.schedule(() {
       d.defaultRoot = null;
       return tempDir.delete(recursive: true);
     });
   });

  test('basics', () {

    // Ensure the current directory is the root of the hop_docgen project
    d.dir('.', [
        d.dir('test'),
        d.dir('lib'),
        d.matcherFile('pubspec.yaml', isNotNull)
    ]).validate(p.current);

    schedule(() {
      _debugPrint(d.defaultRoot);

      return generateDocJson(p.current, d.defaultRoot,
          stdErrWriter: _debugPrint, stdOutWriter: _debugPrint);
    });

    d.dir('.', [
        d.matcherFile('index.json', _isJsonMap),
        d.matcherFile('index.txt', isNotNull),
        d.matcherFile('library_list.json', _isJsonMap),
        d.dir('hop_docgen')
    ]).validate();
  });

}

final Matcher _isJsonMap = predicate((input) {
  try {
    return JSON.decode(input) is Map;
  } catch (e) {
    return false;
  }
}, 'Output is JSON encoded Map');

void _debugPrint(String input) {
  logMessage(input);
}
