/// Validation logic shared by the Add form and covered by unit tests.
class ValidationService {
  /// Returns true when [value] is non-null and has non-whitespace content.
  bool isValidString(String? value) {
    return value != null && value.trim().isNotEmpty;
  }

  /// Form validator: returns an error message, or null when valid.
  String? validateRequired(String? value, String fieldName) {
    return isValidString(value) ? null : 'กรุณากรอก$fieldName';
  }
}
