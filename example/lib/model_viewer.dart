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
    return Scaffold(
      appBar: AppBar(title: Text("Model Viewer")),
      body: ModelViewer(
        backgroundColor: Color.fromARGB(0xFF, 0xEE, 0xEE, 0xEE),
        //src: 'https://modelviewer.dev/shared-assets/models/Astronaut.glb',
        src: pathToModel, // a bundled asset file
        alt: "A shoe.",
        ar: false,
        autoRotate: true,
        cameraControls: true,
      ),
    );
  }

}