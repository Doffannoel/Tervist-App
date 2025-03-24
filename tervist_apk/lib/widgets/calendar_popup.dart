import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CalendarPopup extends StatefulWidget {
  const CalendarPopup({super.key});

  @override
  State<CalendarPopup> createState() => _CalendarPopupState();
}

class _CalendarPopupState extends State<CalendarPopup> {
  DateTime selectedDate = DateTime(2025, 2, 18);
  DateTime currentMonth = DateTime(2025, 2);

  List<int> markedDates = [5, 7, 9, 10, 15];

  void _changeMonth(int offset) {
    setState(() {
      currentMonth = DateTime(currentMonth.year, currentMonth.month + offset);
    });
  }

  int _daysInMonth(DateTime month) {
    final beginningNextMonth = (month.month < 12)
        ? DateTime(month.year, month.month + 1, 1)
        : DateTime(month.year + 1, 1, 1);
    return beginningNextMonth.subtract(const Duration(days: 1)).day;
  }

  @override
  Widget build(BuildContext context) {
    final daysInMonth = _daysInMonth(currentMonth);
    final firstWeekday =
        DateTime(currentMonth.year, currentMonth.month, 1).weekday % 7;
    final weeks = 6; // Fixed 6 rows to ensure consistent height
    final now = DateTime(2025, 2, 20);

    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Month navigation row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => _changeMonth(-1),
                  child: Text(
                    DateFormat("< MMM yyyy").format(
                        DateTime(currentMonth.year, currentMonth.month - 1)),
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.calendar_today, size: 16),
                      const SizedBox(width: 6),
                      Text(DateFormat("MMMM yyyy").format(currentMonth),
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => _changeMonth(1),
                  child: Text(
                    DateFormat("MMM yyyy >").format(
                        DateTime(currentMonth.year, currentMonth.month + 1)),
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Day headers
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: const [
                Text('S'),
                Text('M'),
                Text('T'),
                Text('W'),
                Text('T'),
                Text('F'),
                Text('S')
              ],
            ),
            const SizedBox(height: 12),

            // Calendar grid
            Column(
              children: List.generate(weeks, (week) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: List.generate(7, (day) {
                      int dayIndex = week * 7 + day;
                      int dateNum = dayIndex - firstWeekday + 1;
                      bool isValid = dateNum > 0 && dateNum <= daysInMonth;
                      bool isSelected = isValid &&
                          selectedDate.year == currentMonth.year &&
                          selectedDate.month == currentMonth.month &&
                          selectedDate.day == dateNum;
                      bool isToday = isValid &&
                          now.year == currentMonth.year &&
                          now.month == currentMonth.month &&
                          now.day == dateNum;
                      bool isMarked = markedDates.contains(dateNum);

                      return Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: isSelected
                              ? Border.all(color: Colors.red, width: 2)
                              : isToday
                                  ? Border.all(color: Colors.black, width: 1)
                                  : isMarked
                                      ? Border.all(color: Colors.red, width: 1)
                                      : Border.all(color: Colors.grey.shade300),
                        ),
                        child: Center(
                          child: Text(
                            isValid ? dateNum.toString() : '',
                            style: TextStyle(
                              color: isSelected ? Colors.red : Colors.black,
                              fontWeight: isSelected || isToday
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
