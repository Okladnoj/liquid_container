import 'package:flutter/material.dart';
import 'widgets/widgets.dart';

void main() {
  runApp(const LiquidApp());
}

class LiquidApp extends StatelessWidget {
  static const title = 'Liquid Container';

  const LiquidApp({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: title,
      home: Scaffold(
        appBar: AppBar(
          title: const Text(title),
        ),
        body: Container(
          color: Colors.grey,
          child: ListView(
            children: const [
              BigNoiseLiquidWidget(),
              NotNoiseLiquidWidget(),
              OneLayerLiquidWidget(),
              TwoLayersLiquidWidget(),
              DifferentScaleLiquidWidget(),
              NonBorderLiquidWidget(),
              SameBorderLiquidWidget(),
              SizedBox(height: 300),
            ],
          ),
        ),
      ),
    );
  }
}
