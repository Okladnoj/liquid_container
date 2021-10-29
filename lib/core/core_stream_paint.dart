import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:vector_math/vector_math.dart';

import '../models/model.dart';

/// The main purpose of this class is to find many points of the contour of the liquid widget, fill in the physico-dynamic model and calculate the properties of this model before the next drawing.
class CorePaint {
  late final double height;
  late final double width;
  late final double topRight;
  late final double bottomRight;
  late final double topLeft;
  late final double bottomLeft;
  late Options optionsParam;
  late List<LayerModel> _listLayerModel;
  late Set<Offset> _allOffsets;
  late final double _gap;
  Ticker? _timerOfRedraw;
  final Path _path = Path();
  late bool _isReadTouch;

  /// The main purpose of this class is to find many points of the contour of the liquid widget, fill in the physico-dynamic model and calculate the properties of this model before the next drawing.

  CorePaint({
    required this.height,
    required this.width,
    required this.topRight,
    required this.bottomRight,
    required this.topLeft,
    required this.bottomLeft,
    required this.optionsParam,
  }) {
    _gap = optionsParam.gap;
    _listLayerModel = optionsParam.layers;
    _outputController = StreamController();
    _inputController = StreamController();
    _inputController.stream.listen((event) {
      _updateTouches(event);
    });
    _isReadTouch = false;
    _getPoints();
    _writeDynamicPoints();
    _startRepaint();
  }

  late StreamController<List<LayerModel>> _outputController;

  late StreamController<List<TouchModel>> _inputController;

  Stream<List<LayerModel>> get streamListLayerModel => _outputController.stream;

  StreamSink<List<TouchModel>> get updatePointsStream => _inputController.sink;

  void _updatePoints() {
    final math.Random _random = math.Random();
    final List<TouchModel> touches = optionsParam.touches;
    for (final LayerModel layer in optionsParam.layers) {
      for (final DynamicPoint point in layer.points) {
        final double dx = point.ox - point.x + (_random.nextDouble() - 0.5) * optionsParam.noise;
        final double dy = point.oy - point.y + (_random.nextDouble() - 0.5) * optionsParam.noise;
        final double d = math.sqrt(dx * dx + dy * dy);
        final double f = d * optionsParam.forceFactor;
        point.vx += f * ((dx / d).isNaN ? 0 : (dx / d));
        point.vy += f * ((dy / d).isNaN ? 0 : (dy / d));
        for (int touchIndex = 0; touchIndex < touches.length; touchIndex++) {
          final TouchModel touch = touches[touchIndex];
          layer.paintStyle?.shader = ui.Gradient.radial(Offset(touch.x, touch.y), math.max(width, height), [
            (optionsParam.layers[0].color ?? const Color(0x00000000)),
            (optionsParam.layers.last.color ?? const Color(0x00000000))
          ]);
          double touchForce = layer.touchForce;
          if (_path.contains(Offset(touch.x, touch.y))) {
            touchForce *= -optionsParam.hoverFactor;
          } else {
            layer.paintStyle?.shader = null;
          }
          final double mx = point.x - touch.x;
          final double my = point.y - touch.y;
          final double md = math.sqrt(mx * mx + my * my);
          final double mf = math.max(
            -layer.forceLimit.toDouble(),
            math.min(layer.forceLimit.toDouble(), (touchForce * touch.force) / md),
          );
          point.vx += mf * ((mx / d).isNaN ? 0 : (mx / md));
          point.vy += mf * ((my / d).isNaN ? 0 : (my / md));
        }
        if (touches.isEmpty) {
          layer.paintStyle?.shader = null;
        }
        point.vx *= layer.viscosity;
        point.vy *= layer.viscosity;
        point.x += point.vx;
        point.y += point.vy;
      }
    }

    for (final LayerModel layer in optionsParam.layers) {
      for (final DynamicPoint point in layer.points) {
        _calculateNextPrev(point);
      }
    }
  }

  void _calculateNextPrev(DynamicPoint point) {
    final prev = point.pPrev;
    final next = point.pNext;
    final dPrev = _distanceDynamicPoint(point, prev);
    final dNext = _distanceDynamicPoint(point, next);
    final Line line = Line(
      x: (next?.x ?? 0) - (prev?.x ?? 0),
      y: (next?.y ?? 0) - (prev?.y ?? 0),
    );
    final dLine = math.sqrt(line.x * line.x + line.y * line.y);

    point.cPrev = Offset(
      point.x - (line.x / dLine) * dPrev * optionsParam.tension,
      point.y - (line.y / dLine) * dPrev * optionsParam.tension,
    );
    point.cNext = Offset(
      point.x + (line.x / dLine) * dNext * optionsParam.tension,
      point.y + (line.y / dLine) * dNext * optionsParam.tension,
    );
  }

  double _distanceDynamicPoint(DynamicPoint p1, DynamicPoint? p2) {
    if (p2 == null) {
      return 0;
    }
    return math.sqrt(math.pow(p1.x - p2.x, 2) + math.pow(p1.y - p2.y, 2));
  }

  /// Calculate points around widget
  void _getPoints() {
    double _alfa;
    double _gapTemp;
    double dx = topLeft;
    double dy = 0;
    _allOffsets = <Offset>{};

    /// Up border widget =================================================<
    final double upLine = width - topLeft - topRight;

    _gapTemp = _getGapTemp(line: upLine, gap: _gap).toDouble();

    if (upLine > 0 && topRight < _gap) _allOffsets.add(Offset(dx + _gapTemp / width, dy));
    for (double i = 0; i <= upLine; i += _gapTemp) {
      _allOffsets.add(Offset(dx + i, dy));
    }

    /// The upper right corner of the widget ===========================================<
    if (topRight > 0) {
      final topRightLine = topRight * math.pi / 2;
      _gapTemp = _getGapTemp(line: topRightLine, gap: _gap).toDouble();
      _alfa = (_gapTemp * 180) / (topRight * math.pi);
      final double dxO = width - topRight;
      final double dyO = topRight;
      for (double i = 270; i < 360; i += _alfa) {
        dx = dxO + (topRight * math.cos(radians(i)));
        dy = dyO + (topRight * math.sin(radians(i)));
        _allOffsets.add(Offset(dx, dy));
      }
    }

    /// Right edge of the widget ==================================================<
    final double rightLine = height - topRight - bottomRight;
    _gapTemp = _getGapTemp(line: rightLine, gap: _gap).toDouble();
    dx = width;
    dy = topRight;
    if (rightLine > 0 && topLeft < _gap) _allOffsets.add(Offset(dx, dy + _gapTemp / width));
    for (double i = 0; i <= rightLine; i += _gapTemp) {
      _allOffsets.add(Offset(dx, dy + i));
    }

    /// Bottom-right corner of the widget ============================================<
    if (bottomRight > 0) {
      final bottomRightLine = bottomRight * math.pi / 2;
      _gapTemp = _getGapTemp(line: bottomRightLine, gap: _gap).toDouble();
      _alfa = (_gapTemp * 180) / (bottomRight * math.pi);

      final double dxO = width - bottomRight;
      final double dyO = height - bottomRight;
      for (double i = 0; i < 90; i += _alfa) {
        dx = dxO + (bottomRight * math.cos(radians(i)));
        dy = dyO + (bottomRight * math.sin(radians(i)));
        _allOffsets.add(Offset(dx, dy));
      }
    }

    /// Bottom edge of the widget ==================================================<
    final double bottomLine = width - bottomLeft - bottomRight;
    _gapTemp = _getGapTemp(line: bottomLine, gap: _gap).toDouble();
    dx = bottomLeft;
    dy = height;
    if (bottomLine > 0 && bottomRight < _gap) _allOffsets.add(Offset(dx + bottomLine - _gapTemp / width, dy));
    for (double i = bottomLine; i >= 0; i -= _gapTemp) {
      _allOffsets.add(Offset(dx + i, dy));
    }

    /// Bottom left corner of the widget =============================================<
    if (bottomLeft > 0) {
      final bottomRightLine = bottomLeft * math.pi / 2;
      _gapTemp = _getGapTemp(line: bottomRightLine, gap: _gap).toDouble();
      _alfa = (_gapTemp * 180) / (bottomLeft * math.pi);

      final double dxO = bottomLeft;
      final double dyO = height - bottomLeft;
      for (double i = 90; i < 180; i += _alfa) {
        dx = dxO + (bottomLeft * math.cos(radians(i)));
        dy = dyO + (bottomLeft * math.sin(radians(i)));
        _allOffsets.add(Offset(dx, dy));
      }
    }

    /// Left side of the widget ===================================================<
    final double leftLine = height - topLeft - bottomLeft;
    _gapTemp = _getGapTemp(line: leftLine, gap: _gap).toDouble();
    dx = 0;
    dy = topLeft;
    if (leftLine > 0 && bottomLeft < _gap) _allOffsets.add(Offset(dx, dy + leftLine - _gapTemp / width));
    for (double i = leftLine; i >= 0; i -= _gapTemp) {
      _allOffsets.add(Offset(dx, dy + i));
    }

    /// The upper left corner of the widget ============================================<
    if (topLeft > 0) {
      final topRightLine = topLeft * math.pi / 2;
      _gapTemp = _getGapTemp(line: topRightLine, gap: _gap).toDouble();
      _alfa = (_gapTemp * 180) / (topLeft * math.pi);

      final double dxO = topLeft;
      final double dyO = topLeft;
      for (double i = 180; i < 270; i += _alfa) {
        dx = dxO + (topLeft * math.cos(radians(i)));
        dy = dyO + (topLeft * math.sin(radians(i)));
        _allOffsets.add(Offset(dx, dy));
      }
    }
  }

  /// Populating Dynamic Point Models
  void _writeDynamicPoints() {
    for (final LayerModel layerModel in optionsParam.layers) {
      layerModel.points.clear();
      for (int i = 0; i < _allOffsets.length; i++) {
        layerModel.points.add(DynamicPoint(
          x: _allOffsets.elementAt(i).dx,
          y: _allOffsets.elementAt(i).dy,
          ox: _allOffsets.elementAt(i).dx,
          oy: _allOffsets.elementAt(i).dy,
          vx: 0,
          vy: 0,
        ));
      }

      /// Padding point positioning relative to [pPrev] and [pNext]
      for (final LayerModel layerModel in optionsParam.layers) {
        for (int i = 1; i <= layerModel.points.length; i++) {
          final v1 = (i + -1) % layerModel.points.length;
          final v0 = (i + 0) % layerModel.points.length;
          final v2 = (i + 1) % layerModel.points.length;
          layerModel.points[v0].pPrev = layerModel.points[v1];
          layerModel.points[v0].pNext = layerModel.points[v2];
        }
      }

      /// Constructing a widget face
      _setBorder();
    }
  }

  void _setBorder() {
    final DynamicPoint point = optionsParam.layers[0].points.last;
    _path.moveTo(point.ox, point.oy);
    for (final DynamicPoint point in optionsParam.layers[0].points) {
      _path.lineTo(point.ox, point.oy);
    }
    _path.lineTo(point.ox, point.oy);
  }

  /// Step calculation
  num _getGapTemp({required num line, required num gap}) {
    if (line / 2 <= gap) {
      return line / 2;
    } else {
      if (((line % gap) / 2) < gap) {
        final w1 = line % gap;
        final w2 = line ~/ gap;
        final w3 = w1 / w2;
        final w4 = gap + w3;
        return w4;
      } else {
        final w1 = gap - (line % gap);
        final w2 = (line ~/ gap) - 1;
        final w3 = w1 / w2;
        final w4 = gap + w3;
        return w4;
      }
    }
  }

  Future<void> _updateTouches(List<TouchModel> data) async {
    if (data.isNotEmpty && data.first.isShow) {
      optionsParam.touches = data;
    } else if (_isReadTouch) {
      _isReadTouch = false;
    }

    try {
      //
      // _updatePoints();
    } catch (e) {
      print(e);
    }
  }

  int _tic = 0;

  void _startRepaint() {
    _outputController.sink.add(_listLayerModel);
    _timerOfRedraw = Ticker((_) {
      _tic++;
      final isUpdate = (_tic % optionsParam.stepRedrawing) == 0;
      if (isUpdate) {
        if (optionsParam.stepRedrawing == _tic) {
          _tic = 0;
        }
        _updatePoints();
        if (!_isReadTouch) {
          optionsParam.touches = [];
          _isReadTouch = true;
        }
        if (_listLayerModel.first.points.first.cNext != null) {
          _outputController.sink.add(_listLayerModel);
        } else {}
      }
    });
    _timerOfRedraw?.start();
  }

  void dispose() {
    _outputController.close();
    _inputController.close();
    _timerOfRedraw?.dispose();
  }
}
