import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  String gender = "";
  bool isLoading = false;
  File? _image;
  final ImagePicker _picker = ImagePicker();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController yearController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  // Load data from SharedPreferences
  Future<void> _loadSavedData() async {
    setState(() => isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      phoneController.text = prefs.getString('user_mobile') ?? "";
      nameController.text = prefs.getString('user_name') ?? "";
      yearController.text = prefs.getString('user_email') ?? ""; // Mapping email to this field
      gender = prefs.getString('user_gender') ?? "";
      
      String? imagePath = prefs.getString('profile_image');
      if (imagePath != null) {
        _image = File(imagePath);
      }
      
      isLoading = false;
    });
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  // Save data to SharedPreferences
  Future<void> _handleSave() async {
    setState(() => isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_name', nameController.text);
      await prefs.setString('user_email', yearController.text);
      await prefs.setString('user_gender', gender);
      
      if (_image != null) {
        await prefs.setString('profile_image', _image!.path);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile updated successfully"), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to save: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text("Edit Profile", style: TextStyle(color: Colors.white)),
      ),
      body: isLoading 
        ? const Center(child: CircularProgressIndicator(color: Color(0xFFFFD400)))
        : SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.grey[900],
                      backgroundImage: _image != null ? FileImage(_image!) : null,
                      child: _image == null 
                          ? const Icon(Icons.person, size: 60, color: Colors.white24) 
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Color(0xFFFFD400),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.camera_alt, color: Colors.black, size: 20),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              buildField("Phone Number", "Enter phone", phoneController, readOnly: true),
              buildField("Name *", "Enter your name", nameController),
              buildField("Year of Birth *", "Enter email", yearController),
              const SizedBox(height: 20),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Select your gender *",
                  style: TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  genderButton("Male"),
                  genderButton("Female"),
                  genderButton("Prefer not to say"),
                ],
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFD400),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: isLoading ? null : _handleSave,
                  child: const Text("Save", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
    );
  }

  Widget buildField(String label, String hint, TextEditingController controller, {bool readOnly = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          labelStyle: const TextStyle(color: Colors.white),
          hintStyle: const TextStyle(color: Colors.grey),
          filled: true,
          fillColor: const Color(0xff1a1a1a),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.white24),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFFFD400)),
          ),
        ),
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

  Widget genderButton(String text) {
    return ChoiceChip(
      label: Text(text),
      selected: gender == text,
      labelStyle: TextStyle(color: gender == text ? Colors.black : Colors.white),
      selectedColor: const Color(0xFFFFD400),
      backgroundColor: const Color(0xff1a1a1a),
      onSelected: (bool selected) {
        setState(() {
          gender = selected ? text : "";
        });
      },
    );
  }
}
