import 'package:flutter/material.dart';

class RoutineSchedulePage extends StatefulWidget {
  const RoutineSchedulePage({super.key});

  @override
  State<RoutineSchedulePage> createState() => _RoutineSchedulePageState();
}

class _RoutineSchedulePageState extends State<RoutineSchedulePage> {
  final List<String> _days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
  final Set<String> _selectedDays = {'Senin'};
  TimeOfDay _selectedTime = const TimeOfDay(hour: 8, minute: 0);

  final List<Map<String, dynamic>> _routineItems = [
    {'name': 'Susu Segar 1 Liter', 'qty': 2, 'price': 25000},
  ];

  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _addDummyItem() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Pilih Barang Rutin', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.local_drink, color: Colors.blue),
                title: const Text('Yogurt Botol 250ml'),
                trailing: const Text('Rp 15.000'),
                onTap: () {
                  setState(() {
                    _routineItems.add({'name': 'Yogurt Botol 250ml', 'qty': 1, 'price': 15000});
                  });
                  Navigator.pop(ctx);
                },
              ),
              ListTile(
                leading: const Icon(Icons.bakery_dining, color: Colors.orange),
                title: const Text('Roti Tawar'),
                trailing: const Text('Rp 18.000'),
                onTap: () {
                  setState(() {
                    _routineItems.add({'name': 'Roti Tawar', 'qty': 1, 'price': 18000});
                  });
                  Navigator.pop(ctx);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Jadwal Rutin', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.onSurface),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hari Pengiriman
            const Text('Pilih Hari Pengiriman', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _days.map((day) {
                final isSelected = _selectedDays.contains(day);
                return ChoiceChip(
                  label: Text(day),
                  selected: isSelected,
                  selectedColor: Theme.of(context).primaryColor.withAlpha(50),
                  backgroundColor: Theme.of(context).cardColor,
                  labelStyle: TextStyle(
                    color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).colorScheme.onSurface,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedDays.add(day);
                      } else {
                        if (_selectedDays.length > 1) {
                          _selectedDays.remove(day);
                        }
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Jam Pengiriman
            const Text('Pilih Jam Pengiriman', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            InkWell(
              onTap: _pickTime,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.access_time, color: Colors.black54),
                    const SizedBox(width: 12),
                    Text(
                      _selectedTime.format(context),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    const Text('Ubah', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Daftar Barang
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Barang Rutin', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                TextButton.icon(
                  onPressed: _addDummyItem,
                  icon: const Icon(Icons.add),
                  label: const Text('Tambah'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (_routineItems.isEmpty)
              const Center(child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('Belum ada barang rutin yang dipilih.', style: TextStyle(color: Colors.grey)),
              ))
            else
              ..._routineItems.map((item) {
                return Card(
                  color: Theme.of(context).cardColor,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Theme.of(context).dividerColor.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.image, color: Colors.grey),
                    ),
                    title: Text(item['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Rp ${item['price']} x ${item['qty']}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          _routineItems.remove(item);
                        });
                      },
                    ),
                  ),
                );
              }),
            const SizedBox(height: 32),

            // Simpan Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Jadwal rutin berhasil disimpan!')),
                  );
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Simpan Jadwal Rutin', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
