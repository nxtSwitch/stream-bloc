import 'dart:async';

import 'package:bloc/bloc.dart';

mixin BlocLifecycleMixin<Event> on BlocEventSink<Event> {
  final List<StreamSubscription<Object?>> _subscription = [];

  StreamSubscription<T> listenToStream<T>(
    Stream<T> stream,
    void Function(T event) subscriber,
  ) {
    final subscription = stream.listen(subscriber);
    _subscription.add(subscription);
    return subscription;
  }

  StreamSubscription<T> listenToStreamable<T>(
    Streamable<T> streamable,
    void Function(T event) subscriber,
  ) =>
      listenToStream(streamable.stream, subscriber);

  StreamSubscription<T> reactToStream<T>(
    Stream<T> stream,
    Event Function(T event) reaction,
  ) =>
      listenToStream(stream, (event) => add(reaction(event)));

  StreamSubscription<T> reactToStreamable<T>(
    Streamable<T> streamable,
    Event Function(T event) reaction,
  ) =>
      reactToStream(streamable.stream, reaction);

  @override
  Future<void> close() async {
    await Future.forEach<StreamSubscription<Object?>>(
      _subscription,
      (subscription) => subscription.cancel(),
    );
    return super.close();
  }
}