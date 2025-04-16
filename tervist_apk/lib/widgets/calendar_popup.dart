import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:dotted_border/dotted_border.dart';

// Define the enum for different calendar day states
enum CalendarDayStatus {
  redSolid, // User input food but calories below target
  graySolid, // User input food and calories target fulfilled
  grayDashed, // No food input
  blackDashed, // Today/selected day, calories target not fulfilled
  blackSolid, // Today/selected day, calories target fulfilled
}

class CalendarPopup extends StatefulWidget {
  final DateTime? initialSelectedDate;
  final Function(DateTime)? onDateSelected;
  final Map<DateTime, CalendarDayStatus>? dayStatuses;

  const CalendarPopup({
    super.key,
    this.initialSelectedDate,
    this.onDateSelected,
    this.dayStatuses,
  });

  @override
  State<CalendarPopup> createState() => _CalendarPopupState();
}

class _CalendarPopupState extends State<CalendarPopup> {
  late DateTime selectedDate;
  late DateTime currentMonth;
  late Map<DateTime, CalendarDayStatus> _dayStatuses;

  List<int> markedDates = [5, 7, 9, 10, 15];

  @override
  void initState() {
    super.initState();
    // Use the initialSelectedDate if provided, otherwise use default
    selectedDate = widget.initialSelectedDate ?? DateTime.now();

    // Set the current month based on the selected date
    currentMonth = DateTime(selectedDate.year, selectedDate.month);

    // Initialize day statuses with the provided map or create empty one
    _dayStatuses = widget.dayStatuses ?? {};

    // If dayStatuses is not provided, create sample data for demo
    if (widget.dayStatuses == null) {
      _generateSampleDayStatuses();
    }
  }

  // Method to generate sample day statuses for demonstration
  void _generateSampleDayStatuses() {
    // Current month dates
    final daysInMonth = _daysInMonth(currentMonth);

    // Sample dates with food input but calories below target (red solid)
    final redSolidDays = [5, 7, 9, 10, 15, 22, 25, 29];

    // Sample dates with food input and calories target fulfilled (gray solid)
    final graySolidDays = [2, 3, 4, 8, 16, 23, 30];

    // Sample dates with no food input (gray dashed)
    final grayDashedDays = [1, 6, 11, 12, 13, 14, 17, 20, 26, 27, 28, 31];

    // Today (let's assume it's day 18) with calories target fulfilled (black solid)
    final blackSolidDays = [18];

    // Selected day with calories target not fulfilled (black dashed)
    final blackDashedDays = [19, 21, 24];

    for (var i = 1; i <= daysInMonth; i++) {
      final date = DateTime(currentMonth.year, currentMonth.month, i);

      if (redSolidDays.contains(i)) {
        _dayStatuses[date] = CalendarDayStatus.redSolid;
      } else if (graySolidDays.contains(i)) {
        _dayStatuses[date] = CalendarDayStatus.graySolid;
      } else if (grayDashedDays.contains(i)) {
        _dayStatuses[date] = CalendarDayStatus.grayDashed;
      } else if (blackSolidDays.contains(i)) {
        _dayStatuses[date] = CalendarDayStatus.blackSolid;
      } else if (blackDashedDays.contains(i)) {
        _dayStatuses[date] = CalendarDayStatus.blackDashed;
      }
    }
  }

  void _changeMonth(int offset) {
    setState(() {
      currentMonth = DateTime(currentMonth.year, currentMonth.month + offset);

      // If we change month and don't have status data, generate sample data
      if (widget.dayStatuses == null) {
        _generateSampleDayStatuses();
      }
    });
  }

  void _selectDate(DateTime date) {
    setState(() {
      selectedDate = date;
    });

    // Call the onDateSelected callback if provided
    if (widget.onDateSelected != null) {
      widget.onDateSelected!(date);
    } else {
      // If no callback provided, just return the date and close dialog
      Navigator.pop(context, date);
    }
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
    final now = DateTime.now();

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

                      // Create date object for this cell
                      DateTime? cellDate = isValid
                          ? DateTime(
                              currentMonth.year, currentMonth.month, dateNum)
                          : null;

                      // Get status for this date if it exists
                      CalendarDayStatus? dayStatus =
                          cellDate != null ? _dayStatuses[cellDate] : null;

                      // Check if this is the selected date or today
                      bool isSelectedDate = isValid &&
                          selectedDate.year == currentMonth.year &&
                          selectedDate.month == currentMonth.month &&
                          selectedDate.day == dateNum;

                      bool isToday = isValid &&
                          now.year == currentMonth.year &&
                          now.month == currentMonth.month &&
                          now.day == dateNum;

                      // If this is today or selected date and we don't have explicit status,
                      // default to black dashed (target not met)
                      if ((isToday || isSelectedDate) && dayStatus == null) {
                        dayStatus = CalendarDayStatus.blackDashed;
                      }

                      return GestureDetector(
                        onTap: isValid
                            ? () => _selectDate(DateTime(
                                currentMonth.year, currentMonth.month, dateNum))
                            : null,
                        child: _buildCalendarDayCell(
                          dateNum: dateNum,
                          isValid: isValid,
                          dayStatus: dayStatus,
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

  // Build a calendar day cell with the appropriate styling
  Widget _buildCalendarDayCell({
    required int dateNum,
    required bool isValid,
    CalendarDayStatus? dayStatus,
  }) {
    if (!isValid) {
      // Empty cell for invalid dates
      return Container(
        width: 36,
        height: 36,
      );
    }

    // Default style (for dates without status)
    Color borderColor = Colors.grey.shade300;
    Color textColor = Colors.black;
    bool isDashed = false;
    double borderWidth = 1.0;

    if (dayStatus != null) {
      switch (dayStatus) {
        case CalendarDayStatus.redSolid:
          borderColor = Colors.red;
          textColor = Colors.black;
          isDashed = false;
          borderWidth = 2.0;
          break;
        case CalendarDayStatus.graySolid:
          borderColor = Colors.grey;
          textColor = Colors.black;
          isDashed = false;
          borderWidth = 1.0;
          break;
        case CalendarDayStatus.grayDashed:
          borderColor = Colors.grey;
          textColor = Colors.black;
          isDashed = true;
          borderWidth = 1.0;
          break;
        case CalendarDayStatus.blackDashed:
          borderColor = Colors.black;
          textColor = Colors.black;
          isDashed = true;
          borderWidth = 1.0;
          break;
        case CalendarDayStatus.blackSolid:
          borderColor = Colors.black;
          textColor = Colors.black;
          isDashed = false;
          borderWidth = 1.0;
          break;
      }
    }

    // Create a dashed or solid border based on the status
    if (isDashed) {
      return DottedBorder(
        borderType: BorderType.Circle,
        color: borderColor,
        strokeWidth: borderWidth,
        dashPattern: const [3, 2],
        child: SizedBox(
          width: 34,
          height: 34,
          child: Center(
            child: Text(
              dateNum.toString(),
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
        ),
      );
    } else {
      return Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: borderColor,
            width: borderWidth,
          ),
        ),
        child: Center(
          child: Text(
            dateNum.toString(),
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
      );
    }
  }
}
