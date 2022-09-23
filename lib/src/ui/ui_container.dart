import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../canvas/canvas_draw.dart';
import '../core/core_stream_paint.dart';
import '../models/model.dart';

/// ### [LiquidContainer] - Liquid button container with Hover effect. Easily add liquid effect to your application
/// * Use
///```
/// Widget _buildLiquidButton() {
///   return LiquidContainer(
///     onTap: () {
///       // same code
///     },
///     optionsParam: options,
///     child: const SizedBox(
///       height: 80,
///       width: 300,
///     ),
///   );
/// }
/// ```
class LiquidContainer extends StatelessWidget {
  final double forceFactorTempBuild;
  final BoxDecoration? boxDecorationLabel;
  final Options optionsParam;
  final Widget? child;
  final void Function()? onTap;
  final bool isShowTouchBuild;

  /// ### [LiquidContainer] - Liquid button container with Hover effect. Easily add liquid effect to your application
  /// - Example of a Minimum Liquid Effect Setting
  /// ```
  ///   final options = Options(
  ///     layers: [
  ///       LayerModel(
  ///         points: [],
  ///         viscosity: 0.9,
  ///         touchForce: 30,
  ///         forceLimit: 15,
  ///         color: const Color(0xFF00FF00),
  ///       ),
  ///     ],
  ///     gap: 15,
  ///     noise: 5,
  ///     forceFactorBuild: 10,
  ///     forceFactorOnTap: 150,
  ///   );
  ///```
  ///
  /// ###
  /// * Use
  ///```
  /// Widget _buildLiquidButton() {
  ///   return LiquidContainer(
  ///     onTap: () {
  ///       // same code
  ///     },
  ///     optionsParam: options,
  ///     child: const SizedBox(
  ///       height: 80,
  ///       width: 300,
  ///     ),
  ///   );
  /// }
  /// ```
  const LiquidContainer({
    super.key,
    this.boxDecorationLabel,
    this.onTap,
    required this.optionsParam,
    this.child,
    this.forceFactorTempBuild = 7,
    this.isShowTouchBuild = false,
  });
  @override
  Widget build(BuildContext context) {
    final random = math.Random();
    late double height;
    late double width;
    CorePaint? corePaint;
    Future.delayed(Duration(milliseconds: 50 + random.nextInt(150)), () {
      try {
        corePaint?.updatePointsStream.add([
          touchUpdate(
            Offset(random.nextDouble() * width, random.nextDouble() * height),
            force:
                math.max(optionsParam.forceFactorBuild, forceFactorTempBuild),
            isShow: isShowTouchBuild,
          )
        ]);
        corePaint?.updatePointsStream.add([]);
      } catch (_) {}
    });

    return Container(
      decoration: boxDecorationLabel,
      child: GestureDetector(
        onTap: onTap,
        onTapDown: (_) {
          corePaint?.updatePointsStream.add(
            [
              touchUpdate(
                _.localPosition,
                force: optionsParam.forceFactorOnTap,
                isShow: true,
              ),
            ],
          );
        },
        onVerticalDragUpdate: (_) {
          corePaint?.updatePointsStream.add(
            [
              touchUpdate(
                _.localPosition,
                isShow: true,
              ),
            ],
          );
        },
        onVerticalDragEnd: (details) {
          corePaint?.updatePointsStream.add([]);
        },
        onHorizontalDragUpdate: (_) {
          corePaint?.updatePointsStream.add(
            [
              touchUpdate(_.localPosition, isShow: true),
            ],
          );
        },
        onHorizontalDragEnd: (details) {
          corePaint?.updatePointsStream.add([]);
        },
        onTapUp: (_) {
          corePaint?.updatePointsStream.add([]);
        },
        child: LayoutBuilder(builder: (context, constraints) {
          height = constraints.maxHeight;
          width = constraints.maxWidth;
          double topRight = 0;
          double bottomRight = 0;
          double topLeft = 0;
          double bottomLeft = 0;
          if (boxDecorationLabel?.borderRadius != null) {
            final borderRadius =
                boxDecorationLabel?.borderRadius.toString() ?? '';

            const circular = 'BorderRadius.circular(';
            const only = 'BorderRadius.only(';
            if (borderRadius.contains(circular)) {
              final double cir = double.tryParse(
                    borderRadius.substring(
                      circular.length,
                      borderRadius.length - 2,
                    ),
                  ) ??
                  0;
              topRight = cir;
              bottomRight = cir;
              topLeft = cir;
              bottomLeft = cir;
            } else if (borderRadius.contains(only)) {
              topRight = _getPiceOfString(
                start: 'topRight: Radius.circular(',
                end: ')',
                extract: borderRadius,
              );
              bottomRight = _getPiceOfString(
                start: 'bottomRight: Radius.circular(',
                end: ')',
                extract: borderRadius,
              );
              topLeft = _getPiceOfString(
                start: 'topLeft: Radius.circular(',
                end: ')',
                extract: borderRadius,
              );
              bottomLeft = _getPiceOfString(
                start: 'bottomLeft: Radius.circular(',
                end: ')',
                extract: borderRadius,
              );
            }
          }
          optionsParam.corePaint?.dispose();
          corePaint = CorePaint(
            height: height,
            width: width,
            topRight: topRight,
            bottomRight: bottomRight,
            topLeft: topLeft,
            bottomLeft: bottomLeft,
            optionsParam: optionsParam,
          );
          optionsParam.corePaint = corePaint;
          return StreamBuilder<List<LayerModel>>(
              stream: corePaint?.streamListLayerModel,
              builder: (context, snapshot) {
                final List<Widget> children = [];
                children
                    .addAll(List.generate(optionsParam.layers.length, (index) {
                  final double scale = optionsParam.layerScales[index] *
                      optionsParam.layers[index].scaleLayer;
                  final double xShift = constraints.maxWidth / 2 -
                      constraints.maxWidth * scale / 2;
                  final double yShift = constraints.maxHeight / 2 -
                      constraints.maxHeight * scale / 2;
                  return Container(
                    transform: Matrix4(
                      scale, 0, 0, 0, //
                      0, scale, 0, 0, //
                      0, 0, scale, 0, //
                      xShift, yShift, 0, 1, //
                    ),
                    decoration: boxDecorationLabel?.copyWith(
                        color: optionsParam
                            .layers[optionsParam.layerNumbers[index]].color),
                  );
                }).toList());
                children.add(child ?? const SizedBox.shrink());
                try {
                  if (snapshot.hasData) {
                    final noNull = snapshot.data?.first.points.first.cNext;
                    if (noNull != null) {
                      return CustomPaint(
                        painter: SimplePaint(
                          constraints: constraints,
                          optionsParam: optionsParam,
                        ),
                        child: child,
                      );
                    } else {
                      return Stack(
                        alignment: const Alignment(0, 0),
                        children: children,
                      );
                    }
                  } else {
                    return Stack(
                      alignment: const Alignment(0, 0),
                      children: children,
                    );
                  }
                } catch (_) {
                  return child ?? const SizedBox.shrink();
                }
              });
        }),
      ),
    );
  }

  TouchModel touchUpdate(
    Offset offset, {
    double force = 10,
    required bool isShow,
  }) {
    return TouchModel(
      x: offset.dx,
      y: offset.dy,
      z: 0,
      force: force,
      isShow: isShow,
    );
  }

  void touchCancel(dynamic dynamicPoint) {
    optionsParam.touches = [];
  }
}

/// Gets the radius value from the Border Radius Geometry text properties.
double _getPiceOfString({
  required String start,
  required String end,
  required String extract,
}) {
  final int st = extract.indexOf(start) + start.length;
  final int en = extract.indexOf(end, st);
  final String temp = extract.substring(st, en);
  try {
    return double.parse(temp);
  } catch (e) {
    return 0.0;
  }
}
