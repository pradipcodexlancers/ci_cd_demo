// Barrel file - re-exports the packages/files used almost everywhere
// (Material widgets, GetX, Google Fonts, and our app colors) so other
// files only need a single `import '.../import_to_export.dart';` instead
// of repeating the same four imports over and over.
export 'package:flutter/material.dart';
export 'package:get/get.dart';
export 'package:google_fonts/google_fonts.dart';

export '../constants/app_colors.dart';
