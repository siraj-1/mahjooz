import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/mock/mock_venues.dart';
import '../data/demo_booking_api.dart';
import '../data/demo_booking_registry.dart';

class BookingFlowScreen extends StatefulWidget {
  const BookingFlowScreen({
    super.key,
    required this.venueId,
    required this.resourceId,
  });

  final String venueId;
  final String resourceId;

  @override
  State<BookingFlowScreen> createState() => _BookingFlowScreenState();
}

class _BookingFlowScreenState extends State<BookingFlowScreen> {
  final _api = DemoBookingApi();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _checking = false;
  bool _reserving = false;
  bool? _available;
  String? _message;
  String? _confirmation;
  int _requestVersion = 0;

  String get _date {
    final d = _selectedDate!;
    return '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  String get _time => '${_selectedTime!.hour.toString().padLeft(2, '0')}:00';

  Future<void> _check() async {
    final version = ++_requestVersion;
    if (_selectedDate == null || _selectedTime == null) return;
    setState(() {
      _checking = true;
      _available = null;
      _message = null;
      _confirmation = null;
    });
    try {
      final available = await _api.check(widget.resourceId, _date, _time);
      if (!mounted || version != _requestVersion) return;
      setState(() {
        _available = available;
        _message = available
            ? 'This demo slot is currently available. It is not held until you reserve.'
            : 'This slot is unavailable. Choose another time.';
      });
    } on DioException catch (error) {
      if (!mounted || version != _requestVersion) return;
      setState(() => _message = _errorMessage(error));
    } catch (_) {
      if (!mounted || version != _requestVersion) return;
      setState(() => _message = 'Could not check availability. Try again.');
    } finally {
      if (mounted && version == _requestVersion) {
        setState(() => _checking = false);
      }
    }
  }

  String _errorMessage(DioException error) {
    final data = error.response?.data;
    if (data is Map && data['error'] is String) return data['error'] as String;
    return 'Booking service unavailable. Please try again.';
  }

  Future<void> _reserve() async {
    if (_available != true || _reserving) return;
    setState(() {
      _reserving = true;
      _message = null;
    });
    try {
      final id = await _api.reserve(widget.resourceId, _date, _time);
      if (!mounted) return;
      try {
        await DemoBookingRegistry.record(id);
      } catch (_) {
        if (!mounted) return;
        setState(() {
          _confirmation = id;
          _available = false;
          _message =
              'Booking confirmed, but it could not be saved on this device. Keep this reference: $id';
        });
        return;
      }
      if (mounted) context.go('/bookings');
    } on DioException catch (error) {
      if (!mounted) return;
      setState(() {
        _available = null;
        _message = _errorMessage(error);
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _available = null;
        _message = 'Could not reserve this slot. Check again before retrying.';
      });
    } finally {
      if (mounted) setState(() => _reserving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final venue =
        mockVenues.where((item) => item.id == widget.venueId).firstOrNull;
    final resource = venue?.branches
        .expand((branch) => branch.resources)
        .where((item) => item.id == widget.resourceId)
        .firstOrNull;
    final isDemo =
        venue?.id.startsWith('demo-space-') == true && resource != null;
    return Scaffold(
      appBar: AppBar(title: const Text('Book a demo space')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(resource?.name ?? 'Unknown resource',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(isDemo
                ? 'Demo only · ${venue!.name}. These are example places, not confirmed live listings. Reservations here are not real venue bookings.'
                : 'This resource is not connected to the booking service.'),
            const SizedBox(height: 16),
            if (isDemo) ...[
              const Text('One-hour slots · 10:00–18:00 Asia/Damascus time'),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(_selectedDate == null ? 'Choose a date' : _date),
                trailing: const Icon(Icons.calendar_today),
                onTap: _reserving
                    ? null
                    : () async {
                        final today = DateTime.now();
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: today,
                          firstDate: today,
                          lastDate: today.add(const Duration(days: 60)),
                        );
                        if (picked == null || !mounted) return;
                        setState(() => _selectedDate = picked);
                        await _check();
                      },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(_selectedTime == null
                    ? 'Choose a starting hour'
                    : _selectedTime!.format(context)),
                trailing: const Icon(Icons.schedule),
                onTap: _reserving
                    ? null
                    : () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: const TimeOfDay(hour: 10, minute: 0),
                          initialEntryMode: TimePickerEntryMode.dialOnly,
                        );
                        if (picked == null || !mounted) return;
                        if (picked.hour < 10 ||
                            picked.hour >= 18 ||
                            picked.minute != 0) {
                          setState(() {
                            _selectedTime = null;
                            _available = null;
                            _message =
                                'Choose a whole hour from 10:00 through 17:00.';
                          });
                          return;
                        }
                        setState(() => _selectedTime = picked);
                        await _check();
                      },
              ),
              if (_checking) const LinearProgressIndicator(),
              if (_message != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(_message!, key: const Key('booking-status')),
                ),
              const Spacer(),
              if (_confirmation == null) ...[
                OutlinedButton(
                  onPressed: _checking ||
                          _reserving ||
                          _selectedDate == null ||
                          _selectedTime == null
                      ? null
                      : _check,
                  child: const Text('Check availability again'),
                ),
                ElevatedButton(
                  onPressed: _available == true && !_checking && !_reserving
                      ? _reserve
                      : null,
                  child: Text(_reserving ? 'Reserving…' : 'Reserve demo slot'),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
