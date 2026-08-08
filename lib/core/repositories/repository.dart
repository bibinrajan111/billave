import '../identity/tenant_context.dart';
import '../result/result.dart';

abstract interface class Repository<TEntity, TId> {
  Future<Result<TEntity?>> findById(TId id, TenantContext context);
  Future<Result<void>> save(TEntity entity, TenantContext context);
}
