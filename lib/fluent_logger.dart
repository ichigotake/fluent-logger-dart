/**
 * Fluent logger for Dart.
 *
 * For information on installing and importing this library, see the
 * [fluent_logger package on pub.dartlang.org]
 * (http://pub.dartlang.org/packages/fluent_logger).
 */
library fluent_logger;

import 'dart:io' show Socket, sleep;
import 'dart:async' show Completer, Future;
import 'dart:convert' show JsonEncoder;

/**
 * Use a [FluentLogger] to logging messages to fluentd.
 */
class FluentLogger {

  Socket _socket;
  var _host;
  int _port;
  Duration _timeout;
  int _maxRetryCount;
  Duration _retryInterval;
  String _tagPrefix;
  JsonEncoder _packer;

  // For socket buffer
  String _buffer = "";
  bool sending = false;

  FluentLogger({host, int port, Duration timeout, String tagPrefix, Duration retryInterval, int maxRetryCount}) {
    this._host = host != null ? host : '127.0.0.1';
    this._port = port != null ? port : 24224;
    this._timeout = timeout != null ? timeout : new Duration(milliseconds: 500);
    this._maxRetryCount = maxRetryCount != null ? _maxRetryCount : 12;
    this._retryInterval = retryInterval != null ? retryInterval : new Duration(milliseconds: 500);
    this._tagPrefix = tagPrefix;
    this._packer = new JsonEncoder();
  }

  /**
   * Connect to fluentd socket.
   */
  Future<Socket> connect() {
    return Socket.connect(_host, _port)
      .timeout(_timeout)
      .then((Socket socket){
        _socket = socket;
      })
      .catchError((e){
        if (_socket != null) {
          destroy();
        }
        print("Cannot connect socket: ${e}");
      });
  }

  /**
   * Post log message to fluentd.
   */
  Future post(String tag, Map message, {int timestamp}) {
    Completer completer = new Completer();
    if (!(message is Map)) {
      completer.completeError("Message must be type as Map.");
      return completer.future;
    }
    String sendTag = _tagPrefix != null ? "${_tagPrefix}.${tag}" : tag;
    int sendTimestamp = timestamp != null ? timestamp : new DateTime.now().millisecondsSinceEpoch/1000;
    var sendData = _packer.convert([sendTag, sendTimestamp, message]);
    _buffer += sendData + "\n";
    if (sending) {
      completer.complete();
      return completer.future;
    }
    sending = true;

    if (_socket == null) {
      connect()
        .then((Socket socket) => _send(completer, _buffer))
        .catchError((e){
          sending = false;
          completer.complete(_socket);
        });
    } else {
      _send(completer, _buffer);
    }
    return completer.future;
  }

  /**
   * Send logging message to fluentd.
   */
  _send(Completer completer, sendData) {
    sending = true;
    int retries = 1;
    while (true) {
      try {
        _socket.write(sendData);
        _buffer = "";
        break;
      } catch (e) {
        print("Could not send data: ${_buffer}}\n${e}");
      }
      if (retries++ > _maxRetryCount) {
        print("Could not send data. Over the retry count as ${_maxRetryCount}: ${_buffer}}\n${e}");
        break;
      }
      sleep(_retryInterval);
      continue;
    }
    sending = false;
    completer.complete(_socket);
  }

  /**
   * Destroy socket connection.
   */
  void destroy() {
    if (_socket != null) {
      _socket.destroy();
      _socket = null;
    }
  }

}

// Which Error or Exception?
class ArgumentTypeException implements Exception {
  String message;

  ArgumentTypeException(this.message);

  @override
  String toString() => "ArgumentError: $message";

}
