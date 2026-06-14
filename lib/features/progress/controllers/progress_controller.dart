import 'package:get/get.dart';

import 'package:flutter/foundation.dart';
import '../../../core/services/network_service.dart';
import '../../auth/repositories/auth_repository.dart';

class ProgressController extends GetxController {
  final selectedFilter = 'daily'.obs;
  final leaderboardTab = 'global'.obs;

  final rxSurahsCount = 0.obs;
  final rxHoursCount = 0.0.obs;
  final rxStreakCount = 0.obs;
  final rxCompletedVerses = 0.obs;
  final rxGoalVerses = 6236.obs;
  final growthPercentage = "+0.0%".obs;

  final rxMonthlyGoalPercent = 0.0.obs;
  final rxMonthlyGoalCompleted = 0.obs;
  final rxMonthlyGoalTotal = 10.obs;
  final rxMonthlyGoalTitle = "Monthly Goal".obs;
  final rxMonthlyGoalDesc = "Complete 10 Surahs".obs;

  final rxChallengePercent = 0.0.obs;
  final rxChallengeCompleted = 0.obs;
  final rxChallengeTotal = 50.obs;
  final rxChallengeDesc = "Read 50 verses to climb up the ranks.".obs;

  final rxActivityBarHeights = <double>[].obs;
  final rxActivityBarLabels = <String>[].obs;
  final rxActivitySummaryText = "".obs;

  final achievements = <AchievementItem>[].obs;
  final lockedAchievements = <LockedAchievement>[].obs;

  final rxGlobalPodiumUsers = <LeaderboardUser>[].obs;
  final rxGlobalOtherRankings = <LeaderboardRow>[].obs;
  final rxHasGlobalLeaderboard = false.obs;

  final rxCommunityPodiumUsers = <LeaderboardUser>[].obs;
  final rxCommunityOtherRankings = <LeaderboardRow>[].obs;
  final hasCommunityLeaderboard = false.obs;

  // Continue learning observables
  final rxHasRecentSurah = false.obs;
  final rxHasCompletedSurah = false.obs;
  final rxRecentSurahs = <Map<String, dynamic>>[].obs;

  final rxRecentSurahId = 67.obs;
  final rxRecentSurahTitle = "Surah Al-Mulk".obs;
  final rxRecentSurahVersesRead = 22.obs;
  final rxRecentSurahTotalVerses = 30.obs;

  final rxCompletedSurahId = 1.obs;
  final rxCompletedSurahTitle = "Surah Al-Fatihah".obs;
  final rxCompletedSurahTotalVerses = 7.obs;

  late final NetworkService _networkService;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _networkService = Get.find<NetworkService>();

    // Set fallback initial mock data
    _setFallbackProgress();
    _setFallbackLeaderboard();

    // Fetch live data
    fetchProgress();
    fetchLeaderboardData();

    // Set up reactive triggers
    ever(selectedFilter, (_) => fetchProgress());
    ever(leaderboardTab, (_) => fetchLeaderboardData());
  }

  void setFilter(String filter) {
    selectedFilter.value = filter;
  }

  String _resolvePhotoUrl(dynamic photoVal, String username, {String? background, String? color}) {
    String? photo = photoVal as String?;
    if (photo != null && photo.isNotEmpty) {
      if (!photo.startsWith('http://') && !photo.startsWith('https://')) {
        return "https://quran-app-backend-8b57.onrender.com${photo.startsWith('/') ? photo : '/$photo'}";
      }
      return photo;
    }
    final bgParam = background != null ? '&background=$background' : '';
    final colParam = color != null ? '&color=$color' : '';
    return 'https://ui-avatars.com/api/?name=$username$bgParam$colParam&format=png';
  }

  void setLeaderboardTab(String tab) {
    leaderboardTab.value = tab;
  }

  int get surahsCount => rxSurahsCount.value;
  double get hoursCount => rxHoursCount.value;
  int get streakCount => rxStreakCount.value;
  int get completedVerses => rxCompletedVerses.value;
  int get goalVerses => rxGoalVerses.value;

  String get readSummaryKey => rxActivitySummaryText.value;
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

  List<double> get activityBarHeights => rxActivityBarHeights;
  List<String> get activityBarLabels => rxActivityBarLabels;

  double get monthlyGoalPercent => rxMonthlyGoalPercent.value;
  int get monthlyGoalCompleted => rxMonthlyGoalCompleted.value;
  int get monthlyGoalTotal => rxMonthlyGoalTotal.value;

  double get challengePercent => rxChallengePercent.value;
  int get challengeCompleted => rxChallengeCompleted.value;
  int get challengeTotal => rxChallengeTotal.value;

  List<LeaderboardUser> get podiumUsers {
    if (leaderboardTab.value == 'global') {
      if (rxHasGlobalLeaderboard.value) {
        return rxGlobalPodiumUsers;
      }
      return _getMockPodiumUsers();
    } else {
      if (hasCommunityLeaderboard.value) {
        return rxCommunityPodiumUsers;
      }
      return [];
    }
  }

  List<LeaderboardRow> get otherRankings {
    if (leaderboardTab.value == 'global') {
      if (rxHasGlobalLeaderboard.value) {
        return rxGlobalOtherRankings;
      }
      return _getMockOtherRankings();
    } else {
      if (hasCommunityLeaderboard.value) {
        return rxCommunityOtherRankings;
      }
      return [];
    }
  }

  int get currentCommunityRank => 8;
  int get communityTotalMembers => 1245;
  double get communityWeeklyProgress => 0.65;
  int get communityWeeklyCompleted => 325;
  int get communityWeeklyGoal => 500;

  Future<void> fetchProgress() async {
    isLoading.value = true;
    try {
      final period = selectedFilter.value.toLowerCase();
      debugPrint("ProgressController.fetchProgress: Fetching from '/progress/' with period=$period");
      final response = await _networkService.get(
        '/progress/',
        queryParameters: {'period': period},
      );
      debugPrint("ProgressController.fetchProgress: Response status=${response.statusCode}");
      debugPrint("ProgressController.fetchProgress: Response data=${response.data}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;

        // Parse period stats
        final stats = data['stats'] ?? {};
        rxSurahsCount.value = stats['surahs_completed'] as int? ?? 0;
        rxHoursCount.value = (stats['hours_read'] as num?)?.toDouble() ?? 0.0;
        rxStreakCount.value = stats['streak'] as int? ?? 0;

        // Parse overall progress
        final overall = data['overall_progress'] ?? {};
        rxCompletedVerses.value = overall['verses_read'] as int? ?? 0;
        rxGoalVerses.value = overall['total_verses'] as int? ?? 6236;
        growthPercentage.value = overall['growth'] as String? ?? "+0.0%";

        // Parse goals & challenges
        final monthly = data['monthly_goal'] ?? {};
        rxMonthlyGoalPercent.value =
            ((monthly['percentage'] as num?)?.toDouble() ?? 0.0) / 100.0;
        rxMonthlyGoalCompleted.value = monthly['current'] as int? ?? 0;
        rxMonthlyGoalTotal.value = monthly['target'] as int? ?? 10;
        rxMonthlyGoalTitle.value =
            monthly['title'] as String? ?? 'Monthly Goal';
        rxMonthlyGoalDesc.value =
            monthly['description'] as String? ?? 'Complete 10 Surahs';

        final weekly = data['weekly_challenge'] ?? {};
        rxChallengePercent.value =
            ((weekly['percentage'] as num?)?.toDouble() ?? 0.0) / 100.0;
        rxChallengeCompleted.value = weekly['current'] as int? ?? 0;
        rxChallengeTotal.value = weekly['target'] as int? ?? 50;
        rxChallengeDesc.value =
            weekly['description'] as String? ?? 'Read 50 verses';

        // Parse activity breakdown dynamically
        final breakdown = data['activity_breakdown'] ?? data['daily_activity'] ?? {};
        rxActivitySummaryText.value = breakdown['label'] as String? ?? "";

        final slots = breakdown['slots'] as Map<String, dynamic>? ?? {};
        final List<double> newHeights = [];
        final List<String> newLabels = [];

        double maxVal = 0.0;
        slots.forEach((key, val) {
          final double valDouble = (val as num?)?.toDouble() ?? 0.0;
          if (valDouble > maxVal) maxVal = valDouble;
        });

        List<String> orderedSlots;
        if (period == 'weekly') {
          orderedSlots = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
        } else if (period == 'monthly') {
          orderedSlots = ['W1', 'W2', 'W3', 'W4'];
        } else {
          orderedSlots = ['6AM', '9AM', '12PM', '2PM', '5PM', '7PM', 'Now'];
        }

        for (var key in orderedSlots) {
          final double valDouble = (slots[key] as num?)?.toDouble() ?? 0.0;
          newLabels.add(key);
          if (maxVal > 0) {
            newHeights.add(valDouble / maxVal);
          } else {
            newHeights.add(0.0);
          }
        }

        rxActivityBarHeights.assignAll(newHeights);
        rxActivityBarLabels.assignAll(newLabels);

        // Parse continue learning
        final contLearning = data['continue_learning'] ?? {};
        final List<dynamic> recentSurahsJson = contLearning['recent_surahs'] ?? [];
        if (recentSurahsJson.isNotEmpty) {
          rxRecentSurahs.assignAll(recentSurahsJson.map((e) => Map<String, dynamic>.from(e)).toList());
          rxHasRecentSurah.value = true;
          
          final first = rxRecentSurahs.first;
          rxRecentSurahId.value = first['id'] as int? ?? 67;
          rxRecentSurahTitle.value = first['title'] as String? ?? 'Surah Al-Mulk';
          rxRecentSurahVersesRead.value = first['verses_read'] as int? ?? 22;
          rxRecentSurahTotalVerses.value = first['total_verses'] as int? ?? 30;
        } else {
          final recent = contLearning['recent_surah'];
          if (recent != null && recent is Map && recent.isNotEmpty) {
            rxRecentSurahId.value = recent['id'] as int? ?? 67;
            rxRecentSurahTitle.value = recent['title'] as String? ?? 'Surah Al-Mulk';
            rxRecentSurahVersesRead.value = recent['verses_read'] as int? ?? 22;
            rxRecentSurahTotalVerses.value = recent['total_verses'] as int? ?? 30;
            rxRecentSurahs.assignAll([
              {
                'id': rxRecentSurahId.value,
                'title': rxRecentSurahTitle.value,
                'english_name': recent['english_name'] ?? 'Al-Mulk',
                'verses_read': rxRecentSurahVersesRead.value,
                'total_verses': rxRecentSurahTotalVerses.value,
              }
            ]);
            rxHasRecentSurah.value = true;
          } else {
            rxRecentSurahs.clear();
            rxHasRecentSurah.value = false;
          }
        }

        final completed = contLearning['completed_surah'];
        if (completed != null && completed is Map && completed.isNotEmpty) {
          rxCompletedSurahId.value = completed['id'] as int? ?? 1;
          rxCompletedSurahTitle.value = completed['title'] as String? ?? 'Surah Al-Fatihah';
          rxCompletedSurahTotalVerses.value = completed['total_verses'] as int? ?? 7;
          rxHasCompletedSurah.value = true;
        } else {
          rxHasCompletedSurah.value = false;
        }

        // Parse recent achievements
        final List<dynamic> achList = data['recent_achievements'] ?? [];
        final mapped = achList.map((x) {
          final name = x['name'] as String? ?? '';
          final desc = x['description'] as String? ?? '';
          final icon = x['icon_name'] as String? ?? 'verses';
          final earnedAtStr = x['earned_at'] as String? ?? '';

          bool isNew = false;
          if (earnedAtStr.isNotEmpty) {
            try {
              final earnedAt = DateTime.parse(earnedAtStr);
              final difference = DateTime.now().difference(earnedAt);
              isNew = difference.inHours < 24;
            } catch (_) {}
          }

          return AchievementItem(
            titleKey: name,
            descKey: desc,
            type: icon == 'star'
                ? 'surah'
                : (icon == 'fire' || icon == 'fire_gold' ? 'streak' : 'verses'),
            isNew: isNew,
          );
        }).toList();

        achievements.assignAll(mapped);

        // Populate locked achievements lists reactively
        final Set<String> earnedNames = achList
            .map((x) => x['name'] as String? ?? '')
            .toSet();
        final List<LockedAchievement> locked = [];

        final hasFirstSurah = earnedNames.contains("First Surah");
        locked.add(
          LockedAchievement(
            title: "First Surah",
            desc: "Complete your first Surah",
            isUnlocked: hasFirstSurah,
            progressText: hasFirstSurah ? "Earned" : "0/1 Surahs",
          ),
        );

        final has100Verses = earnedNames.contains("100 Verses");
        locked.add(
          LockedAchievement(
            title: "100 Verses",
            desc: "Read a total of 100 verses",
            isUnlocked: has100Verses,
            progressText: has100Verses
                ? "Earned"
                : "${rxCompletedVerses.value}/100 Verses",
          ),
        );

        final has7Day = earnedNames.contains("7 Day Streak");
        locked.add(
          LockedAchievement(
            title: "7 Day Streak",
            desc: "Read for 7 consecutive days",
            isUnlocked: has7Day,
            progressText: has7Day ? "Earned" : "${rxStreakCount.value}/7 Days",
          ),
        );

        final has100Streak = earnedNames.contains("100 Streak");
        locked.add(
          LockedAchievement(
            title: "100 Streak",
            desc: "Read for 100 consecutive days",
            isUnlocked: has100Streak,
            progressText: has100Streak
                ? "Earned"
                : "${rxStreakCount.value}/100 Days",
          ),
        );

        final hasFastClimber = earnedNames.contains("Fast Climber");
        locked.add(
          LockedAchievement(
            title: "Fast Climber",
            desc: "Gained 3 ranks on the leaderboard",
            isUnlocked: hasFastClimber,
            progressText: hasFastClimber ? "Earned" : "Locked",
          ),
        );

        final hasChallenge = earnedNames.contains("Challenge Champion");
        locked.add(
          LockedAchievement(
            title: "Challenge Champion",
            desc: "Complete a weekly challenge",
            isUnlocked: hasChallenge,
            progressText: hasChallenge ? "Earned" : "Locked",
          ),
        );

        lockedAchievements.assignAll(locked);
      }
    } catch (e) {
      debugPrint(
        "ProgressController.fetchProgress API failed, using fallback: $e",
      );
      _setFallbackProgress();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchLeaderboardData() async {
    if (leaderboardTab.value == 'global') {
      // Fetch global leaderboard from backend
      try {
        final response = await _networkService.get('/progress/leaderboard/');
        if (response.statusCode == 200 || response.statusCode == 201) {
          final List<dynamic> entries = response.data ?? [];
          _parseLeaderboardEntries(entries, isGlobal: true);
          rxHasGlobalLeaderboard.value = true;
          return;
        }
      } catch (e) {
        debugPrint(
          "ProgressController.fetchLeaderboardData global failed, using fallback: $e",
        );
      }
      rxHasGlobalLeaderboard.value = false;
      return;
    }

    try {
      final response = await _networkService.get('/community/');
      if (response.statusCode == 200 || response.statusCode == 201) {
        final List<dynamic> commList = response.data['communities'] ?? [];
        final joined = commList.firstWhere(
          (c) => c['is_member'] == true,
          orElse: () => null,
        );
        if (joined != null) {
          final int communityId = joined['id'];
          await _fetchLeaderboardForCommunity(communityId);
          return;
        }
      }
      hasCommunityLeaderboard.value = false;
      rxCommunityPodiumUsers.clear();
      rxCommunityOtherRankings.clear();
    } catch (e) {
      debugPrint(
        "ProgressController.fetchLeaderboardData failed, using fallback: $e",
      );
      hasCommunityLeaderboard.value = false;
      rxCommunityPodiumUsers.clear();
      rxCommunityOtherRankings.clear();
    }
  }

  void _parseLeaderboardEntries(List<dynamic> entries, {bool isGlobal = false}) {
    final List<LeaderboardUser> podium = [];
    LeaderboardUser fallbackUser(int rank) {
      return LeaderboardUser(
        rank: rank,
        name: 'No User',
        verses: '0',
        avatarUrl:
            'https://ui-avatars.com/api/?name=Empty&background=ccc&color=fff&format=png',
      );
    }

    final filteredEntries = entries.where((entry) {
      final userObj = entry['user'] ?? {};
      final username = userObj['username'] as String? ?? '';
      return username.toLowerCase() != 'admin';
    }).toList();

    LeaderboardUser? user1;
    LeaderboardUser? user2;
    LeaderboardUser? user3;

    if (filteredEntries.isNotEmpty) {
      final first = filteredEntries[0];
      final userObj = first['user'] ?? {};
      final username = userObj['username'] as String? ?? 'User';
      final points = first['points'] as int? ?? 0;
      final photo = _resolvePhotoUrl(userObj['photo'], username, background: '06402B', color: 'fff');
      user1 = LeaderboardUser(
        rank: 1,
        name: username,
        verses: points.toString(),
        avatarUrl: photo,
      );
    }

    if (filteredEntries.length > 1) {
      final second = filteredEntries[1];
      final userObj = second['user'] ?? {};
      final username = userObj['username'] as String? ?? 'User';
      final points = second['points'] as int? ?? 0;
      final photo = _resolvePhotoUrl(userObj['photo'], username, background: '0D5C3A', color: 'fff');
      user2 = LeaderboardUser(
        rank: 2,
        name: username,
        verses: points.toString(),
        avatarUrl: photo,
      );
    }

    if (filteredEntries.length > 2) {
      final third = filteredEntries[2];
      final userObj = third['user'] ?? {};
      final username = userObj['username'] as String? ?? 'User';
      final points = third['points'] as int? ?? 0;
      final photo = _resolvePhotoUrl(userObj['photo'], username, background: 'EFBF04', color: '000');
      user3 = LeaderboardUser(
        rank: 3,
        name: username,
        verses: points.toString(),
        avatarUrl: photo,
      );
    }

    podium.add(user2 ?? fallbackUser(2)); // Left column on podium is Rank 2
    podium.add(user1 ?? fallbackUser(1)); // Center column on podium is Rank 1
    podium.add(user3 ?? fallbackUser(3)); // Right column on podium is Rank 3

    rxGlobalPodiumUsers.assignAll(podium);

    final List<LeaderboardRow> other = [];
    final authRepository = Get.find<AuthRepository>();
    final currentUsername =
        authRepository.currentUser.value?.username ?? '';

    for (int i = 3; i < filteredEntries.length; i++) {
      final entry = filteredEntries[i];
      final userObj = entry['user'] ?? {};
      final username = userObj['username'] as String? ?? 'User';
      final points = entry['points'] as int? ?? 0;
      final photo = _resolvePhotoUrl(userObj['photo'], username);

      final isMe = username == currentUsername;

      other.add(
        LeaderboardRow(
          rank: i + 1,
          name: isMe ? 'You' : username,
          sub: '$points points',
          score: points,
          isHighlighted: isMe,
          avatarUrl: photo,
        ),
      );
    }

    rxGlobalOtherRankings.assignAll(other);
  }

  Future<void> _fetchLeaderboardForCommunity(int communityId) async {
    try {
      final response = await _networkService.get(
        '/community/leaderboard/',
        queryParameters: {'community': communityId},
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final List<dynamic> entries = response.data ?? [];
        final filteredEntries = entries.where((entry) {
          final userObj = entry['user'] ?? {};
          final username = userObj['username'] as String? ?? '';
          return username.toLowerCase() != 'admin';
        }).toList();

        final List<LeaderboardUser> podium = [];
        LeaderboardUser fallbackUser(int rank) {
          return LeaderboardUser(
            rank: rank,
            name: rank == 2 ? 'No Member' : (rank == 3 ? 'No Member' : 'Owner'),
            verses: '0',
            avatarUrl:
                'https://ui-avatars.com/api/?name=Empty&background=ccc&color=fff&format=png',
          );
        }

        LeaderboardUser? user1;
        LeaderboardUser? user2;
        LeaderboardUser? user3;

        if (filteredEntries.isNotEmpty) {
          final first = filteredEntries[0];
          final userObj = first['user'] ?? {};
          final username = userObj['username'] as String? ?? 'User';
          final points = first['points'] as int? ?? 0;
          final photo = _resolvePhotoUrl(userObj['photo'], username, background: '06402B', color: 'fff');
          user1 = LeaderboardUser(
            rank: 1,
            name: username,
            verses: points.toString(),
            avatarUrl: photo,
          );
        }

        if (filteredEntries.length > 1) {
          final second = filteredEntries[1];
          final userObj = second['user'] ?? {};
          final username = userObj['username'] as String? ?? 'User';
          final points = second['points'] as int? ?? 0;
          final photo = _resolvePhotoUrl(userObj['photo'], username, background: '0D5C3A', color: 'fff');
          user2 = LeaderboardUser(
            rank: 2,
            name: username,
            verses: points.toString(),
            avatarUrl: photo,
          );
        }

        if (filteredEntries.length > 2) {
          final third = filteredEntries[2];
          final userObj = third['user'] ?? {};
          final username = userObj['username'] as String? ?? 'User';
          final points = third['points'] as int? ?? 0;
          final photo = _resolvePhotoUrl(userObj['photo'], username, background: 'EFBF04', color: '000');
          user3 = LeaderboardUser(
            rank: 3,
            name: username,
            verses: points.toString(),
            avatarUrl: photo,
          );
        }

        podium.add(user2 ?? fallbackUser(2)); // Left column on podium is Rank 2
        podium.add(
          user1 ?? fallbackUser(1),
        ); // Center column on podium is Rank 1
        podium.add(
          user3 ?? fallbackUser(3),
        ); // Right column on podium is Rank 3

        rxCommunityPodiumUsers.assignAll(podium);

        final List<LeaderboardRow> other = [];
        final authRepository = Get.find<AuthRepository>();
        final currentUsername =
            authRepository.currentUser.value?.username ?? '';

        for (int i = 3; i < filteredEntries.length; i++) {
          final entry = filteredEntries[i];
          final userObj = entry['user'] ?? {};
          final username = userObj['username'] as String? ?? 'User';
          final points = entry['points'] as int? ?? 0;
          final photo = _resolvePhotoUrl(userObj['photo'], username);

          final isMe = username == currentUsername;

          other.add(
            LeaderboardRow(
              rank: i + 1,
              name: isMe ? 'You' : username,
              sub: '$points points read',
              score: points,
              isHighlighted: isMe,
              avatarUrl: photo,
            ),
          );
        }

        rxCommunityOtherRankings.assignAll(other);
        hasCommunityLeaderboard.value = true;
      }
    } catch (e) {
      debugPrint("ProgressController._fetchLeaderboardForCommunity failed: $e");
      hasCommunityLeaderboard.value = false;
    }
  }

  void _setFallbackProgress() {
    final filter = selectedFilter.value;
    if (filter == 'weekly') {
      rxSurahsCount.value = 8;
      rxHoursCount.value = 14.0;
      rxStreakCount.value = 3;
      rxCompletedVerses.value = 15420;
      rxGoalVerses.value = 20000;
      growthPercentage.value = "+15%";
      rxActivityBarHeights.assignAll([
        0.60,
        0.80,
        0.30,
        0.90,
        0.70,
        0.40,
        0.50,
      ]);
      rxActivityBarLabels.assignAll(['M', 'T', 'W', 'T', 'F', 'S', 'S']);
      rxActivitySummaryText.value = "read_summary_weekly";
    } else if (filter == 'monthly') {
      rxSurahsCount.value = 24;
      rxHoursCount.value = 56.0;
      rxStreakCount.value = 15;
      rxCompletedVerses.value = 48500;
      rxGoalVerses.value = 60000;
      growthPercentage.value = "+22%";
      rxActivityBarHeights.assignAll([0.70, 0.90, 0.50, 0.85]);
      rxActivityBarLabels.assignAll(['W1', 'W2', 'W3', 'W4']);
      rxActivitySummaryText.value = "read_summary_monthly";
    } else {
      rxSurahsCount.value = 2;
      rxHoursCount.value = 3.0;
      rxStreakCount.value = 1;
      rxCompletedVerses.value = 4862;
      rxGoalVerses.value = 6236;
      growthPercentage.value = "+12%";
      rxActivityBarHeights.assignAll([
        0.30,
        0.50,
        0.80,
        0.40,
        0.20,
        0.90,
        0.60,
      ]);
      rxActivityBarLabels.assignAll([
        '6AM',
        '9AM',
        '12PM',
        '2PM',
        '5PM',
        '7PM',
        'Now',
      ]);
      rxActivitySummaryText.value = "read_summary_daily";
    }

    rxMonthlyGoalPercent.value = 0.60;
    rxMonthlyGoalCompleted.value = 6;
    rxMonthlyGoalTotal.value = 10;
    rxMonthlyGoalTitle.value = "June Goal";
    rxMonthlyGoalDesc.value = "Complete 10 Surahs";

    rxHasRecentSurah.value = true;
    rxRecentSurahs.assignAll([
      {
        'id': 67,
        'title': 'Surah Al-Mulk',
        'english_name': 'Al-Mulk',
        'verses_read': 22,
        'total_verses': 30,
      },
      {
        'id': 1,
        'title': 'Surah Al-Fatihah',
        'english_name': 'Al-Fatihah',
        'verses_read': 7,
        'total_verses': 7,
      },
    ]);
    rxRecentSurahId.value = 67;
    rxRecentSurahTitle.value = 'Surah Al-Mulk';
    rxRecentSurahVersesRead.value = 22;
    rxRecentSurahTotalVerses.value = 30;
    rxHasCompletedSurah.value = false;

    rxChallengePercent.value = 0.68;
    rxChallengeCompleted.value = 34;
    rxChallengeTotal.value = 50;
    rxChallengeDesc.value = "Read 50 verses to climb up the ranks.";

    achievements.assignAll([
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
    ]);
  }

  void _setFallbackLeaderboard() {
    lockedAchievements.assignAll([
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
    ]);
  }

  List<LeaderboardUser> _getMockPodiumUsers() {
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

  List<LeaderboardRow> _getMockOtherRankings() {
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
