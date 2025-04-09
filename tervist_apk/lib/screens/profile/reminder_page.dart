import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tervist_apk/api/notification_service.dart';
import 'package:tervist_apk/api/reminder_model.dart';
import 'package:tervist_apk/api/reminder_service.dart';

<<<<<<< Updated upstream
import 'package:tervist_apk/api/notification_service.dart';
import 'package:tervist_apk/api/reminder_model.dart';
import 'package:tervist_apk/api/reminder_service.dart';

=======
>>>>>>> Stashed changes

class ReminderPage extends StatefulWidget {
  const ReminderPage({super.key});

  @override
  State<ReminderPage> createState() => _ReminderPageState();
}

class _ReminderPageState extends State<ReminderPage> {
  final ReminderService _reminderService = ReminderService();
  final NotificationService _notificationService = NotificationService();
  bool _isLoading = true;
  String _errorMessage = '';
  bool _notificationsInitialized = false;

  // Map to store reminders from backend
  Map<String, Reminder?> _reminders = {
    'Breakfast': null,
    'Lunch': null,
    'Dinner': null,
    'Snack': null,
<<<<<<< Updated upstream
  final ReminderService _reminderService = ReminderService();
  final NotificationService _notificationService = NotificationService();
  bool _isLoading = true;
  String _errorMessage = '';
  bool _notificationsInitialized = false;

  // Map to store reminders from backend
  Map<String, Reminder?> _reminders = {
    'Breakfast': null,
    'Lunch': null,
    'Dinner': null,
    'Snack': null,
  };

  // Default times for new reminders
  final Map<String, String> _defaultTimes = {
    'Breakfast': '08:00',
    'Lunch': '13:00',
    'Dinner': '19:30',
    'Snack': '15:50',
  };

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _fetchReminders();
  }

  Future<void> _initializeNotifications() async {
    try {
      await _notificationService.init();
      setState(() {
        _notificationsInitialized = true;
      });
    } catch (e) {
      print('Error initializing notifications: $e');
      // Still mark as initialized to prevent repeated attempts
      setState(() {
        _notificationsInitialized = true;
      });
    }
  }

  Future<void> _fetchReminders() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      final reminders = await _reminderService.getReminders();

      // Reset reminders map
      Map<String, Reminder?> newReminders = {
        'Breakfast': null,
        'Lunch': null,
        'Dinner': null,
        'Snack': null,
      };

      // Populate with fetched data
      for (var reminder in reminders) {
        newReminders[reminder.mealType] = reminder;

        // Schedule notifications for active reminders
        if (_notificationsInitialized && reminder.isActive) {
          try {
            await _notificationService.scheduleMealReminder(reminder);
          } catch (e) {
            print('Error scheduling notification: $e');
          }
        }
      }

      setState(() {
        _reminders = newReminders;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading reminders: $e';
        _isLoading = false;
      });
      print(_errorMessage);
    }
  }

  Future<void> _updateReminderStatus(String mealType, bool isActive) async {
    try {
      final reminder = _reminders[mealType];

      if (reminder != null && reminder.id != null) {
        // Update existing reminder
        final updatedReminder = await _reminderService.updateReminderStatus(
            reminder.id, isActive, mealType);

        setState(() {
          _reminders[mealType] = updatedReminder;
        });

        // Update notification
        if (_notificationsInitialized) {
          try {
            await _notificationService.scheduleMealReminder(updatedReminder);
          } catch (e) {
            print('Error scheduling notification: $e');
          }
        }
      } else {
        // Create new reminder with default time
        final newReminder = Reminder(
          mealType: mealType,
          time: _defaultTimes[mealType]!,
          isActive: isActive,
        );

        final savedReminder = await _reminderService.saveReminder(newReminder);

        setState(() {
          _reminders[mealType] = savedReminder;
        });

        // Schedule notification if active
        if (_notificationsInitialized && isActive) {
          try {
            await _notificationService.scheduleMealReminder(savedReminder);
          } catch (e) {
            print('Error scheduling notification: $e');
          }
        }
      }
    } catch (e) {
      final errorMsg = 'Error updating reminder: $e';
      print(errorMsg);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMsg)),
      );
    }
  }

  Future<void> _showTimePickerDialog(String mealType) async {
    // Get current time from reminder or default
    TimeOfDay initialTime;
    if (_reminders[mealType] != null) {
      final timeStr = _reminders[mealType]!.time;
      final timeParts = timeStr.split(':');
      initialTime = TimeOfDay(
        hour: int.parse(timeParts[0]),
        minute: int.parse(timeParts[1]),
      );
    } else {
      final defaultTimeStr = _defaultTimes[mealType]!;
      final timeParts = defaultTimeStr.split(':');
      initialTime = TimeOfDay(
        hour: int.parse(timeParts[0]),
        minute: int.parse(timeParts[1]),
      );
    }

    // Show time picker
    final selectedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.orange,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    // If user selected a time, update the reminder
    if (selectedTime != null) {
      final formattedHour = selectedTime.hour.toString().padLeft(2, '0');
      final formattedMinute = selectedTime.minute.toString().padLeft(2, '0');
      final timeString = '$formattedHour:$formattedMinute';

      try {
        final currentReminder = _reminders[mealType];
        final isActive = currentReminder?.isActive ?? false;

        final newReminder = Reminder(
          id: currentReminder?.id,
          mealType: mealType,
          time: timeString,
          isActive: isActive,
        );

        final updatedReminder =
            await _reminderService.saveReminder(newReminder);

        setState(() {
          _reminders[mealType] = updatedReminder;
        });

        // Update notification
        if (_notificationsInitialized && isActive) {
          try {
            await _notificationService.scheduleMealReminder(updatedReminder);
          } catch (e) {
            print('Error scheduling notification: $e');
          }
        }
      } catch (e) {
        final errorMsg = 'Error updating reminder time: $e';
        print(errorMsg);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMsg)),
        );
      }
    }
  }

  String _formatTimeDisplay(String? timeString) {
    if (timeString == null) return '';

    try {
      final timeParts = timeString.split(':');
      final hour = int.parse(timeParts[0]);
      final minute = timeParts[1];

      return '${hour.toString().padLeft(2, '0')}.${minute}';
    } catch (e) {
      return timeString;
    }
  }

  @override
=======
  final Map<String, bool> reminders = {
    'Breakfast': false,
    'Lunch': false,
    'Dinner': false,
    'Snack': false,
  };

  // Default times for new reminders
  final Map<String, String> _defaultTimes = {
    'Breakfast': '08:00',
    'Lunch': '13:00',
    'Dinner': '19:30',
    'Snack': '15:50',
  };

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _fetchReminders();
  }

  Future<void> _initializeNotifications() async {
    try {
      await _notificationService.init();
      setState(() {
        _notificationsInitialized = true;
      });
    } catch (e) {
      print('Error initializing notifications: $e');
      // Still mark as initialized to prevent repeated attempts
      setState(() {
        _notificationsInitialized = true;
      });
    }
  }

  Future<void> _fetchReminders() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      final reminders = await _reminderService.getReminders();

      // Reset reminders map
      Map<String, Reminder?> newReminders = {
        'Breakfast': null,
        'Lunch': null,
        'Dinner': null,
        'Snack': null,
      };

      // Populate with fetched data
      for (var reminder in reminders) {
        newReminders[reminder.mealType] = reminder;

        // Schedule notifications for active reminders
        if (_notificationsInitialized && reminder.isActive) {
          try {
            await _notificationService.scheduleMealReminder(reminder);
          } catch (e) {
            print('Error scheduling notification: $e');
          }
        }
      }

      setState(() {
        _reminders = newReminders;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading reminders: $e';
        _isLoading = false;
      });
      print(_errorMessage);
    }
  }

  Future<void> _updateReminderStatus(String mealType, bool isActive) async {
    try {
      final reminder = _reminders[mealType];

      if (reminder != null && reminder.id != null) {
        // Update existing reminder
        final updatedReminder = await _reminderService.updateReminderStatus(
            reminder.id, isActive, mealType);

        setState(() {
          _reminders[mealType] = updatedReminder;
        });

        // Update notification
        if (_notificationsInitialized) {
          try {
            await _notificationService.scheduleMealReminder(updatedReminder);
          } catch (e) {
            print('Error scheduling notification: $e');
          }
        }
      } else {
        // Create new reminder with default time
        final newReminder = Reminder(
          mealType: mealType,
          time: _defaultTimes[mealType]!,
          isActive: isActive,
        );

        final savedReminder = await _reminderService.saveReminder(newReminder);

        setState(() {
          _reminders[mealType] = savedReminder;
        });

        // Schedule notification if active
        if (_notificationsInitialized && isActive) {
          try {
            await _notificationService.scheduleMealReminder(savedReminder);
          } catch (e) {
            print('Error scheduling notification: $e');
          }
        }
      }
    } catch (e) {
      final errorMsg = 'Error updating reminder: $e';
      print(errorMsg);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMsg)),
      );
    }
  }

  Future<void> _showTimePickerDialog(String mealType) async {
    // Get current time from reminder or default
    TimeOfDay initialTime;
    if (_reminders[mealType] != null) {
      final timeStr = _reminders[mealType]!.time;
      final timeParts = timeStr.split(':');
      initialTime = TimeOfDay(
        hour: int.parse(timeParts[0]),
        minute: int.parse(timeParts[1]),
      );
    } else {
      final defaultTimeStr = _defaultTimes[mealType]!;
      final timeParts = defaultTimeStr.split(':');
      initialTime = TimeOfDay(
        hour: int.parse(timeParts[0]),
        minute: int.parse(timeParts[1]),
      );
    }

    // Show time picker
    final selectedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.orange,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    // If user selected a time, update the reminder
    if (selectedTime != null) {
      final formattedHour = selectedTime.hour.toString().padLeft(2, '0');
      final formattedMinute = selectedTime.minute.toString().padLeft(2, '0');
      final timeString = '$formattedHour:$formattedMinute';

      try {
        final currentReminder = _reminders[mealType];
        final isActive = currentReminder?.isActive ?? false;

        final newReminder = Reminder(
          id: currentReminder?.id,
          mealType: mealType,
          time: timeString,
          isActive: isActive,
        );

        final updatedReminder =
            await _reminderService.saveReminder(newReminder);

        setState(() {
          _reminders[mealType] = updatedReminder;
        });

        // Update notification
        if (_notificationsInitialized && isActive) {
          try {
            await _notificationService.scheduleMealReminder(updatedReminder);
          } catch (e) {
            print('Error scheduling notification: $e');
          }
        }
      } catch (e) {
        final errorMsg = 'Error updating reminder time: $e';
        print(errorMsg);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMsg)),
        );
      }
    }
  }

  String _formatTimeDisplay(String? timeString) {
    if (timeString == null) return '';

    try {
      final timeParts = timeString.split(':');
      final hour = int.parse(timeParts[0]);
      final minute = timeParts[1];

      return '${hour.toString().padLeft(2, '0')}.${minute}';
    } catch (e) {
      return timeString;
    }
  }

  @override
>>>>>>> Stashed changes
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F7F6),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: Colors.black, width: 1),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    child: Row(
                      children: [
                        const Icon(Icons.arrow_back_ios, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          'Profile',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'Reminder',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 60),
                ],
              ),
            ),
            const SizedBox(height: 32),

<<<<<<< Updated upstream

=======
>>>>>>> Stashed changes
            // Meals title
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Text(
                'Meals',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),

            if (_isLoading)
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(color: Colors.orange),
                ),
              )
            else if (_errorMessage.isNotEmpty)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _errorMessage,
                        style: TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _fetchReminders,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                        ),
                        child: Text('Try Again'),
                      ),
                    ],
                  ),
                ),
              )
            else
              // Meal switches
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _fetchReminders,
                  color: Colors.orange,
                  child: ListView(
                    children: _reminders.keys.map((meal) {
                      final reminder = _reminders[meal];
                      final isActive = reminder?.isActive ?? false;
                      final time = reminder?.time ?? _defaultTimes[meal]!;

                      return Column(
                        children: [
                          InkWell(
                            onTap: () => _showTimePickerDialog(meal),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 16),
                              color: const Color(0xFFF1F7F6),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        meal,
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        _formatTimeDisplay(time),
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          color: Colors.black.withOpacity(0.6),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Switch(
                                    value: isActive,
                                    onChanged: (value) {
                                      _updateReminderStatus(meal, value);
                                    },
                                    activeColor: Colors.orange,
                                    inactiveThumbColor: Colors.white,
                                    inactiveTrackColor: Colors.black,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const Divider(
                              height: 0, thickness: 1, color: Colors.black),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
<<<<<<< Updated upstream
            if (_isLoading)
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(color: Colors.orange),
                ),
              )
            else if (_errorMessage.isNotEmpty)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _errorMessage,
                        style: TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _fetchReminders,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                        ),
                        child: Text('Try Again'),
                      ),
                    ],
                  ),
                ),
              )
            else
              // Meal switches
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _fetchReminders,
                  color: Colors.orange,
                  child: ListView(
                    children: _reminders.keys.map((meal) {
                      final reminder = _reminders[meal];
                      final isActive = reminder?.isActive ?? false;
                      final time = reminder?.time ?? _defaultTimes[meal]!;

                      return Column(
                        children: [
                          InkWell(
                            onTap: () => _showTimePickerDialog(meal),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 16),
                              color: const Color(0xFFF1F7F6),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        meal,
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        _formatTimeDisplay(time),
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          color: Colors.black.withOpacity(0.6),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Switch(
                                    value: isActive,
                                    onChanged: (value) {
                                      _updateReminderStatus(meal, value);
                                    },
                                    activeColor: Colors.orange,
                                    inactiveThumbColor: Colors.white,
                                    inactiveTrackColor: Colors.black,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const Divider(
                              height: 0, thickness: 1, color: Colors.black),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
=======
            // Meal switches
            Expanded(
              child: ListView(
                children: reminders.keys.map((meal) {
                  return Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 16),
                        color: const Color(0xFFF1F7F6),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  meal,
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  times[meal]!,
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: Colors.black.withOpacity(0.6),
                                  ),
                                ),
                              ],
                            ),
                            Switch(
                              value: reminders[meal]!,
                              onChanged: (value) {
                                setState(() {
                                  reminders[meal] = value;
                                });
                              },
                              activeColor: Colors.orange,
                              inactiveThumbColor: Colors.white,
                              inactiveTrackColor: Colors.black,
                            ),
                          ],
                        ),
                      ),
                      const Divider(
                          height: 0, thickness: 1, color: Colors.black),
                    ],
                  );
                }).toList(),
              ),
            ),
>>>>>>> Stashed changes
          ],
        ),
      ),
    );
  }
}