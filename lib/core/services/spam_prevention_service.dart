import 'package:shared_preferences/shared_preferences.dart';

class SpamPreventionService {
  static const String _lastSubmissionKey = 'last_contact_submission';
  static const String _submissionCountKey = 'contact_submission_count';
  static const String _lastResetKey = 'last_submission_reset';
  static const int _maxSubmissionsPerHour = 3;
  static const int _cooldownSeconds = 60;

  Future<Map<String, dynamic>> canSubmit() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    
    // Check cooldown
    final lastSubmissionStr = prefs.getString(_lastSubmissionKey);
    if (lastSubmissionStr != null) {
      final lastSubmission = DateTime.parse(lastSubmissionStr);
      final secondsSinceLastSubmission = now.difference(lastSubmission).inSeconds;

      if (secondsSinceLastSubmission < _cooldownSeconds) {
        final remainingSeconds = _cooldownSeconds - secondsSinceLastSubmission;
        return {
          'allowed': false,
          'message': 'Please wait $remainingSeconds seconds before sending another message.',
        };
      }
    }

    // Check hourly limit
    final lastResetStr = prefs.getString(_lastResetKey);
    final submissionCount = prefs.getInt(_submissionCountKey) ?? 0;

    if (lastResetStr != null) {
      final lastReset = DateTime.parse(lastResetStr);
      final hoursSinceReset = now.difference(lastReset).inHours;

      if (hoursSinceReset < 1) {
        if (submissionCount >= _maxSubmissionsPerHour) {
          return {
            'allowed': false,
            'message': 'You have reached the maximum number of messages per hour. Please try again later.',
          };
        }
      } else {
        await prefs.setInt(_submissionCountKey, 0);
        await prefs.setString(_lastResetKey, now.toIso8601String());
      }
    } else {
      await prefs.setString(_lastResetKey, now.toIso8601String());
    }

    return {'allowed': true, 'message': null};
  }

  Future<void> recordSubmission() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    await prefs.setString(_lastSubmissionKey, now.toIso8601String());
    final currentCount = prefs.getInt(_submissionCountKey) ?? 0;
    await prefs.setInt(_submissionCountKey, currentCount + 1);
  }

  Future<bool> isDuplicate(String message) async {
    final prefs = await SharedPreferences.getInstance();
    final lastMessage = prefs.getString('last_message_content');

    if (lastMessage == null) return false;

    return lastMessage.trim().toLowerCase() == message.trim().toLowerCase();
  }

  Future<void> recordMessage(String message) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_message_content', message);
  }

  Future<void> clearData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_lastSubmissionKey);
    await prefs.remove(_submissionCountKey);
    await prefs.remove(_lastResetKey);
    await prefs.remove('last_message_content');
  }
}
