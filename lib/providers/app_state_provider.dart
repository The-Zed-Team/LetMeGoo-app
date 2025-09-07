import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:letmegoo/providers/user_provider.dart';
import 'package:letmegoo/providers/vehicle_provider.dart';

// Global app state management
class AppStateNotifier extends StateNotifier<bool> {
  AppStateNotifier() : super(false);

  void logout(WidgetRef ref) {
    // Clear user data
    ref.read(userProvider.notifier).clearUserData();
    
    // Clear vehicle data
    ref.read(vehicleProvider.notifier).clearVehicles();
    
    // Reset app state
    state = false;
  }

  void setLoggedIn() {
    state = true;
  }
}

final appStateProvider = StateNotifierProvider<AppStateNotifier, bool>((ref) {
  return AppStateNotifier();
});

// Auto-refresh providers
final autoRefreshUserProvider = StreamProvider.autoDispose<UserState>((ref) async* {
  final userNotifier = ref.watch(userProvider.notifier);
  final userState = ref.watch(userProvider);
  
  // Auto-refresh if data is stale and not currently loading
  if (userState.isDataStale && !userState.isLoading && userState.userData != null) {
    await userNotifier.loadUserData();
  }
  
  yield userState;
});

final autoRefreshVehicleProvider = StreamProvider.autoDispose<VehicleState>((ref) async* {
  final vehicleNotifier = ref.watch(vehicleProvider.notifier);
  final vehicleState = ref.watch(vehicleProvider);
  
  // Auto-refresh if data is stale and not currently loading
  if (vehicleState.isDataStale && !vehicleState.isLoading && vehicleState.vehicles.isNotEmpty) {
    await vehicleNotifier.loadVehicles();
  }
  
  yield vehicleState;
});
