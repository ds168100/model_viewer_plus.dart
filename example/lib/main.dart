import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  MyApp({super.key});

  late WebViewController _controller;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(title: const Text('Model Viewer')),
        body: Column(
          children: [
            Expanded(
              child: ModelViewer(
                backgroundColor: Color.fromARGB(0xFF, 0xEE, 0xEE, 0xEE),
                src: 'assets/shoe.gltf',
                alt: 'A 3D model of an astronaut',
                ar: true,
                arModes: ['scene-viewer', 'webxr', 'quick-look'],
                autoRotate: true,
                iosSrc:
                    'https://modelviewer.dev/shared-assets/models/Astronaut.usdz',
                disableZoom: false,
                onWebViewCreated: (WebViewController controller) =>
                    (_controller = controller),
              ),
            ),
            ElevatedButton(
                onPressed: () async {
                  await _controller.runJavaScript(
                      'changeTexture("/textures/assets/diffuseStreet.jpg")');
                },
                child: Text("Call JavaScript"))
          ],
        ),
      ),
    );
  }
}
