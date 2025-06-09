import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:eco_angler/util/fishingspot.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  LatLng _currentCenter = LatLng(4.2105, 101.9758); // Malaysia
  List<Marker> _markers = [];
  Map<String, dynamic>? _selectedSpot; // for modal
  final Distance _distance = Distance(); // to calculate distance

  @override
  void initState() {
    super.initState();
    _loadFishingSpots();
  }

  void _loadFishingSpots() {
    final fishingMarkers = fishingSpots.map((spot) {
      return Marker(
        point: spot['location'],
        width: 40,
        height: 40,
        child: GestureDetector(
          onTap: () => _showFishingSpotInfo(spot),
          child: Icon(spot['icon'], color: Colors.blue, size: 30),
        ),
      );
    }).toList();

    setState(() {
      _markers.addAll(fishingMarkers);
    });
  }

  void _showFishingSpotInfo(Map<String, dynamic> spot) {
    final spotLocation = spot['location'] as LatLng;
    final double distanceInMeters = _distance.as(
      LengthUnit.Meter,
      _currentCenter,
      spotLocation,
    );

    final String distanceText = distanceInMeters >= 1000
        ? '${(distanceInMeters / 1000).toStringAsFixed(2)} km'
        : '${distanceInMeters.toStringAsFixed(0)} m';

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(120.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(spot['icon'], size: 70, color: Colors.blue),
              SizedBox(height: 10),
              Text(
                spot['name'],
                  textAlign: TextAlign.center,
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                spot['description'],
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15),),
              SizedBox(height: 8),
              Text(
                'Distance: $distanceText',
                style: TextStyle(fontSize: 10),
              ),
              SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  Future<void> _searchLocation(String query) async {
    final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=$query&format=json&limit=1');
    final response = await http.get(url, headers: {
      'User-Agent': 'flutter_map_example/1.0'
    });

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      if (data.isNotEmpty) {
        final lat = double.parse(data[0]['lat']);
        final lon = double.parse(data[0]['lon']);
        final newLocation = LatLng(lat, lon);

        setState(() {
          _currentCenter = newLocation;
          _markers = [
            Marker(
              point: newLocation,
              width: 80,
              height: 80,
              child: Icon(Icons.location_pin, size: 40, color: Colors.red),
            ),
          ];
        });

        _mapController.move(newLocation, 13);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Location not found')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch location')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentCenter,
              initialZoom: 6.0,
            ),
            children: [
              TileLayer(
                urlTemplate:
                'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: ['a', 'b', 'c'],
              ),
              MarkerLayer(markers: _markers),
            ],
          ),

          // Search Bar
          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 6)],
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search Malaysia place...',
                  icon: Icon(Icons.search),
                  border: InputBorder.none,
                ),
                onSubmitted: _searchLocation,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
