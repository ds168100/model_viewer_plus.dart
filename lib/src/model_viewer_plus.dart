/* This is free and unencumbered software released into the public domain. */

import 'dart:async' show Completer;
import 'dart:convert' show utf8;
import 'dart:io'
    show File, HttpRequest, HttpServer, HttpStatus, InternetAddress, Platform;
import 'dart:typed_data' show Uint8List;

import 'package:android_intent_plus/flag.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:android_intent_plus/android_intent.dart' as android_content;
import 'package:webview_flutter/webview_flutter.dart';

import 'html_builder.dart';

class TextureVariants{
  TextureVariants({
    this.name = "Texutre Name",
    this.path = "Path to texture",
  });
  String name;
  String path;

  factory TextureVariants.fromJson(Map<String, dynamic> json) => TextureVariants(
    name: json["name"],
    path: json["path"],
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "path": path
  };
}


/// Flutter widget for rendering interactive 3D models.
class ModelViewer extends StatefulWidget {
  ModelViewer(
      {Key? key,
      this.backgroundColor = Colors.white,
      required this.src,
      this.alt,
      this.ar,
      this.arModes,
      this.arScale,
      this.autoRotate,
      this.autoRotateDelay,
      this.autoPlay,
      this.cameraControls,
      this.iosSrc,
      required this.textures,
      })
      : super(key: key);

  /// The background color for the model viewer.
  ///
  /// The theme's [ThemeData.scaffoldBackgroundColor] by default.
  final Color backgroundColor;

  /// The URL or path to the 3D model. This parameter is required.
  /// Only glTF/GLB models are supported.
  ///
  /// The parameter value must conform to the following:
  ///
  /// - `http://` and `https://` for HTTP(S) URLs
  ///   (for example, `https://modelviewer.dev/shared-assets/models/Astronaut.glb`)
  ///
  /// - `file://` for local files
  ///
  /// - a relative pathname for Flutter app assets
  ///   (for example, `assets/MyModel.glb`)
  final String src;

  /// Configures the model with custom text that will be used to describe the
  /// model to viewers who use a screen reader or otherwise depend on additional
  /// semantic context to understand what they are viewing.
  final String? alt;

  /// Enable the ability to launch AR experiences on supported devices.
  final bool? ar;

  /// A prioritized list of the types of AR experiences to enable, if available.
  final List<String>? arModes;

  /// Controls the scaling behavior in AR mode in Scene Viewer. Set to "fixed"
  /// to disable scaling of the model, which sets it to always be at 100% scale.
  /// Defaults to "auto" which allows the model to be resized.
  final String? arScale;

  /// Enables the auto-rotation of the model.
  final bool? autoRotate;

  /// Sets the delay before auto-rotation begins. The format of the value is a
  /// number in milliseconds. The default is 3000.
  final int? autoRotateDelay;

  /// If this is true and a model has animations, an animation will
  /// automatically begin to play when this attribute is set (or when the
  /// property is set to true). The default is false.
  final bool? autoPlay;

  /// Enables controls via mouse/touch when in flat view.
  final bool? cameraControls;

  /// The URL to a USDZ model which will be used on supported iOS 12+ devices
  /// via AR Quick Look.
  final String? iosSrc;

  final List<TextureVariants> textures;

  @override
  State<ModelViewer> createState() => _ModelViewerState();
}

class _ModelViewerState extends State<ModelViewer> {
  final Completer<WebViewController> _controller =
      Completer<WebViewController>();

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

  @override
  Widget build(final BuildContext context) {
    return WebView(
      initialUrl: null,
      javascriptMode: JavascriptMode.unrestricted,
      initialMediaPlaybackPolicy: AutoMediaPlaybackPolicy.always_allow,
      onWebViewCreated: (final WebViewController webViewController) async {
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
            action: "android.intent.action.VIEW", // Intent.ACTION_VIEW
          data: "https://arvr.google.com/scene-viewer/1.0",
          arguments:  <String, dynamic>{
                'file': widget.src,
                'mode': 'ar_only',
              },
          package: "com.google.ar.core",
          flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],// Intent.FLAG_ACTIVITY_NEW_TASK,
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
        //print('>>>> ModelViewer finished loading: <$url>'); // DEBUG
      },
      onWebResourceError: (final WebResourceError error) {
        print(
            '>>>> ModelViewer failed to load: ${error.description} (${error.errorType} ${error.errorCode})'); // DEBUG
      },
    );
  }

  String _buildHTML(final String htmlTemplate) {
    List<String> textureNames = [];
    for(var element in widget.textures){
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
          final htmlTemplate = await rootBundle
              .loadString('packages/model_viewer_plus/etc/assets/template.html');
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
            ..headers
                .add("Content-Type", "application/json;charset=UTF-8")
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
          if(defaultURL.contains("textures/")){
            var stringPos = defaultURL.lastIndexOf('/');
            var result = (stringPos != -1)? defaultURL.substring((stringPos + 1), defaultURL.length): defaultURL;
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
          }else{
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
