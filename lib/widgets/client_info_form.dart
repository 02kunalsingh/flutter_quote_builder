// lib/widgets/client_info_form.dart
import 'package:flutter/material.dart';

class ClientInfoForm extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController addressController;
  final TextEditingController referenceController;

  const ClientInfoForm({
    Key? key,
    required this.nameController,
    required this.addressController,
    required this.referenceController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Simple grouped inputs
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Client Info', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Client Name')),
          const SizedBox(height: 8),
          TextField(controller: addressController, decoration: const InputDecoration(labelText: 'Address')),
          const SizedBox(height: 8),
          TextField(controller: referenceController, decoration: const InputDecoration(labelText: 'Reference')),
        ]),
      ),
    );
  }
}
