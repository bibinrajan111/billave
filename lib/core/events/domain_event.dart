import '../identity/tenant_context.dart';

abstract interface class DomainEvent {
  String get eventId;
  String get eventType;
  DateTime get occurredAtUtc;
  TenantContext get context;
  int get schemaVersion;
}

typedef DomainEventHandler<T extends DomainEvent> = Future<void> Function(T event);

abstract interface class EventBus {
  Future<void> publish(DomainEvent event);
  void subscribe<T extends DomainEvent>(DomainEventHandler<T> handler);
}
