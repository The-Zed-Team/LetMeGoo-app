import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:letmegoo/core/network/network_info.dart';

part 'injection_container.g.dart';

/// Network info provider
@riverpod
NetworkInfo networkInfo(Ref ref) {
  return NetworkInfoImpl();
}
