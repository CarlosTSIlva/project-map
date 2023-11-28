import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_routes/google_maps_routes.dart';
import 'package:mapsf/main.dart';
import 'package:uuid/uuid.dart';

class MapsRoutesExample extends StatefulWidget {
  const MapsRoutesExample({
    Key? key,
    required this.title,
    required this.points,
    required this.myLocalization,
  }) : super(key: key);
  final String title;
  final List<LatLng> points;
  final ListMaps myLocalization;

  @override
  _MapsRoutesExampleState createState() => _MapsRoutesExampleState();
}

class _MapsRoutesExampleState extends State<MapsRoutesExample> {
  final Completer<GoogleMapController> _controller = Completer();

  MapsRoutes route = MapsRoutes();
  DistanceCalculator distanceCalculator = DistanceCalculator();
  String googleApiKey = "AIzaSyCBy9mMdcref4d5SslIbD8RJ0L6iiWQGZY";
  String totalDistance = 'No route';

  @override
  Widget build(BuildContext context) {
    LatLng myLocation =
        LatLng(widget.myLocalization.latitude, widget.myLocalization.longitude);

    return Scaffold(
      body: Stack(
        children: [
          Align(
            alignment: Alignment.center,
            child: GoogleMap(
              myLocationEnabled: true,
              zoomControlsEnabled: false,
              polylines: route.routes,
              initialCameraPosition: CameraPosition(
                zoom: 15.0,
                target: myLocation,
              ),
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
                print("map Created");
              },
              markers: {
                Marker(
                    markerId: const MarkerId("myLocation"),
                    position: myLocation),
                ...widget.points
                    .map(
                      (e) => Marker(
                        markerId: MarkerId(const Uuid().v4()),
                        position: e,
                      ),
                    )
                    .toList(),
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                  width: 200,
                  height: 50,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15.0)),
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(totalDistance,
                        style: const TextStyle(fontSize: 25.0)),
                  )),
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final allPoints = [...widget.points, myLocation];
          await route.drawRoute(allPoints, 'Test routes',
              const Color.fromRGBO(130, 78, 210, 1.0), googleApiKey,
              travelMode: TravelModes.driving);
          setState(() {});
        },
      ),
    );
  }
}
