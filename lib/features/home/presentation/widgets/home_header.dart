import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:taz/app/theme/app_colors.dart';
import 'package:taz/app/theme/app_spacing.dart';
import 'package:taz/app/theme/app_text_styles.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: AppSpacing.xs,
      children: [
        CircleAvatar(
          backgroundColor: AppColors.card,
          child: Icon(Icons.person_outlined),
        ),
        Expanded(
          child: RichText(
            text: TextSpan(
              text: 'Today',
              style: AppTextStyles.header,
              children: [
                TextSpan(
                  text: ', 18 Nov',
                  style: TextStyle(color: AppColors.secondaryText),
                ),
              ],
            ),
          ),
        ),
        HomeHeaderButton(
          icon: Icons.calendar_month,
          onTap: () {
            log('Calendar Tapped!');
          },
        ),
        HomeHeaderButton(
          icon: Icons.settings,
          onTap: () {
            log('Settings Tapped!');
          },
        ),
        HomeHeaderButton(
          icon: Icons.share,
          onTap: () {
            log('Share Tapped!');
          },
        ),
      ],
    );
  }
}

class HomeHeaderButton extends StatelessWidget {
  const HomeHeaderButton({super.key, required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton.filled(
      onPressed: onTap,
      icon: Icon(icon),
      style: IconButton.styleFrom(
        backgroundColor: AppColors.card,
        foregroundColor: AppColors.primaryText,
        shape: CircleBorder(),
        fixedSize: Size(44, 44),
      ),
    );
  }
}
