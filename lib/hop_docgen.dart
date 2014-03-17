library hop_docgen;

import 'package:args/args.dart';
import 'package:hop/hop_core.dart';
import 'package:path/path.dart' as p;

import 'src/impl.dart';

const _TARGET_BRANCH_ARG = 'target-branch';

/// Creates documentation and populates the [targetBranch] on the local git
/// repository.
///
/// [compiledViewerPath] points to the compiled output of `dartdoc-viewer` or
/// similiar. The contents of [compiledViewerPath] are copied and the output
/// from `docgen` is placed in a `docs` directory within the copied content.
///
/// If [targetBranch] is not provided, `gh-pages` is used as the default value.
Task createDocGenTask(String compiledViewerPath, {String startPage,
    String targetBranch}) {
  if(targetBranch == null) targetBranch = 'gh-pages';

  return new Task((ctx) {
    targetBranch = ctx.arguments[_TARGET_BRANCH_ARG];

    return generateDocs(ctx, p.current, compiledViewerPath,
        startPage: startPage, targetBranch: targetBranch);
  },
      description: 'Generate package documentation using docgen',
      argParser: _dartDocParserConfig(targetBranch));
}

ArgParser _dartDocParserConfig(String targetBranch) => new ArgParser()
    ..addFlag(ALLOW_DIRTY_ARG, abbr: 'd', help: 'Allow a dirty tree to run',
        defaultsTo: false)
    ..addOption(_TARGET_BRANCH_ARG, abbr: 'b', defaultsTo: targetBranch,
        help: 'The git branch which gets the doc output');
