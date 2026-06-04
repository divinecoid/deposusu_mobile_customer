import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/address_provider.dart';
import 'add_address_page.dart';

class AddressPage extends StatelessWidget {
  const AddressPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Alamat Saya', style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.onSurface),
      ),
      body: Consumer<AddressProvider>(
        builder: (context, provider, child) {
          final addresses = provider.addresses;
          
          if (addresses.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.location_off, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  const Text('Belum ada alamat tersimpan', style: TextStyle(color: Colors.grey, fontSize: 16)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: addresses.length,
            itemBuilder: (context, index) {
              final address = addresses[index];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: address.isPrimary 
                        ? Theme.of(context).primaryColor 
                        : Theme.of(context).dividerColor.withValues(alpha: 0.1),
                    width: address.isPrimary ? 2 : 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              address.label == 'Rumah' ? Icons.home : 
                              address.label == 'Kantor' ? Icons.business : Icons.place,
                              color: Theme.of(context).primaryColor,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              address.label,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            if (address.isPrimary) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text('Utama', style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 10, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ],
                        ),
                        PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert, color: Colors.grey),
                          onSelected: (value) {
                            if (value == 'delete') {
                              provider.deleteAddress(address.id);
                            } else if (value == 'set_primary') {
                              provider.setPrimary(address.id);
                            }
                          },
                          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                            if (!address.isPrimary)
                              const PopupMenuItem<String>(
                                value: 'set_primary',
                                child: Text('Jadikan Alamat Utama'),
                              ),
                            const PopupMenuItem<String>(
                              value: 'delete',
                              child: Text('Hapus Alamat', style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(address.recipientName, style: const TextStyle(fontWeight: FontWeight.w600)),
                    Text(address.phoneNumber, style: const TextStyle(color: Colors.grey)),
                    const SizedBox(height: 8),
                    Text(address.fullAddress),
                    if (address.note.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text('Catatan: ${address.note}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const AddAddressPage()));
        },
        backgroundColor: Theme.of(context).primaryColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Tambah Alamat', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
