// Fungsi untuk menentukan Brightness dari warna
import 'dart:ui';

Brightness getBrightness(Color color) {
  // Menghitung kecerahan berdasarkan rumus untuk brightness
  double brightness =
      (color.red * 299 + color.green * 587 + color.blue * 114) / 1000;
  return brightness > 180 ? Brightness.light : Brightness.dark;
}

Color hexToColor(String hexColor) {
  // Ensure the hex string starts with '0xFF' for full opacity
  return Color(int.parse('0xFF$hexColor'));
}
