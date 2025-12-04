import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

class ProfileState {
  final Uint8List? profilePic;
  final String name;

  const ProfileState({this.profilePic, this.name = "No name"});

  ProfileState copyWith({Uint8List? profilePic, String? name}) => ProfileState(
    profilePic: profilePic ?? this.profilePic,
    name: name ?? this.name,
  );
}

class ProfileNotifier extends StateNotifier<ProfileState> {
  ProfileNotifier() : super(const ProfileState());

  void updatePicture(Uint8List? img) => state = state.copyWith(profilePic: img);

  void updateName(String name) => state = state.copyWith(name: name);
}

final profileProvider = StateNotifierProvider((ref) {
  return ProfileNotifier();
});
