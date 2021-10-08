import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

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
    Key? key,
    this.boxDecorationLabel,
    this.onTap,
    required this.optionsParam,
    required this.child,
    this.forceFactorTempBuild = 7,
    this.isShowTouchBuild = false,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final _random = math.Random();
    late double height;
    late double width;
    CorePaint? _corePaint;
    Future.delayed(Duration(milliseconds: 50 + _random.nextInt(150)), () {
      try {
        _corePaint?.updatePointsStream.add([
          touchUpdate(
            Offset(_random.nextDouble() * width, _random.nextDouble() * height),
            force:
                math.max(optionsParam.forceFactorBuild, forceFactorTempBuild),
            isShow: isShowTouchBuild,
          )
        ]);
        _corePaint?.updatePointsStream.add([]);
      } catch (_) {}
    });

    return Container(
      decoration: boxDecorationLabel,
      child: GestureDetector(
        onTap: onTap,
        onTapDown: (_) {
          _corePaint?.updatePointsStream.add(
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
          _corePaint?.updatePointsStream.add(
            [
              touchUpdate(
                _.localPosition,
                isShow: true,
              ),
            ],
          );
        },
        onVerticalDragEnd: (details) {
          _corePaint?.updatePointsStream.add([]);
        },
        onHorizontalDragUpdate: (_) {
          _corePaint?.updatePointsStream.add(
            [
              touchUpdate(_.localPosition, isShow: true),
            ],
          );
        },
        onHorizontalDragEnd: (details) {
          _corePaint?.updatePointsStream.add([]);
        },
        onTapUp: (_) {
          _corePaint?.updatePointsStream.add([]);
        },
        child: LayoutBuilder(builder: (context, constraints) {
          height = constraints.maxHeight;
          width = constraints.maxWidth;
          double topRight = 0;
          double bottomRight = 0;
          double topLeft = 0;
          double bottomLeft = 0;
          if (boxDecorationLabel?.borderRadius != null) {
            final _borderRadius =
                boxDecorationLabel?.borderRadius.toString() ?? '';

            const _circular = 'BorderRadius.circular(';
            const _only = 'BorderRadius.only(';
            if (_borderRadius.contains(_circular)) {
              final double _cir = double.tryParse(
                    _borderRadius.substring(
                      _circular.length,
                      _borderRadius.length - 2,
                    ),
                  ) ??
                  0;
              topRight = _cir;
              bottomRight = _cir;
              topLeft = _cir;
              bottomLeft = _cir;
            } else if (_borderRadius.contains(_only)) {
              topRight = getPiceOfString(
                start: 'topRight: Radius.circular(',
                end: ')',
                extract: _borderRadius,
              );
              bottomRight = getPiceOfString(
                start: 'bottomRight: Radius.circular(',
                end: ')',
                extract: _borderRadius,
              );
              topLeft = getPiceOfString(
                start: 'topLeft: Radius.circular(',
                end: ')',
                extract: _borderRadius,
              );
              bottomLeft = getPiceOfString(
                start: 'bottomLeft: Radius.circular(',
                end: ')',
                extract: _borderRadius,
              );
            }
          }
          optionsParam.corePaint?.dispose();
          _corePaint = CorePaint(
            height: height,
            width: width,
            topRight: topRight,
            bottomRight: bottomRight,
            topLeft: topLeft,
            bottomLeft: bottomLeft,
            optionsParam: optionsParam,
          );
          optionsParam.corePaint = _corePaint;
          return StreamBuilder<List<LayerModel>>(
              stream: _corePaint?.streamListLayerModel,
              builder: (context, snapshot) {
                final List<Widget> children = [];
                children
                    .addAll(List.generate(optionsParam.layers.length, (index) {
                  final double _scale = optionsParam.layerScales[index] *
                      optionsParam.layers[index].scaleLayer;
                  final double xShift = constraints.maxWidth / 2 -
                      constraints.maxWidth * _scale / 2;
                  final double yShift = constraints.maxHeight / 2 -
                      constraints.maxHeight * _scale / 2;
                  return Container(
                    transform: Matrix4(
                      _scale, 0, 0, 0, //
                      0, _scale, 0, 0, //
                      0, 0, _scale, 0, //
                      xShift, yShift, 0, 1, //
                    ),
                    decoration: boxDecorationLabel?.copyWith(
                        color: optionsParam
                            .layers[optionsParam.layerNumbers[index]].color),
                  );
                }).toList());
                children.add(child ?? const CircularProgressIndicator());
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
                  return child ?? const CircularProgressIndicator();
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

double getPiceOfString({
  required String start,
  required String end,
  required String extract,
}) {
  final int _st = extract.indexOf(start) + start.length;
  final int _en = extract.indexOf(end, _st);
  final String _temp = extract.substring(_st, _en);
  try {
    return double.parse(_temp);
  } catch (e) {
    return 0.0;
  }
}
