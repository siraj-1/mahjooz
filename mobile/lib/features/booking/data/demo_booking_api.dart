import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class DemoBooking {
  const DemoBooking({
    required this.id,
    required this.resourceId,
    required this.date,
    required this.time,
    required this.startsAt,
    required this.cancelled,
  });

  final String id;
  final String resourceId;
  final String date;
  final String time;
  final DateTime startsAt;
  final bool cancelled;

  factory DemoBooking.fromJson(Map<String, dynamic> json) => DemoBooking(
        id: json['id'] as String,
        resourceId: json['resourceId'] as String,
        date: json['date'] as String,
        time: json['time'] as String,
        startsAt: DateTime.parse(json['startsAt'] as String),
        cancelled: json['status'] == 'Cancelled',
      );
}

/// Browser preview uses the same-origin bridge. Native builds must supply a
/// reachable HTTPS API host via --dart-define=MAHJOOZ_API_URL=...
class DemoBookingApi {
  DemoBookingApi()
      : _dio = Dio(BaseOptions(
          baseUrl: kIsWeb
              ? '/booking-demo'
              : const String.fromEnvironment('MAHJOOZ_API_URL'),
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ));

  final Dio _dio;

  Future<bool> check(String resourceId, String date, String time) async {
    final response = await _dio.get<Map<String, dynamic>>('/availability',
        queryParameters: {
          'resourceId': resourceId,
          'date': date,
          'time': time
        });
    return response.data?['isAvailable'] == true;
  }

  Future<String> reserve(String resourceId, String date, String time) async {
    final response = await _dio.post<Map<String, dynamic>>('/bookings',
        data: {'resourceId': resourceId, 'date': date, 'time': time});
    return response.data!['id'] as String;
  }

  Future<DemoBooking> find(String id) async {
    final response = await _dio.get<Map<String, dynamic>>('/bookings/$id');
    return DemoBooking.fromJson(response.data!);
  }

  Future<void> cancel(String id) async {
    await _dio.delete<void>('/bookings/$id');
  }
}
