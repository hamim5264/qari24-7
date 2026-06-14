import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart' as dio;
import '../../../core/constants/app_colors.dart';
import '../../../core/services/network_service.dart';
import '../../auth/repositories/auth_repository.dart';

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
  final RxString name;
  final RxString description;
  final RxString photoUrl;
  final File? localImage;
  final RxInt memberCount;
  final RxString status;
  final RxBool isOwner;
  final String rank;
  final RxList<MemberModel> members;

  CommunityModel({
    required this.id,
    required String name,
    required String description,
    required String photoUrl,
    this.localImage,
    required int memberCount,
    required String status,
    required bool isOwner,
    required this.rank,
    List<MemberModel>? members,
  }) : name = name.obs,
       description = description.obs,
       photoUrl = photoUrl.obs,
       memberCount = memberCount.obs,
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

  late final NetworkService _networkService;

  @override
  void onInit() {
    super.onInit();
    _networkService = Get.find<NetworkService>();
    fetchCommunities();
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

  Future<void> fetchCommunities() async {
    isLoading.value = true;
    try {
      final response = await _networkService.get('/community/');
      if (response.statusCode == 200 || response.statusCode == 201) {
        final List<dynamic> commsData = response.data['communities'] ?? [];
        final List<CommunityModel> exploreList = [];
        final List<CommunityModel> joinedList = [];

        final currentUsername = Get.isRegistered<AuthRepository>()
            ? Get.find<AuthRepository>().currentUser.value?.username ?? ''
            : '';

        for (var json in commsData) {
          final idVal = json['id'].toString();
          final nameVal = json['name'] as String? ?? 'Community';
          final descVal = json['description'] as String? ?? '';
          final ownerObj = json['owner'] ?? {};
          final ownerName = ownerObj['username'] as String? ?? '';
          final isOwnerVal =
              json['is_owner'] as bool? ?? (ownerName == currentUsername);
          final isMemberVal = json['is_member'] as bool? ?? false;
          final memberCountVal = json['member_count'] as int? ?? 1;

          final List<dynamic> membersData = json['members'] ?? [];
          final List<MemberModel> mappedMembers = membersData.map((m) {
            final mUsername = m['username'] as String? ?? '';
            var photo = m['photo'] as String? ?? '';
            if (photo.isNotEmpty && !photo.startsWith('http://') && !photo.startsWith('https://')) {
              photo = "https://quran-app-backend-8b57.onrender.com${photo.startsWith('/') ? photo : '/$photo'}";
            }
            final isCurrent = mUsername == currentUsername;
            return MemberModel(
              name: isCurrent ? '$mUsername (You)' : mUsername,
              avatarUrl: photo.isNotEmpty
                  ? photo
                  : 'https://ui-avatars.com/api/?name=$mUsername&background=random&format=png',
              role: mUsername == ownerName ? 'Owner' : 'Member',
              isCurrentUser: isCurrent,
            );
          }).toList();

          if (!mappedMembers.any(
            (m) => m.name.replaceAll(' (You)', '') == ownerName,
          )) {
            mappedMembers.insert(
              0,
              MemberModel(
                name: ownerName == currentUsername
                    ? '$ownerName (You)'
                    : ownerName,
                avatarUrl:
                    'https://ui-avatars.com/api/?name=$ownerName&background=random&format=png',
                role: 'Owner',
                isCurrentUser: ownerName == currentUsername,
              ),
            );
          }

           var photoUrl = json['photo'] as String? ?? '';
          if (photoUrl.isNotEmpty) {
            if (!photoUrl.startsWith('http://') && !photoUrl.startsWith('https://')) {
              photoUrl = "https://quran-app-backend-8b57.onrender.com${photoUrl.startsWith('/') ? photoUrl : '/$photoUrl'}";
            }
          } else {
            photoUrl = 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(nameVal)}&background=0D5C3A&color=fff&format=png';
          }

          final joinRequestStatus = json['join_request_status'] as String? ?? 'none';
          final statusVal = isMemberVal ? 'joined' : (joinRequestStatus == 'pending' ? 'pending' : 'none');

          final comm = CommunityModel(
            id: idVal,
            name: nameVal,
            description: descVal,
            photoUrl: photoUrl,
            memberCount: memberCountVal,
            status: statusVal,
            isOwner: isOwnerVal,
            rank: '12',
            members: mappedMembers,
          );

          if (isMemberVal) {
            joinedList.add(comm);
          } else {
            exploreList.add(comm);
          }
        }

        joinedCommunities.assignAll(joinedList);
        exploreCommunities.assignAll(exploreList);
      }
    } catch (e) {
      debugPrint("CommunityController.fetchCommunities failed: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> joinCommunity(CommunityModel community) async {
    community.status.value = 'pending';
    try {
      final commId = int.tryParse(community.id);
      if (commId == null) return;
      final body = {'community': commId};
      final response = await _networkService.post(
        '/community/join-community/',
        data: body,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar(
          'Community',
          'Join request submitted successfully.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.primary,
          colorText: Colors.white,
        );
        fetchCommunities();
      } else {
        community.status.value = 'none';
        Get.snackbar('Error', 'Failed to submit join request.');
      }
    } catch (e) {
      community.status.value = 'none';
      debugPrint("CommunityController.joinCommunity error: $e");
      Get.snackbar('Error', 'An error occurred: $e');
    }
  }

  Future<void> cancelJoinRequest(CommunityModel community) async {
    try {
      final commId = int.tryParse(community.id);
      if (commId == null) return;
      final body = {'community': commId};
      final response = await _networkService.delete(
        '/community/join-community/',
        data: body,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        community.status.value = 'none';
        Get.snackbar(
          'Community',
          'Join request for ${community.name.value} cancelled.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.grey.shade800,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
        fetchCommunities();
      } else {
        Get.snackbar('Error', 'Failed to cancel join request.');
      }
    } catch (e) {
      debugPrint("CommunityController.cancelJoinRequest error: $e");
      Get.snackbar('Error', 'An error occurred: $e');
    }
  }

  Future<void> leaveCommunity(CommunityModel community) async {
    try {
      final commId = int.tryParse(community.id);
      if (commId == null) return;
      final body = {'community': commId};
      final response = await _networkService.post(
        '/community/leave-community/',
        data: body,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        community.status.value = 'none';
        joinedCommunities.remove(community);
        if (!exploreCommunities.contains(community)) {
          exploreCommunities.add(community);
        }
        Get.snackbar(
          'Community',
          'You have left ${community.name.value}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange.shade800,
          colorText: Colors.white,
        );
        fetchCommunities();
      } else {
        Get.snackbar('Error', 'Failed to leave community.');
      }
    } catch (e) {
      debugPrint("CommunityController.leaveCommunity error: $e");
      Get.snackbar('Error', 'An error occurred: $e');
    }
  }

  Future<void> deleteCommunity(CommunityModel community) async {
    try {
      final commId = int.tryParse(community.id);
      if (commId == null) return;
      final body = {'community': commId};
      final response = await _networkService.post(
        '/community/delete-community/',
        data: body,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        joinedCommunities.remove(community);
        exploreCommunities.remove(community);
        Get.snackbar(
          'Community',
          'Community "${community.name.value}" deleted successfully.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.error,
          colorText: Colors.white,
        );
        fetchCommunities();
      } else {
        Get.snackbar('Error', 'Failed to delete community.');
      }
    } catch (e) {
      debugPrint("CommunityController.deleteCommunity error: $e");
      Get.snackbar('Error', 'An error occurred: $e');
    }
  }

  void clearFields() {
    nameController.clear();
    descController.clear();
    selectedImage.value = null;
  }

  Future<void> createCommunity() async {
    final name = nameController.text.trim();
    final desc = descController.text.trim();

    if (name.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter a community name',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;
    try {
      dynamic payload;
      if (selectedImage.value != null) {
        final file = selectedImage.value!;
        payload = dio.FormData.fromMap({
          'name': name,
          'description': desc.isEmpty ? 'No description provided.' : desc,
          'photo': await dio.MultipartFile.fromFile(
            file.path,
            filename: file.path.split('/').last,
          ),
        });
      } else {
        payload = {
          'name': name,
          'description': desc.isEmpty ? 'No description provided.' : desc,
        };
      }

      final response = await _networkService.post(
        '/community/create-community/',
        data: payload,
      );
      isLoading.value = false;

      if (response.statusCode == 200 || response.statusCode == 201) {
        clearFields();

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
        fetchCommunities();
      } else {
        Get.snackbar('Error', 'Failed to create community.');
      }
    } catch (e) {
      isLoading.value = false;
      debugPrint("CommunityController.createCommunity error: $e");
      Get.snackbar('Error', 'An error occurred: $e');
    }
  }

  Future<bool> updateCommunity(CommunityModel community) async {
    final name = nameController.text.trim();
    final desc = descController.text.trim();

    if (name.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter a community name',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
      return false;
    }

    isLoading.value = true;
    try {
      dynamic payload;
      if (selectedImage.value != null) {
        final file = selectedImage.value!;
        payload = dio.FormData.fromMap({
          'name': name,
          'description': desc.isEmpty ? 'No description provided.' : desc,
          'photo': await dio.MultipartFile.fromFile(
            file.path,
            filename: file.path.split('/').last,
          ),
        });
      } else {
        payload = dio.FormData.fromMap({
          'name': name,
          'description': desc.isEmpty ? 'No description provided.' : desc,
        });
      }

      final response = await _networkService.put(
        '/community/${community.id}/',
        data: payload,
      );
      isLoading.value = false;

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        community.name.value = data['name'] as String? ?? name;
        community.description.value = data['description'] as String? ?? desc;

        var newPhoto = data['photo'] as String? ?? '';
        if (newPhoto.isNotEmpty) {
          if (!newPhoto.startsWith('http://') && !newPhoto.startsWith('https://')) {
            newPhoto = "https://quran-app-backend-8b57.onrender.com${newPhoto.startsWith('/') ? newPhoto : '/$newPhoto'}";
          }
          community.photoUrl.value = newPhoto;
        }

        clearFields();
        fetchCommunities();
        return true;
      } else {
        Get.snackbar('Error', 'Failed to update community.');
        return false;
      }
    } catch (e) {
      isLoading.value = false;
      debugPrint("CommunityController.updateCommunity error: $e");
      Get.snackbar('Error', 'An error occurred: $e');
      return false;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    descController.dispose();
    super.onClose();
  }
}
