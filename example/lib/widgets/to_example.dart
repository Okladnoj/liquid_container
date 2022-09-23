import 'package:flutter/material.dart';
import 'package:liquid_container/liquid_container.dart';

class ToExampleLiquidWidget extends StatefulWidget {
  const ToExampleLiquidWidget({super.key});

  @override
  _ToExampleLiquidWidgetState createState() => _ToExampleLiquidWidgetState();
}

class _ToExampleLiquidWidgetState extends State<ToExampleLiquidWidget> {
  static const _label = 'To Example';
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
        color: const Color(0xFFFF0000),
      ),
    ],
    gap: 30,
    noise: 30,
    forceFactorBuild: 10,
    forceFactorOnTap: 150,
  );
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      margin: const EdgeInsets.only(left: 10, right: 30, top: 100),
      child: _buildLiquidButton(),
    );
  }

  Widget _buildLiquidButton() {
    return LiquidContainer(
      onTap: () {
        // same code
      },
      optionsParam: optionsParam,
      boxDecorationLabel: _borderForm(),
      child: _buildSomeChild(),
    );
  }

  BoxDecoration _borderForm() {
    return const BoxDecoration(
        borderRadius: BorderRadius.only(
      topLeft: Radius.circular(40),
      topRight: Radius.circular(80),
      bottomLeft: Radius.circular(150),
      bottomRight: Radius.circular(20),
    ));
  }

  Row _buildSomeChild() {
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
