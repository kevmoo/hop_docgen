library hop_docgen.impl;

import 'dart:async';
import 'dart:io';

import 'package:bot/bot.dart';
import 'package:bot_io/bot_io.dart';
import 'package:git/git.dart';
import 'package:path/path.dart' as p;
import 'util.dart';

Future doThings(String projectDirectory, String viewerPath,
    {String targetBranch: 'gh-pages'}) {

  GitDir gitDir;
  bool isClean;

  return GitDir.fromExisting(projectDirectory)
       .then((GitDir value) {
         gitDir = value;

         return gitDir.isWorkingTreeClean();
       })
       .then((bool value) {
         isClean = value;
         if(!isClean) {
           //TODO(kevmoo): default to failing on dirty tree, option to allow dirty
           print('The current working dir is dirty!');
         }

         return gitDir.populateBranch(targetBranch,
             (TempDir td) => _populateBranch(td, projectDirectory, viewerPath),
             'test!');
       })
       .then((Commit value) {
         if(value == null) {
           print('No commit. Nothing changed.');
         } else {
           print('New commit created at branch $targetBranch');
           print('Message: ${value.message}');
         }
       });
}

Future _populateBranch(TempDir dir, String projectRoot, String viewerPath) {
  return copyDirectory(viewerPath, dir.path)
      .then((_) {
    var docsDir = new Directory(p.join(dir.path, 'docs'));
    docsDir.create();
    return generateDocJson(projectRoot, docsDir.path);
  });
}

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
  var args = ['--out', outputDir, projectRoot];

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
