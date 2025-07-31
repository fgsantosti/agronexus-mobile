import 'package:agronexus/config/app.dart';
import 'package:agronexus/config/inject_dependencies.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl_standalone.dart';
import 'dart:io';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  configureDependencies();

  await findSystemLocale();
  LocationPermission locationPermission = await Geolocator.checkPermission();

  if (locationPermission == LocationPermission.denied) {
    await Geolocator.requestPermission();
  }
  // Check if location services are enabled
  HttpOverrides.global = MyHttpOverrides();

  runApp(const AgroNexusApp());
}

 class MyHttpOverrides extends HttpOverrides{
  @override
  HttpClient createHttpClient(SecurityContext? context){
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port)=> true;
  }
}
