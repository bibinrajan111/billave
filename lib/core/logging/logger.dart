import '../identity/tenant_context.dart';

enum LogLevel { debug, info, warning, error, critical }

abstract interface class BillAveLogger {
  void log(LogLevel level, String message, {TenantContext? context, Object? error, StackTrace? stackTrace});
}

final class ConsoleBillAveLogger implements BillAveLogger {
  const ConsoleBillAveLogger();

  @override
  void log(LogLevel level, String message, {TenantContext? context, Object? error, StackTrace? stackTrace}) {
    // Centralized placeholder; replace with structured logging provider before production.
  }
}
