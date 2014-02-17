library hop_docgen.generate_json;

import 'dart:async';
import 'dart:io';

import 'package:bot/bot.dart';
import 'util.dart';

Future generateDocJson(String projectRoot, String outputDir,
    {void stdOutWriter(String value), void stdErrWriter(String value)}) {
  requireArgument(FileSystemEntity.isDirectorySync(projectRoot), 'projectRoot',
      'Must exist');
  _requireEmptyDir(outputDir, 'outputDir');

  var process = 'docgen';
  var args = ['--out', outputDir, '.'];

  return Process.start(process, args)
      .then((process) => pipeProcess(process, stdOutWriter: stdOutWriter,
          stdErrWriter: stdErrWriter))
      .then((status) {
        if(status != 0) {
          throw new ProcessException('docgen', args, '', status);
        }
      });
}

void _requireEmptyDir(String path, String argName) {
  requireArgument(FileSystemEntity.isDirectorySync(path), argName,
      '$path does not exist or is not a directory.');

  var dir = new Directory(path);

  requireArgument(dir.listSync().isEmpty, argName,
      '$path is not empty.');
}
