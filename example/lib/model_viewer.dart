import 'dart:io';

import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

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
  List<TextureVariants> testTextures = [];
  PanelController pc = PanelController();
  ModelViewer mv;
  _ModelViewPageState(this.pathToModel);

  @override
  void dispose(){
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    testTextures.add(TextureVariants(name: "Lines", path: "etc/assets/textures/splash_background.jpg"));
    testTextures.add(TextureVariants(name: "Beach", path: "etc/assets/textures/diffuseBeach.jpg"));
    testTextures.add(TextureVariants(name: "Midnight", path: "etc/assets/textures/diffuseMidnight.jpg"));
    testTextures.add(TextureVariants(name: "Street", path: "etc/assets/textures/diffuseStreet.jpg"));
    testTextures.add(TextureVariants(name: "Trippy", path: "etc/assets/textures/occlusionRougnessMetalness.jpg"));


    mv = ModelViewer(
      backgroundColor: Color.fromARGB(0xFF, 0xEE, 0xEE, 0xEE),
      //src: 'https://modelviewer.dev/shared-assets/models/Astronaut.glb',
      src: pathToModel, // a bundled asset file
      alt: "A model.",
      ar: false,
      autoRotate: false,
      cameraControls: true,
      textures: testTextures,
    );


    return Scaffold(
      appBar: AppBar(title: Text("Model Viewer")),
      body: Container(
        child: SlidingUpPanel(
          renderPanelSheet: false,
          controller: pc,
          backdropEnabled: true,
          panelBuilder: (ScrollController sc) => _scrollingList(sc, context),
          collapsed: _collapsed(context),
          body: Container(
            //color: ui_colors.determineAppBarColor(context),
            child: SafeArea(
              child: mv
            ),
          ),
        ),
      ),
    );
  }

  List<DropdownMenuItem<String>> generateDropdownItems() {
    var items = <DropdownMenuItem<String>>[];
    var defaultMenu = DropdownMenuItem<String>(
      child: Text('Default'),
      value: "Default",
    );
    items.add(defaultMenu);

    for (var i = 0; i < testTextures.length; i++) {
      var item = DropdownMenuItem<String>(
        child: Text(testTextures[i].name),
        value: 'textures/${i}',
      );
      items.add(item);
    }
    return items;
  }

  Widget _collapsed(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24.0), topRight: Radius.circular(24.0)),
      ),
      //margin: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 0.0),
      child: Column(
        children: [
          Spacer(),
          Row(
            children: [
              Spacer(),
              /*
              IconButton(onPressed: () => controller.runJavascript("increaseScale()"), icon: Icon(Icons.zoom_in, color: Colors.white,)),
              IconButton(onPressed: () => controller.runJavascript("decreaseScale()"), icon: Icon(Icons.zoom_out, color: Colors.white)),
              IconButton(onPressed: () => controller.runJavascript("decreaseYaw()"), icon: Icon(CupertinoIcons.arrow_turn_down_left)),
              IconButton(onPressed: () => controller.runJavascript("increaseYaw()"), icon: Icon(CupertinoIcons.arrow_turn_down_right)),
               */

              TextButton(onPressed: () => mv.webController.runJavascript("decreaseYaw()"), child: Text("X-", style: TextStyle(fontSize: 20, color: Colors.white),),),
              TextButton(onPressed: () => mv.webController.runJavascript("increaseYaw()"), child: Text("X+", style: TextStyle(fontSize: 20, color: Colors.white),),),
              TextButton(onPressed: () => mv.webController.runJavascript("decreasePitch()"), child: Text("Y-", style: TextStyle(fontSize: 20, color: Colors.white),),),
              TextButton(onPressed: () => mv.webController.runJavascript("increasePitch()"), child: Text("Y+", style: TextStyle(fontSize: 20, color: Colors.white),),),
              TextButton(onPressed: () => mv.webController.runJavascript("decreaseRoll()"), child: Text("Z-", style: TextStyle(fontSize: 20, color: Colors.white),),),
              TextButton(onPressed: () => mv.webController.runJavascript("increaseRoll()"), child: Text("Z+", style: TextStyle(fontSize: 20, color: Colors.white),),),
              Spacer(),
            ],
          ),
          Text("▲ Swipe up for texture selection ▲",
            style: TextStyle(
              color: Colors.white,
            ),),
          Spacer(),
        ],
      ),
    );
  }

  Widget _scrollingList(ScrollController sc, BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 5),
      decoration: BoxDecoration(
        color: Theme.of(context).canvasColor,
        borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24.0), topRight: Radius.circular(24.0)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                height: 100,
              ),
              Align(
                alignment: Alignment.center,
                // Align however you like (i.e .centerRight, centerLeft)
                child: Text("Textures"),
              ),
            ],
          ),
          Expanded(
            child: Container(
              color: Theme.of(context).canvasColor,
              child: Stack(
                children: [
                  ListView.builder(
                    controller: sc,
                    itemCount: (testTextures.length + 1),
                    itemBuilder: (BuildContext context, int i) {
                      return createCard(i, context);
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<IconData> determineFileStatusIcon(String pathToFile) async{
    var fileToCheck = File(pathToFile);
    if(fileToCheck.existsSync() || pathToFile.contains("assets/")){
      return Icons.download_done_outlined;
    }else{
      return Icons.cloud;
    }
  }

  Future<IconData> defaultIcon() async{
    return Icons.download_done_outlined;
  }

  Widget createCard(int index, BuildContext context) {
    Widget cardToReturn = Card(
      child: ListTile(onTap: () async {
        var textureCommandSwitch = '';
        if(index == 0){
          textureCommandSwitch = 'Default';
        }else{
          textureCommandSwitch = 'textures/${testTextures[index - 1].path}';
        }
        var jsCommand = "changeTexture('${textureCommandSwitch}')";
        print(jsCommand);
        await mv.webController.runJavascript(jsCommand);
        await pc.close();
      },
        title: Text((index == 0) ? ("Default") : (testTextures[index - 1].name)),

        trailing: FutureBuilder<IconData>(
            future: (index == 0) ? defaultIcon() : determineFileStatusIcon(testTextures[index-1].path),
            builder:
                (BuildContext context, AsyncSnapshot<IconData> snapshot) {
              return Icon(snapshot.data);
            }),

      ),
    );
    return cardToReturn;
  }



}