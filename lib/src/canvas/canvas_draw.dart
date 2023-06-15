import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
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
    final List<LayerModel> listLayerModel = _optionsParam.layers;
    final List<double> listLayerScales = _optionsParam.layerScales;
    final List<int> layerNumbers = _optionsParam.layerNumbers;
    int i = 0;
    try {
      for (final int layerNumber in layerNumbers) {
        final layerModel = listLayerModel[layerNumber];
        final Path path = Path();
        final Paint? paintStyle = layerModel.paintStyle;
        final double scale = listLayerScales[i++] * layerModel.scaleLayer;
        for (int i = 0; i < layerModel.points.length; i++) {
          final int v0 = (i + 0) % layerModel.points.length;
          final int v1 = (i + 1) % layerModel.points.length;

          /// If the point to draw the line coincides with the origin of the Bézier path
          if (layerModel.points[0] == layerModel.points[i]) {
            path.moveTo(
              layerModel.points[v0].x,
              layerModel.points[v0].y,
            );
            path.cubicTo(
              layerModel.points[v0].cNext?.dx ?? 0,
              layerModel.points[v0].cNext?.dy ?? 0,
              layerModel.points[v1].cPrev?.dx ?? 0,
              layerModel.points[v1].cPrev?.dy ?? 0,
              layerModel.points[v1].x,
              layerModel.points[v1].y,
            );
          } else {
            path.cubicTo(
              layerModel.points[v0].cNext?.dx ?? 0,
              layerModel.points[v0].cNext?.dy ?? 0,
              layerModel.points[v1].cPrev?.dx ?? 0,
              layerModel.points[v1].cPrev?.dy ?? 0,
              layerModel.points[v1].x,
              layerModel.points[v1].y,
            );
          }
        }
        final double xShift =
            _constraints.maxWidth / 2 - _constraints.maxWidth * scale / 2;
        final double yShift =
            _constraints.maxHeight / 2 - _constraints.maxHeight * scale / 2;
        if (paintStyle != null) {
          canvas.drawPath(
            path.transform(Float64List.fromList([
              scale, 0, 0, 0, //
              0, scale, 0, 0, //
              0, 0, scale, 0, //
              xShift, yShift, 0, 1, //
            ])),
            paintStyle,
          );
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('$e');
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
