import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:latlng/latlng.dart';
import 'package:geolocator/geolocator.dart';
void main() => runApp(const MyApp());

 Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    return await Geolocator.getCurrentPosition();
  }
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
Future<String> obtenerRutaDeDirecciones(LatLng origen, LatLng destino) async {
  final apiKey = "AIzaSyDU3gMh7xxQQfucsKbshcWLRl3RFXBu4do";
  final url = "https://maps.googleapis.com/maps/api/directions/json"
      "?origin=${origen.latitude},${origen.longitude}"
      "&destination=${destino.latitude},${destino.longitude}"
      "&key=$apiKey";
  final response = await http.get(Uri.parse(url));
  final json = jsonDecode(response.body);
  final rutas = json["routes"] as List<dynamic>;
  final primerRuta = rutas.first;
  final patronesPolilinea = primerRuta["overview_polyline"]["points"] as String;
  return patronesPolilinea;
}

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Material App',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Material App Bar'),
        ),
        body: const Center(
          child: Text('Hello World'),
        ),
        floatingActionButton: FloatingActionButton(onPressed: () => (()  {
          Position position = _determinePosition() as Position;
          LatLng origen=new LatLng(position.latitude, position.longitude);
          LatLng destino=new LatLng(position.latitude, position.longitude);
          obtenerRutaDeDirecciones(origen,destino);
        })))
    );
  }
}