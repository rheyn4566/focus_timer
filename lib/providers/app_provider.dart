import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _keyOnboardingComplete = 'onboarding_complete';

class AppProvider extends ChangeNotifier {
  bool _onboardingComplete = false;
  bool _isLoading = true;

  bool get onboardingComplete => _onboardingComplete;
  bool get isLoading => _isLoading;

  AppProvider() {
    _loadOnboardingState();
  }

  Future<void> _loadOnboardingState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _onboardingComplete = prefs.getBool(_keyOnboardingComplete) ?? false;
    } catch (_) {
      _onboardingComplete = false;
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyOnboardingComplete, true);
    _onboardingComplete = true;
    notifyListeners();
  }
}
