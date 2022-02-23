/* This is free and unencumbered software released into the public domain. */

import 'dart:async' show Completer;
import 'dart:convert' show utf8;
import 'dart:io'
    show File, HttpRequest, HttpServer, HttpStatus, InternetAddress, Platform;
import 'dart:typed_data' show Uint8List;

import 'package:android_intent_plus/flag.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:android_intent_plus/android_intent.dart' as android_content;
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'html_builder.dart';

import 'model_viewer_plus.dart';

class ModelViewerState extends State<ModelViewer> {
  final Completer<WebViewController> _controller =
      Completer<WebViewController>();
  late WebViewController controller;
  String dropDownText = "Default";
  PanelController pc = PanelController();

  HttpServer? _proxy;

  @override
  void initState() {
    super.initState();
    _initProxy();
  }

  @override
  void dispose() {
    super.dispose();
    if (_proxy != null) {
      _proxy!.close(force: true);
      _proxy = null;
    }
  }

  @override
  void didUpdateWidget(final ModelViewer oldWidget) {
    super.didUpdateWidget(oldWidget);
    // TODO
  }

  Widget createWebView() {
    return WebView(
      initialUrl: null,
      javascriptMode: JavascriptMode.unrestricted,
      initialMediaPlaybackPolicy: AutoMediaPlaybackPolicy.always_allow,
      onWebViewCreated: (final WebViewController webViewController) async {
        controller = webViewController;
        _controller.complete(webViewController);
        final host = _proxy!.address.address;
        final port = _proxy!.port;
        final url = "http://$host:$port/";
        print('>>>> ModelViewer initializing... <$url>'); // DEBUG
        await webViewController.loadUrl(url);
      },
      navigationDelegate: (final NavigationRequest navigation) async {
        //print('>>>> ModelViewer wants to load: <${navigation.url}>'); // DEBUG
        if (!Platform.isAndroid) {
          return NavigationDecision.navigate;
        }
        if (!navigation.url.startsWith("intent://")) {
          return NavigationDecision.navigate;
        }
        try {
          // See: https://developers.google.com/ar/develop/java/scene-viewer
          final intent = android_content.AndroidIntent(
            action: "android.intent.action.VIEW",
            // Intent.ACTION_VIEW
            data: "https://arvr.google.com/scene-viewer/1.0",
            arguments: <String, dynamic>{
              'file': widget.src,
              'mode': 'ar_only',
            },
            package: "com.google.ar.core",
            flags: <int>[
              Flag.FLAG_ACTIVITY_NEW_TASK
            ], // Intent.FLAG_ACTIVITY_NEW_TASK,
          );
          await intent.launch();
        } catch (error) {
          print('>>>> ModelViewer failed to launch AR: $error'); // DEBUG
        }
        return NavigationDecision.prevent;
      },
      onPageStarted: (final String url) {
        //print('>>>> ModelViewer began loading: <$url>'); // DEBUG
      },
      onPageFinished: (final String url) {
        controller
            .runJavascript('document.body.style.overflow = \'hidden\';');
        //print('>>>> ModelViewer finished loading: <$url>'); // DEBUG
      },
      onWebResourceError: (final WebResourceError error) {
        print(
            '>>>> ModelViewer failed to load: ${error.description} (${error.errorType} ${error.errorCode})'); // DEBUG
      },
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
            textureCommandSwitch = 'textures/${(index - 1)}';
          }
          var jsCommand = "changeTexture('${textureCommandSwitch}')";
          print(jsCommand);
          await controller.runJavascript(jsCommand);
          await pc.close();
          },
          title: Text((index == 0) ? ("Default") : (widget.textures[index - 1].name)),

          trailing: FutureBuilder<IconData>(
              future: (index == 0) ? defaultIcon() : determineFileStatusIcon(widget.textures[index-1].path),
              builder:
                  (BuildContext context, AsyncSnapshot<IconData> snapshot) {
                return Icon(snapshot.data);
              }),

        ),
      );
    return cardToReturn;
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
                   itemCount: (widget.textures.length + 1),
                   itemBuilder: (BuildContext context, int i) {
                     //return getSingleTextureCard(_textureListToShow[i], modelToShow, currentScene, context);
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

              TextButton(onPressed: () => controller.runJavascript("decreaseYaw()"), child: Text("X-", style: TextStyle(fontSize: 20, color: Colors.white),),),
              TextButton(onPressed: () => controller.runJavascript("increaseYaw()"), child: Text("X+", style: TextStyle(fontSize: 20, color: Colors.white),),),
              TextButton(onPressed: () => controller.runJavascript("decreasePitch()"), child: Text("Y-", style: TextStyle(fontSize: 20, color: Colors.white),),),
              TextButton(onPressed: () => controller.runJavascript("increasePitch()"), child: Text("Y+", style: TextStyle(fontSize: 20, color: Colors.white),),),
              TextButton(onPressed: () => controller.runJavascript("decreaseRoll()"), child: Text("Z-", style: TextStyle(fontSize: 20, color: Colors.white),),),
              TextButton(onPressed: () => controller.runJavascript("increaseRoll()"), child: Text("Z+", style: TextStyle(fontSize: 20, color: Colors.white),),),
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



  @override
  Widget build(final BuildContext context) {
    return Container(
      child: SlidingUpPanel(
        renderPanelSheet: false,
        controller: pc,
        backdropEnabled: true,
        panelBuilder: (ScrollController sc) => _scrollingList(sc, context),
        collapsed: _collapsed(context),
        body: Container(
          //color: ui_colors.determineAppBarColor(context),
          child: SafeArea(
            child: Stack(
              children: [
                Container(
                  color: Theme.of(context).canvasColor,
                  child: createWebView(),
                ),
              ],
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

    for (var i = 0; i < widget.textures.length; i++) {
      var item = DropdownMenuItem<String>(
        child: Text(widget.textures[i].name),
        value: 'textures/${i}',
      );
      items.add(item);
    }
    return items;
  }

  String _buildHTML(final String htmlTemplate) {
    var textureNames = <String>[];
    for (var element in widget.textures) {
      textureNames.add(element.name);
    }
    return HTMLBuilder.build(
      htmlTemplate: htmlTemplate,
      backgroundColor: widget.backgroundColor,
      src: '/model',
      alt: widget.alt,
      ar: widget.ar,
      arModes: widget.arModes,
      arScale: widget.arScale,
      autoRotate: widget.autoRotate,
      autoRotateDelay: widget.autoRotateDelay,
      autoPlay: widget.autoPlay,
      cameraControls: widget.cameraControls,
      textures: textureNames,
      iosSrc: widget.iosSrc,
    );
  }

  Future<void> _initProxy() async {
    final url = Uri.parse(widget.src);

    _proxy = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    _proxy!.listen((final HttpRequest request) async {
      //print("${request.method} ${request.uri}"); // DEBUG
      //print(request.headers); // DEBUG
      final response = request.response;

      switch (request.uri.path) {
        case '/':
        case '/index.html':
          final htmlTemplate = await rootBundle.loadString(
              'packages/model_viewer_plus/etc/assets/template.html');
          final html = utf8.encode(_buildHTML(htmlTemplate));
          response
            ..statusCode = HttpStatus.ok
            ..headers.add("Content-Type", "text/html;charset=UTF-8")
            ..headers.add("Content-Length", html.length.toString())
            ..add(html);
          await response.close();
          break;

        case '/model-viewer.js':
          final code = await _readAsset(
              'packages/model_viewer_plus/etc/assets/model-viewer.js');
          response
            ..statusCode = HttpStatus.ok
            ..headers
                .add("Content-Type", "application/javascript;charset=UTF-8")
            ..headers.add("Content-Length", code.lengthInBytes.toString())
            ..add(code);
          await response.close();
          break;

        case '/external-list.js':
          final code = await _readAsset(
              'packages/model_viewer_plus/etc/assets/external-list.js');
          response
            ..statusCode = HttpStatus.ok
            ..headers
                .add("Content-Type", "application/javascript;charset=UTF-8")
            ..headers.add("Content-Length", code.lengthInBytes.toString())
            ..add(code);
          await response.close();
          break;

        case '/variant-list.js':
          final code = await _readAsset(
              'packages/model_viewer_plus/etc/assets/variant-list.js');
          response
            ..statusCode = HttpStatus.ok
            ..headers
                .add("Content-Type", "application/javascript;charset=UTF-8")
            ..headers.add("Content-Length", code.lengthInBytes.toString())
            ..add(code);
          await response.close();
          break;

        case '/model-manipulation.js':
          final code = await _readAsset(
              'packages/model_viewer_plus/etc/assets/model-manipulation.js');
          response
            ..statusCode = HttpStatus.ok
            ..headers
                .add("Content-Type", "application/javascript;charset=UTF-8")
            ..headers.add("Content-Length", code.lengthInBytes.toString())
            ..add(code);
          await response.close();
          break;

        case '/panningScript.js':
          final code = await _readAsset(
              'packages/model_viewer_plus/etc/assets/panningScript.js');
          response
            ..statusCode = HttpStatus.ok
            ..headers
                .add("Content-Type", "application/javascript;charset=UTF-8")
            ..headers.add("Content-Length", code.lengthInBytes.toString())
            ..add(code);
          await response.close();
          break;

        case '/additionalTextures.json':
          final code = await _readAsset(
              'packages/model_viewer_plus/etc/assets/additionalTextures.json');
          response
            ..statusCode = HttpStatus.ok
            ..headers.add("Content-Type", "application/json;charset=UTF-8")
            ..headers.add("Content-Length", code.lengthInBytes.toString())
            ..add(code);
          await response.close();
          break;

        case '/model':
          if (url.isAbsolute && !url.isScheme("file")) {
            await response.redirect(url); // TODO: proxy the resource
          } else {
            final data = await (url.isScheme("file")
                ? _readFile(url.path)
                : _readAsset(url.path));
            response
              ..statusCode = HttpStatus.ok
              ..headers.add("Content-Type", "application/octet-stream")
              ..headers.add("Content-Length", data.lengthInBytes.toString())
              ..headers.add("Access-Control-Allow-Origin", "*")
              ..add(data);
            await response.close();
          }
          break;

        case '/favicon.ico':
        default:
          var defaultURL = request.uri.toString();
          if (defaultURL.contains("textures/")) {
            var stringPos = defaultURL.lastIndexOf('/');
            var result = (stringPos != -1)
                ? defaultURL.substring((stringPos + 1), defaultURL.length)
                : defaultURL;
            var pos = int.parse(result);
            var textureURL = widget.textures[pos].path;
            var textureURI = Uri.parse(textureURL);

            if (textureURI.isAbsolute && !textureURI.isScheme("file")) {
              await response.redirect(textureURI); // TODO: proxy the resource
            } else {
              final data = await (textureURI.isScheme("file")
                  ? _readFile(textureURI.path)
                  : _readAsset(textureURI.path));
              response
                ..statusCode = HttpStatus.ok
                ..headers.add("Content-Type", "image/png")
                ..headers.add("Content-Length", data.lengthInBytes.toString())
                ..headers.add("Access-Control-Allow-Origin", "*")
                ..add(data);
              await response.close();
            }
          } else {
            final text = utf8.encode("Resource '${request.uri}' not found");
            response
              ..statusCode = HttpStatus.notFound
              ..headers.add("Content-Type", "text/plain;charset=UTF-8")
              ..headers.add("Content-Length", text.length.toString())
              ..add(text);
            await response.close();
          }
          break;
      }
    });
  }

  Future<Uint8List> _readAsset(final String key) async {
    final data = await rootBundle.load(key);
    return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  }

  Future<Uint8List> _readFile(final String path) async {
    return await File(path).readAsBytes();
  }
}
