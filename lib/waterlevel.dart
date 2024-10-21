import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_database/firebase_database.dart';

class MyWidget extends StatefulWidget {
  final String? mlResult;
  final String? mlConfidence;
  final String? iotResult;
  final String? iotConfidence;

  const MyWidget({
    Key? key,
    this.mlResult,
    this.mlConfidence,
    this.iotResult,
    this.iotConfidence,
  }) : super(key: key);

  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  final TextEditingController _soilTypeController = TextEditingController();
  final TextEditingController _temperatureController = TextEditingController();
  final TextEditingController _weatherConditionController =
      TextEditingController();

  String? _prediction;
  String? _selectedCropType;
  String? _selectedRegion;

  final List<String> cropTypeList = [
    'BANANA',
    'BEAN',
    'CABBAGE',
    'CITRUS',
    'COTTON',
    'MAIZE',
    'MELON',
    'MUSTARD',
    'ONION',
    'POTATO',
    'RICE',
    'SOYABEAN',
    'SUGARCANE',
    'TOMATO',
    'WHEAT',
  ];

  final List<String> regionList = [
    'DESERT',
    'HUMID',
    'SEMI ARID',
    'SEMI HUMID',
  ];

  @override
  void initState() {
    super.initState();
    _setupRealTimeListener(); // Set up real-time listener for Firebase data
    _weatherConditionController.text = _getBestWeatherCondition().toUpperCase();
  }

  // Function to map humidity to soil type
  String _getSoilTypeFromHumidity(double humidity) {
    if (humidity >= 0 && humidity <= 30) {
      return 'DRY';
    } else if (humidity >= 31 && humidity <= 60) {
      return 'HUMID';
    } else {
      return 'WET';
    }
  }

  // Function to map temperature to a range
  String _getTemperatureRange(double temperature) {
    if (temperature >= 10 && temperature <= 20) {
      return '10-20';
    } else if (temperature > 20 && temperature <= 30) {
      return '20-30';
    } else if (temperature > 30 && temperature <= 40) {
      return '30-40';
    } else if (temperature > 40 && temperature <= 50) {
      return '40-50';
    } else {
      return 'Unknown Range';
    }
  }

  // Real-time Firebase listener to get live updates
  void _setupRealTimeListener() {
    final databaseReference = FirebaseDatabase.instance.ref();

    // Listener for humidity
    databaseReference.child('humidity').onValue.listen((event) {
      if (event.snapshot.exists) {
        double humidity = double.parse(event.snapshot.value.toString());
        setState(() {
          _soilTypeController.text = _getSoilTypeFromHumidity(humidity);
        });
      }
    });

    // Listener for temperature
    databaseReference.child('Temperature').onValue.listen((event) {
      if (event.snapshot.exists) {
        double temperature = double.parse(event.snapshot.value.toString());
        setState(() {
          _temperatureController.text = _getTemperatureRange(temperature);
        });
      }
    });

    // Listener for totalVolume
    databaseReference.child('totalVolume').onValue.listen((event) async {
      if (event.snapshot.exists) {
        double totalVolume = double.parse(event.snapshot.value.toString());

        // Get the current prediction value
        final predictionSnapshot =
            await databaseReference.child('predictwaterlevel').get();
        double predictionValue = predictionSnapshot.exists
            ? double.parse(predictionSnapshot.value.toString())
            : 0;

        // Check if totalVolume exceeds predictionValue
        if (totalVolume > predictionValue) {
          // Set all values to 0 if condition is met
          await databaseReference.child('relay').set(0); // Relay off
          await databaseReference
              .child('predictwaterlevel')
              .set(0); // Reset prediction value
          await databaseReference
              .child('totalVolume')
              .set(0); // Reset total volume
        }
      }
    });
  }

  String _getBestWeatherCondition() {
    double? mlConfidence = double.tryParse(widget.mlConfidence ?? '0');
    double? iotConfidence = double.tryParse(widget.iotConfidence ?? '0');

    if ((mlConfidence ?? 0) > (iotConfidence ?? 0)) {
      return widget.mlResult ?? 'Unknown';
    } else {
      return widget.iotResult ?? 'Unknown';
    }
  }

  Future<void> _getPrediction() async {
    final url = 'http://192.168.247.195:5001/waterlevel';
    final response = await http.post(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'croptype': _selectedCropType ?? '',
        'soiltype': _soilTypeController.text,
        'region': _selectedRegion ?? '',
        'temperature': _temperatureController.text,
        'weathercondition': _weatherConditionController.text,
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      double predictionValue =
          double.tryParse(data['pred_value'].toString()) ?? 0;
      double updatedPrediction = predictionValue * 1000;

      setState(() {
        _prediction = updatedPrediction.toString();
      });

      // Update Firebase with the prediction value
      await _updateFirebaseValues(updatedPrediction);
    } else {
      setState(() {
        _prediction = 'Failed to get prediction';
      });
    }
  }

  Future<void> _updateFirebaseValues(double predictionValue) async {
    final databaseReference = FirebaseDatabase.instance.ref();

    // Get the current totalVolume from Firebase
    final totalVolumeSnapshot =
        await databaseReference.child('totalVolume').get();
    double totalVolume = totalVolumeSnapshot.exists
        ? double.parse(totalVolumeSnapshot.value.toString())
        : 0;

    // Check if totalVolume is greater than predictionValue
    if (totalVolume > predictionValue) {
      // If totalVolume exceeds predictionValue, set relay, predictwaterlevel, and totalVolume to 0
      await databaseReference.child('relay').set(0);
      await databaseReference.child('predictwaterlevel').set(0);
      await databaseReference.child('totalVolume').set(0);
    } else {
      // Otherwise, update predictwaterlevel with the new prediction value
      await databaseReference.child('predictwaterlevel').set(predictionValue);
      // Update relay only when the prediction value is updated
      await databaseReference.child('relay').set(1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Water Level Prediction'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              DropdownButtonFormField<String>(
                value: _selectedCropType,
                items: cropTypeList.map((String crop) {
                  return DropdownMenuItem<String>(
                    value: crop,
                    child: Text(crop),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedCropType = newValue;
                  });
                },
                decoration: const InputDecoration(labelText: 'Crop Type'),
              ),
              TextField(
                controller: _soilTypeController,
                decoration: const InputDecoration(labelText: 'Soil Type'),
              ),
              DropdownButtonFormField<String>(
                value: _selectedRegion,
                items: regionList.map((String region) {
                  return DropdownMenuItem<String>(
                    value: region,
                    child: Text(region),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedRegion = newValue;
                  });
                },
                decoration: const InputDecoration(labelText: 'Region'),
              ),
              TextField(
                controller: _temperatureController,
                decoration: const InputDecoration(labelText: 'Temperature'),
              ),
              TextField(
                controller: _weatherConditionController,
                decoration:
                    const InputDecoration(labelText: 'Weather Condition'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _getPrediction,
                child: const Text('Get Prediction'),
              ),
              const SizedBox(height: 20),
              Text('Prediction: ${_prediction ?? "N/A"}'),
            ],
          ),
        ),
      ),
    );
  }
}
