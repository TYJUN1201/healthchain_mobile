import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PatientInfoPage extends StatefulWidget {
  final String jsonUrl;

  PatientInfoPage({required this.jsonUrl});

  @override
  _PatientInfoPageState createState() => _PatientInfoPageState();
}

class _PatientInfoPageState extends State<PatientInfoPage> {
  late Map<String, dynamic>? patientData;
  bool isLoading = false;

  Future<void> fetchJSON() async {
    setState(() {
      isLoading = true;
    });
    try {
      final response = await http.get(Uri.parse(widget.jsonUrl));

      if (response.statusCode == 200) {
        setState(() {
          patientData = json.decode(response.body);
        });
      } else {
        print('Failed to load data, status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    fetchJSON();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Patient Information'),
        ),
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : patientData == null
                ? Center(child: CircularProgressIndicator())
                : Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SingleChildScrollView(
                      child: Form(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            SizedBox(height: 5),
                            _buildTextField(
                                'ID', patientData!['patientBio']['id']),
                            _buildTextField(
                                'Name', patientData!['patientBio']['name']),
                            _buildTextField('Birth Date',
                                patientData!['patientBio']['birthDate']),
                            _buildTextField('Phone Number',
                                patientData!['patientBio']['phoneNumber']),
                            _buildTextField('Address',
                                patientData!['patientBio']['_address']),
                            SizedBox(height: 20),
                            _buildTextField(
                                'Medical Report ID',
                                patientData!['patientMedicalData']
                                    ['medReportId']),
                            _buildTextField('Weight',
                                patientData!['patientMedicalData']['weight']),
                            _buildTextField('Height',
                                patientData!['patientMedicalData']['height']),
                            _buildTextField(
                                'Blood Group',
                                patientData!['patientMedicalData']
                                    ['bloodGroup']),
                            _buildTextField(
                                'Disease Name',
                                patientData!['patientMedicalData']
                                    ['diseaseName']),
                            _buildTextField(
                                'Disease Description',
                                patientData!['patientMedicalData']
                                    ['diseaseDescription']),
                            _buildTextField(
                                'Disease Started On',
                                patientData!['patientMedicalData']
                                    ['diseaseStartedOn']),
                            _buildTextField('Medicine',
                                patientData!['patientMedicalData']['medicine']),
                            _buildTextField('Dose',
                                patientData!['patientMedicalData']['dose']),
                            _buildTextField('Remarks',
                                patientData!['patientMedicalData']['remarks']),
                          ],
                        ),
                      ),
                    ),
                  ));
  }

  Widget _buildTextField(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextFormField(
        readOnly: true,
        initialValue: value ?? '',
        // Use empty string if value is null
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        maxLines: null,
        // Allow multiple lines
        minLines: 1, // Ensure at least 1 line is visible
      ),
    );
  }
}
