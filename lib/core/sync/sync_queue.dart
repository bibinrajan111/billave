import '../identity/tenant_context.dart';
import '../result/result.dart';

enum SyncOperationType { create, update, delete, command }

enum SyncStatus { pending, running, succeeded, failed }

final class SyncOperation {
  const SyncOperation({
    required this.id,
    required this.type,
    required this.entityType,
    required this.entityId,
    required this.payload,
    required this.context,
    required this.createdAtUtc,
    this.idempotencyKey,
  });

  final String id;
  final SyncOperationType type;
  final String entityType;
  final String entityId;
  final Map<String, Object?> payload;
  final TenantContext context;
  final DateTime createdAtUtc;
  final String? idempotencyKey;
}

abstract interface class SyncQueue {
  Future<Result<void>> enqueue(SyncOperation operation);
  Future<Result<List<SyncOperation>>> pending({int limit = 100});
  Future<Result<void>> markSucceeded(String operationId);
  Future<Result<void>> markFailed(String operationId, Failure failure);
}
