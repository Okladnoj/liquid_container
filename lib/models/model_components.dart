import 'dart:ui';

/// The layer model on the basis of which the image is drawn on [Canvas]
class LayerModel {
  /// Bézier path points that are on the edge of the liquid widget
  List<DynamicPoint> points;
  double viscosity;
  double touchForce;
  int forceLimit;
  Paint? paintStyle;
  Color? color;

  /// Scaling the size of the liquid layer, depends on the order of the layers
  double scaleLayer;

  /// The layer model on the basis of which the image is drawn on [Canvas]
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

/// Coordinate point with physical properties at the edge of the widget.
class DynamicPoint {
  /// Axis current position x
  double x;

  /// Axis current position y
  double y;

  /// X-axis start position
  double ox;

  /// Y-axis start position
  double oy;

  /// The current speed of the point movement along the X axis
  double vx;

  /// The current speed of the point movement along the Y axis
  double vy;

  /// Next, the same point on the edge of the widget
  DynamicPoint? pNext;

  /// Previous, the same point on the edge of the widget
  DynamicPoint? pPrev;

  /// The vertex of the control vector of the cubic Bezier line, located from the side of the next point on the edge of the widget.
  Offset? cNext;

  /// The vertex of the control vector of the cubic Bezier line, located to the side of the previous point on the edge of the widget.
  Offset? cPrev;

  /// ### Coordinate point with physical properties at the edge of the widget.
  ///
  /// Axis current position x
  /// ```
  /// double x;
  /// ```

  /// Axis current position y
  /// ```
  /// double y;
  /// ```

  /// X-axis start position
  /// ```
  /// double ox;
  /// ```

  /// Y-axis start position
  /// ```
  /// double oy;
  /// ```

  /// The current speed of the point movement along the X axis
  /// ```
  /// double vx;
  /// ```

  /// The current speed of the point movement along the Y axis
  /// ```
  /// double vy;
  /// ```

  /// Next, the same point on the edge of the widget
  /// ```
  /// DynamicPoint? pNext;
  /// ```

  /// Previous, the same point on the edge of the widget
  /// ```
  /// DynamicPoint? pPrev;
  /// ```

  /// The vertex of the control vector of the cubic Bezier line, located from the side of the next point on the edge of the widget.
  /// ```
  /// Offset? cNext;
  /// ```

  /// The vertex of the control vector of the cubic Bezier line, located to the side of the previous point on the edge of the widget.
  /// ```
  /// Offset? cPrev;
  /// ```
  ///
  DynamicPoint({
    required this.x,
    required this.y,
    required this.ox,
    required this.oy,
    required this.vx,
    required this.vy,
  });
}

/// ### Touch point with properties
///
class TouchModel {
  /// Coordinate [x]
  double x;

  /// Coordinate [y]
  double y;

  /// Coordinate [z] (Not supported at the moment)
  double z;

  /// Pressing force on the liquid element. [x]
  double force;

  /// whether to show a short touch (Tap) on the [LiquidContainer]
  bool isShow = false;

  /// ### Touch point with properties
  ///
  /// * Coordinate [x]
  /// ```
  /// double x;
  /// ```

  /// * Coordinate [y]
  /// ```
  /// double y;
  /// ```

  /// * Coordinate [z] (Not supported at the moment)
  /// ```
  /// double z;
  /// ```

  /// * Pressing force on the liquid element. [x]
  /// ```
  /// double force;
  /// ```

  /// * whether to show a short touch (Tap) on the [LiquidContainer]
  /// ```
  /// bool isShow = false;
  /// ```
  /// *
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
