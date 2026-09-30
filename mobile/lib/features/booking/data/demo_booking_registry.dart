import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Keeps only opaque demo booking references on this device. The booking
/// details are fetched from the server, rather than trusting local copies.
class DemoBookingRegistry {
  static const _storage = FlutterSecureStorage();
  static const _key = 'mahjooz_demo_booking_ids';

  static Future<List<String>> readIds() async {
    final encoded = await _storage.read(key: _key);
    if (encoded == null) return [];
    final decoded = jsonDecode(encoded);
    if (decoded is! List || decoded.any((id) => id is! String)) {
      throw const FormatException('Invalid saved booking references');
    }
    return decoded.cast<String>();
  }

  static Future<void> record(String id) async {
    final ids = await readIds();
    if (ids.contains(id)) return;
    ids.add(id);
    await _storage.write(key: _key, value: jsonEncode(ids));
  }
}
