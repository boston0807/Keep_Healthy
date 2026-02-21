import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => CameraPageState();
}

class CameraPageState extends State<CameraPage> {
  late final List<CameraDescription>? _cameras;
  late CameraController _controller;
  Future<void>? _initializeControllerFuture;
  bool isFrontCamera = false;

  Future<void> getCamera() async{
    _cameras = await availableCameras();
  }

  Future<void> setupCamera() async{
    await getCamera();
    _controller = CameraController(_cameras![1], ResolutionPreset.medium);
    _initializeControllerFuture = _controller.initialize();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    setupCamera();
  }

  @override
  void dispose(){
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
      ),
      body: FutureBuilder(future: _initializeControllerFuture, builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done){
          return Stack(
            children: [
              CameraPreview(_controller),
              Align(
                alignment: .bottomCenter,
                child: Container(
                padding: const EdgeInsets.symmetric(vertical: 20),
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  color: Colors.black,
                ),
                child: Stack(
                  
                  alignment: Alignment.center,
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.circle, color: Color.fromARGB(255, 255, 255, 255)),
                      iconSize: 80,
                    ),
                    Positioned(
                      right: 70,
                      child: IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.cameraswitch_rounded, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              )
              )
            ],
          );
        } else{
          return const Center(child: CircularProgressIndicator(),);
        }

      }),
      backgroundColor: const Color.fromARGB(255, 0, 0, 0),
    );
  }
}