import 'domain_event.dart';

final class InMemoryEventBus implements EventBus {
  final Map<Type, List<DomainEventHandler<DomainEvent>>> _handlers = {};

  @override
  Future<void> publish(DomainEvent event) async {
    final List<DomainEventHandler<DomainEvent>> handlers = _handlers[event.runtimeType] ?? const [];
    for (final DomainEventHandler<DomainEvent> handler in handlers) {
      await handler(event);
    }
  }

  @override
  void subscribe<T extends DomainEvent>(DomainEventHandler<T> handler) {
    final List<DomainEventHandler<DomainEvent>> handlers = _handlers.putIfAbsent(
      T,
      () => <DomainEventHandler<DomainEvent>>[],
    );
    handlers.add((DomainEvent event) => handler(event as T));
  }
}
