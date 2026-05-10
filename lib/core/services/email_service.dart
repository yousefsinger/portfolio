import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;

import '../constants/app_constants.dart';

class EmailJSService {
  Future<bool> sendEmail({
    required String name,
    required String email,
    required String message,
  }) async {
    if (!_isValidEmail(email)) {
      throw Exception('Invalid email format');
    }

    final String formattedTime = _getFormattedTime();

    try {
      final response = await http.post(
        Uri.parse(AppStrings.endpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'service_id': AppStrings.serviceId,
          'template_id': AppStrings.templateId,
          'user_id': AppStrings.publicKey,
          'template_params': {
            'name': name,
            'email': email,
            'message': message,
            'title': 'Contact Form Request',
            'time': formattedTime,
          },
        }),
      );

      if (response.statusCode == 200) {
        log('Email sent successfully!');
        return true;
      } else {
        log('EmailJS Error: ${response.body}');
        throw Exception('Server Error: ${response.statusCode}');
      }
    } catch (e) {
      log('Email Service Failure: $e');
      rethrow;
    }
  }

  String _getFormattedTime() {
    final now = DateTime.now();
    return "${now.hour}:${now.minute.toString().padLeft(2, '0')} (${now.day}/${now.month}/${now.year})";
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
}
