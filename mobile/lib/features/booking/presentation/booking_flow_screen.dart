import 'package:flutter/material.dart';

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
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  // TODO: this screen is intentionally a placeholder. Real date/time
  // selection needs to call the Availability Engine (once it exists on
  // the backend) before rendering slots as available — don't hardcode
  // "available" here even for a demo, since that's exactly the
  // assumption the whole booking engine exists to prevent.

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Book')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                _selectedDate == null
                    ? 'Choose a date'
                    : _selectedDate.toString().split(' ').first,
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 60)),
                );
                if (picked != null) setState(() => _selectedDate = picked);
              },
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                _selectedTime == null
                    ? 'Choose a time'
                    : _selectedTime!.format(context),
              ),
              trailing: const Icon(Icons.schedule),
              onTap: () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                if (picked != null) setState(() => _selectedTime = picked);
              },
            ),
            const SizedBox(height: 24),
            const Text(
              'Availability isn\'t checked yet — this screen is a UI '
              'placeholder until the backend booking engine exists.',
              style: TextStyle(color: Colors.grey),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _selectedDate != null && _selectedTime != null
                  ? () {} // TODO: wire to POST /bookings once the engine exists.
                  : null,
              child: const Text('Reserve (disabled until backend exists)'),
            ),
          ],
        ),
      ),
    );
  }
}
