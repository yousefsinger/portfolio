import 'package:flutter/material.dart';

Widget dialogField(String label, TextEditingController ctrl,
    {int maxLines = 1, ValueChanged<String>? onChanged}) {
  return TextField(
    controller: ctrl,
    maxLines: maxLines,
    onChanged: onChanged,
    decoration: InputDecoration(labelText: label),
  );
}

void confirmDelete(
    BuildContext context, String message, VoidCallback onConfirm) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Confirm Delete'),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            onConfirm();
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: const Text('Delete'),
        ),
      ],
    ),
  );
}
