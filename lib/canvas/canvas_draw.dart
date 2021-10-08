import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import '../models/model.dart';

/// A simple canvas draws a group of model-based ([Options]) filled paths for each tick of the redraw.
class SimplePaint extends CustomPainter {
  final Options _optionsParam;
  final BoxConstraints _constraints;

  /// ### A simple canvas draws a group of model-based ([Options]) filled paths for each tick of the redraw.
  const SimplePaint({
    required BoxConstraints constraints,
    required Options optionsParam,
  })  : _optionsParam = optionsParam,
        _constraints = constraints;

  @override
  void paint(Canvas canvas, Size size) {
    final List<LayerModel> _listLayerModel = _optionsParam.layers;
    final List<double> _listLayerScales = _optionsParam.layerScales;
    final List<int> _layerNumbers = _optionsParam.layerNumbers;
    int _i = 0;
    try {
      for (final int _layerNumber in _layerNumbers) {
        final _layerModel = _listLayerModel[_layerNumber];
        final Path _path = Path();
        final Paint? _paintStyle = _layerModel.paintStyle;
        final double _scale = _listLayerScales[_i++] * _layerModel.scaleLayer;
        for (int i = 0; i < _layerModel.points.length; i++) {
          final int v0 = (i + 0) % _layerModel.points.length;
          final int v1 = (i + 1) % _layerModel.points.length;

          /// If the point to draw the line coincides with the origin of the Bézier path
          if (_layerModel.points[0] == _layerModel.points[i]) {
            _path.moveTo(
              _layerModel.points[v0].x,
              _layerModel.points[v0].y,
            );
            _path.cubicTo(
              _layerModel.points[v0].cNext?.dx ?? 0,
              _layerModel.points[v0].cNext?.dy ?? 0,
              _layerModel.points[v1].cPrev?.dx ?? 0,
              _layerModel.points[v1].cPrev?.dy ?? 0,
              _layerModel.points[v1].x,
              _layerModel.points[v1].y,
            );
          } else {
            _path.cubicTo(
              _layerModel.points[v0].cNext?.dx ?? 0,
              _layerModel.points[v0].cNext?.dy ?? 0,
              _layerModel.points[v1].cPrev?.dx ?? 0,
              _layerModel.points[v1].cPrev?.dy ?? 0,
              _layerModel.points[v1].x,
              _layerModel.points[v1].y,
            );
          }
        }
        final double xShift =
            _constraints.maxWidth / 2 - _constraints.maxWidth * _scale / 2;
        final double yShift =
            _constraints.maxHeight / 2 - _constraints.maxHeight * _scale / 2;
        if (_paintStyle != null) {
          canvas.drawPath(
            _path.transform(Float64List.fromList([
              _scale, 0, 0, 0, //
              0, _scale, 0, 0, //
              0, 0, _scale, 0, //
              xShift, yShift, 0, 1, //
            ])),
            _paintStyle,
          );
        }
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
