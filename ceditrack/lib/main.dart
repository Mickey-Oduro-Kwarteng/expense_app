import 'package:flutter/material.dart';
import 'home_page.dart';

void main() {
runApp(const CediTrackApp());
}

class CediTrackApp extends StatelessWidget {
const CediTrackApp({super.key});

@override
Widget build(BuildContext context) {
return MaterialApp(
title: 'CediTrack',
debugShowCheckedModeBanner: false,
theme: ThemeData(useMaterial3: true),
home: const HomePage(),
);
}
}
