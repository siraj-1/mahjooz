import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/widgets/mahjooz_bottom_nav.dart';
import '../../../shared/models/venue.dart';

const _green = Color(0xFF187E58);
const _paleGreen = Color(0xFFD6EDD4);
const _muted = Color(0xFF68756C);

/// A shared place overview. The two demo spaces have bookable preview
/// inventory; other sample places retain their branch details without
/// claiming availability, prices, ratings or photos.
class DemoVenueDetail extends StatefulWidget {
  const DemoVenueDetail({super.key, required this.venue});

  final Venue venue;

  @override
  State<DemoVenueDetail> createState() => _DemoVenueDetailState();
}

class _DemoVenueDetailState extends State<DemoVenueDetail> {
  String _category = 'desk';
  bool _showSpaces = false;

  @override
  Widget build(BuildContext context) {
    final venue = widget.venue;
    final isBookableDemo = venue.id.startsWith('demo-space-');
    final desks = venue.countResources('desk');
    final offices = venue.countResources('office');

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('محجوز.',
              style: TextStyle(
                  color: _green, fontSize: 26, fontWeight: FontWeight.w600)),
          backgroundColor: Colors.white,
        ),
        body: ListView(
          children: [
            Container(
              height: 210,
              color: _green,
              child: Stack(
                children: [
                  const Center(
                    child: CustomPaint(
                      size: Size(170, 112),
                      painter: _DeskIllustration(),
                    ),
                  ),
                  Positioned(
                    bottom: 12,
                    left: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF126443),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Text('رسم توضيحي · لا توجد صورة',
                          style: TextStyle(color: Colors.white, fontSize: 10)),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(venue.name,
                      style: const TextStyle(
                          fontSize: 21, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 5),
                  Text(
                    isBookableDemo
                        ? 'مكان تجريبي · تفاصيل الموقع غير مؤكدة'
                        : 'مكان للعرض · لا توجد تفاصيل حجز مؤكدة',
                    style: const TextStyle(fontSize: 11, color: _muted),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      _TabLabel(
                          title: 'نبذة',
                          selected: !_showSpaces,
                          onTap: () => setState(() => _showSpaces = false)),
                      const SizedBox(width: 22),
                      _TabLabel(
                          title: 'المساحات',
                          selected: _showSpaces,
                          onTap: () => setState(() => _showSpaces = true)),
                    ],
                  ),
                  const Divider(height: 1, color: Color(0xFFE4E9E3)),
                  const SizedBox(height: 15),
                  if (isBookableDemo) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 13, vertical: 13),
                      decoration: BoxDecoration(
                        color: _paleGreen,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.access_time_rounded,
                              color: Color(0xFF216C42), size: 19),
                          SizedBox(width: 9),
                          Expanded(
                            child: Text('ساعات الحجز · 10:00 ص – 6:00 م',
                                style: TextStyle(
                                    color: Color(0xFF165D37), fontSize: 12)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],
                  Text(
                    _showSpaces
                        ? isBookableDemo
                            ? 'اختر نوع المساحة، ثم حدد يوماً ووقتاً لفحص التوفر.'
                            : 'تفاصيل المساحات والحجز غير مؤكدة لهذا المكان.'
                        : isBookableDemo
                            ? 'هذه مساحة للعرض التجريبي فقط. يمكنك استعراض المقاعد والمكاتب وفحص المواعيد، لكن الحجز ليس في مكان فعلي.'
                            : venue.description ??
                                'هذه قائمة للعرض فقط، وليست مكاناً متاحاً للحجز المؤكد.',
                    style: const TextStyle(
                        fontSize: 12, height: 1.8, color: Color(0xFF414A43)),
                  ),
                  const SizedBox(height: 23),
                  if (isBookableDemo) ...[
                    const Text('شو بتحتاج؟',
                        style: TextStyle(
                            fontSize: 17, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 11),
                    Row(
                      children: [
                        Expanded(
                          child: _ChoiceCard(
                            title: 'مقعد عمل',
                            count: '$desks ${desks == 1 ? 'مقعد' : 'مقاعد'}',
                            icon: Icons.chair_outlined,
                            selected: _category == 'desk',
                            onTap: () => setState(() => _category = 'desk'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _ChoiceCard(
                            title: 'مكتب خاص',
                            count:
                                '$offices ${offices == 1 ? 'مكتب' : 'مكاتب'}',
                            icon: Icons.meeting_room_outlined,
                            selected: _category == 'office',
                            onTap: () => setState(() => _category = 'office'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 11),
                    const Text(
                        'هذه أعداد المساحات، وليست أعداداً متاحة الآن. التوفر يظهر بعد اختيار الموعد.',
                        style: TextStyle(color: _muted, fontSize: 10.5)),
                  ] else ...[
                    const Text('تفاصيل المكان',
                        style: TextStyle(
                            fontSize: 17, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 10),
                    if (venue.branches.isEmpty)
                      const Text('لا تتوفر مساحات للحجز في هذا المثال.',
                          style: TextStyle(color: _muted, fontSize: 12))
                    else
                      for (final branch in venue.branches) ...[
                        Text(branch.name,
                            style:
                                const TextStyle(fontWeight: FontWeight.w600)),
                        for (final resource in branch.resources)
                          Row(
                            children: [
                              Expanded(
                                child: Text(resource.name,
                                    style: const TextStyle(
                                        color: _muted, fontSize: 12)),
                              ),
                              TextButton(
                                onPressed: () => context.push(
                                    '/venue/${venue.id}/book/${resource.id}'),
                                child: const Text('عرض الحجز'),
                              ),
                            ],
                          ),
                        const SizedBox(height: 10),
                      ],
                  ],
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isBookableDemo)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 10),
                child: FilledButton(
                  onPressed: () =>
                      context.push('/venue/${venue.id}/select/$_category'),
                  style: FilledButton.styleFrom(
                    backgroundColor: _green,
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(_category == 'desk'
                      ? 'عرض المقاعد المتاحة'
                      : 'عرض المكاتب المتاحة'),
                ),
              ),
            const MahjoozBottomNav(currentIndex: 0),
          ],
        ),
      ),
    );
  }
}

class _DeskIllustration extends CustomPainter {
  const _DeskIllustration();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final w = size.width;
    final h = size.height;
    // Table, legs, and an open laptop: an illustration, not a venue photo.
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(w * .09, h * .67, w * .82, h * .09),
            const Radius.circular(2)),
        paint);
    canvas.drawLine(Offset(w * .19, h * .76), Offset(w * .19, h), paint);
    canvas.drawLine(Offset(w * .81, h * .76), Offset(w * .81, h), paint);
    final laptop = Path()
      ..moveTo(w * .34, h * .65)
      ..lineTo(w * .40, h * .15)
      ..lineTo(w * .60, h * .15)
      ..lineTo(w * .66, h * .65)
      ..close();
    canvas.drawPath(laptop, paint);
    canvas.drawLine(Offset(w * .29, h * .65), Offset(w * .71, h * .65), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _TabLabel extends StatelessWidget {
  const _TabLabel(
      {required this.title, required this.selected, required this.onTap});

  final String title;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.only(bottom: 12, top: 5),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                  color: selected ? _green : Colors.transparent, width: 2),
            ),
          ),
          child: Text(title,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  color: selected ? _green : _muted)),
        ),
      );
}

class _ChoiceCard extends StatelessWidget {
  const _ChoiceCard({
    required this.title,
    required this.count,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String count;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
        color: selected ? _paleGreen : Colors.white,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: selected ? _green : const Color(0xFFDDE2DD)),
          borderRadius: BorderRadius.circular(14),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: SizedBox(
            height: 123,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: _green, size: 22),
                const SizedBox(height: 7),
                Text(title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                Text(count,
                    style: const TextStyle(color: _muted, fontSize: 11)),
              ],
            ),
          ),
        ),
      );
}
