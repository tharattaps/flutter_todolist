import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_todolist/validation_service.dart';

void main() {
  group('ValidationService.isValidString', () {
    final service = ValidationService();

    test('Test Case 1: valid text ("Hello World") returns true', () {
      expect(service.isValidString('Hello World'), isTrue);
    });

    test('Test Case 2: empty string ("") returns false', () {
      expect(service.isValidString(''), isFalse);
    });

    test('Test Case 2: null returns false', () {
      expect(service.isValidString(null), isFalse);
    });

    test('whitespace-only string returns false', () {
      expect(service.isValidString('   '), isFalse);
    });
  });
}
