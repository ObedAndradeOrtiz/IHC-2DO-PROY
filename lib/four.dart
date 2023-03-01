// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
// ignore_for_file: unused_import

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_directions_api/google_directions_api.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_webservice/directions.dart' as ws;
import 'package:google_maps_flutter/google_maps_flutter.dart'as ms;
import 'package:google_maps_webservice/places.dart' as desc;
import 'package:google_maps_webservice/directions.dart' as dir;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

//AIzaSyDU3gMh7xxQQfucsKbshcWLRl3RFXBu4do
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'IHC',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'IHC'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static const int _snakeRows = 20;
  static const int _snakeColumns = 20;
  static const double _snakeCellSize = 10.0;

  List<double>? accelerometerValues;
  List<double>? userAccelerometerValues;
  List<double>? gyroscopeValues;
  List<double>? magnetometerValues;
  FlutterTts flutterTts = FlutterTts();

  final _streamSubscriptions = <StreamSubscription<dynamic>>[];
  SpeechToText speechToText = SpeechToText();
  bool _speechEnabled = false;
  String _lastWords = '';
  void initAccelerometer() async {
    accelerometerEvents.listen((AccelerometerEvent event) async {
      if (event.x.abs() > 15 || event.y.abs() > 15 || event.z.abs() > 15) {
        print("El dispositivo se ha agitado!");
        _startListening();
      }
    });
  }

  void _startListening() async {
    print("INGRESANDO A ESCUCHAR");
    setState(() {});
    await speechToText.listen(onResult: _onSpeechResult);
    //
    setState(() {});
  }

  void _stopListening() async {
    print("REPRODUECIENDO VOS " + _lastWords);
    await speechToText.stop();
    setState(() {});
  }


void guiar(ms.LatLng lat)async{
  // Obtener la ubicación actual del usuario y la dirección de destino
LatLng currentLocation =lat;
String destinationAddress = 'a, Av. Grigotá sobre, Doble vía La Guardia, La Guardia';

// Calcular la ruta y las direcciones necesarias para llegar a la ubicación de destino
}
void buscar(LatLng  ubicacion) async{
  print("INGRESANDO A VER LA RUTA");
Position position = await _determinePosition();
DirectionsService directionsService = DirectionsService();
final directions = dir.GoogleMapsDirections(apiKey: "AIzaSyDU3gMh7xxQQfucsKbshcWLRl3RFXBu4do");
// final result = await directions.directionsWithLocation(
//   origin:  dir.Location(lat:ubicacion.latitude ,lng:ubicacion.longitude),
//   destination: dir.Location(lat:ubicacion.latitude , lng:ubicacion.longitude),
//   travelMode: TravelMode.walking);
 print("CALCULANDO");
LatLng origin = LatLng(position.latitude,position.longitude); 
LatLng destination = LatLng(ubicacion.latitude, ubicacion.longitude); 

 print("CALCULANDOx2");

  Future<void> directionsResponse =directionsService.route(
  DirectionsRequest(
    origin: "${origin.latitude},${origin.longitude}",
    destination: "${destination.latitude},${destination.longitude}",
    travelMode: TravelMode.walking,
  ),
    (DirectionsResult result, DirectionsStatus? status) {
    if (status == DirectionsStatus.ok) {
      print("direccion encontradas");
    } else {
      
    }
  },
);

// List<Location> locations = await locationFromAddress("1600 Amphitheatre Parkway, Mountain View, CA");
// loc.LocationData destinationLocation = loc.LocationData.fromMap({
//   "latitude": locations[0].latitude,
//   "longitude": locations[0].longitude
// });


}
 void reproducir(String texto) async {
    //await flutterTts.speak("CAPTURANDO LA indicación "+texto);
    if (Localizacion(texto)) {
      Position position = await _determinePosition();
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);

      String locationText =
          "Latitud: ${position.latitude}, Longitud: ${position.longitude}";
      Placemark placemark = placemarks[0];
      print(placemarks[0].toString());
      String? address = placemark.thoroughfare;
      List<String> localidad = [];
      localidad.add(placemark.name!);
      localidad.add(placemark.country!);
      localidad.add(placemark.name!);
      String direccion = "Tu localidad es:" +
          localidad[0].toString() +
          " En el país de " +
          localidad[1];
      if (placemark.name != "") {
        direccion = direccion + " en la calle" + placemark.name!;
      }
      await flutterTts.speak(direccion);
      final places = desc.GoogleMapsPlaces(
          apiKey: "AIzaSyDU3gMh7xxQQfucsKbshcWLRl3RFXBu4do");
      desc.PlacesSearchResponse response = await places.searchNearbyWithRadius(
          new desc.Location(lat: position.latitude, lng: position.longitude),
          100,
          type: "establishment");
     
      if (response.status == "OK") {
        // El primer lugar en la lista de lugares cercanos es el más cercano.
        String nombreDelLugarCercano = response.results[0].name;
        for (int i = 0; i < response.results.length; i++) {
          print("LUGAR CERCANO " + response.results[i].name);
          print("LUGAR CERCANO " + response.results[i].geometry!.location.lat.toString());
        }
      }
    LatLng origin = LatLng(response.results[1].geometry!.location.lat,response.results[0].geometry!.location.lng); 
    print(origin);
     buscar(origin);
     //await _getDirections();
    }
  }

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

  bool Localizacion(String texto) {
    if (texto.contains("dónde estoy")) {
      return true;
    }
    return false;
  }

  void _onSpeechResult(SpeechRecognitionResult result) async {
    setState(() {
      _lastWords = result.recognizedWords;
    });
    print("palabras reconocidas " + _lastWords);
    reproducir(_lastWords);
    setState(() {
      _lastWords = "";
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed:
              speechToText.isNotListening ? _startListening : _stopListening,
          child: Icon(speechToText.isNotListening ? Icons.mic_off : Icons.mic),
        ),
        backgroundColor: Color(0xFFFFFFFF),
        body: SafeArea(
            child: Center(
          child: Container(
              decoration: BoxDecoration(color: Color(0xFFFFFFFF)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    height: MediaQuery.of(context).size.height / 5,
                  ),
                  _speechEnabled == false
                      ? Center(
                          child: ZoomIn(
                          child:
                              // ignore: sort_child_properties_last
                              Column(children: [
                            SizedBox(
                              height: MediaQuery.of(context).size.height / 15,
                            ),
                            Image.asset(
                              "assets/icon.png",
                              scale: 1,
                              width: 300,
                            )
                          ]),
                          duration: Duration(seconds: 1),
                        ))
                      : Center(
                          child: ZoomIn(
                          child:
                              Column(children: [
                            SizedBox(
                              height: MediaQuery.of(context).size.height / 15,
                            ),
                            Image.asset(
                              "assets/icon.png",
                              scale: 1,
                              width: 300,
                            )
                          ]),
                          duration: Duration(seconds: 1),
                        )),
                  Expanded(
                      child: Align(
                          alignment: Alignment.bottomCenter,
                          child: SizedBox(
                              height: 25,
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text(
                                      "©Copyright 2023",
                                      style: TextStyle(
                                          color:
                                              Color.fromARGB(255, 38, 68, 201),
                                          fontWeight: FontWeight.w700),
                                    ),
                                  ])) // Your footer widget
                          )),
                ],
              )),
        )));
  }

  //   return Scaffold(
  @override
  void dispose() {
    super.dispose();
    for (final subscription in _streamSubscriptions) {
      subscription.cancel();
    }
  }

  void _initSpeech() async {
    _speechEnabled = await speechToText.initialize();

    setState(() {});
  }

  void SaludoInicial() async {
    await flutterTts.speak(
        "HOLA, SOY IHC, DEBES AGITAR EL teléfono, PARA PODER INTERACTUAR CONMIGO");
  }

  @override
  void initState() {
    super.initState();
    _initSpeech();
    initAccelerometer();
    //SaludoInicial();
    _streamSubscriptions.add(
      accelerometerEvents.listen(
        (AccelerometerEvent event) {
          setState(() {
            accelerometerValues = <double>[event.x, event.y, event.z];
          });
        },
      ),
    );
    _streamSubscriptions.add(
      gyroscopeEvents.listen(
        (GyroscopeEvent event) {
          setState(() {
            gyroscopeValues = <double>[event.x, event.y, event.z];
          });
        },
      ),
    );
    _streamSubscriptions.add(
      userAccelerometerEvents.listen(
        (UserAccelerometerEvent event) {
          setState(() {
            userAccelerometerValues = <double>[event.x, event.y, event.z];
          });
        },
      ),
    );
    _streamSubscriptions.add(
      magnetometerEvents.listen(
        (MagnetometerEvent event) {
          setState(() {
            magnetometerValues = <double>[event.x, event.y, event.z];
          });
        },
      ),
    );
  }
}
