import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:library_app/repositroy/ReservationRepository.dart';
import 'CurrentUser_provider.dart';

final reservationHistoryProvider = FutureProvider<Map<String, dynamic>>((
  ref,
) async {
  final user = ref.watch(currentUserProvider);
  if (user == null || user.userID == null) {
    return {};
  }

  final repo = ReservationRepository();
  return repo.getUserHistory(user.userID!);
});
