import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// For time formatting

class AddMedicinePage extends StatefulWidget {
  const AddMedicinePage({super.key});

  @override
  State<AddMedicinePage> createState() => _AddMedicinePageState();
}

class _AddMedicinePageState extends State<AddMedicinePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _doseController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  String _selectedType = 'Tablet';
  bool _reminderOn = false;
  List<TimeOfDay> _reminderTimes = [];

  final List<String> _medicineTypes = ['Tablet', 'Capsule', 'Syrup', 'Drop', 'Injection'];

  // Method to pick reminder time
  void _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() => _reminderTimes.add(picked));
    }
  }

  // Method to save medicine
  void _saveMedicine() async {
    final name = _nameController.text.trim();
    final dose = _doseController.text.trim();
    final amount = int.tryParse(_amountController.text.trim()) ?? 0;

    if (name.isEmpty || dose.isEmpty || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all fields.')),
      );
      return;
    }

    // Create the Medicine object
    final newMedicine = Medicine(
      name: name,
      type: _selectedType,
      dose: dose,
      amount: amount,
      reminderTimes: _reminderTimes,
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
          'type': newMedicine.type,
          'dose': newMedicine.dose,
          'amount': newMedicine.amount,
          'reminderTimes': newMedicine.reminderTimes.map((e) => e.format(context)).toList(),
        });

        // Show confirmation message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Medicine added successfully!')),
        );

        // Close the page after saving and return to HomePage
        Navigator.pop(context);  // Go back to HomePage
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Medicine'),
        backgroundColor: Color(0xFFEB5E5E), 
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Medicine Name
            _buildInputField(
              controller: _nameController,
              labelText: 'Medicine Name',
              hintText: 'Enter the medicine name',
            ),
            const SizedBox(height: 12),

            // Medicine Type Dropdown
            _buildDropdownField(),
            const SizedBox(height: 12),

            // Dosage
            _buildInputField(
              controller: _doseController,
              labelText: 'Dosage (e.g. 500mg)',
              hintText: 'Enter the dosage',
            ),
            const SizedBox(height: 12),

            // Amount
            _buildInputField(
              controller: _amountController,
              labelText: 'Amount',
              hintText: 'Enter the amount',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),

            // Set Reminder Toggle
            _buildReminderSwitch(),

            // Show reminder times if reminder is turned on
            if (_reminderOn) _buildReminderTimes(),

            const SizedBox(height: 30),

            // Save Button
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  // Input field widget to reduce redundancy
  Widget _buildInputField({
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        filled: true,
        fillColor: Colors.grey.shade100,
      ),
      keyboardType: keyboardType,
    );
  }

  // Dropdown field for selecting medicine type
  Widget _buildDropdownField() {
    return DropdownButtonFormField<String>(
      value: _selectedType,
      items: _medicineTypes.map((type) {
        return DropdownMenuItem(value: type, child: Text(type));
      }).toList(),
      onChanged: (value) => setState(() => _selectedType = value!),
      decoration: InputDecoration(
        labelText: 'Medicine Type',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        filled: true,
        fillColor: Colors.grey.shade100,
      ),
    );
  }

  // Reminder switch widget
  Widget _buildReminderSwitch() {
    return SwitchListTile(
      title: const Text('Set Reminder'),
      value: _reminderOn,
      onChanged: (value) => setState(() => _reminderOn = value),
      activeColor: Color.fromARGB(255, 236, 75, 75),
    );
  }

  // Show reminder times if reminder is turned on
  Widget _buildReminderTimes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // List reminder times
        ..._reminderTimes.map((time) => Text('• ${time.format(context)}')),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          onPressed: _pickTime,
          icon: const Icon(Icons.access_time),
          label: const Text('Add Time'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFFEB5E5E),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          ),
        ),
      ],
    );
  }

  // Save button with a more modern style
  Widget _buildSaveButton() {
    return ElevatedButton(
      onPressed: _saveMedicine,
      child: const Text('Save Medicine'),
      style: ElevatedButton.styleFrom(
        minimumSize: const Size.fromHeight(50), backgroundColor: Color(0xFFEB5E5E), // Primary color for the button
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12), // Rounded corners
        ),
      ),
    );
  }
}

// Medicine Model Class
class Medicine {
  final String name;
  final String type;
  final String dose;
  final int amount;
  final List<TimeOfDay> reminderTimes;

  Medicine({
    required this.name,
    required this.type,
    required this.dose,
    required this.amount,
    required this.reminderTimes,
  });
}
