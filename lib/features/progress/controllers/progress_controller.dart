import 'package:get/get.dart';

class ProgressController extends GetxController {
  final selectedFilter = 'daily'.obs;

  final leaderboardTab = 'global'.obs;

  void setFilter(String filter) {
    selectedFilter.value = filter;
  }

  void setLeaderboardTab(String tab) {
    leaderboardTab.value = tab;
  }

  int get surahsCount {
    switch (selectedFilter.value) {
      case 'weekly':
        return 8;
      case 'monthly':
        return 24;
      case 'daily':
      default:
        return 2;
    }
  }

  int get hoursCount {
    switch (selectedFilter.value) {
      case 'weekly':
        return 14;
      case 'monthly':
        return 56;
      case 'daily':
      default:
        return 3;
    }
  }

  int get streakCount {
    switch (selectedFilter.value) {
      case 'weekly':
        return 3;
      case 'monthly':
        return 15;
      case 'daily':
      default:
        return 1;
    }
  }

  int get completedVerses {
    switch (selectedFilter.value) {
      case 'weekly':
        return 15420;
      case 'monthly':
        return 48500;
      case 'daily':
      default:
        return 4862;
    }
  }

  int get goalVerses {
    switch (selectedFilter.value) {
      case 'weekly':
        return 20000;
      case 'monthly':
        return 60000;
      case 'daily':
      default:
        return 6236;
    }
  }

  String get readSummaryKey {
    switch (selectedFilter.value) {
      case 'weekly':
        return 'read_summary_weekly';
      case 'monthly':
        return 'read_summary_monthly';
      case 'daily':
      default:
        return 'read_summary_daily';
    }
  }

  String get chartLabelKey {
    switch (selectedFilter.value) {
      case 'weekly':
        return 'weekly_activity';
      case 'monthly':
        return 'monthly_activity';
      case 'daily':
      default:
        return 'daily_activity';
    }
  }

  List<double> get activityBarHeights {
    switch (selectedFilter.value) {
      case 'weekly':
        return [0.60, 0.80, 0.30, 0.90, 0.70, 0.40, 0.50];
      case 'monthly':
        return [0.70, 0.90, 0.50, 0.85];
      case 'daily':
      default:
        return [0.30, 0.50, 0.80, 0.40, 0.20, 0.90, 0.60];
    }
  }

  List<String> get activityBarLabels {
    switch (selectedFilter.value) {
      case 'weekly':
        return ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
      case 'monthly':
        return ['W1', 'W2', 'W3', 'W4'];
      case 'daily':
      default:
        return ['6AM', '9AM', '12PM', '2PM', '5PM', '7PM', 'Now'];
    }
  }

  final achievements = <AchievementItem>[
    AchievementItem(
      titleKey: 'achievement_7day_title',
      descKey: 'achievement_7day_desc',
      type: 'streak',
      isNew: true,
    ),
    AchievementItem(
      titleKey: 'achievement_first_surah_title',
      descKey: 'achievement_first_surah_desc',
      type: 'surah',
      isNew: true,
    ),
    AchievementItem(
      titleKey: 'achievement_100verses_title',
      descKey: 'achievement_100verses_desc',
      type: 'verses',
      isNew: true,
    ),
  ].obs;

  double get monthlyGoalPercent => 0.60; // 60%
  int get monthlyGoalCompleted => 6;

  int get monthlyGoalTotal => 10;

  List<LeaderboardUser> get podiumUsers {
    return [
      LeaderboardUser(
        rank: 2,
        name: 'Ahmad K.',
        verses: selectedFilter.value == 'weekly' ? '245' : '1,245',
        avatarUrl:
            'https://ui-avatars.com/api/?name=Ahmad+K&background=0D5C3A&color=fff',
      ),
      LeaderboardUser(
        rank: 1,
        name: 'Sarah M.',
        verses: selectedFilter.value == 'weekly' ? '856' : '1,856',
        avatarUrl:
            'https://ui-avatars.com/api/?name=Sarah+M&background=06402B&color=fff',
      ),
      LeaderboardUser(
        rank: 3,
        name: 'Omar A.',
        verses: selectedFilter.value == 'weekly' ? '120' : '1,120',
        avatarUrl:
            'https://ui-avatars.com/api/?name=Omar+A&background=EFBF04&color=000',
      ),
    ];
  }

  List<LeaderboardRow> get otherRankings {
    final isGlobal = leaderboardTab.value == 'global';

    if (isGlobal) {
      return [
        LeaderboardRow(
          rank: 4,
          name: 'Fatima Club',
          sub: '712 verses read',
          score: 986,
          isHighlighted: false,
          avatarUrl:
              'https://ui-avatars.com/api/?name=Fatima+Club&background=A78BFA&color=fff',
        ),
        LeaderboardRow(
          rank: 5,
          name: 'Yusuf Club',
          sub: '665 verses read',
          score: 924,
          isHighlighted: false,
          avatarUrl:
              'https://ui-avatars.com/api/?name=Yusuf+Club&background=60A5FA&color=fff',
        ),
        LeaderboardRow(
          rank: 6,
          name: 'Aisha Club',
          sub: '648 verses read',
          score: 910,
          isHighlighted: false,
          avatarUrl:
              'https://ui-avatars.com/api/?name=Aisha+Club&background=FBCFE8&color=000',
        ),
        LeaderboardRow(
          rank: 7,
          name: 'Ibrahim Club',
          sub: '632 verses read',
          score: 905,
          isHighlighted: false,
          avatarUrl:
              'https://ui-avatars.com/api/?name=Ibrahim+Club&background=2DD4BF&color=fff',
        ),
        LeaderboardRow(
          rank: 8,
          name: 'Readers Club',
          sub: '620 verses read',
          score: 892,
          isHighlighted: true,
          avatarUrl:
              'https://ui-avatars.com/api/?name=Readers+Club&background=06402B&color=fff',
        ),
      ];
    } else {
      return [
        LeaderboardRow(
          rank: 4,
          name: 'Fatima H.',
          sub: '712 verses read',
          score: 986,
          isHighlighted: false,
          avatarUrl:
              'https://ui-avatars.com/api/?name=Fatima+H&background=A78BFA&color=fff',
        ),
        LeaderboardRow(
          rank: 5,
          name: 'Yusuf T.',
          sub: '665 verses read',
          score: 924,
          isHighlighted: false,
          avatarUrl:
              'https://ui-avatars.com/api/?name=Yusuf+T&background=60A5FA&color=fff',
        ),
        LeaderboardRow(
          rank: 6,
          name: 'Aisha R.',
          sub: '648 verses read',
          score: 910,
          isHighlighted: false,
          avatarUrl:
              'https://ui-avatars.com/api/?name=Aisha+R&background=FBCFE8&color=000',
        ),
        LeaderboardRow(
          rank: 7,
          name: 'Ibrahim S.',
          sub: '632 verses read',
          score: 905,
          isHighlighted: false,
          avatarUrl:
              'https://ui-avatars.com/api/?name=Ibrahim+S&background=2DD4BF&color=fff',
        ),
        LeaderboardRow(
          rank: 8,
          name: 'You',
          sub: '620 verses read',
          score: 892,
          isHighlighted: true,
          avatarUrl:
              'https://ui-avatars.com/api/?name=You&background=06402B&color=fff',
        ),
      ];
    }
  }

  double get challengePercent => 0.68;

  int get challengeCompleted => 34;

  int get challengeTotal => 50;

  int get currentCommunityRank => 8;

  int get communityTotalMembers => 1245;

  double get communityWeeklyProgress => 0.65;

  int get communityWeeklyCompleted => 325;

  int get communityWeeklyGoal => 500;

  final lockedAchievements = <LockedAchievement>[
    LockedAchievement(
      title: 'Fast Climber',
      desc: 'Gained 3 ranks',
      isUnlocked: true,
      progressText: 'Earned',
    ),
    LockedAchievement(
      title: '100 Streak',
      desc: '100 days reading',
      isUnlocked: false,
      progressText: '47/100',
    ),
    LockedAchievement(
      title: 'Champion',
      desc: 'Reach #1 ranking',
      isUnlocked: false,
      progressText: 'Locked',
    ),
  ].obs;
}

class AchievementItem {
  final String titleKey;
  final String descKey;
  final String type;
  final bool isNew;

  AchievementItem({
    required this.titleKey,
    required this.descKey,
    required this.type,
    required this.isNew,
  });
}

class LeaderboardUser {
  final int rank;
  final String name;
  final String verses;
  final String avatarUrl;

  LeaderboardUser({
    required this.rank,
    required this.name,
    required this.verses,
    required this.avatarUrl,
  });
}

class LeaderboardRow {
  final int rank;
  final String name;
  final String sub;
  final int score;
  final bool isHighlighted;
  final String avatarUrl;

  LeaderboardRow({
    required this.rank,
    required this.name,
    required this.sub,
    required this.score,
    required this.isHighlighted,
    required this.avatarUrl,
  });
}

class LockedAchievement {
  final String title;
  final String desc;
  final bool isUnlocked;
  final String progressText;

  LockedAchievement({
    required this.title,
    required this.desc,
    required this.isUnlocked,
    required this.progressText,
  });
}
