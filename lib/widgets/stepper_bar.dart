import 'package:flutter/material.dart';
import 'package:uniswap_app/theme/app_colors.dart';

class StepperBar extends StatelessWidget {
  final int total;
  final int current;
  const StepperBar({super.key, required this.total, required this.current});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(total, (i) {
        final active = i <= current;
        return Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: EdgeInsets.only(right: i == total - 1 ? 0 : 6),
            height: 3,
            decoration: BoxDecoration(
              color: active ? AppColors.primary : AppColors.divider,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        );
      }),
    );
  }
}

class StepperBarWithLabels extends StatelessWidget {
  final List<String> labels;
  final int current;
  const StepperBarWithLabels({
    super.key,
    required this.labels,
    required this.current,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: List.generate(labels.length, (i) {
            final active = i <= current;
            return Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: EdgeInsets.only(right: i == labels.length - 1 ? 0 : 4),
                height: 3,
                decoration: BoxDecoration(
                  color: active ? AppColors.primary : AppColors.divider,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 10),
        Row(
          children: List.generate(labels.length, (i) {
            final active = i == current;
            return Expanded(
              child: Text(
                labels[i],
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: active ? AppColors.primary : AppColors.textSecondary,
                  fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}
