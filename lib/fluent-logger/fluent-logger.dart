library FluentLogger;

import 'dart:io' show Socket, sleep;
import 'dart:async' show Completer, Future;
import 'dart:convert' show JsonEncoder;

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
  String buffer = "";
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

  Future<Socket> connect() {
    return Socket.connect(_host, _port)
      .timeout(_timeout)
      .then((Socket socket){
        _socket = socket;
      })
      .catchError((e){
        if (_socket != null) {
          _socket.destroy();
        }
        print("Cannot send data: ${e}");
      });
  }

  Future post(String tag, Map message, {int timestamp}) {
    Completer completer = new Completer();
    if (!(message is Map)) {
      completer.completeError("Message must be type as Map.");
      return completer.future;
    }
    String sendTag = _tagPrefix != null ? "${_tagPrefix}.${tag}" : tag;
    int sendTimestamp = timestamp != null ? timestamp : new DateTime.now().millisecondsSinceEpoch/1000;
    var sendData = _packer.convert([sendTag, sendTimestamp, message]);
    buffer += sendData + "\n";
    if (sending) {
      return completer.future;
    }
    sending = true;

    if (_socket == null) {
      connect()
        .then((Socket socket) => _send(completer, buffer))
        .catchError((e){
          print("Connect error: ${e}");
          sending = false;
          completer.complete(_socket);
        });
    } else {
      _send(completer, buffer);
    }
    return completer.future;
  }

  void _send(Completer completer, sendData) {
    sending = true;
    int retries = 1;
    while (true) {
      sleep(_retryInterval);
      if (retries++ > _maxRetryCount) {
        completer.complete(_socket);
        break;
      }
      _socket.write(sendData);
      completer.complete(_socket);
      sending = false;
      buffer = "";
      break;
    }
  }

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
