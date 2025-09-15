class Validators {
  static String? requiredField(String? value) {
    if (value == null || value.isEmpty) {
      return 'Field ini wajib diisi';
    }
    return null;
  }

  static String? validateNumber(String? value) {
    if (value == null || value.isEmpty) return 'Field ini wajib diisi';
    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'Harus berupa angka';
    }
    return null;
  }
}
