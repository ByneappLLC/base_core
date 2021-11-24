import 'package:base_core/base_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const WATER = 1;
  const FOOD = 2;
  const BEER = 3;
  const NONE = 0;

  bool _isWater(String value) {
    return value == "water";
  }

  bool _isFood(String value) {
    return value == "food";
  }

  bool _isBeer(String value) {
    return value == "beer";
  }

  test('Should emit expected data', () async {
    var item = "food";

    final val = match<String, int>(item)
        .on(_isWater, () => WATER)
        .on(_isBeer, () => BEER)
        .on(_isFood, () => FOOD)
        .orElse(() => NONE)
        .run();

    expect(val, FOOD);
  });
}
