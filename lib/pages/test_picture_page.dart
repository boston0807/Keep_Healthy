import 'package:flutter/material.dart';
import 'dart:io';

class TestPicturePage extends StatelessWidget {
  final String imagePath;
  const TestPicturePage({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Image.file(File(imagePath)),
    );
  }
}