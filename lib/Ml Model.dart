import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'component/constants.dart';
import 'component/custom_outline.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:pepperdisesesidentification/weathertypeiot.dart'; // Import the IoT Weather page
import 'package:pepperdisesesidentification/waterlevel.dart'; // Import the Water Level page

class MlModel extends StatefulWidget {
  @override
  State<MlModel> createState() => _MlModel();
}

class _MlModel extends State<MlModel> {
  String? result;
  String? confidence;
  final picker = ImagePicker();
  File? img;
  var url = "http://192.168.247.195:5000/predictweathertype";

  Future pickImage(ImageSource source) async {
    try {
      final pickedFile = await picker.getImage(source: source);
      if (pickedFile != null) {
        setState(() {
          img = File(pickedFile.path);
        });
      } else {
        print('No image selected.');
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  Future upload() async {
    if (img == null) {
      print('No image selected for upload.');
      return;
    }

    try {
      final request = http.MultipartRequest("POST", Uri.parse(url));
      final headers = {"Content-Type": "multipart/form-data"};
      request.files.add(
        http.MultipartFile(
            'fileup', img!.readAsBytes().asStream(), img!.lengthSync(),
            filename: img!.path.split('/').last),
      );
      request.headers.addAll(headers);

      final myRequest = await request.send();
      final res = await http.Response.fromStream(myRequest);

      if (myRequest.statusCode == 200) {
        final resJson = jsonDecode(res.body);
        print("response here: $resJson");
        setState(() {
          result = resJson['prediction'];
          confidence = resJson['confidence'].toString();
        });
      } else {
        print("Error ${myRequest.statusCode}: ${res.body}");
      }
    } catch (e) {
      print('Error uploading image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Constants.kBlackColor,
      extendBody: true,
      appBar: AppBar(
        backgroundColor: Constants.kPinkColor,
        title: Text('Weather Type Prediction'),
        actions: [
          IconButton(
            icon: Icon(Icons.water_damage),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => IotWeather(
                        mlResult: result,
                        mlConfidence:
                            confidence)), // Navigate to IoT Weather page
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.device_thermostat),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => MyWidget(
                        mlResult: result,
                        mlConfidence:
                            confidence)), // Navigate to Water Level page
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: screenHeight,
                ),
                child: IntrinsicHeight(
                  child: Stack(
                    children: [
                      Positioned(
                        top: screenHeight * 0.1,
                        left: -88,
                        child: Container(
                          height: 166,
                          width: 166,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Constants.kPinkColor,
                          ),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(
                              sigmaX: 200,
                              sigmaY: 200,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: screenHeight * 0.3,
                        right: -100,
                        child: Container(
                          height: 200,
                          width: 200,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Constants.kGreenColor,
                          ),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(
                              sigmaX: 200,
                              sigmaY: 200,
                            ),
                            child: Container(
                              height: 200,
                              width: 200,
                              color: Colors.transparent,
                            ),
                          ),
                        ),
                      ),
                      SafeArea(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: screenHeight * 0.05,
                            ),
                            CustomOutline(
                              strokeWidth: 4,
                              radius: screenWidth * 0.8,
                              padding: const EdgeInsets.all(4),
                              width: screenWidth * 0.8,
                              height: screenWidth * 0.8,
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Constants.kPinkColor,
                                  Constants.kPinkColor.withOpacity(0),
                                  Constants.kGreenColor.withOpacity(0.1),
                                  Constants.kGreenColor
                                ],
                                stops: const [
                                  0.2,
                                  0.4,
                                  0.6,
                                  1,
                                ],
                              ),
                              child: Center(
                                child: img == null
                                    ? Container(
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          image: DecorationImage(
                                            fit: BoxFit.cover,
                                            alignment: Alignment.bottomLeft,
                                            image: AssetImage(
                                                'assets/img-onboarding.png'),
                                          ),
                                        ),
                                      )
                                    : Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          image: DecorationImage(
                                            fit: BoxFit.cover,
                                            alignment: Alignment.bottomLeft,
                                            image: FileImage(img!),
                                          ),
                                        ),
                                      ),
                              ),
                            ),
                            SizedBox(
                              height: screenHeight * 0.05,
                            ),
                            Center(
                              child: img == null
                                  ? Text(
                                      'THE MODEL HAS NOT BEEN PREDICTED',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Constants.kWhiteColor
                                            .withOpacity(0.85),
                                        fontSize: screenHeight <= 667 ? 18 : 34,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    )
                                  : Column(
                                      children: [
                                        Text(
                                          'Weather Type: $result\nConfidence: $confidence',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: Constants.kWhiteColor
                                                .withOpacity(0.85),
                                            fontSize:
                                                screenHeight <= 667 ? 18 : 34,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                            SizedBox(
                              height: screenHeight * 0.03,
                            ),
                            CustomOutline(
                              strokeWidth: 3,
                              radius: 20,
                              padding: const EdgeInsets.all(3),
                              width: 160,
                              height: 38,
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Constants.kPinkColor,
                                  Constants.kGreenColor,
                                ],
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Constants.kPinkColor.withOpacity(0.5),
                                      Constants.kGreenColor.withOpacity(0.5),
                                    ],
                                  ),
                                ),
                                child: ElevatedButton(
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      Colors.white12,
                                    ),
                                  ),
                                  onPressed: () =>
                                      pickImage(ImageSource.gallery),
                                  child: Text(
                                    'Pick Image Here',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Constants.kWhiteColor,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            CustomOutline(
                              strokeWidth: 3,
                              radius: 20,
                              padding: const EdgeInsets.all(3),
                              width: 160,
                              height: 38,
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Constants.kPinkColor,
                                  Constants.kGreenColor,
                                ],
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Constants.kPinkColor.withOpacity(0.5),
                                      Constants.kGreenColor.withOpacity(0.5),
                                    ],
                                  ),
                                ),
                                child: ElevatedButton(
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      Colors.white12,
                                    ),
                                  ),
                                  onPressed: () =>
                                      pickImage(ImageSource.camera),
                                  child: Text(
                                    'Open Camera',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Constants.kWhiteColor,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            CustomOutline(
                              strokeWidth: 3,
                              radius: 20,
                              padding: const EdgeInsets.all(3),
                              width: 160,
                              height: 38,
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Constants.kPinkColor,
                                  Constants.kGreenColor,
                                ],
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Constants.kPinkColor.withOpacity(0.5),
                                      Constants.kGreenColor.withOpacity(0.5),
                                    ],
                                  ),
                                ),
                                child: ElevatedButton(
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      Colors.white12,
                                    ),
                                  ),
                                  onPressed: () => upload(),
                                  child: Text(
                                    'Upload Image',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Constants.kWhiteColor,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
