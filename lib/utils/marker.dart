import 'dart:ui';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

Future<BitmapDescriptor> getResizedIcon(String path, double size) async {
  // Memuat gambar dari aset
  final ByteData data = await rootBundle.load(path);
  final List<int> bytes = data.buffer.asUint8List();
  final ui.Image image = await decodeImageFromList(Uint8List.fromList(bytes));

  // Resize gambar sambil mempertahankan aspek rasio
  final ui.Image resizedImage = await _resizeImageWithAspectRatio(image, size);

  // Mengonversi gambar yang sudah di-resize menjadi BitmapDescriptor
  final ByteData? byteData =
      await resizedImage.toByteData(format: ui.ImageByteFormat.png);
  final Uint8List resizedBytes = byteData!.buffer.asUint8List();

  // ignore: deprecated_member_use
  return BitmapDescriptor.fromBytes(resizedBytes);
}

Future<ui.Image> _resizeImageWithAspectRatio(
    ui.Image image, double size) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, size, size));
  final paint = Paint()..filterQuality = FilterQuality.high;

  // Menentukan skala untuk mempertahankan aspek rasio
  final double originalWidth = image.width.toDouble();
  final double originalHeight = image.height.toDouble();
  final double aspectRatio = originalWidth / originalHeight;

  double targetWidth;
  double targetHeight;

  if (aspectRatio > 1) {
    // Gambar lebih lebar daripada tinggi
    targetWidth = size;
    targetHeight = size / aspectRatio;
  } else {
    // Gambar lebih tinggi daripada lebar
    targetWidth = size * aspectRatio;
    targetHeight = size;
  }

  // Menempatkan gambar di tengah kanvas
  final double offsetX = (size - targetWidth) / 2;
  final double offsetY = (size - targetHeight) / 2;

  // Gambar ulang gambar dengan ukuran baru
  canvas.drawImageRect(
    image,
    Rect.fromLTWH(0, 0, originalWidth, originalHeight), // Gambar asli
    Rect.fromLTWH(
        offsetX, offsetY, targetWidth, targetHeight), // Gambar yang di-resize
    paint,
  );

  final picture = recorder.endRecording();
  return await picture.toImage(size.toInt(), size.toInt());
}
