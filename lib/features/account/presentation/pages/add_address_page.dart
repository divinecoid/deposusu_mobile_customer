import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/address_provider.dart';

class AddAddressPage extends StatefulWidget {
  const AddAddressPage({super.key});

  @override
  State<AddAddressPage> createState() => _AddAddressPageState();
}

class _AddAddressPageState extends State<AddAddressPage> {
  String _selectedLabel = 'Rumah';
  bool _isPrimary = false;
  
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _saveAddress() {
    if (_nameController.text.isEmpty || _phoneController.text.isEmpty || _addressController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Harap isi semua kolom wajib')));
      return;
    }

    final provider = Provider.of<AddressProvider>(context, listen: false);
    final newAddress = Address(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      label: _selectedLabel,
      recipientName: _nameController.text,
      phoneNumber: _phoneController.text,
      fullAddress: _addressController.text,
      note: _noteController.text,
      isPrimary: _isPrimary,
    );

    provider.addAddress(newAddress);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Tambah Alamat', style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.onSurface),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Label Alamat', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildLabelChip('Rumah'),
                const SizedBox(width: 8),
                _buildLabelChip('Kantor'),
                const SizedBox(width: 8),
                _buildLabelChip('Lainnya'),
              ],
            ),
            const SizedBox(height: 24),
            
            _buildTextField(label: 'Nama Penerima', controller: _nameController),
            const SizedBox(height: 16),
            _buildTextField(label: 'Nomor HP', controller: _phoneController, keyboardType: TextInputType.phone),
            const SizedBox(height: 24),
            
            const Text('Pin Lokasi', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Theme.of(context).dividerColor.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.location_on, color: Colors.grey[400], size: 40),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {
                      // Mock map picker
                    },
                    child: Text('Tentukan Koordinat di Peta', style: TextStyle(color: Theme.of(context).primaryColor)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            _buildTextField(label: 'Alamat Lengkap', controller: _addressController, maxLines: 3),
            const SizedBox(height: 16),
            _buildTextField(label: 'Catatan (Opsional)', controller: _noteController, hint: 'Cth: Rumah pojok cat putih'),
            const SizedBox(height: 24),
            
            Row(
              children: [
                Checkbox(
                  value: _isPrimary,
                  activeColor: Theme.of(context).primaryColor,
                  onChanged: (val) {
                    setState(() {
                      _isPrimary = val ?? false;
                    });
                  },
                ),
                const Text('Jadikan alamat utama', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 40),
            
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _saveAddress,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Simpan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildLabelChip(String label) {
    final isSelected = _selectedLabel == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedLabel = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).primaryColor.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? Theme.of(context).primaryColor : Colors.grey[300]!),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Theme.of(context).primaryColor : Colors.grey[600],
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.grey),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Theme.of(context).primaryColor),
            ),
          ),
        ),
      ],
    );
  }
}
