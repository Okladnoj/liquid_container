import 'dart:ui';

class LayerModel {
  /// точки контура Безье
  List<DynamicPoint> points;
  double viscosity;
  double touchForce;
  int forceLimit;
  Paint? paintStyle;
  Color? color;

  /// Масштабирование размера жидкого слоя, зависит от порядка слоев
  double scaleLayer;

  /// Модель слоя на основе которой отрисовывается изображение на [Canvas]
  LayerModel({
    List<DynamicPoint>? points,
    required this.viscosity,
    required this.touchForce,
    required this.forceLimit,
    this.color,
    this.scaleLayer = 1,
    Paint? paintStyle,
  })  : points = points ?? [],
        paintStyle = paintStyle ?? Paint()
          ..color = color ?? const Color(0xA1FF0000)
          ..strokeWidth = 1
          ..style = PaintingStyle.fill;
}

class DynamicPoint {
  double x;
  double y;
  double ox;
  double oy;
  double vx;
  double vy;
  DynamicPoint? pNext;
  DynamicPoint? pPrev;
  Offset? cNext;
  Offset? cPrev;

  DynamicPoint({
    required this.x,
    required this.y,
    required this.ox,
    required this.oy,
    required this.vx,
    required this.vy,
  });
}

class TouchModel {
  double x;
  double y;
  double z;
  double force;
  bool isShow = false;

  /// Создание модели касания экрана
  TouchModel({
    required this.x,
    required this.y,
    required this.z,
    required this.force,
    required this.isShow,
  });
}

class BezierPoints {
  Offset controlPointOne;
  Offset endPoint;
  Offset controlPointTwo;
  BezierPoints({
    required this.controlPointOne,
    required this.endPoint,
    required this.controlPointTwo,
  });
}

class VectorDistance {
  double vx;
  double vy;
  double distance;
  VectorDistance({
    required this.vx,
    required this.vy,
    required this.distance,
  });
}

class Line {
  double x;
  double y;

  Line({
    required this.x,
    required this.y,
  });
}
