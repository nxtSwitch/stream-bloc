import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

/// A convenience mixin that allows to associate subscriptions' lifecycles with
/// [BlocEventSink]'s lifecycle, thus emulating automated subscription
/// management.
mixin BlocLifecycleMixin<Event> on BlocEventSink<Event> {
  final List<StreamSubscription<dynamic>> _subscriptions = [];

  void _maybeAddEvent(Event? event) {
    if (event != null) add(event);
  }

  /// Listens to a `Stream`, automatically closing the subscription on closing
  /// of the [BlocEventSink].
  @protected
  StreamSubscription<T> listenToStream<T>(
    Stream<T> stream,
    void Function(T event) onData, {
    void Function(Object error, StackTrace stackTrace)? onError,
    void Function()? onDone,
  }) {
    final subscription = stream.listen(
      onData,
      onError: onError,
      onDone: onDone,
    );
    _subscriptions.add(subscription);
    return subscription;
  }

  /// Listens to a `Streamable`, automatically closing the subscription on
  /// closing of the [BlocEventSink].
  @protected
  StreamSubscription<T> listenToStreamable<T>(
    Streamable<T> streamable,
    void Function(T event) onData, {
    void Function(Object error, StackTrace stackTrace)? onError,
    void Function()? onDone,
  }) =>
      listenToStream(
        streamable.stream,
        onData,
        onError: onError,
        onDone: onDone,
      );

  /// Reacts to a `Stream` by adding an event to this [BlocEventSink] on certain
  /// source stream events, automatically closing the subscription on closing of
  /// the [BlocEventSink].
  @protected
  StreamSubscription<T> reactToStream<T>(
    Stream<T> stream,
    Event Function(T event) onData, {
    Event Function(Object error, StackTrace stackTrace)? onError,
    Event Function()? onDone,
  }) =>
      listenToStream(
        stream,
        (event) => add(
          onData(event),
        ),
        onError: (error, stackTrace) => _maybeAddEvent(
          onError?.call(error, stackTrace),
        ),
        onDone: () => _maybeAddEvent(
          onDone?.call(),
        ),
      );

  /// Reacts to a `Streamable` by adding an event to this [BlocEventSink] on
  /// certain source streamable events, automatically closing the subscription
  /// on closing of the [BlocEventSink].
  @protected
  StreamSubscription<T> reactToStreamable<T>(
    Streamable<T> streamable,
    Event Function(T event) onData, {
    Event Function(Object error, StackTrace stackTrace)? onError,
    Event Function()? onDone,
  }) =>
      reactToStream(
        streamable.stream,
        onData,
        onError: onError,
        onDone: onDone,
      );

  @override
  Future<void> close() async {
    for (final subscription in _subscriptions) {
      await subscription.cancel();
    }
    return super.close();
  }
}
