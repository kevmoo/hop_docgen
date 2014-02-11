library hop_runner;

import 'package:hop/hop.dart';
import 'package:hop/hop_tasks.dart';

import '../test/harness_console.dart' as test;

void main(List<String> args) {

  addTask('test', createUnitTestTask(test.testCore));


  runHop(args);
}
