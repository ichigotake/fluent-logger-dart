library FluentLogger;

import 'dart:io' show Socket;
import 'dart:async' show Future;
import 'dart:convert' show JsonEncoder;

class FluentLogger {

  var _host;
  int _port;
  int _timeout;
  String _tagPrefix;
  JsonEncoder _packer;

  FluentLogger({host, int port, int timeout, String tagPrefix}) {
    this._host = host != null ? host : '127.0.0.1';
    this._port = port != null ? port : 24224;
    this._timeout = timeout != null ? timeout : 3000;
    this._tagPrefix = tagPrefix;
    this._packer = new JsonEncoder();
  }

  Future<Socket> post(String tag, Map message, {int timestamp}) {
    if (!(message is Map)) {
      throw new ArgumentTypeException("Message must be type as Map.");
    }

    String sendTag = _tagPrefix != null ? "${_tagPrefix}.${tag}" : tag;
    int sendTimestamp = timestamp != null ? timestamp : new DateTime.now().millisecondsSinceEpoch/1000;
    var sendData = _packer.convert([sendTag, sendTimestamp, message]);
    return Socket.connect(_host, _port)
      .timeout(new Duration(milliseconds: _timeout))
      .then((Socket socket){
        socket.listen(
                (data){},
                onDone: () => socket.destroy());
      socket.write(sendData);
      socket.close();
      })
      .catchError((e){
        print("Cannot send data: ${e}");
        return post(tag, message);
      });
  }

}

// Which Error or Exception?
class ArgumentTypeException implements Exception {
  String message;

  ArgumentTypeException(this.message);

  @override
  String toString() => "ArgumentError: $message";

}
