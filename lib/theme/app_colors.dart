import 'package:flutter/material.dart';

// WHY a class with private constructor?
// → Prevents anyone from doing AppColors()
// → It's a namespace, not an object
// → All values are static = accessed without instance

class AppColors {
  AppColors._(); // private constructor

  // ── Backgrounds ───────────────────────────────
  // These go from darkest to lightest
  // Think of it as elevation levels
  static const background  = Color(0xFF0D0D0D); // screen bg
  static const surface     = Color(0xFF1A1A1A); // cards
  static const surfaceHigh = Color(0xFF252525); // elevated cards

  // ── Brand Color ───────────────────────────────
  // The amber/orange you see on all buttons
  static const primary      = Color(0xFFF5A623);
  static const primaryDark  = Color(0xFFD4891A); // pressed state

  // ── Text ─────────────────────────────────────
  static const textPrimary   = Color(0xFFFFFFFF); // headings
  static const textSecondary = Color(0xFF9CA3AF); // subtitles
  static const textHint      = Color(0xFF6B7280); // placeholders

  // ── Utility ───────────────────────────────────
  static const divider = Color(0xFF2A2A2A); // thin lines
  static const error   = Color(0xFFEF4444); // red errors
  static const success = Color(0xFF22C55E); // green success

  // ── Special ───────────────────────────────────
  // Used for image overlays so text is readable
  static const imageOverlay = Color(0x80000000); // 50% black
}