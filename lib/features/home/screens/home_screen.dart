import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../app.dart';
import '../../community/controllers/community_controller.dart';
import '../../progress/controllers/progress_controller.dart';
import '../controllers/home_controller.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/start_recitation_card.dart';
import '../widgets/stats_row.dart';
import '../widgets/community_card.dart';
import '../widgets/continue_learning_section.dart';

void refreshAllHomeData() {
  if (Get.isRegistered<HomeController>()) {
    Get.find<HomeController>().fetchHomeContent();
  }
  if (Get.isRegistered<CommunityController>()) {
    Get.find<CommunityController>().fetchCommunities();
  }
  if (Get.isRegistered<ProgressController>()) {
    Get.find<ProgressController>().fetchProgress();
    Get.find<ProgressController>().fetchLeaderboardData();
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with RouteAware {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final modalRoute = ModalRoute.of(context);
    if (modalRoute != null) {
      routeObserver.subscribe(this, modalRoute);
    }
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    // Called when the top route has been popped off, and this route shows up again.
    refreshAllHomeData();
  }

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

