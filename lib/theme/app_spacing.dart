import 'package:flutter/material.dart';

// WHY a spacing system?
// → Consistency. Everything uses multiples of 4px.
// → 4, 8, 12, 16, 24, 32, 48
// → This is how EVERY professional design system works
// → (Material Design, Apple HIG, Tailwind CSS — all do this)

class AppSpacing {
  AppSpacing._();

  static const double xs  = 4.0;
  static const double sm  = 8.0;
  static const double md  = 16.0;
  static const double lg  = 24.0;
  static const double xl  = 32.0;
  static const double xxl = 48.0;

  // ── Pre-built SizedBox gaps ───────────────────
  // WHY? So you write gapMD instead of SizedBox(height:16)
  // Saves typing, stays consistent

  // Vertical gaps
  static const gapXS = SizedBox(height: xs);
  static const gapSM = SizedBox(height: sm);
  static const gapMD = SizedBox(height: md);
  static const gapLG = SizedBox(height: lg);
  static const gapXL = SizedBox(height: xl);

  // Horizontal gaps
  static const hGapXS = SizedBox(width: xs);
  static const hGapSM = SizedBox(width: sm);
  static const hGapMD = SizedBox(width: md);
  static const hGapLG = SizedBox(width: lg);

  // ── Common Padding presets ────────────────────
  static const EdgeInsets screen  = 
    EdgeInsets.symmetric(horizontal: md);

  static const EdgeInsets card    = EdgeInsets.all(md);

  static const EdgeInsets cardH   = 
    EdgeInsets.symmetric(horizontal: md, vertical: sm);
}