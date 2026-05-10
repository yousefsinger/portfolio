import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/gradient_border_card.dart';
import '../../../../core/services/email_service.dart';
import '../../../../core/services/spam_prevention_service.dart';

class ContactForm extends StatefulWidget {
  const ContactForm({super.key});

  @override
  State<ContactForm> createState() => _ContactFormState();
}

class _ContactFormStateValue {
  final bool loading;
  final String? resultMessage;
  final bool isSuccess;

  _ContactFormStateValue({
    this.loading = false,
    this.resultMessage,
    this.isSuccess = false,
  });
}

class _ContactFormState extends State<ContactForm> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _messageCtrl = TextEditingController();
  late final ValueNotifier<_ContactFormStateValue> _formStateNotifier;

  final _emailService = EmailJSService();
  final _spamService = SpamPreventionService();

  @override
  void initState() {
    super.initState();
    _formStateNotifier =
        ValueNotifier<_ContactFormStateValue>(_ContactFormStateValue());
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _messageCtrl.dispose();
    _formStateNotifier.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final name = _nameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final message = _messageCtrl.text.trim();

    if (name.isEmpty || email.isEmpty || message.isEmpty) {
      _formStateNotifier.value = _ContactFormStateValue(
        resultMessage: 'Please fill in all fields.',
        isSuccess: false,
      );
      return;
    }

    _formStateNotifier.value = _ContactFormStateValue(loading: true);

    try {
      // 1. Check Spam Prevention
      final spamCheck = await _spamService.canSubmit();
      if (!spamCheck['allowed']) {
        _formStateNotifier.value = _ContactFormStateValue(
          resultMessage: spamCheck['message'],
          isSuccess: false,
        );
        return;
      }

      // 2. Check for Duplicates
      if (await _spamService.isDuplicate(message)) {
        _formStateNotifier.value = _ContactFormStateValue(
          resultMessage: 'You have already sent this message.',
          isSuccess: false,
        );
        return;
      }

      // 3. Send Email
      final success = await _emailService.sendEmail(
        name: name,
        email: email,
        message: message,
      );

      if (success) {
        // 4. Record Submission
        await _spamService.recordSubmission();
        await _spamService.recordMessage(message);

        _formStateNotifier.value = _ContactFormStateValue(
          isSuccess: true,
          resultMessage: 'Message sent successfully!',
        );
        _nameCtrl.clear();
        _emailCtrl.clear();
        _messageCtrl.clear();
      }
    } catch (e) {
      _formStateNotifier.value = _ContactFormStateValue(
        isSuccess: false,
        resultMessage: e.toString().replaceFirst('Exception: ', ''),
      );
    } finally {
      if (mounted) {
        _formStateNotifier.value = _ContactFormStateValue(
          loading: false,
          isSuccess: _formStateNotifier.value.isSuccess,
          resultMessage: _formStateNotifier.value.resultMessage,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<_ContactFormStateValue>(
      valueListenable: _formStateNotifier,
      builder: (context, state, _) {
        return GradientBorderCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Send me a message',
                style: TextStyle(
                  color: AppColors.purple,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  hintText: 'Name',
                  prefixIcon: Icon(Icons.person_outline_rounded),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'Email',
                  prefixIcon: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: SvgPicture.asset(
                      'assets/icons/gmailicon.svg',
                      width: 18,
                      height: 18,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _messageCtrl,
                maxLines: 5,
                decoration: const InputDecoration(
                  hintText: 'Message',
                  prefixIcon: Padding(
                    padding: EdgeInsets.only(bottom: 60),
                    child: Icon(Icons.chat_bubble_outline_rounded),
                  ),
                  alignLabelWithHint: true,
                ),
              ),
              if (state.resultMessage != null) ...[
                const SizedBox(height: 12),
                Text(
                  state.resultMessage!,
                  style: TextStyle(
                    color: state.isSuccess ? Colors.green : Colors.red.shade400,
                    fontSize: 13,
                  ),
                ),
              ],
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: state.loading ? null : _sendMessage,
                  icon: state.loading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.send_rounded, size: 18),
                  label: const Text('Send Message'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
