import 'package:flutter/material.dart';

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

  void _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _reminderTimes.add(picked);
      });
    }
  }

  void _saveMedicine() {
    final name = _nameController.text.trim();
    final dose = _doseController.text.trim();
    final amount = int.tryParse(_amountController.text.trim()) ?? 0;

    if (name.isEmpty || dose.isEmpty || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all fields.')),
      );
      return;
    }

    final newMedicine = Medicine(
      name: name,
      type: _selectedType,
      dose: dose,
      amount: amount,
      reminderTimes: _reminderOn ? _reminderTimes : [],
    );

    Navigator.pop(context, newMedicine);
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
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Medicine Name'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedType,
              items: _medicineTypes.map((type) {
                return DropdownMenuItem(value: type, child: Text(type));
              }).toList(),
              onChanged: (value) => setState(() => _selectedType = value!),
              decoration: const InputDecoration(labelText: 'Medicine Type'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _doseController,
              decoration: const InputDecoration(labelText: 'Dosage (e.g. 500mg)'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Amount'),
            ),
            const SizedBox(height: 20),
            SwitchListTile(
              title: const Text('Set Reminder'),
              value: _reminderOn,
              onChanged: (value) {
                setState(() {
                  _reminderOn = value;
                  if (!_reminderOn) _reminderTimes.clear();
                });
              },
            ),
            if (_reminderOn) ...[
              const SizedBox(height: 10),
              const Text("Reminder Times:", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ..._reminderTimes.map((time) => Text("• ${time.format(context)}")),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: _pickTime,
                icon: const Icon(Icons.access_time),
                label: const Text('Add Time'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
              ),
            ],
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _saveMedicine,
              child: const Text('Save Medicine'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                backgroundColor: Colors.pinkAccent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ✅ This class must be in the same file or imported wherever it's needed
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
