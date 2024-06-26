// ignore_for_file: library_private_types_in_public_api, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class StudentsPortalPage extends StatefulWidget {
  const StudentsPortalPage({Key? key}) : super(key: key);

  @override
  _StudentsPortalPageState createState() => _StudentsPortalPageState();
}

class _StudentsPortalPageState extends State<StudentsPortalPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _admissionNumberController =
      TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _admissionNumberController.dispose();
    super.dispose();
  }

  Future<List<Map<String, dynamic>>?> fetchStudentResult(
      String name, String admissionNumber) async {
    const String url =
        'https://raw.githubusercontent.com/7442charles/ecascade_jsons/main/results.json';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final students = data['students'] as List<dynamic>;

      List<Map<String, dynamic>> results = students
          .where((student) =>
              student['name'] == name &&
              student['admissionNumber'] == admissionNumber)
          .toList()
          .cast<Map<String, dynamic>>();

      if (results.isNotEmpty) {
        return results;
      }
    }

    return null;
  }

  void _submitForm() async {
    String name = _nameController.text.trim();
    String admissionNumber =
        _admissionNumberController.text.trim().toUpperCase();

    if (name.isEmpty || admissionNumber.isEmpty) {
      _showErrorDialog('Please enter both name and admission number.');
      return;
    }

    List<String> nameParts = name.split(' ');
    nameParts = nameParts.map((part) {
      if (part.isNotEmpty) {
        return part[0].toUpperCase() + part.substring(1);
      }
      return '';
    }).toList();
    name = nameParts.join(' ');

    setState(() {
      _isLoading = true;
      _searchResults = [];
    });

    final resultData = await fetchStudentResult(name, admissionNumber);

    setState(() {
      _isLoading = false;
    });

    if (resultData != null) {
      setState(() {
        _searchResults = resultData;
      });
    } else {
      setState(() {
        _searchResults = [];
      });
      _showErrorDialog(
          'No result found for \n $name \n ${admissionNumber.toUpperCase()}');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Please Try Again'),
          content: Text(message),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _downloadResults() {
    // Write code here to download the results as a PDF file
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Students Portal',
          style: TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Check your grade',
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Enter name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: _admissionNumberController,
                decoration: InputDecoration(
                  labelText: 'Enter admission full number',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
              const SizedBox(height: 24.0),
              ElevatedButton(
                onPressed: _isLoading ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white, backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      )
                    : const Text(
                        'Submit',
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
              const SizedBox(height: 24.0),
              ListView.builder(
                shrinkWrap: true,
                physics: const ClampingScrollPhysics(),
                itemCount: _searchResults.length,
                itemBuilder: (BuildContext context, int index) {
                  final student = _searchResults[index];
                  final studentName = student['name'];
                  final admissionNumber = student['admissionNumber'];
                  final units = student['units'] as Map<String, dynamic>;

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Column(
                      children: [
                        ListTile(
                          title: Text(
                            studentName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18.0,
                            ),
                          ),
                          subtitle: Text(
                            admissionNumber,
                            style: const TextStyle(
                              fontSize: 16.0,
                            ),
                          ),
                        ),
                        ExpansionTile(
                          title: const Text(
                            'View Results',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16.0,
                            ),
                          ),
                          children: [
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const ClampingScrollPhysics(),
                              itemCount: units.length,
                              itemBuilder: (BuildContext context, int index) {
                                final unitName = units.keys.elementAt(index);
                                final unitScore = units[unitName];
                                return ListTile(
                                  title: Text(unitName),
                                  subtitle: Text('Score: $unitScore'),
                                );
                              },
                            ),
                            TextButton(
                              onPressed: _downloadResults,
                              child: const Text('Download Results'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
