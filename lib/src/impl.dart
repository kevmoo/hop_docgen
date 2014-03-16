library hop_docgen.impl;

import 'dart:async';
import 'dart:io';

import 'package:bot/bot.dart';
import 'package:git/git.dart';
import 'package:hop/hop_core.dart';
import 'package:path/path.dart' as p;

import 'util.dart';

const ALLOW_DIRTY_ARG = 'allow-dirty';

Future generateDocs(TaskContext ctx, String projectDirectory, String viewerPath,
    {String startPage, String targetBranch: 'gh-pages'}) {

  if (!FileSystemEntity.isDirectorySync(viewerPath)) {
    throw new ArgumentError(
        'The provided viewerPath is not a directory: $viewerPath');
  }

  GitDir gitDir;

  bool allowDirty = ctx.arguments[ALLOW_DIRTY_ARG];

  return GitDir.fromExisting(projectDirectory)
       .then((GitDir value) {
         gitDir = value;

         return gitDir.isWorkingTreeClean();
       })
       .then((bool isClean) {
         if(!allowDirty && !isClean) {
           ctx.fail('Working tree is dirty. Cannot generate docs.\n'
               'Try using the --${ALLOW_DIRTY_ARG} flag.');
         }

          return _getCommitMessageFuture(gitDir, isClean);
         }).then((commitMsg) {

         return gitDir.updateBranch(targetBranch,
             (Directory dir) => _populateBranch(dir, projectDirectory,
                 startPage, viewerPath),
             commitMsg);
       })
       .then((Commit value) {
         if(value == null) {
           ctx.info('No commit. Nothing changed.');
         } else {
           ctx.info('New commit created at branch $targetBranch');
           ctx.info('Message: ${value.message}');
         }
       });
}

Future<String> _getCommitMessageFuture(GitDir gitDir, bool isClean) {
  return gitDir.getCurrentBranch()
    .then((BranchReference branchRef) {

      var abbrevSha = branchRef.sha.substring(0, 7);

      var msg = "Docs generated for ${branchRef.branchName} at ${abbrevSha}";

      if(!isClean) {
        msg = msg + ' (dirty)';
      }

      return msg;
    });
}

Future _populateBranch(Directory dir, String projectRoot, String startPageName,
    String viewerPath) {
  return copyDirectory(viewerPath, dir.path)
      .then((_) {
    var docsDir = new Directory(p.join(dir.path, 'docs'));
    docsDir.create();
    return generateDocJson(projectRoot, docsDir.path,
        startPageName: startPageName, stdErrWriter: print, stdOutWriter: print);
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
    {String startPageName, void stdOutWriter(String value),
      void stdErrWriter(String value)}) {
  requireArgument(FileSystemEntity.isDirectorySync(projectRoot), 'projectRoot',
      'Must exist');
  _requireEmptyDir(outputDir, 'outputDir');

  var process = 'docgen';
  var args = ['--no-include-sdk'];

  if(startPageName != null) {
    args.addAll(['--start-page', startPageName]);
  }

  args.addAll(['--out', outputDir]);

  args.add(projectRoot);

  print('docgen args: ${args.join(' ')}');

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
  if(fse is Link) {
    throw new ArgumentError('Cannot rock on the link at ${fse.path}');
  }

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
