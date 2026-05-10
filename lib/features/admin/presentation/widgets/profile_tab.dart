import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/drive_url_helper.dart';
import '../../../../core/utils/gradient_border_card.dart';
import '../../../portfolio/domain/entities/portfolio_entities.dart';
import '../cubit/admin_cubit.dart';

class ProfileTab extends StatefulWidget {
  final ProfileEntity profile;
  const ProfileTab({super.key, required this.profile});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  late TextEditingController _nameCtrl;
  late TextEditingController _titleCtrl;
  late TextEditingController _subtitleCtrl;
  late TextEditingController _bioCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _githubCtrl;
  late TextEditingController _linkedinCtrl;
  late TextEditingController _cvUrlCtrl;
  late TextEditingController _photoUrlCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.profile.name);
    _titleCtrl = TextEditingController(text: widget.profile.title);
    _subtitleCtrl = TextEditingController(text: widget.profile.subtitle);
    _bioCtrl = TextEditingController(text: widget.profile.bio);
    _emailCtrl = TextEditingController(text: widget.profile.email);
    _phoneCtrl = TextEditingController(text: widget.profile.phone);
    _githubCtrl = TextEditingController(text: widget.profile.github);
    _linkedinCtrl = TextEditingController(text: widget.profile.linkedin);
    _cvUrlCtrl = TextEditingController(text: widget.profile.cvUrl);
    _photoUrlCtrl = TextEditingController(text: widget.profile.photoUrl);

    // Add listener for real-time preview update
    _photoUrlCtrl.addListener(_onPhotoUrlChanged);
  }

  void _onPhotoUrlChanged() {
    setState(() {}); // Rebuild to update preview
  }

  @override
  void dispose() {
    _photoUrlCtrl.removeListener(_onPhotoUrlChanged);
    _nameCtrl.dispose();
    _titleCtrl.dispose();
    _subtitleCtrl.dispose();
    _bioCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _githubCtrl.dispose();
    _linkedinCtrl.dispose();
    _cvUrlCtrl.dispose();
    _photoUrlCtrl.dispose();
    super.dispose();
  }

  void _save(BuildContext context) {
    final updated = ProfileEntity(
      name: _nameCtrl.text,
      title: _titleCtrl.text,
      subtitle: _subtitleCtrl.text,
      bio: _bioCtrl.text,
      photoUrl: _photoUrlCtrl.text,
      email: _emailCtrl.text,
      phone: _phoneCtrl.text,
      github: _githubCtrl.text,
      linkedin: _linkedinCtrl.text,
      cvUrl: _cvUrlCtrl.text,
      badges: widget.profile.badges,
    );

    context.read<AdminCubit>().updateProfile(updated);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(40),
      child: Center(
        child: SizedBox(
          width: 700,
          child: GradientBorderCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Edit Profile',
                    style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 32),
                // Photo URL preview
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.purple, width: 2),
                        ),
                        child: ClipOval(
                          child: _photoUrlCtrl.text.isNotEmpty
                              ? Image.network(
                                  convertDriveUrl(_photoUrlCtrl.text),
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const Icon(
                                      Icons.broken_image_rounded,
                                      size: 60,
                                      color: AppColors.purple))
                              : const Icon(Icons.person_rounded,
                                  size: 60, color: AppColors.purple),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Paste photo URL below',
                        style: TextStyle(
                          color: AppColors.cyan,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                _buildField('Photo URL', _photoUrlCtrl),
                const SizedBox(height: 16),
                _buildField('Name', _nameCtrl),
                const SizedBox(height: 16),
                _buildField('Title', _titleCtrl),
                const SizedBox(height: 16),
                _buildField('Subtitle', _subtitleCtrl),
                const SizedBox(height: 16),
                _buildField('Bio', _bioCtrl, maxLines: 5),
                const SizedBox(height: 16),
                _buildField('Email', _emailCtrl),
                const SizedBox(height: 16),
                _buildField('Phone', _phoneCtrl),
                const SizedBox(height: 16),
                _buildField('GitHub URL', _githubCtrl),
                const SizedBox(height: 16),
                _buildField('LinkedIn URL', _linkedinCtrl),
                const SizedBox(height: 16),
                _buildField('CV URL', _cvUrlCtrl),
                const SizedBox(height: 8),
                const Text(
                  'Google Drive share links are supported and will be opened as a smooth preview automatically.',
                  style: TextStyle(
                    color: AppColors.textSecondaryDark,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 32),
                BlocBuilder<AdminCubit, AdminState>(
                  builder: (context, state) => SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed:
                          state is AdminLoading ? null : () => _save(context),
                      child: state is AdminLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text('Save Changes'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController ctrl,
      {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                color: AppColors.purple, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        TextField(
          controller: ctrl,
          maxLines: maxLines,
          decoration: InputDecoration(hintText: label),
        ),
      ],
    );
  }
}
