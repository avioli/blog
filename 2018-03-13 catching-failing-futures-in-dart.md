# Catching failing Futures in Dart

You cannot catch a [Future][future] computation error, if it is not attached to
the Future itself, within the same event-loop cycle, or given enough time for
the catch handler to be set.

When I renewed exploring [Dart][dart], because of [Flutter][flutter], I really
wanted to use a [FutureBuilder][future-builder], which works with a Future.

A _very_ simplistic representation of the problem:

```dart
// main.dart
import 'dart:async';

Future asyncFunc() async {
  // Simulate a future computation exception.
  // This could be any exception.
  throw new FormatException('thrown-error');
}

void main() {
  var future;
  // A try/catch is useless, but still...
  try {
    future = asyncFunc();
  } catch (e) {
    print('caught???'); // Nope!
  }

  Timer.run(() {
    // This will be scheduled after the asyncFunc is fired, thus missing
    // the opportunity to attach the catchError callback.

    future.catchError((error) {
      print('Caught error: $error'); // Nope!
    });

    // If there is more work that will keep the app from exiting,
    // this will eventually get attached and run.
  });
}
```

After running above you get:

```bash
bash$ dart main.dart
Unhandled exception:
FormatException: thrown-error
# ... stack-trace follows
```

One of the ways to catch it is, if there is enough other delays within
`asyncFunc` to allow the `catchError` to be attached, before it throws:

```dart
// main.dart
...
// Works in this edge-case
Future asyncFunc() async {
  // Simulate some async work - like an HttpClientRequest
  await new Future.delayed(const Duration(milliseconds: 100));

  // Simulate a future computation error
  throw new FormatException('thrown-error');
}
...
```

But what if the `catchError` gets attached just "later"?

```dart
// main.dart
...
  new Timer(const Duration(milliseconds: 200), () {
    future.catchError((error) {
      print('Caught error: $error'); // Nope!
    });
  });
...
```

This is how Flutter's SDK works - you create a new [Future][future] in
`initState` or a `setState` call, then use a [FutureBuilder][future-builder] to
handle it and provide user feedback. The only problem is that there is a delay
between the state change and the builder adding the `catchError` handler.

## Flutter's FutureBuilder

Here is a snippet of code for a Flutter `StatefulWidget`.

The important pieces are the `_futureBuilder()`, `_startAsync()` and
`asyncFunc()`.

```dart
// lib/main.dart
import 'dart:async';
import 'package:flutter/material.dart';

void main() => runApp(new App());

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => new _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<String> _future; // Starts as null

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new Center(
        child: new Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _futureBuilder(),
            _button(),
          ],
        ),
      ),
    );
  }

  Widget _futureBuilder() {
    return new FutureBuilder<String>(
      future: _future, // a Future<String> or null
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
            return const Text('Press button to start');
          case ConnectionState.waiting:
            return const Text('Awaiting result...');
          default:
            if (snapshot.hasError)
              return new Text('Error: ${snapshot.error}');
            else
              return new Text('Result: ${snapshot.data}');
        }
      },
    );
  }

  Widget _button() {
    return new RaisedButton(
      child: const Text('ASYNC ACTION'),
      onPressed: _startAsync,
    );
  }

  void _startAsync() {
    setState(() {
      // _future = asyncFunc(); // Won't throw;
      _future = asyncFunc(something: true); // Will throw
    });
  }
}

Future<String> asyncFunc({bool something}) async {
  if (something == true) {
    throw new FormatException('thrown-error');
  }

  final dur = const Duration(seconds: 2);
  return new Future.delayed(dur, () => 'done');
  // return new Future.delayed(dur, () => new Future.error('async-error'));
}
```

Now, if `asyncFunc()` throws, within the same event-loop cycle, before the SDK
([FutureBuilder][future-builder] in particular) internal machine attaches a
`catchError` to the Future - you get an Unhandled exception!

The [FutureBuilder][future-builder] will eventually show that an error
occurred, but there will be this unhandled exception log.

For some people this is fine.

You can attach a `catchError` yourself, but then the
[FutureBuilder][future-builder] won't get the error state... ever. It will only
get a `null` in `snapshot.data`.

```dart
// lib/main.dart
...
  void _startAsync() {
    setState(() {
      _future = asyncFunc(something: true).catchError((err) {
        // do something with err
        print(err);
      });
    });
  }
...
```

What to do?

Don't get me wrong - that unhandled exception is something that you can guard
against (and should), since it is a parameter sent to the async function, that
causes it to throw.

A release build won't crash the app. It will simply get logged:

```bash
#...
[VERBOSE-2:dart_error.cc(16)] Unhandled exception:
```

## My solutions

### The simple one

```dart
// lib/main.dart
...
  void _startAsync() {
    setState(() {
      _future = asyncFunc(something: true)
      _future.catchError((err) {
        // do something with err
        print(err);
      });
    });
  }
...
```

Just log it yourself? Silly.

### Hoist the error out of the future

Add yet another prop - to hold the caught error. Actually - any error the Future results with.

```dart
// lib/main.dart
...
class _HomePageState extends State<HomePage> {
  Future _future; // Starts as null
  Object _lastError; // Starts as null

  ...

  Widget _futureBuilder() {
    return new FutureBuilder<String>(
      future: _future, // a Future<String> or null
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        // check if _lastError is set since snapshot.error won't get set
        if (_lastError != null) {
          return new Text('Last Error: $_lastError');
        }
        switch (snapshot.connectionState) {
          case ConnectionState.none:
            return const Text('Press button to start');
          case ConnectionState.waiting:
            return const Text('Awaiting result...');
          default:
            // `snapshot.error` will never get set!
            // if (snapshot.hasError)
            //  return new Text('Error: ${snapshot.error}');
            return new Text('Result: ${snapshot.data}');
        }
      },
    );
  }

  ...

  void _startAsync() {
    setState(() {
      _lastError = null;

      _future = asyncFunc().catchError((err) {
        // Note - this will be set outside of setState,
        // but the build() call won't have ran yet.
        _lastError = err;
      });
    });
  }
...
```

### Simply don't use FutureBuilder

Use props for the state and the result (or for the error and the result).

Not great, but whatever.

```dart
// lib/main.dart
import 'dart:async';
import 'package:flutter/material.dart';

void main() => runApp(new App());

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => new _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _futureState;
  String _futureResult;

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new Center(
        child: new Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _resultWidget(),
            _button(),
          ],
        ),
      ),
    );
  }

  Widget _resultWidget() {
    if (_futureState != null) {
      return new Text(_futureState);
    }

    if (_futureResult == null) {
      return const Text('Press button to start');
    }

    return new Text('Result: $_futureResult');
  }

  Widget _button() {
    return new RaisedButton(
      child: const Text('ASYNC ACTION'),
      onPressed: _startAsync,
    );
  }

  Future _startAsync() async {
    setState(() {
      _futureState = 'Awaiting result...';
      _futureResult = null;
    });

    try {
      String result = await asyncFunc(something: true);
      setState(() {
        _futureState = null;
        _futureResult = result;
      });
    } catch (err) {
      setState(() {
        _futureState = 'Error: $err';
      });
    }
  }
}

Future<String> asyncFunc({bool something}) async {
  if (something == true) {
    throw new FormatException('thrown-error');
  }

  final dur = const Duration(seconds: 2);
  return new Future.delayed(dur, () => 'done');
  // return new Future.delayed(dur, () => new Future.error('async-error'));
}
```

## runZoned

I want to mention [runZoned][run-zoned], since it could be used to capture
unhandled exceptions, but it is not end-user-friendly and all I could think of
is to log unhandled errors for analysis.

```dart
// lib/main.dart
...
import 'dart:async';

void main() {
  runZoned(() {
    runApp(new App());
  }, onError: (error) {
    // The triple mights:
    //  - The app is in a state, where it might have crashed.
    //  - Recovery might not be possible.
    //  - But there might be an upcoming catchError.

    // Log the error so a following app-run can submit it for you to analyse.

    // Ensure you don't cause other, unwanted, exceptions at this point!

    // Finally - re-throw the error so any catchError that will get attached
    // later can act upon it.
    throw error;
  });
}
...
```

I'm open for discussion [on Twitter](https://twitter.com/avioli).

[flutter]: https://flutter.io
[future-builder]: https://docs.flutter.io/flutter/widgets/FutureBuilder-class.html
[dart]: https://www.dartlang.org
[future]: https://api.dartlang.org/stable/1.24.3/dart-async/Future-class.html
[run-zoned]: https://api.dartlang.org/stable/1.24.3/dart-async/runZoned.html

Tags: Dart Flutter