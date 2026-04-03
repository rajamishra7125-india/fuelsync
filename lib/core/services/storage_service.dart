import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';

/// Storage Service - File Upload + Local Preferences
class StorageService {
  final SupabaseClient _supabase;

  StorageService() : _supabase = Supabase.instance.client;

  // ============================================
  // 📸 FILE UPLOAD OPERATIONS
  // ============================================

  Future<String?> uploadProof({
    required File file,
    required String bucket,
    required String folder,
  }) async {
    try {
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}${path.extension(file.path)}';
      final filePath = '$folder/$fileName';

      await _supabase.storage.from(bucket).upload(filePath, file);

      final imageUrl = _supabase.storage.from(bucket).getPublicUrl(filePath);
      return imageUrl;
    } catch (e) {
      debugPrint('Upload error: $e');
      return null;
    }
  }

  // ============================================
  // 🏪 SHOP PREFERENCES (Multi-Company)
  // ============================================

  /// Get current shop ID
  Future<String?> getShopId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('current_shop_id');
  }

  /// Set current shop ID
  Future<void> setShopId(String shopId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('current_shop_id', shopId);
  }

  /// Clear shop ID (logout)
  Future<void> clearShopId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('current_shop_id');
  }

  // ============================================
  // 🔄 SYNC MODE PREFERENCES
  // ============================================

  /// Get current sync mode
  Future<String> getSyncMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('sync_mode') ?? 'offline';
  }

  /// Set sync mode (offline, local, cloud)
  Future<void> setSyncMode(String mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('sync_mode', mode);
  }

  // ============================================
  // 👤 USER PREFERENCES
  // ============================================

  /// Get current user ID
  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('current_user_id');
  }

  /// Set current user ID
  Future<void> setUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('current_user_id', userId);
  }

  /// Get current user role
  Future<String?> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('current_user_role');
  }

  /// Set current user role
  Future<void> setUserRole(String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('current_user_role', role);
  }

  // ============================================
  // 🎯 ONBOARDING STATUS
  // ============================================

  /// Check if onboarding is completed
  Future<bool> isOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('onboarding_complete') ?? false;
  }

  /// Mark onboarding as complete
  Future<void> setOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);
  }

  // ============================================
  // 🧹 CLEAR ALL DATA
  // ============================================

  /// Clear all stored preferences
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
