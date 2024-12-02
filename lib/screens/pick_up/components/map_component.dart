import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../utils/marker.dart';

class MapComponent extends StatefulWidget {
  final Function(LatLng, String)? onDragMyPosition;
  final Function(LatLng, String)? onDragDestinatePosition;
  const MapComponent(
      {super.key, this.onDragMyPosition, this.onDragDestinatePosition});

  // Menambahkan GlobalKey untuk mengakses state widget ini dari luar
  // ignore: library_private_types_in_public_api
  static final GlobalKey<_MapComponentState> mapComponentKey =
      GlobalKey<_MapComponentState>();

  @override
  State<MapComponent> createState() => _MapComponentState();
}

class _MapComponentState extends State<MapComponent> {
  late GoogleMapController mapController;
  final LatLng _initialMarkerPosition = const LatLng(-3.009420, 114.388659);

  Set<Marker> _markers = {};
  String? _mapStyle;
  bool myLocationInit = false;
  double iconSize = 100;
  double _mapRotation = 0.0;

  void _updateMarkerRotation(double newRotation) {
    setState(() {
      _markers = _markers.map((marker) {
        if (marker.markerId == const MarkerId('riderMarker')) {
          // Sesuaikan rotasi marker
          return marker.copyWith(rotationParam: 360 - newRotation + 130);
        }
        return marker;
      }).toSet();
    });
  }

  @override
  void initState() {
    super.initState();
    _loadMapStyle();
  }

  void _onMapCreated(GoogleMapController controller) async {
    mapController = controller;
  }

  Future<void> _loadMapStyle() async {
    _mapStyle = await DefaultAssetBundle.of(context)
        .loadString('assets/map_style.json');
    setState(() {});
  }

  void addMarker({double iconSize = 100.0}) async {
    final BitmapDescriptor customIcon = await getResizedIcon(
      'assets/marker/marker-pin-white.png', // Path gambar ikon
      iconSize, // Ukuran ikon
    );

    setState(() {
      myLocationInit = true;
      _markers.add(
        Marker(
          markerId: const MarkerId('myLocationMarker'),
          position: _initialMarkerPosition,
          icon: customIcon,
        ),
      );
    });

    changeMarkerPosition(_initialMarkerPosition);

    // Pindahkan kamera ke posisi baru
    mapController.animateCamera(
      CameraUpdate.newLatLngZoom(_initialMarkerPosition, 15.0),
    );
  }

  void addDraggableMarker() async {
    final BitmapDescriptor customIcon = await getResizedIcon(
      'assets/marker/marker-pin-orange.png', // Path gambar ikon
      100, // Ukuran ikon
    );

    setState(() {
      _markers.add(
        Marker(
          markerId: const MarkerId('destinationMarker'),
          position: _initialMarkerPosition,
          icon: customIcon,
          draggable: true, // Aktifkan dragging
          onDragEnd: (newPositions) {
            setState(() {
              // Update posisi marker tanpa menambah marker baru
              _markers = _markers.map((marker) {
                if (marker.markerId == const MarkerId('destinationMarker')) {
                  // Update posisi marker yang digerakkan
                  return marker.copyWith(positionParam: newPositions);
                }
                return marker;
              }).toSet();
            });

            // Ambil informasi dari koordinat baru
            placemarkFromCoordinates(
                    newPositions.latitude, newPositions.longitude)
                .then((placemarks) {
              var output = 'No results found.';
              if (placemarks.isNotEmpty) {
                output = placemarks[0].street ?? 'Street not found';
              }

              if (widget.onDragDestinatePosition != null) {
                widget.onDragDestinatePosition!(newPositions, output);
              }
            });
          },
        ),
      );
    });

    // Pindahkan kamera ke posisi baru
    _moveCameraWithOffset(_initialMarkerPosition, zoom: 15, offset: -0.007);
  }

  void addRiderMarker() async {
    final BitmapDescriptor customIcon = await getResizedIcon(
      'assets/marker/car-icon-splash.png', // Path gambar ikon
      150, // Ukuran ikon
    );

    LatLng position = const LatLng(-2.999283, 114.388786);

    setState(() {
      _markers.add(
        Marker(
            markerId: const MarkerId('riderMarker'),
            position: position,
            icon: customIcon,
            rotation: 130),
      );
    });

    _moveCameraWithOffset(position, zoom: 15, offset: -0.007);
  }

  void changeMarkerPosition(LatLng newPosition) async {
    if (!myLocationInit) {
      addMarker();
      return;
    }

    final BitmapDescriptor customIcon = await getResizedIcon(
      'assets/marker/marker-pin-white.png', // Path gambar ikon
      iconSize, // Ukuran ikon
    );
    setState(() {
      // Buat marker baru dengan posisi yang diperbarui
      final updatedMarker = Marker(
        markerId: const MarkerId('myLocationMarker'),
        position: newPosition,
        icon: customIcon, // Gunakan ikon yang sama
        draggable: true, // Pastikan draggable tetap aktif jika dibutuhkan
        onDragEnd: (newPositions) {
          setState(() {
            // Update posisi marker tanpa menambah marker baru
            _markers = _markers.map((marker) {
              if (marker.markerId == const MarkerId('myLocationMarker')) {
                // Update posisi marker yang digerakkan
                return marker.copyWith(positionParam: newPositions);
              }
              return marker;
            }).toSet();
          });

          // Ambil informasi dari koordinat baru
          placemarkFromCoordinates(
                  newPositions.latitude, newPositions.longitude)
              .then((placemarks) {
            var output = 'No results found.';
            if (placemarks.isNotEmpty) {
              output = placemarks[0].street ?? 'Street not found';
            }
            if (widget.onDragMyPosition != null) {
              widget.onDragMyPosition!(newPositions, output);
            }
          });
        },
      );

      // Hapus marker lama dan tambahkan yang baru
      _markers.removeWhere(
          (marker) => marker.markerId == const MarkerId('myLocationMarker'));
      _markers.add(updatedMarker);

      // Pindahkan kamera ke posisi baru
      _moveCameraWithOffset(newPosition);
    });
  }

  void _moveCameraWithOffset(LatLng newPosition,
      {double zoom = 18, double offset = -0.0007}) {
    // Hitung offset berdasarkan latitude
    final LatLng adjustedPosition = LatLng(
      newPosition.latitude + offset, // Tambahkan offset ke latitude
      newPosition.longitude, // Longitude tetap
    );

    // Animasi kamera ke posisi yang disesuaikan
    mapController.animateCamera(
      CameraUpdate.newLatLngZoom(adjustedPosition, zoom),
    );
  }

  void pinMarker(String markerId) async {
    final BitmapDescriptor customIcon = await getResizedIcon(
      markerId == 'myLocationMarker'
          ? 'assets/marker/marker-white.png'
          : 'assets/marker/marker-orange.png', // Path gambar ikon
      100, // Ukuran ikon
    );

    setState(() {
      final position = _markers
          .firstWhere(
            (marker) => marker.markerId == MarkerId(markerId),
          )
          .position;
      final updatedMarker = Marker(
          markerId: MarkerId(markerId),
          icon: customIcon,
          draggable: false,
          position: position);

      _markers.removeWhere((marker) => marker.markerId == MarkerId(markerId));
      _markers.add(updatedMarker);

      _moveCameraWithOffset(position);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: _initialMarkerPosition,
          zoom: 15.0,
        ),
        style: _mapStyle,
        markers: _markers,
        onCameraMove: (CameraPosition position) {
          setState(() {
            _mapRotation = position.bearing; // Simpan rotasi
            _updateMarkerRotation(_mapRotation); // Perbarui marker
          });
        },
      ),
    );
  }
}
