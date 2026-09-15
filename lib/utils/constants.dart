import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// ─────────────────────────────────────────────
// API Base URL — points to your XAMPP backend.
// Automatically uses 10.0.2.2 for Android emulator, and localhost for Windows / Web / iOS.
// ─────────────────────────────────────────────
String get kBaseUrl {
  if (kIsWeb) return 'http://localhost/api';
  if (defaultTargetPlatform == TargetPlatform.android) {
    return 'http://10.0.2.2/api';
  }
  return 'http://localhost/api';
}

// shared_preferences key for the auth token
const String kTokenKey = 'auth_token';

/// Central colour palette for the Restaurant App — Dark Theme.
class AppColors {
  // ── Accent / Brand colours (unchanged) ──────────────────────────────────
  static const Color primary = Color(0xFFFF4757);          // Warm coral accent red
  static const Color primaryLight = Color(0xFF3A1218);     // Dark tint of primary for icon backgrounds
  static const Color accentYellow = Color(0xFFFFA502);
  static const Color accentGreen = Color(0xFF2ED573);
  static const Color categorySelected = Color(0xFFFF4757);
  static const Color categorySelectedBorder = Color(0xFFFF4757);
  static const Color ratingStar = Color(0xFFFFA502);
  static const Color success = Color(0xFF2ED573);
  static const Color error = Color(0xFFFF4757);

  // ── Dark theme neutral colours ────────────────────────────────────────────
  static const Color background = Color(0xFF121212);       // Near-black screen bg
  static const Color cardBackground = Color(0xFF1E1E1E);   // Slightly lighter dark card
  static const Color surfaceVariant = Color(0xFF2A2A2A);   // Inputs, pills, qty controls
  static const Color textPrimary = Color(0xFFF1F1F1);      // Near-white primary text
  static const Color textSecondary = Color(0xFF9E9E9E);    // Medium grey secondary text
  static const Color border = Color(0xFF2E2E2E);           // Subtle dark border
  static const Color iconCircle = Color(0xFF2A2A2A);       // Dark grey for icon circle backgrounds
}

/// All Restaurant REST API endpoints — paths relative to [kBaseUrl].
class ApiEndpoints {
  // Auth
  static const String login     = '/login';
  static const String register  = '/register';
  static const String logout    = '/logout';
  static const String user      = '/user';

  // Restaurant Data
  static const String categories = '/categories';
  static const String banners    = '/banners';
  static const String menuItems  = '/menu-items';
  static String menuItemById(dynamic id) => '/menu-items/$id';
  
  // Legacy aliases
  static const String products   = '/menu-items';
  static String productById(dynamic id) => '/menu-items/$id';

  // Cart
  static const String cart            = '/cart';
  static String cartItem(dynamic id)  => '/cart/$id';

  // Favorites
  static const String favorites              = '/favorites';
  static String favoriteItem(dynamic id)    => '/favorites/$id';
  static const String wishlist               = '/favorites';
  static String wishlistItem(dynamic id)     => '/favorites/$id';

  // Addresses
  static const String addresses              = '/addresses';
  static String addressById(dynamic id)      => '/addresses/$id';

  // Orders
  static const String orders                 = '/orders';
  static String orderById(dynamic id)        => '/orders/$id';
}
