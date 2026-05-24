import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_colors.dart';

class MemberModel {
  final String name;
  final String avatarUrl;
  final String role;
  final bool isCurrentUser;

  MemberModel({
    required this.name,
    required this.avatarUrl,
    required this.role,
    this.isCurrentUser = false,
  });
}

class CommunityModel {
  final String id;
  final String name;
  final String description;
  final String photoUrl;
  final File? localImage;
  final RxInt memberCount;
  final RxString status;
  final RxBool isOwner;
  final String rank;
  final RxList<MemberModel> members;

  CommunityModel({
    required this.id,
    required this.name,
    required this.description,
    required this.photoUrl,
    this.localImage,
    required int memberCount,
    required String status,
    required bool isOwner,
    required this.rank,
    List<MemberModel>? members,
  }) : memberCount = memberCount.obs,
       status = status.obs,
       isOwner = isOwner.obs,
       members = (members ?? []).obs;
}

class CommunityController extends GetxController {
  var isLoading = false.obs;

  final exploreCommunities = <CommunityModel>[].obs;
  final joinedCommunities = <CommunityModel>[].obs;

  final nameController = TextEditingController();
  final descController = TextEditingController();
  final Rxn<File> selectedImage = Rxn<File>();
  final ImagePicker _picker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    _prepopulateData();
  }

  void _prepopulateData() {
    final defaultMembers = [
      MemberModel(
        name: 'Fatima H.',
        avatarUrl:
            'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&q=80&w=100',
        role: 'Owner',
      ),
      MemberModel(
        name: 'Yusuf T.',
        avatarUrl:
            'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&q=80&w=100',
        role: 'member_since'.trParams({'year': '2024'}),
      ),
      MemberModel(
        name: 'Aisha R.',
        avatarUrl:
            'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&q=80&w=100',
        role: 'member_since'.trParams({'year': '2023'}),
      ),
      MemberModel(
        name: 'Ibrahim S.',
        avatarUrl:
            'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&q=80&w=100',
        role: 'member_since'.trParams({'year': '2020'}),
      ),
    ];

    final readersClub = CommunityModel(
      id: 'readers_club',
      name: 'Readers Club',
      description:
          'Build a space to grow together, share insights, and compete.',
      photoUrl:
          'https://images.unsplash.com/photo-1506880018603-83d5b814b5a6?auto=format&fit=crop&q=80&w=200',
      memberCount: 25,
      status: 'joined',
      isOwner: true,
      rank: '8',
      members: List.from(defaultMembers),
    );

    final huffazGlobal = CommunityModel(
      id: 'huffaz_global',
      name: 'Huffaz Global',
      description:
          'A global network of Quran memorizers revising and reciting together daily.',
      photoUrl:
          'https://images.unsplash.com/photo-1542838132-92c53300491e?auto=format&fit=crop&q=80&w=200',
      memberCount: 3200,
      status: 'joined',
      isOwner: false,
      rank: '3',
      members: List.from(defaultMembers)
        ..add(
          MemberModel(
            name: 'Hamim (You)',
            avatarUrl: '',
            role: 'Member',
            isCurrentUser: true,
          ),
        ),
    );

    joinedCommunities.add(readersClub);
    joinedCommunities.add(huffazGlobal);

    exploreCommunities.add(huffazGlobal);

    final quranReaders = CommunityModel(
      id: 'quran_readers',
      name: 'Quran Readers',
      description: 'Daily recitation and reflection. Open to all levels.',
      photoUrl:
          'https://images.unsplash.com/photo-1516979187457-637abb4f9353?auto=format&fit=crop&q=80&w=200',
      memberCount: 1850,
      status: 'none',
      isOwner: false,
      rank: '12',
      members: List.from(defaultMembers),
    );

    final tajweedMasters = CommunityModel(
      id: 'tajweed_masters',
      name: 'Tajweed Masters',
      description:
          'Focusing on correcting recitation mistakes and perfecting Tashkeel.',
      photoUrl:
          'https://images.unsplash.com/photo-1434030216411-0b793f4b4173?auto=format&fit=crop&q=80&w=200',
      memberCount: 2400,
      status: 'none',
      isOwner: false,
      rank: '5',
      members: List.from(defaultMembers),
    );

    exploreCommunities.addAll([huffazGlobal, quranReaders, tajweedMasters]);
  }

  Future<void> pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 500,
        maxHeight: 500,
      );
      if (pickedFile != null) {
        selectedImage.value = File(pickedFile.path);
        Get.snackbar(
          'Success',
          'Community picture selected successfully!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.primary.withValues(alpha: 0.9),
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to pick image: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.9),
        colorText: Colors.white,
      );
    }
  }

  void removeSelectedImage() {
    selectedImage.value = null;
  }

  void joinCommunity(CommunityModel community) {
    community.status.value = 'pending';
    Get.snackbar(
      'Community',
      'Join request sent to ${community.name}',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.primary,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  void cancelJoinRequest(CommunityModel community) {
    community.status.value = 'none';
    Get.snackbar(
      'Community',
      'Join request for ${community.name} cancelled.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.grey.shade800,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  void leaveCommunity(CommunityModel community) {
    community.status.value = 'none';
    joinedCommunities.remove(community);
    if (!exploreCommunities.contains(community) && community.id != 'new_comm') {
      exploreCommunities.add(community);
    }
    Get.snackbar(
      'Community',
      'You have left ${community.name}',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.orange.shade800,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  void deleteCommunity(CommunityModel community) {
    joinedCommunities.remove(community);
    exploreCommunities.remove(community);
    Get.snackbar(
      'Community',
      'Community "${community.name}" deleted successfully.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.error,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  void createCommunity() {
    if (nameController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter a community name',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
      return;
    }

    final newCommunity = CommunityModel(
      id: 'new_comm_${DateTime.now().millisecondsSinceEpoch}',
      name: nameController.text.trim(),
      description: descController.text.trim().isEmpty
          ? 'No description provided.'
          : descController.text.trim(),
      photoUrl:
          'https://images.unsplash.com/photo-1522071820081-009f0129c71c?auto=format&fit=crop&q=80&w=200',
      localImage: selectedImage.value,
      memberCount: 1,
      status: 'joined',
      isOwner: true,
      rank: '99+',
      members: [
        MemberModel(
          name: 'Hamim (You)',
          avatarUrl: '',
          role: 'Owner',
          isCurrentUser: true,
        ),
      ],
    );

    joinedCommunities.add(newCommunity);

    nameController.clear();
    descController.clear();
    selectedImage.value = null;

    if (Get.isBottomSheetOpen == true) {
      Get.back();
    }

    Get.snackbar(
      'Success',
      'Community created successfully!',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.primary,
      colorText: Colors.white,
    );
  }

  @override
  void onClose() {
    nameController.dispose();
    descController.dispose();
    super.onClose();
  }
}
