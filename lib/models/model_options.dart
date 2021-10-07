import '../core/core_stream_paint.dart';
import 'model_components.dart';

class Options {
  /// Designer with liquid widget settings
  Options({
    this.tension = 0.45,
    this.width = 50,
    this.height = 20,
    this.hoverFactor = -0.3,
    this.gap = 5,
    this.forceFactor = 0.15,
    this.forceFactorBuild = 1,
    this.forceFactorOnTap = 1,
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
    this.layerNumbers = layerNumbers ?? List.generate(this.layers.length, (index) => index);
    layerScales = scaleOptionLayer ?? List.generate(this.layers.length, (index) => 1.0);
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
  List<LayerModel> layers;
  late List<int> layerNumbers;
  late List<double> layerScales;
  List<TouchModel> touches;
  double noise;
  CorePaint? corePaint;
  void refreshLayerModel() {
    final List<LayerModel> _tempLayers = [];
    for (final LayerModel layer in layers) {
      _tempLayers.add(LayerModel(
        points: layer.points,
        viscosity: layer.viscosity,
        touchForce: layer.touchForce,
        forceLimit: layer.forceLimit,
        color: layer.color,
      ));
      if (layer.color == null) {
        print(layer.color);
      }
    }

    layers = _tempLayers;
  }
}
