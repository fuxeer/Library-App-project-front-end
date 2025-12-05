import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:library_app/repositroy/UserRepository.dart';
import '../model/User.dart';

// 1️⃣ User state notifier
class CurrentUserNotifier extends StateNotifier<User?> {
  final UserRepository _repo;

  CurrentUserNotifier(this._repo) : super(null);

  // Set user after login
  void setUser(User user) {
    state = user;
  }

  // Update any field using copyWith
  void update({
    String? name,
    String? userName,
    String? password,
    String? email,
    String? dateOfBirth,
    String? gender,
    int? phoneNo,
    String? address,
    String? userType,
  }) {
    if (state == null) return;
    state = state!.copyWith(
      name: name,
      userName: userName,
      password: password,
      email: email,
      dateOfBirth: dateOfBirth,
      gender: gender,
      phoneNo: phoneNo,
      address: address,
      userType: userType,
    );
  }

  // Clear user on logout
  void clear() {
    state = null;
  }

  // Login function calling repository
  Future<bool> login(String username, String password) async {
    final user = await _repo.GetUser(username, password);
    if (user != null) {
      setUser(user);
      return true;
    }
    return false;
  }
}

// 2️⃣ Provider for repository
final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository();
});

// 3️⃣ Provider for current user
final currentUserProvider = StateNotifierProvider<CurrentUserNotifier, User?>(
  (ref) => CurrentUserNotifier(ref.read(userRepositoryProvider)),
);

// 4️⃣ Extension for copyWith in User model
extension UserCopyWith on User {
  User copyWith({
    int? userID,
    String? name,
    String? userName,
    String? password,
    String? email,
    String? dateOfBirth,
    String? gender,
    int? phoneNo,
    String? address,
    String? userType,
  }) {
    return User(
      userID: userID ?? this.userID,
      name: name ?? this.name,
      userName: userName ?? this.userName,
      password: password ?? this.password,
      email: email ?? this.email,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      phoneNo: phoneNo ?? this.phoneNo,
      address: address ?? this.address,
      userType: userType ?? this.userType,
    );
  }
}
