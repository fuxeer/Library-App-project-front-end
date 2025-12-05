import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:library_app/repositroy/ReservationRepository.dart';

final reservationRepositoryProvider = Provider(
  (ref) => ReservationRepository(),
);
