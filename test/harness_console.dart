library test;

import 'package:unittest/unittest.dart';

import 'generate_docs_test.dart' as generate_docs;

void main(List<String> args) {
  testCore(new SimpleConfiguration());
}

void testCore(Configuration config) {
  unittestConfiguration = config;

  group('generate_docs', generate_docs.main);
}
