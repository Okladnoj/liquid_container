import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:liquid_container/liquid_container.dart';

void main() {
  test('init', () {
    LiquidContainer(
      optionsParam: Options(),
      child: const SizedBox.shrink(),
    );
  });
}
