import 'package:flutter/foundation.dart';
import 'package:kidstube/providers/video_provider.dart';

class MockVideoProvider extends VideoProvider {
  @override
  Future<void> init() async {
    // Skip real scanning in tests
  }
}
