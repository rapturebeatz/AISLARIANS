import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../models/profile_model.dart';
import '../data/directory_repository.dart';

final directoryListProvider = StreamProvider<List<ProfileModel>>((ref) {
  return ref.read(directoryRepositoryProvider).streamAllProfiles();
});

final searchQueryProvider = StateProvider<String>((ref) => '');

final selectedDepartmentProvider = StateProvider<String?>((ref) => null);

final selectedYearProvider = StateProvider<int?>((ref) => null);

final filteredDirectoryProvider = Provider<List<ProfileModel>>((ref) {
  final profiles = ref.watch(directoryListProvider).valueOrNull ?? [];
  final query = ref.watch(searchQueryProvider).toLowerCase();
  final department = ref.watch(selectedDepartmentProvider);
  final year = ref.watch(selectedYearProvider);

  return profiles.where((p) {
    if (query.isNotEmpty && !p.fullName.toLowerCase().contains(query)) return false;
    if (department != null && p.department != department) return false;
    if (year != null && p.graduationYear != year) return false;
    return true;
  }).toList();
});

final directoryLoadingProvider = StateProvider<bool>((ref) => false);
