library hop_docgen.impl;

import 'dart:async';
import 'dart:io';

import 'package:bot/bot.dart';
import 'package:path/path.dart' as p;
import 'util.dart';

Future copyDirectory(String sourceDirectory, String targetDir) {
  requireArgument(FileSystemEntity.isDirectorySync(sourceDirectory),
      'sourceDirectory', 'Must exist');
  _requireEmptyDir(targetDir, 'targetDir');

  var dir = new Directory(sourceDirectory);

  return streamForEachAsync(dir.list(recursive: true, followLinks: false),
      (fse) => _copyItem(fse, sourceDirectory, targetDir));
}

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

dynamic _copyItem(FileSystemEntity fse, String source, String target) {
  if(fse is Directory) return null;
  if(fse is Link) throw new ArgumentError('Cannot rock on the link at ${fse.path}');

  var relative = p.relative(fse.path, from: source);

  var newPath = p.join(target, relative);

  var parentDirPath = p.dirname(newPath);

  var parentDir = new Directory(parentDirPath);

  return parentDir.create(recursive: true).then((_) {
    return (fse as File).copy(newPath);
  });
}

void _requireEmptyDir(String path, String argName) {
  requireArgument(FileSystemEntity.isDirectorySync(path), argName,
      '$path does not exist or is not a directory.');

  var dir = new Directory(path);

  requireArgument(dir.listSync().isEmpty, argName,
      '$path is not empty.');
}
