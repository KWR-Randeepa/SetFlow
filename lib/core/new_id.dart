import 'dart:convert';
import 'dart:math';

// Generates a new unique ID using a secure random number generator and encodes it in base64 URL format.
String newId() {
  final random = Random.secure();
  return base64UrlEncode(List<int>.generate(24, (_) => random.nextInt(256)));
}
