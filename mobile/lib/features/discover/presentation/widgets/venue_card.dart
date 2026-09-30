import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../shared/models/venue.dart';

const _green = Color(0xFF187E58);
const _muted = Color(0xFF6D736E);

class VenueCard extends StatelessWidget {
  const VenueCard({
    super.key,
    required this.venue,
    required this.category,
    this.onTap,
  });

  final Venue venue;
  final String category;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDemoSpace = venue.id.startsWith('demo-space-');
    final isDemoCafe = venue.id.startsWith('demo-cafe-');
    final count = venue.countResources(category);
    final resourceLabel = category == 'desk'
        ? (count == 1 ? 'مقعد' : 'مقاعد')
        : (count == 1 ? 'مكتب' : 'مكاتب');
    return Column(
      children: [
        Material(
          color: Colors.white,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 2),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _PhotoPlaceholder(),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          venue.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF202820)),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          isDemoSpace
                              ? 'مكان تجريبي · لا توجد تفاصيل مؤكدة للموقع'
                              : isDemoCafe
                                  ? 'مقهى تجريبي · ليس قائمة حقيقية'
                                  : 'بيانات المكان قيد التحقق',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 10.5, height: 1.5, color: _muted),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 5,
                          runSpacing: 5,
                          children: [
                            _Tag(
                              label: isDemoSpace
                                  ? '$count $resourceLabel'
                                  : 'عرض تجريبي',
                            ),
                            if (isDemoSpace)
                              const _Tag(label: 'الحجز 10 ص – 6 م'),
                          ],
                        ),
                        const SizedBox(height: 9),
                        const Text(
                          'استعرض التفاصيل',
                          style: TextStyle(
                              color: _green,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const Divider(height: 1, thickness: 1, color: Color(0xFFE9ECE8)),
      ],
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFDCF1DC),
          borderRadius: BorderRadius.circular(7),
        ),
        child: Text(label,
            style: const TextStyle(
                color: Color(0xFF276E42),
                fontSize: 9.5,
                fontWeight: FontWeight.w500)),
      );
}

class _PhotoPlaceholder extends StatelessWidget {
  const _PhotoPlaceholder();

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: _DashedBorderPainter(),
        child: const SizedBox(
          width: 96,
          height: 96,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.image_outlined, size: 21, color: Color(0xFF9DA79E)),
              SizedBox(height: 4),
              Text('لا توجد صورة',
                  style: TextStyle(fontSize: 9, color: _muted)),
            ],
          ),
        ),
      );
}

class _DashedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFCCD2CB)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
          Offset.zero & size, const Radius.circular(14)));
    for (final metric in path.computeMetrics()) {
      for (double distance = 0; distance < metric.length; distance += 8) {
        canvas.drawPath(
            metric.extractPath(distance, math.min(distance + 4, metric.length)),
            paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
