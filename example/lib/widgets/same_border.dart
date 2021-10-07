import 'package:flutter/material.dart';
import 'package:liquid_container/liquid_container.dart';

class SameBorderLiquidWidget extends StatefulWidget {
  const SameBorderLiquidWidget({Key? key}) : super(key: key);

  @override
  _SameBorderLiquidWidgetState createState() => _SameBorderLiquidWidgetState();
}

class _SameBorderLiquidWidgetState extends State<SameBorderLiquidWidget> {
  static const _label = 'Same Border';
  final optionsParam = Options(
    layers: [
      LayerModel(
        points: [],
        viscosity: 0.9,
        touchForce: 30,
        forceLimit: 15,
        color: const Color(0xFF00FF00),
      ),
      LayerModel(
        points: [],
        viscosity: 0.9,
        touchForce: 50,
        forceLimit: 10,
        color: const Color(0xFF0000FF),
      ),
    ],
    gap: 30,
    noise: 10,
    forceFactorBuild: 10,
    forceFactorOnTap: 150,
  );
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      margin: const EdgeInsets.only(left: 10, right: 30, top: 100),
      child: LiquidContainer(
        onTap: _onTapToLiquidButton,
        optionsParam: optionsParam,
        boxDecorationLabel: BoxDecoration(borderRadius: BorderRadius.circular(50)),
        child: _buildForegroundChild(),
      ),
    );
  }

  void _onTapToLiquidButton() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                _label,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF00FFD5),
                ),
              ),
              IconButton(
                onPressed: ScaffoldMessenger.of(context).clearSnackBars,
                icon: const Icon(
                  Icons.close,
                  size: 30,
                  color: Colors.redAccent,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Row _buildForegroundChild() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const <Widget>[
        Icon(
          Icons.liquor_outlined,
          color: Color(0xFF00FFD5),
          size: 60,
        ),
        SizedBox(width: 5),
        Text(
          _label,
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w900,
            color: Color(0xFF00FFD5),
          ),
        ),
      ],
    );
  }
}
