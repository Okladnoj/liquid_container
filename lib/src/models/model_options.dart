import 'package:flutter/foundation.dart';

import '../core/core_stream_paint.dart';
import 'model_components.dart';

/// ### [Options] - powerful customization engine for fluid physics widget
class Options {
  /// ### [Options] - powerful customization engine for fluid physics widget
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
  /// - Use [options]
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

  Options({
    this.tension = 0.45,
    this.width = 50,
    this.height = 20,
    this.hoverFactor = -0.3,
    this.gap = 5,
    this.forceFactor = 0.15,
    this.forceFactorBuild = 1,
    this.forceFactorOnTap = 1,
    this.stepRedrawing = 2,
    List<LayerModel>? layers,
    List<TouchModel>? touches,

    /// To draw layers
    List<int>? layerNumbers,

    /// Scale object size at each level, independent of layer order
    List<double>? scaleOptionLayer,
    this.noise = 0,
  })  : layers = layers ??
            [
              LayerModel(
                points: [],
                viscosity: 0.5,
                touchForce: 100,
                forceLimit: 2,
              ),
              LayerModel(
                points: [],
                viscosity: 0.8,
                touchForce: 150,
                forceLimit: 3,
              ),
            ],
        touches = touches ?? [] {
    assert(stepRedrawing > 0);
    this.layerNumbers =
        layerNumbers ?? List.generate(this.layers.length, (index) => index);
    layerScales =
        scaleOptionLayer ?? List.generate(this.layers.length, (index) => 1.0);
  }
  late double tension;
  late double width;
  late double height;
  late double gap;
  late double hoverFactor;
  late double forceFactor;

  /// Perturbation of the liquid widget when it is built
  double forceFactorBuild;

  /// Liquid widget disturbance when pressed
  double forceFactorOnTap;

  /// Animation redraw step
  /// (decreasing the animation step increases the fluid velocity and loads the computing power of the device)
  ///
  /// Animation step must be greater than [0]
  int stepRedrawing;
  List<LayerModel> layers;
  late List<int> layerNumbers;
  late List<double> layerScales;
  List<TouchModel> touches;
  double noise;
  CorePaint? corePaint;
  void refreshLayerModel() {
    final List<LayerModel> tempLayers = [];
    for (final LayerModel layer in layers) {
      tempLayers.add(LayerModel(
        points: layer.points,
        viscosity: layer.viscosity,
        touchForce: layer.touchForce,
        forceLimit: layer.forceLimit,
        color: layer.color,
      ));
      if (layer.color == null) {
        if (kDebugMode) {
          debugPrint('${layer.color}');
        }
      }
    }

    layers = tempLayers;
  }
}
