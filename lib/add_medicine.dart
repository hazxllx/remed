import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Medicine Model Class
class Medicine {
  final String name;
  final String genericName;
  final String description;
  final String dose;
  final String type;
  final bool beforeMeal;
  final bool afterMeal;
  final int timesPerDay;
  final double amount;
  final List<String> reminderTimes;

  Medicine({
    required this.name,
    required this.genericName,
    required this.description,
    required this.dose,
    required this.type,
    required this.beforeMeal,
    required this.afterMeal,
    required this.timesPerDay,
    required this.amount,
    required this.reminderTimes,
  });

  // Convert Firestore document data into Medicine model
  factory Medicine.fromFirestore(Map<String, dynamic> doc) {
    return Medicine(
      name: doc['name'] ?? '',
      genericName: doc['genericName'] ?? '',
      description: doc['description'] ?? '',
      dose: doc['dose'] ?? '',
      type: doc['type'] ?? '',
      beforeMeal: doc['beforeMeal'] ?? false,
      afterMeal: doc['afterMeal'] ?? false,
      timesPerDay: doc['timesPerDay'] ?? 1,
      amount: doc['amount'] ?? 0.0,
      reminderTimes: List<String>.from(doc['reminderTimes'] ?? []),
    );
  }
}

class AddMedicinePage extends StatefulWidget {
  const AddMedicinePage({super.key});

  @override
  _AddMedicinePageState createState() => _AddMedicinePageState();
}

class _AddMedicinePageState extends State<AddMedicinePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _genericNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _doseController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  String _selectedType = 'Tablet';
  bool _beforeMeal = false;
  bool _afterMeal = false;
  int _timesPerDay = 1;
  List<TimeOfDay> _reminderTimes = [];

  final List<String> _medicineTypes = ['Tablet', 'Capsule', 'Syrup', 'Drop', 'Injection'];

  // Method to save medicine to Firestore
  void _saveMedicine() async {
    final name = _nameController.text.trim();
    final genericName = _genericNameController.text.trim();
    final description = _descriptionController.text.trim();
    final dose = _doseController.text.trim();
    final amount = double.tryParse(_amountController.text.trim()) ?? 0.0;

    if (name.isEmpty || genericName.isEmpty || description.isEmpty || dose.isEmpty || amount == 0.0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all fields.')),
      );
      return;
    }

    // Convert reminder times to strings like "5:19"
    List<String> reminderTimesStrings = _reminderTimes.map((time) {
      return '${time.hour}:${time.minute}';
    }).toList();

    // Create the Medicine object
    final newMedicine = Medicine(
      name: name,
      genericName: genericName,
      description: description,
      dose: dose,
      type: _selectedType,
      beforeMeal: _beforeMeal,
      afterMeal: _afterMeal,
      timesPerDay: _timesPerDay,
      amount: amount,
      reminderTimes: reminderTimesStrings, // Store as a list of strings
    );

    // Save to Firestore
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final uid = user.uid;
      final medicineRef = FirebaseFirestore.instance.collection('users').doc(uid).collection('medicines');

      try {
        // Add the medicine document
        await medicineRef.add({
          'name': newMedicine.name,
          'genericName': newMedicine.genericName,
          'description': newMedicine.description,
          'dose': newMedicine.dose,
          'type': newMedicine.type,
          'beforeMeal': newMedicine.beforeMeal,
          'afterMeal': newMedicine.afterMeal,
          'timesPerDay': newMedicine.timesPerDay,
          'amount': newMedicine.amount,
          'reminderTimes': newMedicine.reminderTimes, // Store reminder times as list of strings
        });

        // Show confirmation message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Medicine added successfully!')),
        );

        // Close the page after saving and return to HomePage
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save medicine.')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not logged in')),
      );
    }
  }

  // Method to open time picker and add reminder time
  void _addReminderTime() async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null) {
      setState(() {
        _reminderTimes.add(pickedTime);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Medicine'),
        backgroundColor: Colors.pinkAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),

            // Medicine Name
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Medicine Name',
                prefixIcon: Icon(Icons.medical_services),
                filled: true,
                fillColor: Color(0xFFFFC0CB),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            // Generic Name
            TextField(
              controller: _genericNameController,
              decoration: const InputDecoration(
                labelText: 'Generic Name',
                filled: true,
                fillColor: Color(0xFFFFC0CB),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            // Description
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Short Description',
                filled: true,
                fillColor: Color(0xFFFFC0CB),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            // Dosage
            TextField(
              controller: _doseController,
              decoration: const InputDecoration(
                labelText: 'Dosage',
                filled: true,
                fillColor: Color(0xFFFFC0CB),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            // Amount
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Amount (e.g. 20mg)',
                filled: true,
                fillColor: Color(0xFFFFC0CB),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            // Medicine Type Dropdown
            DropdownButtonFormField<String>(
              value: _selectedType,
              items: _medicineTypes.map((type) {
                return DropdownMenuItem(value: type, child: Text(type));
              }).toList(),
              onChanged: (value) => setState(() => _selectedType = value!),
              decoration: const InputDecoration(
                labelText: 'Type of medicine',
                filled: true,
                fillColor: Color(0xFFFFC0CB),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            // Consumption Time Options
            Row(
              children: [
                Checkbox(
                  value: _beforeMeal,
                  onChanged: (value) => setState(() => _beforeMeal = value!),
                ),
                const Text('Before meal'),
                const SizedBox(width: 10),
                Checkbox(
                  value: _afterMeal,
                  onChanged: (value) => setState(() => _afterMeal = value!),
                ),
                const Text('After meal'),
              ],
            ),
            const SizedBox(height: 12),

            // How many times a day
            Row(
              children: [
                Radio<int>(
                  value: 1,
                  groupValue: _timesPerDay,
                  onChanged: (value) => setState(() => _timesPerDay = value!),
                ),
                const Text('1 time'),
                Radio<int>(
                  value: 2,
                  groupValue: _timesPerDay,
                  onChanged: (value) => setState(() => _timesPerDay = value!),
                ),
                const Text('2 times'),
                Radio<int>(
                  value: 3,
                  groupValue: _timesPerDay,
                  onChanged: (value) => setState(() => _timesPerDay = value!),
                ),
                const Text('3 times'),
              ],
            ),
            const SizedBox(height: 12),

            // Add Reminder Times Button
            ElevatedButton(
              onPressed: _addReminderTime,
              child: const Text('Add Reminder Time'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pinkAccent,
                textStyle: const TextStyle(color: Colors.white), // Ensure text is white
              ),
            ),
            const SizedBox(height: 12),

            // Show Selected Reminder Times
            Column(
              children: _reminderTimes.map((time) {
                return Text('Reminder at: ${time.format(context)}');
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Save Button (Styled to match the same color)
            ElevatedButton(
              onPressed: _saveMedicine,
              child: const Text('SAVE'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                backgroundColor: Colors.pinkAccent,
                textStyle: const TextStyle(color: Colors.white), // Ensure text is white
              ),
            ),
          ],
        ),
      ),
    );
  }
}
