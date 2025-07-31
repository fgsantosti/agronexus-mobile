import 'package:agronexus/config/routers/router.dart';
import 'package:agronexus/config/theme/theme.dart';
import 'package:flutter/material.dart';

class AgroNexusApp extends StatelessWidget {
  const AgroNexusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'AgroNexus',
      routerConfig: AgroNexusRouter.router,
      debugShowCheckedModeBanner: false,
      theme: agroNexusTheme,
    );
  }
}
