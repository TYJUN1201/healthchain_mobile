import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:healthchain/pages/files/viewEMR.dart';
class EMRInputScreen extends StatefulWidget {
  @override
  _EMRInputScreenState createState() => _EMRInputScreenState();
}

class _EMRInputScreenState extends State<EMRInputScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _ageController = TextEditingController();
  TextEditingController _dateController = TextEditingController();
  TextEditingController _hospitalController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Set the date controller to the current date
    _dateController.text = DateTime.now().toLocal().toString().split(' ')[0];
  }

  void _selectDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null && pickedDate != DateTime.now()) {
      setState(() {
        _dateController.text = pickedDate.toLocal().toString().split(' ')[0];
      });
    }
  }

  void _saveEMR() {
    if (_formKey.currentState!.validate()) {
      Map<String, dynamic> emrData = {
        'name': _nameController.text,
        'age': _ageController.text,
        'date': _dateController.text,
        'hospital': _hospitalController.text,
      };

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EMRViewPage(emrData: emrData),
        ),
      );
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EMR Input'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter name';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _ageController,
                  decoration: const InputDecoration(labelText: 'Age'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter age';
                    } else {
                      int? age = int.tryParse(value);
                      if (age == null || age < 0 || age >= 140) {
                        return 'Please enter a valid age';
                      }
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _dateController,
                  decoration: const InputDecoration(labelText: 'Date'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a date';
                    }
                    return null;
                  },
                  onTap: _selectDate, // Call _selectDate when the TextFormField is tapped
                ),
                TextFormField(
                  controller: _hospitalController,
                  decoration: const InputDecoration(labelText: 'Hospital'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter hospital';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: _saveEMR,
                    child: const Text('Save'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class EMRViewScreen extends StatelessWidget {
  final String jsonEMR;

  EMRViewScreen({super.key, required this.jsonEMR});

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> emrData = jsonDecode(jsonEMR);
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Name: ${emrData['name']}'),
            Text('Age: ${emrData['age']}'),
            Text('Date: ${emrData['date']}'),
            Text('Hospital: ${emrData['hospital']}'),
          ],
        ),
      ),
    );
  }
}