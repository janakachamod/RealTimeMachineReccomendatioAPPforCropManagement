import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_database/firebase_database.dart'; // Firebase Realtime Database
import 'package:pepperdisesesidentification/waterlevel.dart'; // Import the Water Level page

class IotWeather extends StatefulWidget {
  final String? mlResult;
  final String? mlConfidence;

  const IotWeather({Key? key, this.mlResult, this.mlConfidence})
      : super(key: key);

  @override
  _IotWeatherState createState() => _IotWeatherState();
}

class _IotWeatherState extends State<IotWeather> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _temperatureController = TextEditingController();
  final TextEditingController _humidityController = TextEditingController();
  final TextEditingController _windSpeedController = TextEditingController();
  final TextEditingController _pressureController = TextEditingController();
  String? _iotPrediction;
  double? _iotConfidence;

  final DatabaseReference _database =
      FirebaseDatabase.instance.ref(); // Firebase reference

  @override
  void initState() {
    super.initState();
    _listenToWeatherDataFromFirebase(); // Fetch real-time data from Firebase
  }

  // Helper method to handle fetching either integer or double values
  dynamic _getNumberFromSnapshot(DataSnapshot snapshot) {
    final value = snapshot.value;
    if (value is int) {
      return value.toDouble(); // Convert int to double if needed
    } else if (value is double) {
      return value;
    } else {
      return double.tryParse(
          value.toString()); // Attempt to parse any other value
    }
  }

  void _listenToWeatherDataFromFirebase() {
    _database.onValue.listen((DatabaseEvent event) {
      DataSnapshot snapshot = event.snapshot;

      if (snapshot.exists) {
        setState(() {
          _temperatureController.text =
              snapshot.child('Temperature').value.toString();
          _humidityController.text =
              snapshot.child('humidity').value.toString();
          _windSpeedController.text =
              snapshot.child('Windspeed').value.toString();
          _pressureController.text =
              snapshot.child('Atmosphericpressure').value.toString();
        });
      } else {
        print("No data available in Firebase");
      }
    }, onError: (error) {
      print('Error listening to weather data: $error');
    });
  }

  Future<void> _predict() async {
    if (_formKey.currentState?.validate() ?? false) {
      final response = await http.post(
        Uri.parse('http://192.168.247.195:5002/predictiot'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'Temperature': double.tryParse(_temperatureController.text),
          'Humidity': double.tryParse(_humidityController.text),
          'Wind Speed': double.tryParse(_windSpeedController.text),
          'Atmospheric Pressure': double.tryParse(_pressureController.text),
        }),
      );

      final responseData = json.decode(response.body);
      setState(() {
        _iotPrediction = responseData['prediction'];
        _iotConfidence = responseData['confidence'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double mlConf =
        widget.mlConfidence != null ? double.parse(widget.mlConfidence!) : 0.0;

    String bestWeatherCondition = widget.mlResult ?? "Unknown";
    double bestConfidence = mlConf;

    if (_iotPrediction != null && _iotConfidence != null) {
      if (_iotConfidence! > mlConf) {
        bestWeatherCondition = _iotPrediction!;
        bestConfidence = _iotConfidence!;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('IoT Weather Prediction'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _temperatureController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Temperature'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter temperature';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _humidityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Humidity'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter humidity';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _windSpeedController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Wind Speed'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter wind speed';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _pressureController,
                keyboardType: TextInputType.number,
                decoration:
                    const InputDecoration(labelText: 'Atmospheric Pressure'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter atmospheric pressure';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _predict,
                child: const Text('Predict'),
              ),
              const SizedBox(height: 20),
              if (_iotPrediction != null && _iotConfidence != null)
                Text(
                  'IoT Prediction: $_iotPrediction\nIoT Confidence: ${(_iotConfidence! * 100).toStringAsFixed(2)}%',
                  style: const TextStyle(
                    fontSize: 16, // Reduced font size for smaller text
                    fontWeight: FontWeight
                        .w500, // Semi-bold, adjust this for lighter text
                    color: Colors
                        .black87, // A slightly lighter color for aesthetics
                  ),
                ),
              const SizedBox(height: 20),
              Text(
                'Best Weather Condition: $bestWeatherCondition\nConfidence: ${(bestConfidence * 100).toStringAsFixed(2)}%',
                style: const TextStyle(
                  fontSize: 16, // Same reduced font size
                  fontWeight:
                      FontWeight.w500, // Semi-bold, can be adjusted as needed
                  color: Colors.black87, // Consistent color with the above text
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MyWidget(
                        mlResult: widget.mlResult,
                        mlConfidence: widget.mlConfidence,
                        iotResult: _iotPrediction,
                        iotConfidence: _iotConfidence?.toString(),
                      ),
                    ),
                  );
                },
                child: const Text('Proceed to Water Level Prediction'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _temperatureController.dispose();
    _humidityController.dispose();
    _windSpeedController.dispose();
    _pressureController.dispose();
    super.dispose();
  }
}
