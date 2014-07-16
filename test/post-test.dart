library LiveTest;

import 'dart:convert' show JSON;
import 'dart:io' show Socket, Process, ProcessResult;
import 'package:unittest/unittest.dart';
import '../lib/fluent-logger/fluent-logger.dart';

/**
 *
 * Before run `fluentd` on localhost.
 *
 *    <source>
 *      type forward
 *      port 24224
 *    </source>
 *    <match test.*>
 *      type file
 *      path $path_to_log_file
 *    </match>
 *
 * And run this file.
 */
main() {
  FluentLogger logger = new FluentLogger(host: '127.0.0.1', port: 24224);
  test("Post an message", () {
    logger.post("test.greet", {"greeting": "Hello world!"});
  });
  test("Post an invalid message", () {
    logger.post("test.greet", "Hello world!")
      .then((Socket socket) => fail("Message must be type as Map."));
  });
}
