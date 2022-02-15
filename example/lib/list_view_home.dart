import 'package:flutter/material.dart';
import 'package:model_viewer_plus_example/model_viewer.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage();
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("<model-viewer> example"),
        ),
        body: ListView(
          children: [
            Card(
                child: ListTile(
                  title:Text("Shoe") ,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ModelViewPage(pathToModel: 'etc/assets/MaterialsVariantsShoe.glb',)),)
                ),
            ),
            Card(
              child: ListTile(
                title: Text("Astronaut"),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ModelViewPage(pathToModel: 'etc/assets/Astronaut.glb',)),)
              ),
            ),
            Card(
              child: ListTile(
                  title: Text("EC Pipes"),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ModelViewPage(pathToModel: 'etc/assets/EC_Pipes.gltf',)),)
              ),
            ),
          ],
          shrinkWrap: true,
        )
    );
  }
}
