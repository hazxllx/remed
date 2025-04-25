//updated homepage
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'settings.dart'; // Import settings.dart to access the SettingsPage
import 'add_medicine.dart'; // Import AddMedicinePage

class HomePage extends StatefulWidget {
  final String username;
  const HomePage({super.key, required this.username});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late DateTime _now;
  late Timer _timer;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _startTimer();
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


  // Use a Stream to get real-time updates from Firestore
  Stream<List<Map<String, dynamic>>> _getRemindersStream() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return Stream.value([]); // Return an empty stream if no user is logged in

    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('medicines')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        final reminderTimes = List<String>.from(data['reminderTimes'] ?? []);
        final validReminders = reminderTimes.where((time) {
          final now = DateFormat("h:mm a").format(DateTime.now());
          return time == now; // Check if this reminder matches the current time
        }).toList();

        // Only return reminders with valid times
        if (validReminders.isNotEmpty) {
          return {
            'name': data['name'] ?? 'Unnamed',
            'dose': data['dose'] ?? 'Not specified',
            'type': data['type'] ?? 'Not specified',
            'reminderTimes': validReminders,
          };
        } else {
          return null; // Return null if no valid reminder for this time
        }
      }).where((reminder) => reminder != null).cast<Map<String, dynamic>>().toList(); // Filter out null reminders
    });
  }

  // Build the reminder card widget for each reminder
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
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            reminder['name'] ?? 'Unnamed',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.access_time, size: 18, color: Colors.grey),
              const SizedBox(width: 4),
              Text(reminder['reminderTimes'].join(", ") ?? '', style: const TextStyle(color: Colors.grey)),
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

  // Handle BottomNavigationBar tap
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 1:
        Navigator.pushNamed(context, '/medCabinet');
        break;
      case 2:
        Navigator.pushNamed(context, '/report');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<DateTime> weekDates =
        List.generate(7, (i) => _now.subtract(Duration(days: _now.weekday - i - 1)));

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
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
                                  const Text("👋", style: TextStyle(fontSize: 20)),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Today, ${DateFormat("d MMMM").format(_now)}",
                                style: const TextStyle(fontSize: 14, color: Colors.grey),
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
                            icon: const Icon(Icons.settings),
                            onPressed: () {
                              // Navigate to the SettingsPage when settings icon is clicked
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => SettingsPage()), // Updated to remove 'title' parameter
                              );
                            },
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
                          onTap: () => setState(() => _now = date),
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
                                  DateFormat('E').format(date),
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
                    child: StreamBuilder<List<Map<String, dynamic>>>(
                      stream: _getRemindersStream(),  // StreamBuilder to listen to Firestore changes
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return const Center(child: Text("Failed to load reminders"));
                        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const Center(child: Text("No reminders today"));
                        }

                        return ListView(
                          children: snapshot.data!.map(_buildReminderCard).toList(),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 20,
              right: 20,
              child: FloatingActionButton(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AddMedicinePage()),
                  );
                  if (result != null) {
                    setState(() {
                      // Trigger a state update if needed
                    });
                  }
                },
                backgroundColor: Colors.redAccent,
                child: const Icon(Icons.add, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.redAccent,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.medical_services_outlined),
            label: 'Med Cabinet',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.insert_chart_outlined),
            label: 'Report',
          ),
        ],
      ),
    );
  }
}
