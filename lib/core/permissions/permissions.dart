import '../identity/tenant_context.dart';

final class Permission {
  const Permission(this.value);
  final String value;
}

abstract interface class PermissionChecker {
  Future<bool> hasPermission(TenantContext context, Permission permission);
}
