import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/auth_provider.dart';
import '../widgets/otp_verification_dialog.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;

  String _initialPhone = '';
  String _initialEmail = '';

  @override
  void initState() {
    super.initState();
    final authProvider = context.read<AuthProvider>();
    final user = authProvider.user;

    final initialName = user?['name'] ?? '';
    _initialPhone = user?['phone'] ?? '';
    _initialEmail = user?['email'] ?? '';
    final initialPhoto = user?['photo'];

    _nameController = TextEditingController(text: initialName);
    _phoneController = TextEditingController(text: _initialPhone);
    _emailController = TextEditingController(text: _initialEmail);

    if (initialPhoto != null && initialPhoto.isNotEmpty) {
      _profileImage = File(initialPhoto);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _profileImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  void _showImagePickerOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text('Ganti Foto Profil', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
              ),
              ListTile(
                leading: Icon(Icons.camera_alt, color: Theme.of(context).primaryColor),
                title: Text('Ambil dari Kamera', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library, color: Theme.of(context).primaryColor),
                title: Text('Pilih dari Galeri', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Future<void> _handleSave() async {
    final authProvider = context.read<AuthProvider>();

    final newName = _nameController.text.trim();
    final newPhone = _phoneController.text.trim();
    final newEmail = _emailController.text.trim();
    final newPhotoPath = _profileImage?.path;

    // 1. Instantly update name and photo
    await authProvider.updateBasicProfile(newName, newPhotoPath);

    bool needPhoneOtp = newPhone != _initialPhone && newPhone.isNotEmpty;
    bool needEmailOtp = newEmail != _initialEmail && newEmail.isNotEmpty;

    if (!needPhoneOtp && !needEmailOtp) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil berhasil diperbarui'), backgroundColor: Colors.green),
      );
      Navigator.pop(context);
      return;
    }

    // 2. Request OTP for Phone if changed
    if (needPhoneOtp) {
      await authProvider.requestOtp('phone', newPhone);
      final success = await _showOtpDialog('phone', newPhone);
      if (success == true) {
        _initialPhone = newPhone;
      } else {
        // Revert controller if failed/cancelled
        _phoneController.text = _initialPhone;
      }
    }

    // 3. Request OTP for Email if changed
    if (needEmailOtp) {
      await authProvider.requestOtp('email', newEmail);
      final success = await _showOtpDialog('email', newEmail);
      if (success == true) {
        _initialEmail = newEmail;
      } else {
        // Revert controller if failed/cancelled
        _emailController.text = _initialEmail;
      }
    }

    // If both succeeded, or if one succeeded and the other wasn't needed, we can pop if we want, or just let user see it updated.
    // We'll pop if everything is synced to initial
    if (_phoneController.text == _initialPhone && _emailController.text == _initialEmail) {
      Navigator.pop(context);
    }
  }

  Future<bool?> _showOtpDialog(String type, String newValue) async {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return OtpVerificationDialog(
          updateType: type,
          newValue: newValue,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Edit Profil', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Center(
              child: GestureDetector(
                onTap: () => _showImagePickerOptions(context),
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Theme.of(context).primaryColor.withAlpha(30),
                      backgroundImage: _profileImage != null ? FileImage(_profileImage!) : null,
                      child: _profileImage == null
                          ? Icon(Icons.person, size: 60, color: Theme.of(context).primaryColor)
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.camera_alt, color: Colors.grey),
                          onPressed: () => _showImagePickerOptions(context),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            _buildTextField('Nama Lengkap', _nameController, false),
            const SizedBox(height: 16),
            _buildTextField('Nomor Handphone', _phoneController, false, keyboardType: TextInputType.phone),
            const SizedBox(height: 16),
            _buildTextField('Email', _emailController, false, keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _handleSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Simpan Perubahan', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, bool obscure, {TextInputType keyboardType = TextInputType.text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 8),
        TextField(
          obscureText: obscure,
          keyboardType: keyboardType,
          controller: controller,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }
}
