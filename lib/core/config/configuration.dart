enum ConfigurationScope { platform, country, tenant, restaurant, branch, device }

final class ConfigurationKey<T extends Object> {
  const ConfigurationKey(this.name);
  final String name;
}

abstract interface class ConfigurationProvider {
  T? get<T extends Object>(ConfigurationKey<T> key, {required ConfigurationScope scope});
}
