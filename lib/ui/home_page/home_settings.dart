/// The widget for displaying SETTINGS page
///
/// Copyright (C) 2023 The Authors
///
/// License: GNU General Public License, Version 3 (the "License")
/// https://www.gnu.org/licenses/gpl-3.0.en.html
//
// This program is free software: you can redistribute it and/or modify it under
// the terms of the GNU General Public License as published by the Free Software
// Foundation, either version 3 of the License, or (at your option) any later
// version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
// details.
//
// You should have received a copy of the GNU General Public License along with
// this program.  If not, see <https://www.gnu.org/licenses/>.
///
/// Authors: Ye Duan

// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/services.dart';
import 'package:securedialog/constants/app.dart';
import 'package:securedialog/utils/time_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../service/home_page_service.dart';
import '../../utils/base_widget.dart';
import '../login_page/login_page.dart';

const storage = FlutterSecureStorage(); // Initialize secure storage

class HomeSettings extends StatefulWidget {
  final Map<dynamic, dynamic>? authData;

  const HomeSettings(this.authData, {super.key});

  @override
  _HomeSettingsState createState() => _HomeSettingsState();
}

class _HomeSettingsState extends State<HomeSettings> {
  TextEditingController encKeyController = TextEditingController();
  TextEditingController webIdController = TextEditingController();
  final HomePageService homePageService = HomePageService();
  bool isTextVisible = false;
  bool isCaptureLocationEnabled = false;
  int locationCaptureFrequency = 1; // Default to 1 minute
  String? lastSurveyTime;

  @override
  void initState() {
    super.initState();
    _loadEncryptionKey();
    _loadWebID();
    _loadSettings();
  }

  _loadEncryptionKey() async {
    String? storedKey = await storage.read(key: 'encKey');
    setState(() {
      encKeyController.text = storedKey ?? 'N/A';
    });
  }

  _loadWebID() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? lastInputURL = prefs.getString(Constants.lastInputURLKey);
    setState(() {
      webIdController.text = lastInputURL ?? '';
    });
  }

  _updateEncryptionKey(String newKey) async {
    await storage.write(key: 'encKey', value: newKey); // Write to storage
    _loadEncryptionKey();
  }

  _updateWebID(String newWebID) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(Constants.lastInputURLKey, newWebID);
  }

  _loadSettings() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isCaptureLocationEnabled = prefs.getBool('captureLocation') ?? false;
      locationCaptureFrequency = prefs.getInt('locationCaptureFrequency') ?? 1;
    });
  }

  _saveSettings() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('captureLocation', isCaptureLocationEnabled);
    prefs.setInt('locationCaptureFrequency', locationCaptureFrequency);
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      color: Constants.backgroundColor,
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 8),
            Center(
              child: Text(
                'Your Information',
                style: TextStyle(
                  fontSize: 30,
                  fontFamily: "KleeOne",
                  fontWeight: FontWeight.bold,
                  color: Colors.teal[800],
                ),
              ),
            ),
            const SizedBox(height: 20),
            FutureBuilder<String?>(
              future: storage.read(key: 'encKey'), // Read from storage
              builder: (BuildContext context, AsyncSnapshot<String?> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text("Error: ${snapshot.error}");
                } else {
                  return SizedBox(
                    width: double.infinity,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 25.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Encryption Key:',
                            style: TextStyle(
                              fontSize: 20,
                              fontFamily: "KleeOne",
                              fontWeight: FontWeight.bold,
                              color: Colors.teal[800],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 200,
                                child: TextField(
                                  controller: encKeyController,
                                  readOnly: false,
                                  obscureText: !isTextVisible,
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontFamily: "KleeOne",
                                      color: Colors.blueGrey[700]),
                                  textAlign: TextAlign.left,
                                  autofocus: false,
                                  inputFormatters: <TextInputFormatter>[
                                    LengthLimitingTextInputFormatter(100),
                                  ],
                                  decoration: InputDecoration(
                                    hintText: "Your Enc-Key",
                                    isCollapsed: true,
                                    contentPadding: const EdgeInsets.all(10.0),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      borderSide: const BorderSide(
                                          color: Colors.grey, width: 1.0),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      borderSide: const BorderSide(
                                          color: Colors.grey, width: 1.0),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      borderSide: const BorderSide(
                                          color: Colors.teal, width: 1.5),
                                    ),
                                    suffixIcon: IconButton(
                                      // Add this icon button
                                      icon: Icon(
                                        isTextVisible
                                            ? Icons.visibility
                                            : Icons.visibility_off,
                                        color: Colors.teal[400],
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          isTextVisible = !isTextVisible;
                                        });
                                      },
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 18),
                              ElevatedButton(
                                onPressed: () {
                                  _updateEncryptionKey(encKeyController.text);
                                },
                                style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all(
                                      Colors.teal[400]),
                                  // Other styles here
                                ),
                                child: const Text(" SAVE "),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'WebID:',
                            style: TextStyle(
                              fontSize: 20,
                              fontFamily: "KleeOne",
                              fontWeight: FontWeight.bold,
                              color: Colors.teal[800],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 200.0,
                                child: TextField(
                                  controller: webIdController,
                                  readOnly: false,
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontFamily: "KleeOne",
                                      color: Colors.blueGrey[700]),
                                  decoration: InputDecoration(
                                    hintText:
                                        "https://pod-url.example-server.net/profile/card#me",
                                    contentPadding: const EdgeInsets.all(10.0),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      borderSide: const BorderSide(
                                          color: Colors.grey, width: 1.0),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      borderSide: const BorderSide(
                                          color: Colors.grey, width: 1.0),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      borderSide: const BorderSide(
                                          color: Colors.teal, width: 1.5),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 18),
                              ElevatedButton(
                                onPressed: () {
                                  _updateWebID(webIdController.text);
                                },
                                style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all(
                                      Colors.teal[400]),
                                ),
                                child: const Text(" SAVE "),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          SwitchListTile(
                            title: Text(
                                'Capture Location',
                              style: TextStyle(
                                fontSize: 20,
                                fontFamily: "KleeOne",
                                fontWeight: FontWeight.bold,
                                color: Colors.teal[800],
                              ),
                            ),
                            value: isCaptureLocationEnabled,
                            onChanged: (bool value) {
                              print("Switch toggled to: $value");
                              setState(() {
                                isCaptureLocationEnabled = value;
                              });
                              _saveSettings();
                            },
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Location Capture Frequency:',
                            style: TextStyle(
                              fontSize: 20,
                              fontFamily: "KleeOne",
                              fontWeight: FontWeight.bold,
                              color: Colors.teal[800],
                            ),
                          ),
                          const SizedBox(height: 12),
                          DropdownButton<int>(
                            value: locationCaptureFrequency,
                            items: const [
                              DropdownMenuItem<int>(value: 1, child: Text('1 Minute')),
                              DropdownMenuItem<int>(value: 5, child: Text('5 Minutes')),
                              DropdownMenuItem<int>(value: 60, child: Text('1 hour')),
                            ],
                            onChanged: (int? newValue) {
                              setState(() {
                                locationCaptureFrequency = newValue!;
                              });
                              _saveSettings();
                            },
                          ),
                          const SizedBox(height: 20),
                          FutureBuilder<String>(
                            future: homePageService.getLastSurveyTime(widget.authData!),
                            builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const CircularProgressIndicator();
                              } else if (snapshot.hasError) {
                                return Text("Error: ${snapshot.error}");
                              } else {
                                lastSurveyTime = snapshot.data ?? Constants.none;
                                return Padding(
                                  padding: const EdgeInsets.only(top: 0.0, left: 0.0),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Last Survey Time:',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontFamily: "KleeOne",
                                          fontWeight: FontWeight.bold,
                                          color: Colors.teal[800],
                                        ),
                                      ),
                                      const SizedBox(width: 18),
                                      Text(
                                        TimeUtils.reformatYYYYMMDDHHMMSS(lastSurveyTime!),
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontFamily: "KleeOne",
                                            color: Colors.blueGrey[700]
                                        ),
                                      )
                                    ],
                                  ),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                }
              },
            ),
            BaseWidget.getPadding(25),
            BaseWidget.getElevatedButton(() async {
              bool? isLogout = await showDialog<bool>(
                  context: context,
                  builder: (context) {
                    return BaseWidget.getConfirmationDialog(context, "Message",
                        "Are you sure to logout?", "Emm, not yet", "Goodbye");
                  });
              if (isLogout == null || !isLogout || !mounted) {
                return;
              }
              homePageService.logout(widget.authData!["logoutUrl"]);
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (_) {
                return const LoginPage();
              }));
            }, "Logout", MediaQuery.of(context).size.width / 1.25, 50),
            BaseWidget.getPadding(101),
          ],
        ),
      ),
    );
  }
}
