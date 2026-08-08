import '../di/service_registry.dart';

abstract interface class BillAvePlugin {
  String get id;
  String get name;
  String get version;
  void register(ServiceRegistry registry);
}
