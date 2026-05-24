import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/start_recitation_card.dart';
import '../widgets/stats_row.dart';
import '../widgets/community_card.dart';
import '../widgets/continue_learning_section.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      body: const SafeArea(
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DashboardHeader(),

              StartRecitationCard(),

              StatsRow(),

              CommunityCard(),

              ContinueLearningSection(),

              SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
