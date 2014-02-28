library hop_docgen.util;

import 'dart:async';
import 'dart:io';

//TODO(kevmoo): move this guy to bot_io
Future<int> pipeProcess(Process process,
    {void stdOutWriter(String value), void stdErrWriter(String value)}) {

  var futures = [process.exitCode];

  futures.add(process.stdout.forEach((data) => _stdListen(data, stdOutWriter)));

  futures.add(process.stderr.forEach((data) => _stdListen(data, stdErrWriter)));

  return Future.wait(futures).then((List values) {
    assert(values.length == futures.length);
    assert(values[0] != null);
    return values[0] as int;
  });
}

void _stdListen(List<int> data, void writer(String input)) {
  if (writer != null) {
    writer(SYSTEM_ENCODING.decode(data).trim());
  }
}
