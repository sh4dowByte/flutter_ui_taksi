import 'dart:convert';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

Future<List<LatLng>> getRoute(LatLng origin, LatLng destination) async {
  const String apiKey = 'YOUR_MAPS_API_KEY'; // Masukkan API Key Anda
  final String url =
      'https://maps.googleapis.com/maps/api/directions/json?origin=${origin.latitude},${origin.longitude}&destination=${destination.latitude},${destination.longitude}&key=$apiKey';

  final response = await http.get(Uri.parse(url));
  if (response.statusCode == 200) {
    final Map<String, dynamic> data = json.decode(response.body);
    final List<dynamic> steps = data['routes'][0]['legs'][0]['steps'];

    // Ekstrak polylines dari setiap langkah
    List<LatLng> polylineCoordinates = [];
    for (var step in steps) {
      final polyline = decodePolyline(step['polyline']['points']);
      polylineCoordinates.addAll(polyline);
    }

    return polylineCoordinates;
  } else {
    throw Exception('Failed to fetch directions');
  }
}

// Decode polyline
List<LatLng> decodePolyline(String encoded) {
  List<LatLng> polyline = [];
  int index = 0, len = encoded.length;
  int lat = 0, lng = 0;

  while (index < len) {
    int b, shift = 0, result = 0;
    do {
      b = encoded.codeUnitAt(index++) - 63;
      result |= (b & 0x1f) << shift;
      shift += 5;
    } while (b >= 0x20);
    int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
    lat += dlat;

    shift = 0;
    result = 0;
    do {
      b = encoded.codeUnitAt(index++) - 63;
      result |= (b & 0x1f) << shift;
      shift += 5;
    } while (b >= 0x20);
    int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
    lng += dlng;

    polyline.add(LatLng(lat / 1E5, lng / 1E5));
  }
  return polyline;
}
