library hop_runner;

import 'package:hop/hop.dart';
import 'package:hop/hop_tasks.dart';
import 'package:path/path.dart' as p;

import 'package:hop_docgen/src/impl.dart';

import '../test/harness_console.dart' as test;

void main(List<String> args) {

  addTask('test', createUnitTestTask(test.testCore));

  addTask('silly', (ctx) {

    return doThings(p.current, '../kev_dartdoc_viewer', 'hop_docgen');
  });


  runHop(args);
}
