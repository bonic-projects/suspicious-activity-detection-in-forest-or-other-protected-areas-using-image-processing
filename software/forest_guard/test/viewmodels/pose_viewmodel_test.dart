import 'package:flutter_test/flutter_test.dart';
import 'package:forest_guard/app/app.locator.dart';

import '../helpers/test_helpers.dart';

void main() {
  group('PoseViewModel Tests -', () {
    setUp(() => registerServices());
    tearDown(() => locator.reset());
  });
}
