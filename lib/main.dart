import 'package:flutter/material.dart';
import 'theme.dart';
import 'root_nav.dart';

void main() => runApp(const EmbaApp());

class EmbaApp extends StatelessWidget {
  const EmbaApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EMBA Fan App',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      home: const RootNav(),
    );
  }
}
