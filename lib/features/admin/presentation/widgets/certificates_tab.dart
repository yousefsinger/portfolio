import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/gradient_border_card.dart';
import '../../../portfolio/domain/entities/portfolio_entities.dart';
import '../cubit/admin_cubit.dart';
import 'admin_helpers.dart';

class CertificatesTab extends StatelessWidget {
  final List<CertificateEntity> certificates;
  const CertificatesTab({super.key, required this.certificates});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text('Certificates (${certificates.length})',
                    style: Theme.of(context).textTheme.headlineMedium),
              ),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showAddCertDialog(context),
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('Add Certificate'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView.separated(
              itemCount: certificates.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final c = certificates[index];
                return GradientBorderCard(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: AppColors.purple.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.military_tech_rounded,
                            color: AppColors.purple),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(c.title,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            Text('${c.issuer} · ${c.date}',
                                style: Theme.of(context).textTheme.bodyMedium),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline_rounded,
                            color: Colors.red),
                        onPressed: () => confirmDelete(
                          context,
                          'Delete "${c.title}"?',
                          () => context
                              .read<AdminCubit>()
                              .deleteCertificate(c.id),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showAddCertDialog(BuildContext context) {
    final titleCtrl = TextEditingController();
    final issuerCtrl = TextEditingController();
    final dateCtrl = TextEditingController();
    final urlCtrl = TextEditingController();

    final adminCubit = context.read<AdminCubit>();
    showDialog(
        context: context,
        builder: (ctx) => BlocProvider.value(
              value: adminCubit,
              child: AlertDialog(
                backgroundColor: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.darkSurface
                    : AppColors.lightSurface,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.cardRadius)),
                title: const Text('Add New Certificate'),
                content: SizedBox(
                  width: 500,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      dialogField('Title', titleCtrl),
                      const SizedBox(height: 12),
                      dialogField('Issuer (e.g. Udemy)', issuerCtrl),
                      const SizedBox(height: 12),
                      dialogField('Date (e.g. Jan 2025)', dateCtrl),
                      const SizedBox(height: 12),
                      dialogField('Credential URL (optional)', urlCtrl),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      final cert = CertificateEntity(
                        id: '',
                        title: titleCtrl.text,
                        issuer: issuerCtrl.text,
                        date: dateCtrl.text,
                        credentialUrl:
                            urlCtrl.text.isEmpty ? null : urlCtrl.text,
                      );
                      adminCubit.addCertificate(cert);
                      Navigator.pop(ctx);
                    },
                    child: const Text('Add'),
                  ),
                ],
              ),
            ));
  }
}
