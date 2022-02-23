import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

class ModelViewPage extends StatefulWidget {
  final String pathToModel;
  ModelViewPage({
    Key key,
    this.pathToModel,
  }) : super(key: key);

  @override
  _ModelViewPageState createState() => _ModelViewPageState(pathToModel);
}

class _ModelViewPageState extends State<ModelViewPage>{
  String pathToModel;
  _ModelViewPageState(this.pathToModel);

  @override
  void dispose(){
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<TextureVariants> testTextures = [];
    testTextures.add(TextureVariants(name: "Lines", path: "etc/assets/textures/splash_background.jpg"));
    testTextures.add(TextureVariants(name: "Beach", path: "etc/assets/textures/diffuseBeach.jpg"));
    testTextures.add(TextureVariants(name: "Midnight", path: "etc/assets/textures/diffuseMidnight.jpg"));
    testTextures.add(TextureVariants(name: "Street", path: "etc/assets/textures/diffuseStreet.jpg"));
    testTextures.add(TextureVariants(name: "Trippy", path: "etc/assets/textures/occlusionRougnessMetalness.jpg"));

    testTextures.add(TextureVariants(name: "Lines 2", path: "etc/assets/textures/splash_background.jpg"));
    testTextures.add(TextureVariants(name: "Beach 2", path: "etc/assets/textures/diffuseBeach.jpg"));
    testTextures.add(TextureVariants(name: "Midnight 2", path: "etc/assets/textures/diffuseMidnight.jpg"));
    testTextures.add(TextureVariants(name: "Street 2", path: "etc/assets/textures/diffuseStreet.jpg"));
    testTextures.add(TextureVariants(name: "Trippy 2", path: "etc/assets/textures/occlusionRougnessMetalness.jpg"));

    return Scaffold(
      appBar: AppBar(title: Text("Model Viewer")),
      body: ModelViewer(
        backgroundColor: Color.fromARGB(0xFF, 0xEE, 0xEE, 0xEE),
        //src: 'https://modelviewer.dev/shared-assets/models/Astronaut.glb',
        src: pathToModel, // a bundled asset file
        alt: "A shoe.",
        ar: false,
        autoRotate: false,
        cameraControls: true,
        textures: testTextures,
      ),
    );
  }

}