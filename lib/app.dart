import 'package:flutter/material.dart';

import 'bootstrap/billave_bootstrap.dart';

Future<void> runBillAveApp() async {
  WidgetsFlutterBinding.ensureInitialized();
  await BillAveBootstrap.initialize();
  runApp(const BillAveApp());
}

class BillAveApp extends StatelessWidget {
  const BillAveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Text('BillAve is starting...'),
        ),
      ),
    );
  }
}
