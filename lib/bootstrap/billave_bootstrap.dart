import '../core/core.dart';

final ServiceRegistry billAveServices = ServiceRegistry();

final class BillAveBootstrap {
  const BillAveBootstrap._();

  static Future<void> initialize() async {
    billAveServices
      ..registerSingleton<Clock>(const SystemClock())
      ..registerSingleton<EventBus>(InMemoryEventBus())
      ..registerSingleton<BillAveLogger>(const ConsoleBillAveLogger());
  }
}
