import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';

class SetEvent extends StatefulWidget {
  @override
  _SetEventState createState() => _SetEventState();
}

class _SetEventState extends State<SetEvent> {
  final TextEditingController _eventNameController = TextEditingController();
  DateTime? _selectedDateTime;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  void _initializeNotifications() {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _scheduleNotification(
      String eventName, DateTime dateTime) async {
    var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
      'event_reminder_channel',
      'Event Reminders',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );

    var platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.schedule(
      0,
      'Smart Farmer',
      eventName,
      dateTime,
      platformChannelSpecifics,
    );
  }

  Future<void> _pickDateTime() async {
    DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (date != null) {
      TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (time != null) {
        setState(() {
          _selectedDateTime =
              DateTime(date.year, date.month, date.day, time.hour, time.minute);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Set Event'),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        // Wrapped the content in SingleChildScrollView
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _eventNameController,
              decoration: InputDecoration(
                labelText: 'Event Name',
                labelStyle: TextStyle(color: Colors.teal),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _pickDateTime,
              icon: const Icon(Icons.calendar_today),
              label: Text(
                _selectedDateTime == null
                    ? 'Set Date & Time' // Placeholder when no date/time is selected
                    : DateFormat('yyyy-MM-dd HH:mm').format(
                        _selectedDateTime!), // Display date/time when selected
              ),
              style: ElevatedButton.styleFrom(
                primary: Colors.teal,
              ),
            ),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  if (_eventNameController.text.isNotEmpty &&
                      _selectedDateTime != null) {
                    _scheduleNotification(
                        _eventNameController.text, _selectedDateTime!);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Event scheduled successfully!'),
                    ));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text(
                          'Please enter event details and select date/time.'),
                    ));
                  }
                },
                child: const Text('Set Event'),
                style: ElevatedButton.styleFrom(
                  primary: Colors.teal,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  textStyle: const TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
