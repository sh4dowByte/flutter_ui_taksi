import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_ui_taksi/config/pallete.dart';
import 'package:flutter_ui_taksi/config/routes.dart';
import 'package:flutter_ui_taksi/utils/color.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../widget/widget.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> items = [
      {
        'title': 'Need a ride?',
        'subtitle': 'Find me a ride now',
        'color': 'FE6B35',
        'image': 'assets/car.png',
      },
      {
        'title': 'Need groceries?',
        'subtitle': 'Buy me Groceries!',
        'color': '35FE55',
        'image': 'assets/fruits.png',
      },
      {
        'title': 'Need a delivery?',
        'subtitle': 'Let’s deliver!',
        'color': '35DAFE',
        'image': 'assets/motorcycle.png',
      },
      {
        'title': 'Hmm... Hungry?!',
        'subtitle': 'YUM \nYUM',
        'color': 'FE3535',
        'image': 'assets/pizza.png',
      },
    ];

    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(20).copyWith(top: 60),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Row(
              children: [
                AppButtonIcon(
                  icon: AppSvgIcon('person'),
                ),
                SizedBox(width: 16),
                AppButtonIcon(
                  icon: AppSvgIcon('notifications'),
                  isNotify: true,
                ),
                SizedBox(width: 14),
                Expanded(
                    child: AppTextSearch(
                  hintText: 'Where to ..?',
                  suffixIcon: AppSvgIcon(
                    'search',
                    width: 17,
                    height: 17,
                  ),
                ))
              ],
            ),
            const SizedBox(height: 12),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(0),
                children: [
                  // Title
                  const Text(
                    'Good Evening Peyman',
                    style: TextStyle(fontWeight: FontWeight.w100),
                  ),
                  const SizedBox(height: 12),

                  // Money
                  const Stack(
                    children: [
                      AppSvg(
                        'bg-money',
                        height: 120,
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(height: 10),
                            Text(
                              '5.264.000 IRR',
                              style: TextStyle(
                                  fontSize: 24, fontWeight: FontWeight.w200),
                            ),
                            SizedBox(height: 10),
                            Text(
                              'IS YOUR CURRENT BALANCE',
                              style: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w200),
                            ),
                            SizedBox(height: 10),
                            Text(
                              '+ ADD TO BALANCE',
                              style: TextStyle(
                                  color: Pallete.color5,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w200),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Recomended
                  GridView.builder(
                    padding: const EdgeInsets.all(0),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: items.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20,
                      childAspectRatio: 1.6,
                    ),
                    itemBuilder: (context, index) {
                      final item = items[index];

                      return AppRecomendedCard(item: item);
                    },
                  ),

                  const SizedBox(height: 24),

                  // Pay Banner
                  const AppBanner(),

                  const SizedBox(height: 24),

                  const Text(
                    'Active services around you',
                    style: TextStyle(fontWeight: FontWeight.w100),
                  ),
                  const SizedBox(height: 12),

                  // Maps
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: const MapSmallComponent(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AppBanner extends StatelessWidget {
  const AppBanner({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.only(top: 10, bottom: 10),
          height: 90,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: Pallete.gradientColor, // Warna gradien
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(23), // Membulatkan sudut
          ),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset('assets/phone.png', height: 120),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  'PAY IN A BLINK!',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 7),
                Text('ACTIVATE TAKSI CRED NOW!'),
              ],
            ),
          ],
        )
      ],
    );
  }
}

class MapSmallComponent extends StatefulWidget {
  const MapSmallComponent({super.key});

  @override
  State<MapSmallComponent> createState() => _MapSmallComponentState();
}

class _MapSmallComponentState extends State<MapSmallComponent> {
  late GoogleMapController mapController;

  final LatLng _initialPosition = const LatLng(-3.015727, 114.394987); // Kapuas

  final LatLng _centerPosition =
      const LatLng(-3.015727, 114.394987); // Koordinat pusat

  final Set<Circle> _circles = {};

  void _onMapCreated(GoogleMapController controller) async {
    mapController = controller;
  }

  final Set<Marker> _markers = {};

  String? _mapStyle; // Variable to hold the map style

  // Load map style from assets
  Future<void> _loadMapStyle() async {
    _mapStyle = await DefaultAssetBundle.of(context)
        .loadString('assets/map_style.json');
  }

  @override
  void initState() {
    super.initState();
    _loadMapStyle(); // Load map style when widget is initialized
    _addMarkersAround(_centerPosition);
  }

  Future<void> _addMarkersAround(LatLng center) async {
    const double iconSize = 45;
    const double maxOffset =
        0.006; // Jarak maksimum offset untuk penyebaran marker
    final Random random = Random();

    List<LatLng> markerPositions = [];
    for (int i = 0; i < 16; i++) {
      // Menghasilkan offset acak dalam rentang yang lebih besar untuk membuat posisi marker lebih tersebar
      double randomLat =
          center.latitude + (random.nextDouble() * maxOffset * 2) - maxOffset;
      double randomLng =
          center.longitude + (random.nextDouble() * maxOffset * 2) - maxOffset;

      // Menambahkan marker position ke dalam list
      markerPositions.add(LatLng(randomLat, randomLng));
    }

    // Tambahkan lingkaran (splash radius)
    _circles.add(
      Circle(
        circleId: const CircleId('splashRadius'),
        center: _initialPosition,
        radius: 100, // Radius dalam meter
        fillColor: Colors.orange.withOpacity(0.3),
        strokeColor: Colors.orange,
        strokeWidth: 2,
      ),
    );

    // Menambahkan marker ke dalam set _markers
    for (int i = 0; i < markerPositions.length; i++) {
      // Memuat ikon marker dengan ukuran tertentu
      // ignore: deprecated_member_use
      BitmapDescriptor customIcon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(iconSize, iconSize)),
        i % 2 == 0
            ? 'assets/marker/marker-orange.png'
            : 'assets/marker/marker-green.png',
      );

      _markers.add(
        Marker(
          markerId: MarkerId('marker_$i'),
          position: markerPositions[i],
          icon: customIcon,
        ),
      );
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 159,
      child: GoogleMap(
        onMapCreated: _onMapCreated,
        zoomControlsEnabled: false,
        myLocationEnabled: true, // Aktifkan lokasi pengguna
        myLocationButtonEnabled: true,
        initialCameraPosition: CameraPosition(
          target: _initialPosition,
          zoom: 15.0,
        ),
        style: _mapStyle,
        markers: _markers,
        circles: _circles,
      ),
    );
  }
}

class AppRecomendedCard extends StatelessWidget {
  const AppRecomendedCard({
    super.key,
    required this.item,
  });

  final Map<String, dynamic> item;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, Routes.pickUp),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Text(
              item['title'],
              style: const TextStyle(fontSize: 12),
            ),
          ),
          const SizedBox(height: 4),
          Stack(
            children: [
              Container(
                padding: const EdgeInsets.only(top: 20, left: 60, right: 27),
                margin: const EdgeInsets.only(left: 20),
                height: 82,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: hexToColor(item['color']).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Pallete.s),
                ),
              ),
              Positioned(
                left: 0,
                top: 10,
                child: Row(
                  children: [
                    Image.asset(
                      item['image'],
                      fit: BoxFit.cover,
                      height: 62,
                    ),
                    const SizedBox(width: 20),
                    SizedBox(width: 70, child: Text(item['subtitle'])),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
