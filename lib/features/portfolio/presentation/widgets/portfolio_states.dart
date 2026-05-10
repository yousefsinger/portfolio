import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';

class PortfolioLoadingView extends StatelessWidget {
  const PortfolioLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(color: AppColors.purple),
    );
  }
}

class PortfolioErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const PortfolioErrorView({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 48),
          const SizedBox(height: 16),
          Text(message),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onRetry,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
