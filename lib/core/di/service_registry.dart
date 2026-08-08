typedef ServiceFactory<T extends Object> = T Function(ServiceRegistry registry);

final class ServiceRegistry {
  final Map<Type, Object> _singletons = {};
  final Map<Type, ServiceFactory<Object>> _factories = {};

  void registerSingleton<T extends Object>(T instance) {
    _singletons[T] = instance;
  }

  void registerFactory<T extends Object>(ServiceFactory<T> factory) {
    _factories[T] = (ServiceRegistry registry) => factory(registry);
  }

  T resolve<T extends Object>() {
    final Object? singleton = _singletons[T];
    if (singleton != null) {
      return singleton as T;
    }

    final ServiceFactory<Object>? factory = _factories[T];
    if (factory != null) {
      return factory(this) as T;
    }

    throw StateError('Service of type $T is not registered.');
  }
}
