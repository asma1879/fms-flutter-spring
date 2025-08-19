import 'package:flutter/material.dart';
import 'package:freelance_app/screens/client_posted_jobs_screen.dart'; // Import the posted jobs screen
import 'package:freelance_app/services/job_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ClientPostJobScreen extends StatefulWidget {
  const ClientPostJobScreen({super.key});

  @override
  State<ClientPostJobScreen> createState() => _ClientPostJobScreenState();
}

class _ClientPostJobScreenState extends State<ClientPostJobScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController budgetController = TextEditingController();
  final TextEditingController deadlineController = TextEditingController();
  final TextEditingController skillsController = TextEditingController();
  int? clientId;

  bool submitting = false;

  @override
  void initState() {
    super.initState();
    _loadClientId();
  }

  Future<void> _loadClientId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      clientId = prefs.getInt('userId'); // assuming you store it as 'userId'
    });
  }

  Future<void> _submitJob() async {
    if (!_formKey.currentState!.validate()) return;
    if (clientId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not logged in. Please log in again.')),
      );
      return;
    }

    setState(() {
      submitting = true;
    });

    final success = await JobService().postJob({
      'title': titleController.text,
      'description': descriptionController.text,
      'budget': double.tryParse(budgetController.text) ?? 0,
      'deadline': deadlineController.text,
      'skills': skillsController.text,
      'client': {'id': clientId},
    });

    setState(() {
      submitting = false;
    });

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Job posted successfully!')),
      );
      _formKey.currentState!.reset();
      titleController.clear();
      descriptionController.clear();
      budgetController.clear();
      deadlineController.clear();
      skillsController.clear();

      // Navigate to posted jobs screen after successful post
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ClientPostedJobsScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to post job.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post a Job'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Create a new job post',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 183, 58, 131),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Job Title',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value!.isEmpty ? 'Please enter job title' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: descriptionController,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      labelText: 'Job Description',
                      border: OutlineInputBorder(),
                      alignLabelWithHint: true,
                    ),
                    validator: (value) =>
                        value!.isEmpty ? 'Please enter job description' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: budgetController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Budget (USD)',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value!.isEmpty ? 'Please enter budget' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: deadlineController,
                    decoration: const InputDecoration(
                      labelText: 'Deadline (YYYY-MM-DD)',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value!.isEmpty ? 'Please enter deadline' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: skillsController,
                    decoration: const InputDecoration(
                      labelText: 'Required Skills (comma separated)',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value!.isEmpty ? 'Please enter required skills' : null,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: submitting ? null : _submitJob,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 164, 183, 58),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: submitting
                          ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                          : const Text(
                              'Post Job',
                              style: TextStyle(fontSize: 18),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
