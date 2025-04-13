import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tervist_apk/api/edit_profile_service.dart';
import 'package:tervist_apk/screens/onboarding_screen.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();

  DateTime? _selectedBirthday;
  String? _selectedGender;
  String _profileImagePath = 'assets/images/profilepicture.png';
  bool _isImageFromAsset = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final profile = await EditProfileService.getProfile();
    if (profile == null) return;

    if (!mounted) return; // ✅ tambahkan pengecekan ini sebelum setState
    setState(() {
      _usernameController.text = profile['username'] ?? '';
      _bioController.text = profile['bio'] ?? '';
      _cityController.text = profile['city'] ?? '';
      _stateController.text = profile['state'] ?? '';
      if (profile['weight'] != null && profile['weight'] != '') {
        _weightController.text =
            double.parse(profile['weight']).toStringAsFixed(2);
      }

      if (_weightController.text == '0' || _weightController.text == 'null') {
        _weightController.text = '';
      }
      _selectedGender = profile['gender'] == '-' ? null : profile['gender'];

      if (profile['birthday'] != null && profile['birthday'] != '') {
        _selectedBirthday = DateTime.tryParse(profile['birthday']);
      }

      // If there's a profile image path stored, use it
      if (profile['profile_picture'] != null &&
          profile['profile_picture'].toString().isNotEmpty) {
        _profileImagePath = profile['profile_picture'];
        _isImageFromAsset = false;
      }
    });
  }

  Future<void> _pickImage() async {
    bool permissionGranted = false;

    // For Android 13+ (API level 33+)
    if (await Permission.photos.request().isGranted) {
      permissionGranted = true;
    }
    // For Android 12 and below
    else if (await Permission.storage.request().isGranted) {
      permissionGranted = true;
    }

    if (permissionGranted) {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        setState(() {
          _profileImagePath = image.path;
          _isImageFromAsset = false;
        });
      }
    } else {
      if (mounted) {
        // Show dialog when permission is denied
        showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: const Text('Permission Required'),
            content: const Text(
                'This app needs gallery access to select profile images. Please grant permission in app settings.'),
            actions: <Widget>[
              TextButton(
                child: const Text('Cancel'),
                onPressed: () => Navigator.of(context).pop(),
              ),
              TextButton(
                child: const Text('Open Settings'),
                onPressed: () {
                  Navigator.of(context).pop();
                  openAppSettings();
                },
              ),
            ],
          ),
        );
      }
    }
  }

  void _saveProfile() async {
    print("Weight to be sent: ${_weightController.text}");

    final success = await EditProfileService.updateProfile({
      'username': _usernameController.text,
      'bio': _bioController.text,
      'city': _cityController.text,
      'state': _stateController.text,
      'birthday': _selectedBirthday?.toIso8601String().split('T').first,
      'gender': _selectedGender,
      'weight': _weightController.text.isNotEmpty
          ? double.tryParse(_weightController.text)
          : null,
      'profileImage': _isImageFromAsset ? null : _profileImagePath,
    });

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update profile')),
      );
    }
  }

  void _logout() async {
    await EditProfileService.logout();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F7F6),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              _buildProfileSection(),
              const SizedBox(height: 50),
              _buildSocialSection(),
              const SizedBox(height: 50),
              _buildPersonalSection(),
              const SizedBox(height: 20),
              _buildLogoutButton(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black),
      ),
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
                style: GoogleFonts.poppins(fontSize: 12, color: Colors.black)),
          ),
          Text('Profile',
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold, fontSize: 20)),
          TextButton(
            onPressed: _saveProfile,
            child: Text('Save',
                style: GoogleFonts.poppins(fontSize: 12, color: Colors.black)),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSection() {
    return Container(
      width: 303,
      height: 119,
      constraints: const BoxConstraints(maxWidth: 350),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.center, // ubah ini dari center ke start
        children: [
          SizedBox(width: 16), // untuk padding kiri,
          // Foto profil
          Padding(
            padding: const EdgeInsets.only(
                top: 0.5), // geser sedikit ke bawah biar sejajar
            child: GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey.shade400, width: 1),
                  image: DecorationImage(
                    image: _isImageFromAsset
                        ? AssetImage(_profileImagePath)
                        : (_profileImagePath.startsWith('http')
                                ? NetworkImage(_profileImagePath)
                                : FileImage(File(_profileImagePath)))
                            as ImageProvider,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 25),

          // Username & Bio
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 15,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  margin: const EdgeInsets.only(bottom: 8),
                  height: 22,
                  width: 112,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Center(
                    child: TextField(
                      controller: _usernameController,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  height: 22,
                  width: 112,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Center(
                    child: TextField(
                      controller: _bioController,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(fontSize: 11),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialSection() {
    return _buildSectionCard(title: 'Social', children: [
      _buildInputRow('Bio', _bioController),
      _buildInputRow('City', _cityController),
      _buildInputRow('State', _stateController),
    ]);
  }

  Widget _buildPersonalSection() {
    return _buildSectionCard(title: 'Personal Data', children: [
      _buildBirthdayRow(),
      _buildDropdownRow(),
      _buildInputRow('Weight (kg)', _weightController),
    ]);
  }

  Widget _buildLogoutButton() {
    return GestureDetector(
      onTap: _logout,
      child: Container(
        width: 131,
        height: 47,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.orange),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Center(
          child: Text('Log Out',
              style: GoogleFonts.poppins(
                  color: Colors.orange,
                  fontSize: 16,
                  fontWeight: FontWeight.w500)),
        ),
      ),
    );
  }

  Widget _buildSectionCard(
      {required String title, required List<Widget> children}) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 350),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black),
      ),
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Center(
              child: Text(title,
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold, fontSize: 10)),
            ),
          ),
          const Divider(height: 1, thickness: 1),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInputRow(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.poppins(fontSize: 10)),
          SizedBox(
            width: 200,
            child: TextField(
              controller: controller,
              textAlign: TextAlign.right,
              style: GoogleFonts.poppins(fontSize: 10),
              // Remove the number-specific keyboard type
              keyboardType: label == 'Weight (kg)'
                  ? TextInputType.numberWithOptions(decimal: true)
                  : TextInputType.text,
              // Only apply input formatters for weight
              inputFormatters: label == 'Weight (kg)'
                  ? [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'^\d{0,3}(\.\d{0,2})?$'))
                    ]
                  : null,
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
                hintText: "",
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBirthdayRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Select Birthday', style: GoogleFonts.poppins(fontSize: 10)),
          GestureDetector(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _selectedBirthday ?? DateTime(2000),
                firstDate: DateTime(1900),
                lastDate: DateTime.now(),
              );
              if (picked != null) {
                setState(() {
                  _selectedBirthday = picked;
                });
              }
            },
            child: Text(
              _selectedBirthday != null
                  ? DateFormat('dd MMM yyyy').format(_selectedBirthday!)
                  : '',
              style: GoogleFonts.poppins(fontSize: 10),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Gender', style: GoogleFonts.poppins(fontSize: 10)),
          DropdownButton<String>(
            value: _selectedGender,
            items: ['Male', 'Female'].map((gender) {
              return DropdownMenuItem(
                value: gender,
                child: Text(
                  gender,
                  style: GoogleFonts.poppins(fontSize: 10),
                ),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedGender = value;
              });
            },
            hint: Text(
              '',
              style: GoogleFonts.poppins(fontSize: 10),
            ),
            underline: Container(
              height: 1,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
