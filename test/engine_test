import 'package:flutter_test/flutter_test.dart';
import 'package:seismic2800/engine.dart';

void main() {
  test('default input is internally consistent and computes finite results', () {
    final input = SeismicInput();
    expect(input.floors.last.height, input.height);
    final result = compute(input);
    expect(result.v.isFinite, isTrue);
    expect(result.sds, greaterThan(0));
    expect(result.fi.length, input.floors.length);
    expect(result.fi.fold<double>(0, (sum, force) => sum + force),
        closeTo(result.v, 1e-6));
  });

  test('rejects non-positive floor weight', () {
    final input = SeismicInput();
    input.floors.first.weight = 0;
    expect(() => compute(input), throwsArgumentError);
  });

  test('rejects non-increasing floor elevations', () {
    final input = SeismicInput();
    input.floors[1].height = input.floors.first.height;
    expect(() => compute(input), throwsArgumentError);
  });
}
