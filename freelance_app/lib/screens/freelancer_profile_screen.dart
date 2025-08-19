import 'dart:io';

import 'package:flutter/material.dart';
import 'package:freelance_app/models/freelancer_profile.dart';
import 'package:freelance_app/services/freelancer_profile_service.dart';
import 'package:image_picker/image_picker.dart';

class FreelancerProfileScreen extends StatefulWidget {
  final int userId;
  final bool readOnly;

  const FreelancerProfileScreen({
    required this.userId,
    this.readOnly = false,
    super.key,
  });

  @override
  State<FreelancerProfileScreen> createState() =>
      _FreelancerProfileScreenState();
}

class _FreelancerProfileScreenState extends State<FreelancerProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final FreelancerProfileService _service = FreelancerProfileService();

  FreelancerProfile? _profile;
  bool _loading = true;
  bool _saving = false;
  String? _error;

  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _overviewController = TextEditingController();
  final TextEditingController _skillsController = TextEditingController();
  final TextEditingController _educationController = TextEditingController();
  final TextEditingController _experienceController = TextEditingController();
  final TextEditingController _hourlyRateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await _service.getProfile(widget.userId);
      setState(() {
        _profile = profile;
        _loading = false;

        _titleController.text = profile.title ?? '';
        _overviewController.text = profile.overview ?? '';
        _skillsController.text = profile.skills ?? '';
        _educationController.text = profile.education ?? '';
        _experienceController.text = profile.experience ?? '';
        _hourlyRateController.text = profile.hourlyRate ?? '';
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load profile';
        _loading = false;
      });
    }
  }

  Future<void> _pickImage() async {
    final picked =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked != null) {
      setState(() {
        _selectedImage = File(picked.path);
      });
    }
  }

  Future<void> _uploadImage() async {
    if (_selectedImage == null) return;

    setState(() => _saving = true);
    try {
      final imageUrl = await _service.uploadImage(_selectedImage!);
      setState(() {
        _profile?.profileImageUrl = imageUrl;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image uploaded successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to upload image')),
      );
    } finally {
      setState(() => _saving = false);
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);
    try {
      final updatedProfile = FreelancerProfile(
        id: _profile?.id,
        userId: widget.userId,
        title: _titleController.text.trim(),
        overview: _overviewController.text.trim(),
        skills: _skillsController.text.trim(),
        education: _educationController.text.trim(),
        experience: _experienceController.text.trim(),
        hourlyRate: _hourlyRateController.text.trim(),
        profileImageUrl: _profile?.profileImageUrl,
      );

      final savedProfile = await _service.updateProfile(updatedProfile);
      setState(() {
        _profile = savedProfile;
        _saving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile saved successfully')),
      );
    } catch (e) {
      setState(() {
        _error = 'Failed to save profile';
        _saving = false;
      });
    }
  }

  Widget _profileImage() {
    final imageUrl = _selectedImage != null
        ? FileImage(_selectedImage!)
        : (_profile?.profileImageUrl != null &&
                _profile!.profileImageUrl!.isNotEmpty)
            ? NetworkImage('http://localhost:8080${_profile!.profileImageUrl!}')
            : const AssetImage('assets/default_image.jpg') as ImageProvider;

    return Stack(
      children: [
        CircleAvatar(
          radius: 60,
          backgroundImage: imageUrl,
          backgroundColor: Colors.grey[200],
        ),
        if (!widget.readOnly)
          Positioned(
            bottom: 0,
            right: 4,
            child: InkWell(
              onTap: _pickImage,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.teal,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                padding: const EdgeInsets.all(6),
                child: const Icon(Icons.edit, color: Colors.white, size: 20),
              ),
            ),
          ),
      ],
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _overviewController.dispose();
    _skillsController.dispose();
    _educationController.dispose();
    _experienceController.dispose();
    _hourlyRateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.readOnly ? 'Freelancer Profile' : 'Edit Profile'),
        backgroundColor: Colors.teal,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(child: _profileImage()),
                  const SizedBox(height: 24),
                  widget.readOnly
                      ? _buildReadOnlyProfile()
                      : Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              _buildTextField(_titleController, 'Title',
                                  'e.g. Flutter Developer'),
                              const SizedBox(height: 16),
                              _buildTextField(_overviewController, 'Overview',
                                  'Brief intro about yourself',
                                  maxLines: 4),
                              const SizedBox(height: 16),
                              _buildTextField(
                                  _skillsController, 'Skills', 'Separate by commas'),
                              const SizedBox(height: 16),
                              _buildTextField(_educationController, 'Education',
                                  'Your qualifications'),
                              const SizedBox(height: 16),
                              _buildTextField(_experienceController, 'Experience',
                                  'Your work history',
                                  maxLines: 3),
                              const SizedBox(height: 16),
                              _buildTextField(_hourlyRateController, 'Hourly Rate',
                                  'e.g. \$30/hr'),
                              const SizedBox(height: 24),
                              _saving
                                  ? const Center(child: CircularProgressIndicator())
                                  : Row(
                                      children: [
                                        ElevatedButton(
                                          onPressed: _uploadImage,
                                          child: const Text('Upload Image'),
                                          style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.teal),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: ElevatedButton(
                                            onPressed: _saveProfile,
                                            child: const Text('Save Profile'),
                                            style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.teal),
                                          ),
                                        ),
                                      ],
                                    ),
                            ],
                          ),
                        ),
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Text(
                        _error!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                ],
              ),
            ),
    );
  }

  /// ---------------- Read-only Profile View ----------------
  Widget _buildReadOnlyProfile() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildReadOnlyCard('Title', _titleController.text),
        const SizedBox(height: 16),
        _buildReadOnlyCard('Overview', _overviewController.text, maxLines: 5),
        const SizedBox(height: 16),
        _buildReadOnlyCard('Skills', _skillsController.text),
        const SizedBox(height: 16),
        _buildReadOnlyCard('Education', _educationController.text),
        const SizedBox(height: 16),
        _buildReadOnlyCard('Experience', _experienceController.text, maxLines: 4),
        const SizedBox(height: 16),
        _buildReadOnlyCard('Hourly Rate', _hourlyRateController.text),
      ],
    );
  }

  Widget _buildReadOnlyCard(String label, String value, {int maxLines = 1}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.grey[100],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.grey[700]),
            ),
            const SizedBox(height: 8),
            Text(
              value.isNotEmpty ? value : 'Not provided',
              style: const TextStyle(fontSize: 16, color: Colors.black87),
              maxLines: maxLines,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    String hint, {
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      enabled: !widget.readOnly,
      readOnly: widget.readOnly,
      style: TextStyle(
        fontSize: 16,
        color: widget.readOnly ? Colors.black87 : Colors.black,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: widget.readOnly,
        fillColor: widget.readOnly ? Colors.grey[100] : null,
        labelStyle: TextStyle(
          color: widget.readOnly ? Colors.grey[700] : Colors.grey[600],
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: widget.readOnly ? Colors.grey.shade400 : Colors.grey.shade600,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.teal, width: 2),
        ),
      ),
      validator: (value) =>
          (!widget.readOnly && (value == null || value.trim().isEmpty))
              ? 'Please enter $label'
              : null,
    );
  }
}
