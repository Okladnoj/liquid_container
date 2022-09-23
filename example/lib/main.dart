import 'package:flutter/material.dart';
import 'widgets/widgets.dart';

void main() {
  runApp(const LiquidApp());
}

class LiquidApp extends StatelessWidget {
  static const title = 'Liquid Container';

  const LiquidApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: title,
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: Scaffold(
        appBar: AppBar(
          title: const Text(title),
        ),
        body: ListView(
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
    );
  }
}
