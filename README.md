# fluent-logger for Dartlang

fluent-logger implementation for Dart inspired by [fluent-logger-perl](https://github.com/fluent/fluent-logger-perl)

UNDER DEVELOPMENT.

If found bug or issues, please contribute to [the fluent-logger-dart repository!](https://github.com/ichigotake/fluent-logger-dart/issues)

## Usage

They currently only work on platforms where `dart:io` is available.

``` dart
FluentLogger logger = new FluentLogger(host: '127.0.0.1', port: 24224, timeout: 300);
logger.post("test.greet", {"greeting": "Good afternoon :)"})
  .then((e) => 'success!')
  .catchError((e) => 'failed...')
  .whenComplete((action) => logger.destroy());
```

## TODO

- Retries posting message when failed to post to `fluentd`.

## License

MIT License

## See also

- [https://github.com/ichigotake/fluent-logger-dart](https://github.com/ichigotake/fluent-logger-dart)
- [https://pub.dartlang.org/packages/fluent_logger](https://pub.dartlang.org/fluent_logger)
- [Fluentd | Open Source Log Management](http://www.fluentd.org/)
- [https://github.com/fluent/fluentd](https://github.com/fluent/fluentd)
