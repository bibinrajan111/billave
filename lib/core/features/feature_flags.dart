import '../identity/tenant_context.dart';

enum FeatureScope { platform, country, plan, tenant, restaurant, branch }

final class FeatureFlag {
  const FeatureFlag(this.key);
  final String key;
}

abstract interface class FeatureFlagProvider {
  Future<bool> isEnabled(FeatureFlag flag, TenantContext context, {FeatureScope? scope});
}
