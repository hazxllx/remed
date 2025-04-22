import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:intl/intl.dart'; 

// HomePage widget - Main screen displaying reminders and user-specific information
class HomePage extends StatefulWidget {
  final String username; // Username passed to the widget
  const HomePage({super.key, required this.username});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late DateTime _now; // Current date and time
  late Timer _timer; // Timer to update date and time periodically

  @override
  void initState() {
    super.initState();
    _now = DateTime.now(); // Initialize the current date
    _startTimer(); // Start the timer to update the date every minute
  }

  // Starts a timer that updates the current date every minute
  void _startTimer() {
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      final currentTime = DateTime.now();
      if (_now.day != currentTime.day) {
        setState(() => _now = currentTime); // Update the date if the day has changed
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  // Returns the current date formatted as "YYYY-MM-DD"
  String _formattedDate() {
    return "${_now.year.toString().padLeft(4, '0')}-${_now.month.toString().padLeft(2, '0')}-${_now.day.toString().padLeft(2, '0')}";
  }

  // Fetches reminders for the current user from Firestore
  Future<List<Map<String, dynamic>>> _getReminders() async {
    final uid = FirebaseAuth.instance.currentUser?.uid; // Get the current user's UID
    if (uid == null) return []; // Return an empty list if the user is not logged in
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('reminders')
        .where('date', isEqualTo: _formattedDate()) // Fetch reminders for today
        .get();

    return snapshot.docs.map((doc) => doc.data()).toList(); // Return the list of reminders
  }

  // Builds a UI card for displaying a reminder
  Widget _buildReminderCard(Map<String, dynamic> reminder) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(2, 2),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            reminder['name'] ?? 'Unnamed', // Display reminder name or default text
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.access_time, size: 18, color: Colors.grey),
              const SizedBox(width: 4),
              Text(reminder['time'] ?? '', style: const TextStyle(color: Colors.grey)),
              const SizedBox(width: 12),
              const Icon(Icons.medication, size: 18, color: Colors.grey),
              const SizedBox(width: 4),
              Text(reminder['dose'] ?? '', style: const TextStyle(color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<DateTime> weekDates =
        List.generate(7, (i) => _now.subtract(Duration(days: _now.weekday - i - 1))); // Generate dates for the current week

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.redAccent,
        icon: const Icon(Icons.add),
        label: const Text('Add Reminder'),
        onPressed: () {},
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.event_note, color: Colors.redAccent),
              label: const Text("My Meds", style: TextStyle(color: Colors.redAccent)),
            ),
            IconButton(
              icon: const Icon(Icons.analytics_outlined),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.person_outline),
              onPressed: () {},
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.pinkAccent,
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                "Hello, ${widget.username}",
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Text(
                                "👋",
                                style: TextStyle(fontSize: 20),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Today, ${DateFormat("d MMMM").format(_now)}",
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.notifications_none),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(Icons.tune),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 70,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: weekDates.length,
                  itemBuilder: (context, index) {
                    final date = weekDates[index];
                    final isSelected = _now.day == date.day;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _now = date;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 12),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.redAccent : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              date.day.toString(),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isSelected ? Colors.white : Colors.black,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"][date.weekday % 7],
                              style: TextStyle(
                                fontSize: 12,
                                color: isSelected ? Colors.white : Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                "Today's Reminder",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: FutureBuilder<List<Map<String, dynamic>>>( // Fetch reminders from Firestore
                  future: _getReminders(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return const Center(child: Text("Failed to load reminders"));
                    } else if (snapshot.data == null || snapshot.data!.isEmpty) {
                      return const Center(child: Text("No reminders today"));
                    }

                    return ListView(
                      children: snapshot.data!.map(_buildReminderCard).toList(),
                    );
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
