import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocode/geocode.dart';
import 'package:geolocator/geolocator.dart';
import 'package:getwidget/getwidget.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mapsf/audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:url_launcher/url_launcher.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:flutter_google_places/flutter_google_places.dart';

const google_api = "AIzaSyCBy9mMdcref4d5SslIbD8RJ0L6iiWQGZY";

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // home: const MyHomePage(title: 'Flutter Demo Home Page'),
      home: const MyHomePage(title: "asdasd"),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final controller = TextEditingController();
  GeoCode geoCode = GeoCode();

  List<ListMaps> listSelect2 = [
    ListMaps(
      name: "Teste 1",
      latitude: double.parse("43.7991083"),
      longitude: double.parse("-79.5339667"),
      distance: 2,
    ),
  ];

  ListMaps myLocalization = ListMaps(
    latitude: 0,
    longitude: 0,
    distance: 0,
  );

  Future<void> _launchURL(String url) async {
    if (!await launchUrl(Uri.parse(url), mode: LaunchMode.inAppBrowserView)) {
      throw Exception('Could not launch $url');
    }
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    print(path);
    return File('$path/url.txt');
  }

  Future<File> writeCounter(String counter) async {
    final file = await _localFile;

    // Write the file
    return file.writeAsString(counter);
  }

  Future<int> readCounter() async {
    try {
      final file = await _localFile;

      // Read the file
      final contents = await file.readAsString();

      return int.parse(contents);
    } catch (e) {
      // If encountering an error, return 0
      return 02;
    }
  }

  @override
  void initState() {
    super.initState();
    Future<bool> _handleLocationPermission() async {
      bool serviceEnabled;
      LocationPermission permission;

      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
                'Location services are disabled. Please enable the services')));
        return false;
      }
      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Location permissions are denied')));
          return false;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
                'Location permissions are permanently denied, we cannot request permissions.')));
        return false;
      }
      Geolocator.getCurrentPosition().then(
        (value) {
          setState(() {
            myLocalization = ListMaps(
              latitude: value.latitude,
              longitude: value.longitude,
              distance: 0,
            );
          });
        },
      );

      return true;
    }

    _handleLocationPermission();
  }

  @override
  Widget build(BuildContext context) {
    listSelect2.sort((a, b) => a.distance.compareTo(b.distance));
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Row(
              children: [
                const SizedBox(
                  width: 8,
                ),
                Expanded(
                  child: TextField(
                    controller: controller,
                    onChanged: (v) async {},
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Endereço',
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: GFButton(
                    onPressed: () async {
                      print("sakdkd");

                      final teste = await geoCode.forwardGeocoding(
                        address: controller.text,
                      );

                      final listMaps2 = ListMaps(
                        name: controller.text,
                        latitude: teste.latitude ?? 0,
                        longitude: teste.longitude ?? 0,
                        distance: 0,
                      );

                      setState(() {
                        listSelect2.add(listMaps2);
                      });
                      controller.clear();
                    },
                    text: "Adicionar",
                    type: GFButtonType.outline2x,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: GFButton(
                    onPressed: () async {
                      Prediction? prediction = await PlacesAutocomplete.show(
                          context: context,
                          apiKey: google_api,
                          mode: Mode.fullscreen, // Mode.overlay
                          language: "en",
                          components: [Component(Component.locality, "pk")]);
                      print(prediction?.description ?? "asdas");
                    },
                    text: "Audio",
                    type: GFButtonType.outline2x,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.5,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const Text("Minha localização"),
                    Text("Latitude: ${myLocalization.latitude}"),
                    ...listSelect2
                        .map((e) => Row(
                              children: [
                                Text("${e.name} "),
                                const Spacer(),
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      listSelect2.remove(e);
                                    });
                                  },
                                  icon: const Icon(Icons.delete),
                                ),
                              ],
                            ))
                        .toList(),
                  ],
                ),
              ),
            ),
            GFButton(
              onPressed: () {
                print("ue");
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => MapsRoutesExample(
                      title: 'GMR Demo Home',
                      points: listSelect2
                          .map((e) => LatLng(e.latitude, e.longitude))
                          .toList(),
                      myLocalization: myLocalization,
                    ),
                  ),
                );
                print("ue2");
              },
              text: "navigation to MapsRoutesExample",
            ),
            // GFButton(
            //   onPressed: () async {
            //     String stringmap = "";
            //     print("iniciou");
            //     for (var i = 0; i < 6; i++) {
            //       print(((i + 1) * 5));
            //       stringmap +=
            //           "43.836424,-79.3024487/43.836424,-79.3024487/43.836424,-79.3024487/43.7991083,-79.5339667/43.7991083,-79.5339667/";
            //     }

            //     final url =
            //         'https://www.google.com/maps/dir/$stringmap@43.5224109,-79.9034981,10z/data=!3m1!4b1!4m2!4m1!3e0!11m1!6b1?entry=ttu';
            //     print("gerou url");
            //     await writeCounter(url);
            //   },
            //   text: "write file",
            //   type: GFButtonType.outline2x,
            // ),

            // GFButton(
            //   onPressed: () async {
            //     String stringmap = "";
            //     print("iniciou");

            //     print("passou map");
            //     // for de 28 vezes
            //     for (var i = 0; i < 29; i++) {
            //       listSelect2.map((e) {
            //         if (e == listSelect2[listSelect2.length - 1]) {
            //           stringmap += "${e.latitude},${e.longitude}";
            //           return "${e.latitude},${e.longitude}";
            //         } else {
            //           stringmap += "${e.latitude},${e.longitude}|";
            //           return "${e.latitude},${e.longitude}|";
            //         }
            //       }).toList();
            //     }

            //     print(stringmap.length);
            //     final url =
            //         'https://www.google.com/maps/dir/?api=1&origin=${myLocalization.latitude},${myLocalization.longitude}&destination=${listSelect2.last.latitude},${listSelect2.last.longitude}&waypoints=$stringmap&travelmode=driving&dir_action=navigate';
            //     print("gerou url");

            //     await writeCounter(url);
            //     print("tentou ler");

            //     readCounter().then((value) => print(value));

            //     // final List<LatLng> latLong = listSelect2
            //     //     .map((e) => LatLng(e.latitude, e.longitude))
            //     //     .toList();
            //     // Navigator.of(context).push(
            //     //   MaterialPageRoute(
            //     //     builder: (context) => MapsRoutesExample(
            //     //         title: 'GMR Demo Home', points: latLong),
            //     //   ),
            //     // );
            //   },
            //   text: "Buscar uma rot2",
            //   type: GFButtonType.outline2x,
            // ),
          ],
        ),
      ),
    );
  }
}

class ListMaps {
  final String? name;
  final double latitude;
  final double longitude;
  final double distance;

  ListMaps({
    this.name,
    required this.latitude,
    required this.longitude,
    required this.distance,
  });
}
