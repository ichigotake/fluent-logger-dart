library LiveTest;

import 'dart:convert' show JSON;
import 'dart:async';
import 'dart:io' show Socket, Process, ProcessResult;
import 'package:unittest/unittest.dart';
import '../lib/fluent_logger.dart';

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
  FluentLogger logger = new FluentLogger(host: '127.0.0.1', port: 24224, timeout: new Duration(milliseconds: 300));

  test("Post an message", (){
    return logger.post("test.greet", {"greeting": "Hello world!"});
  });

  test("Post an message", (){
    return logger.post("test.greet", {"greeting": "Good afternoon :)"});
  });

  test("Message must be type as Map", (){
    logger.post("test.greet", "Hello world!")
      .then((e) => fail('failed'))
      .catchError((e) => expectAsync(e));
  });

  test("Destroy socket", (){
    return logger.destroy();
  });

  test("Post an message after destroy socket", (){
    return logger.post("test.greet", {"greeting": "Good night..."});
  });

  test("Too many post few times", (){
    Completer completer = new Completer();
    for (int i=0; i<1000; i++) {
      logger.post("test.greet", {"greeting": "Storm greeting! " + i.toString()});
    }
    completer.complete();
    return completer.future;
  });

  test("Destroy socket", (){
    return logger.destroy();
  });


}
