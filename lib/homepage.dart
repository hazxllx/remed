import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'add_medicine.dart'; // For adding new medicine
import 'settings.dart'; // For settings page

class HomePage extends StatefulWidget {
  final String username;

  const HomePage({super.key, required this.username});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late DateTime _now;
  late Timer _timer;
  List<Medicine> _medicines = []; // List to store medicines from Firestore

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _startTimer();
    _fetchMedicines(); // Fetch medicines when the page loads
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      final currentTime = DateTime.now();
      if (_now.day != currentTime.day) {
        setState(() => _now = currentTime);
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  // Fetch medicines from Firestore
  void _fetchMedicines() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      try {
        final snapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('medicines')
            .get();

        setState(() {
          _medicines = snapshot.docs.map((doc) {
            final data = doc.data();
            return Medicine(
              name: data['name'] ?? '',
              type: data['type'] ?? '',
              dose: data['dose'] ?? '',
              amount: data['amount'] ?? 0,
              // Convert reminder times back from String to TimeOfDay
              reminderTimes: List<TimeOfDay>.from(
                (data['reminderTimes'] ?? []).map((timeStr) {
                  final time = TimeOfDay.fromDateTime(DateFormat("hh:mm a").parse(timeStr));
                  return time;
                }),
              ),
            );
          }).toList();
        });
      } catch (e) {
        print('Error fetching medicines: $e');
      }
    }
  }

  String _formatDate(DateTime date) {
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return "${weekdays[date.weekday - 1]}, ${date.day} ${months[date.month - 1]}";
  }

  @override
  Widget build(BuildContext context) {
    final List<DateTime> weekDates = List.generate(
      5,
      (index) => _now.subtract(Duration(days: 2 - index)),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.pinkAccent,
        onPressed: () async {
          // Navigate to the AddMedicinePage and wait for the result
          final Medicine? medicine = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddMedicinePage()),
          );

          // After adding the medicine, refresh the list
          if (medicine != null) {
            _fetchMedicines(); // Re-fetch medicines from Firestore
          }
        },
        child: const Icon(Icons.add, size: 30, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.home_outlined, color: Colors.black),
                onPressed: () {
                  setState(() => _now = DateTime.now());
                },
              ),
              IconButton(
                icon: const Icon(Icons.settings_outlined, color: Colors.black),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SettingsPage(title: 'Settings')),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const CircleAvatar(
                    radius: 24,
                    backgroundImage: AssetImage('assets/user.png'),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(color: Colors.black, fontSize: 18),
                        children: [
                          const TextSpan(text: "Hey, "),
                          TextSpan(
                            text: widget.username,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const TextSpan(text: " 👋"),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                "Today, ${_formatDate(_now)}",
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 60,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: weekDates.length,
                  itemBuilder: (context, index) {
                    final date = weekDates[index];
                    final isSelected = date.day == _now.day &&
                        date.month == _now.month &&
                        date.year == _now.year;

                    final dayAbbr = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"][date.weekday % 7];

                    return Container(
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.pinkAccent : const Color(0xFFF2F2F2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            date.day.toString(),
                            style: TextStyle(
                              fontSize: 16,
                              color: isSelected ? Colors.white : Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            dayAbbr,
                            style: TextStyle(
                              fontSize: 14,
                              color: isSelected ? Colors.white : Colors.black,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    "To take",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "Edit",
                    style: TextStyle(color: Colors.pinkAccent),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Display the list of medicines with reminder times
              Expanded(
                child: ListView.builder(
                  itemCount: _medicines.length,
                  itemBuilder: (context, index) {
                    final medicine = _medicines[index];
                    return ListTile(
                      title: Text(medicine.name),
                      subtitle: Text(
                        'Reminder: ${medicine.reminderTimes.map((time) => time.format(context)).join(', ')}',
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
