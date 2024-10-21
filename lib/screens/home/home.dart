import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:pepperdisesesidentification/Ml Model.dart'; // Import MlModel
import 'package:pepperdisesesidentification/constants/colors.dart';
import 'package:pepperdisesesidentification/services/auth.dart';
import 'package:pepperdisesesidentification/waterlevel.dart'; // Import WaterLevel
import 'package:pepperdisesesidentification/weathertypeiot.dart';
import 'package:pepperdisesesidentification/waterdatagraph.dart';
import 'package:pepperdisesesidentification/SetEvent.dart';
import 'package:pepperdisesesidentification/screens/authenicate/signin.dart'; // Import WeatherTypeIOT

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _currentIndex = 0;

  final DatabaseReference _totalVolumeRef =
      FirebaseDatabase.instance.ref().child('totalVolume');
  final DatabaseReference _predictWaterLevelRef =
      FirebaseDatabase.instance.ref().child('predictwaterlevel');
  final DatabaseReference _relayRef =
      FirebaseDatabase.instance.ref().child('relay');
  final DatabaseReference _buzzerRef =
      FirebaseDatabase.instance.ref().child('buzzer');

  double _totalVolume = 0.0;
  double _predictWaterLevel = 0.0;
  bool _relayStatus = false;
  bool _buzzerStatus = false;

  @override
  void initState() {
    super.initState();
    _startListeningToFirebase();
  }

  void _startListeningToFirebase() {
    _totalVolumeRef.onValue.listen((event) {
      final value = event.snapshot.value;
      if (value is int) {
        setState(() {
          _totalVolume = value.toDouble();
        });
      } else if (value is double) {
        setState(() {
          _totalVolume = value;
        });
      }
    });

    _predictWaterLevelRef.onValue.listen((event) {
      final value = event.snapshot.value;
      if (value is int) {
        setState(() {
          _predictWaterLevel = value.toDouble();
        });
      } else if (value is double) {
        setState(() {
          _predictWaterLevel = value;
        });
      }
    });

    _relayRef.onValue.listen((event) {
      final relayValue = event.snapshot.value as int? ?? 0;
      setState(() {
        _relayStatus = relayValue == 1;
      });
    });

    _buzzerRef.onValue.listen((event) {
      final buzzerValue = event.snapshot.value as int? ?? 0;
      setState(() {
        _buzzerStatus = buzzerValue == 1;
      });
    });
  }

  void _toggleRelay() {
    setState(() {
      _relayStatus = !_relayStatus;
      _relayRef.set(_relayStatus ? 1 : 0);
    });
  }

  void _toggleBuzzer() {
    setState(() {
      _buzzerStatus = !_buzzerStatus;
      _buzzerRef.set(_buzzerStatus ? 1 : 0);
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _pages = [
      HomePage(
        totalVolume: _totalVolume,
        predictWaterLevel: _predictWaterLevel,
        relayStatus: _relayStatus,
        buzzerStatus: _buzzerStatus,
        onRelayToggle: _toggleRelay,
        onBuzzerToggle: _toggleBuzzer,
      ),
      MlModel(),
      WaterDataGraph(),
      SetEvent(),
    ];

    return Scaffold(
      backgroundColor: bgBlack,
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: bgBlack,
        actions: [
          ElevatedButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(bgBlack),
            ),
            onPressed: () async {
              final AuthService _auth = AuthService();
              await _auth.signOut();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => SignIn(toggle: () {}),
                ),
              );
            },
            child: const Icon(
              Icons.exit_to_app,
            ),
          ),
        ],
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.greenAccent,
        unselectedItemColor: Colors.white54,
        selectedLabelStyle:
            TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        unselectedLabelStyle: TextStyle(fontSize: 12),
        iconSize: 28,
        showSelectedLabels: true,
        showUnselectedLabels: false,
        items: const [
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.symmetric(vertical: 6),
              child: Icon(Icons.home),
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.symmetric(vertical: 6),
              child: Icon(Icons.science),
            ),
            label: 'Predictions',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.symmetric(vertical: 6),
              child: Icon(Icons.wb_sunny),
            ),
            label: 'Visualize Data',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.symmetric(vertical: 6),
              child: Icon(Icons.water),
            ),
            label: 'Reminders',
          ),
        ],
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  final double totalVolume;
  final double predictWaterLevel;
  final bool relayStatus;
  final bool buzzerStatus;
  final VoidCallback onRelayToggle;
  final VoidCallback onBuzzerToggle;

  HomePage({
    required this.totalVolume,
    required this.predictWaterLevel,
    required this.relayStatus,
    required this.buzzerStatus,
    required this.onRelayToggle,
    required this.onBuzzerToggle,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Home Dashboard",
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          _buildStatusCard(
              "Total Volume", "${totalVolume.toStringAsFixed(2)} mm"),
          const SizedBox(height: 20),
          _buildStatusCard(
              "Predict Level", "${predictWaterLevel.toStringAsFixed(2)} mm"),
          const SizedBox(height: 20),
          _buildControlCard("Relay", relayStatus, onRelayToggle),
          const SizedBox(height: 20),
          _buildControlCard("Buzzer", buzzerStatus, onBuzzerToggle),
        ],
      ),
    );
  }

  Widget _buildStatusCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: Colors.grey[300],
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlCard(String title, bool status, VoidCallback onToggle) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          Switch(
            value: status,
            onChanged: (value) {
              onToggle();
            },
            activeColor: Colors.green,
            inactiveThumbColor: Colors.red,
          ),
        ],
      ),
    );
  }
}
