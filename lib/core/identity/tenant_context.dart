final class TenantContext {
  const TenantContext({
    required this.tenantId,
    required this.userId,
    this.restaurantId,
    this.branchId,
    this.deviceId,
  });

  final String tenantId;
  final String userId;
  final String? restaurantId;
  final String? branchId;
  final String? deviceId;
}
