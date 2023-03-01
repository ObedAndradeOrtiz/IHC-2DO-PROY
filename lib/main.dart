import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_webservice/places.dart' as desc;
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
  bool tolking = false;
  final _streamSubscriptions = <StreamSubscription<dynamic>>[];
  SpeechToText speechToText = SpeechToText();
  bool _speechEnabled = false;
  String _lastWords = '';
  void initAccelerometer() async {
    accelerometerEvents.listen((AccelerometerEvent event) async {
      if (event.x.abs() > 25 || event.y.abs() > 25 || event.z.abs() > 25) {
        print("El dispositivo se ha agitado!");
         await flutterTts.speak("hola!");
        _startListening();
      }
    });
  }

AccelerometerEvent? _lastEvent;
int _lastDirection = 0;
int _stepThreshold = 10;
int _stepCount = 0;

void _listenToAccelerometer() {
  accelerometerEvents.listen((AccelerometerEvent event) async {
    if (_lastEvent != null) {
      double yDiff = event.y - _lastEvent!.y;
      if (yDiff.abs() > _stepThreshold) {
        int direction = yDiff.isNegative ? -1 : 1;
        if (direction != _lastDirection) {
          _stepCount++;
          _lastDirection = direction;
         
        }
      }
    }
    _lastEvent = event;
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

  String DeleteHTML(String texto) {
    String parseado = "";
    for (int i = 0; i < texto.length; i++) {
      if (texto[i] != "<") {
        parseado = parseado + texto[i];
      } else {
        for (int j = i; j < texto.length; j++) {
          if (texto[j] == ">") {
            i = j;
            j = texto.length;
          }
        }
      }
    }
    return parseado;
  }

  Future<void> buscar(LatLng ubicacion) async {
    print("INGRESANDO A VER LA RUTA");
    Position position = await _determinePosition();
    print("CALCULANDO");
    LatLng origin = LatLng(position.latitude, position.longitude);
    LatLng destino = LatLng(ubicacion.latitude, ubicacion.longitude);
    final apiKey = "AIzaSyDU3gMh7xxQQfucsKbshcWLRl3RFXBu4do";
    final url = "https://maps.googleapis.com/maps/api/directions/json"
        "?origin=${origin.latitude},${origin.longitude}"
        "&destination=${destino.latitude},${destino.longitude}"
        "&key=$apiKey";
    print(url);
    final response = await http.get(Uri.parse(url));
    final json = jsonDecode(response.body);
    final rutas = json["routes"][0]["legs"][0]["steps"] as List<dynamic>;
    startReadingInstructions( rutas); 
    print(rutas);
   
  }
 Future<void> startReadingInstructions( final rutas) async {
     for (final rut in rutas) {
      String textoConHTML = rut["html_instructions"].toString();
      String textoSinHTML = DeleteHTML(textoConHTML);
      print(textoSinHTML);
      await reproducirTexto(textoSinHTML);
    }
  }
  Future<void> reproducirTexto(String textoSinHTML) async {
    setState(() {
      tolking = true;
    });

    await flutterTts.speak(textoSinHTML);
    setState(() {
      tolking = false;
    });
  }

  bool hablando() {
    return tolking;
  }

  Future<void> reproducir(String texto) async {
    if (Localizacion(texto)) {
      Position position = await _determinePosition();
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);
      Placemark placemark = placemarks[0];
      print(placemarks[0].toString());
      List<String> localidad = [];
      localidad.add(placemark.name!);
      localidad.add(placemark.country!);
      localidad.add(placemark.name!);
      final places = desc.GoogleMapsPlaces(
          apiKey: "AIzaSyDU3gMh7xxQQfucsKbshcWLRl3RFXBu4do");
      desc.PlacesSearchResponse response = await places.searchNearbyWithRadius(
          new desc.Location(lat: position.latitude, lng: position.longitude),
          100,
          type: "establishment");
      if (response.status == "OK") {
        String nombreDelLugarCercano = response.results[1].name;
        await flutterTts
            .speak("Te encuentras cerca de : " + nombreDelLugarCercano+" sobre la sublocalidad "+placemark.subLocality.toString());
      }
      LatLng origin = LatLng(response.results[1].geometry!.location.lat,
          response.results[0].geometry!.location.lng);
      print(origin);
      //buscar(origin);
    }
    if(texto.contains("emergencia")){
      //http://quirogascz.ddns.net:5002
       var responde = await http.get(
        Uri.parse("http://quirogascz.ddns.net:5002/mensaje?message=OBED ESTA EN UNA EMERGENCIA!"));
         await flutterTts.speak("Se ha enviado un mensaje de emergencia a wasap");
    }
    if(llamar(texto)){
      launchCaller();
       await flutterTts.speak("llamada de emergencia");
       
    }
     if(texto.contains("hc")){
       await flutterTts.speak("como estas amigo Obed, que necesitas?");
       
    }
    if(dia(texto)){
      DateTime now = DateTime.now();
    String dayOfWeek = _getDayOfWeek(now.weekday);
     await flutterTts.speak('Hoy es $dayOfWeek');
    }
    if(texto.contains("cuenta mis pasos")){
      _listenToAccelerometer();
      await flutterTts.speak("Comenzando a contar");
    }
    if(texto.contains("Cuántos pasos voy")){
       await flutterTts.speak(_stepCount.toString());
    }
    if(texto.contains("delante de mí")){
        Position position = await _determinePosition();
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);
      Placemark placemark = placemarks[0];
      print(placemarks[0].toString());
      List<String> localidad = [];
      localidad.add(placemark.name!);
      localidad.add(placemark.country!);
      localidad.add(placemark.name!);
      final places = desc.GoogleMapsPlaces(
          apiKey: "AIzaSyDU3gMh7xxQQfucsKbshcWLRl3RFXBu4do");
      desc.PlacesSearchResponse response = await places.searchNearbyWithRadius(
          new desc.Location(lat: position.latitude, lng: position.longitude),
          100,
          type: "establishment");
      if (response.status == "OK") {
        String nombreDelLugarCercano = response.results[1].name;
      await flutterTts
            .speak("Te encuentras al frente de "+response.results[2].name);
      }
    }
    if(texto.contains("búsqueda por web")){
      final query = texto.replaceAll("búsqueda por web", ""); // reemplaza con tu consulta de búsqueda
final apiKey = 'AIzaSyDU3gMh7xxQQfucsKbshcWLRl3RFXBu4do'; // reemplaza con tu clave de API de búsqueda web
final url = 'https://www.googleapis.com/customsearch/v1?key=$apiKey&cx=017576662512468239146:omuauf_lfve&q=$query';
final response = await http.get(Uri.parse(url));
if (response.statusCode == 200) {
  print(response.body);
 //await flutterTts.speak("El resultado es "+response.body);
} else {
  print("error");
}

    }
    // else {
    //    await flutterTts.speak("No comprendo tu pregunta, vuelve a agitar");
    // }
  }
  String _getDayOfWeek(int weekday) {
    switch (weekday) {
      case 1:
        return 'lunes';
      case 2:
        return 'martes';
      case 3:
        return 'miércoles';
      case 4:
        return 'jueves';
      case 5:
        return 'viernes';
      case 6:
        return 'sábado';
      case 7:
        return 'domingo';
      default:
        return '';
    }
  }
  void launchCaller() async {
    String phoneNumber="77035251";
    String url = 'tel:$phoneNumber';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'No se pudo marcar el número $phoneNumber.';
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
bool dia(String texto){
if (texto.contains("día es hoy")) {
      return true;
    }
    return false;
}
  bool Localizacion(String texto) {
    if (texto.contains("dónde estoy")) {
      return true;
    }
    return false;
  }
bool llamar(String texto) {
    if (texto.contains("llamar")) {
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
                          child: Column(children: [
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
                                    Text(
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
    SaludoInicial();
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
