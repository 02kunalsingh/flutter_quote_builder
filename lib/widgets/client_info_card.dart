import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ClientInfoCard extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController addressController;
  final TextEditingController referenceController;

  const ClientInfoCard(
      {Key? key,
      required this.nameController,
      required this.addressController,
      required this.referenceController})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // This widget expects to be placed inside a Form so that callers can
    // validate the fields via a FormState. Each input uses a validator so
    // required fields show inline errors when validation runs.
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 12)
          ]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: Colors.indigo.shade50,
                  borderRadius: BorderRadius.circular(8)),
              child: const FaIcon(FontAwesomeIcons.user, color: Colors.indigo)),
          const SizedBox(width: 12),
          const Text('Client Information',
              style: TextStyle(fontWeight: FontWeight.w700)),
        ]),
        const SizedBox(height: 12),
        TextFormField(
            controller: nameController,
            decoration: InputDecoration(
                labelText: 'Client name',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Required';
              return null;
            }),
        const SizedBox(height: 10),
        TextFormField(
            controller: addressController,
            maxLines: 2,
            decoration: InputDecoration(
                labelText: 'Address',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8)))),
        const SizedBox(height: 10),
        TextFormField(
            controller: referenceController,
            decoration: InputDecoration(
                labelText: 'Reference',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Required';
              return null;
            }),
      ]),
    );
  }
}
