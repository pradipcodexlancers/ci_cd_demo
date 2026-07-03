import '../utils/import_to_export.dart';

/// Poppins text-style helpers used throughout the app instead of raw
/// `TextStyle(...)` calls, so every screen shares one consistent font
/// (Google Fonts' Poppins) and a fixed set of weights.
///
/// Usage: `Text('Hello', style: semiboldPoppins(16))`.

// Poppins - regular weight (400). Used for body text, subtitles, hints.
TextStyle regularPoppins(double fontSize, {Color textColor = AppColors.blackColor}) {
  return GoogleFonts.poppins(color: textColor, fontSize: fontSize, fontWeight: FontWeight.w400);
}

// Poppins - medium weight (500). Used for labels and secondary emphasis.
TextStyle mediumPoppins(double fontSize, {Color textColor = AppColors.blackColor}) {
  return GoogleFonts.poppins(color: textColor, fontSize: fontSize, fontWeight: FontWeight.w500);
}

// Poppins - semibold weight (600). Used for card titles, buttons.
TextStyle semiboldPoppins(double fontSize, {Color textColor = AppColors.blackColor}) {
  return GoogleFonts.poppins(color: textColor, fontSize: fontSize, fontWeight: FontWeight.w600);
}

// Poppins - bold weight (700). Used for screen titles/headings.
TextStyle boldPoppins(double fontSize, {Color textColor = AppColors.blackColor}) {
  return GoogleFonts.poppins(color: textColor, fontSize: fontSize, fontWeight: FontWeight.w700);
}

// Poppins - caller-supplied weight, for the rare one-off case the presets above don't cover.
TextStyle customPoppins(double fontSize, {Color textColor = AppColors.blackColor, FontWeight? fontWeight}) {
  return GoogleFonts.poppins(color: textColor, fontSize: fontSize, fontWeight: fontWeight);
}
