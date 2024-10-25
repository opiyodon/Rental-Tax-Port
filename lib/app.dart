import 'package:flutter/material.dart';
import 'package:rental_tax_port/routes.dart';
import 'package:rental_tax_port/theme.dart';

class RentalTaxPortApp extends StatelessWidget {
  const RentalTaxPortApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Rental Tax Port',
      theme: appTheme,
      initialRoute: '/',
      onGenerateRoute: generateRoute,
    );
  }
}