library test;

import 'package:unittest/unittest.dart';

import 'generate_docs_test.dart' as generate_docs;

void main() {
  groupSep = ' - ';
  group('generate_docs', generate_docs.main);
}
