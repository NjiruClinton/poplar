class PhoneUtils {
  static String normalizeKenyanNumber(String number) {
    String value = number.trim();

    value = value.replaceAll(
      RegExp(r'[\s\-\(\)]'),
      '',
    );

    if (value.startsWith('+254')) {
      return value;
    }

    if (value.startsWith('254')) {
      return '+$value';
    }

    if (value.startsWith('0')) {
      return '+254${value.substring(1)}';
    }

    return value;
  }
}