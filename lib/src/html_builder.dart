/* This is free and unencumbered software released into the public domain. */

import 'dart:convert' show htmlEscape;

import 'package:flutter/material.dart';

abstract class HTMLBuilder {
  HTMLBuilder._();

  static String build(
      {final String htmlTemplate = '',
      required final String src,
      final Color backgroundColor = const Color(0xFFFFFF),
      final String? alt,
      final bool? ar,
      final List<String>? arModes,
      final String? arScale,
      final bool? autoRotate,
      final int? autoRotateDelay,
      final bool? autoPlay,
      //final List<String>? textures,
      final bool? cameraControls,

      final String? iosSrc}) {
    final html = StringBuffer(htmlTemplate);
    html.write('<model-viewer');
    html.write(' id="model"');
    html.write(' src="${htmlEscape.convert(src)}"');
    html.write(
        ' style="background-color: rgb(${backgroundColor.red}, ${backgroundColor.green}, ${backgroundColor.blue});"');
    if (alt != null) {
      html.write(' alt="${htmlEscape.convert(alt)}"');
    }
    // TODO: animation-name
    // TODO: animation-crossfade-duration
    if (ar ?? false) {
      html.write(' ar');
    }
    if (arModes != null) {
      html.write(' ar-modes="${htmlEscape.convert(arModes.join(' '))}"');
    }
    if (arScale != null) {
      html.write(' ar-scale="${htmlEscape.convert(arScale)}"');
    }
    if (autoRotate ?? false) {
      html.write(' auto-rotate');
    }
    if (autoRotateDelay != null) {
      html.write(' auto-rotate-delay="$autoRotateDelay"');
    }
    if (autoPlay ?? false) {
      html.write(' autoplay');
    }
    // TODO: skybox-image
    if (cameraControls ?? false) {
      html.write(' camera-controls');
    }
    // TODO: camera-orbit
    // TODO: camera-target
    // TODO: environment-image
    // TODO: exposure
    // TODO: field-of-view
    // TODO: interaction-policy
    // TODO: interaction-prompt
    // TODO: interaction-prompt-style
    // TODO: interaction-prompt-threshold
    if (iosSrc != null) {
      html.write(' ios-src="${htmlEscape.convert(iosSrc)}"');
    }
    // TODO: max-camera-orbit
    // TODO: max-field-of-view
    // TODO: min-camera-orbit
    // TODO: min-field-of-view
    // TODO: poster
    // TODO: loading
    // TODO: quick-look-browsers
    // TODO: reveal
    // TODO: shadow-intensity
    // TODO: shadow-softness

    html.writeln('></model-viewer>');
    /*
    html.write('<center><section>');
    //html.write('><section>');
    //html.write(' <center><b>Inspection Type:</b> <select id="variant"></select></center>');
    html.write('<center><select id="variant">');
    html.write('<option value="Default">Default</option>');
    /*
    for(var i=0; i<textures!.length; i++){
      var newOption = '<option value="textures/${i}">${textures[i]}</option>';
      html.write(newOption);
    }

     */
    html.write('</select></center>');
    html.write('</section></center>');
    //html.writeln('</model-viewer>');
     */

    return html.toString();
  }
}

