# fluent-logger for Dartlang

fluent-logger implementation for Dart inspired by [fluent-logger-perl](https://github.com/fluent/fluent-logger-perl)

UNDER DEVELOPMENT.

## Install

TBD

Will uploaded this to [https://pub.dartlang.org/](https://pub.dartlang.org/).

## Usage

``` dart
FluentLogger logger = new FluentLogger(host: '127.0.0.1', port: 24224, timeout: 300);
logger.post("test.greet", {"greeting": "Good afternoon :)"})
  .then((e) => 'success!')
  .catchError((e) => 'failed...')
  .whenComplete((action) => logger.destroy());
```

## TODO

- Retries posting message when failed to post to `fluentd`.
- Write `Dart Doc`.

## License

MIT License
