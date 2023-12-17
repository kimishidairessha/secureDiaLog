/// The widget for displaying KEY page
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
/// Authors: Bowen Yang, Ye Duan

// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:securedialog/service/home_page_service.dart';
import 'package:securedialog/service/key_page_service.dart';

import '../../utils/base_widget.dart';
import 'package:securedialog/constants/app.dart';
import '../../utils/global.dart';
import '../home_page/home_page.dart';
import '../login_page/login_page.dart';

class KeyPage extends StatefulWidget {
  final Map<dynamic, dynamic>? authData;

  const KeyPage(this.authData, {Key? key}) : super(key: key);

  @override
  State<KeyPage> createState() => _KeyPageState();
}

class _KeyPageState extends State<KeyPage> {
  final storage = const FlutterSecureStorage();
  TextEditingController encKeyController = TextEditingController();
  final KeyPageService keyPageService = KeyPageService();
  final HomePageService homePageService = HomePageService();
  bool isIconVisible = false;
  bool hidePassword = true;

  @override
  void initState() {
    super.initState();
    _loadEncryptionKey();
  }

  _loadEncryptionKey() async {
    String? storedKey = await storage.read(key: 'encKey');
    if (storedKey != null) {
      if (await keyPageService.checkAndSetEncKey(widget.authData, storedKey)) {
        Global.isEncKeySet = true;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  HomePage(widget.authData, Constants.indexPage)),
        );
      } else {
        // If the stored key is invalid, show it in the text field
        // and pop up a warning
        setState(() {
          encKeyController.text = storedKey;
          isIconVisible =
              false; // Make the visibility icon visible if text is present
        });
        showDialog<bool>(
          context: context,
          builder: (context) {
            return BaseWidget.getNoticeDialog(
                context,
                "Warning",
                "The encryption key you stored is incorrect. "
                    "Please enter the correct key.",
                "Try again");
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BaseWidget.getAppBar("SecureDiaLog"),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            BaseWidget.getPadding(15.0),
            Container(
              alignment: Alignment.topCenter,
              width: MediaQuery.of(context).size.width - 30,
              child: BaseWidget.getTitleText(
                  "For your privacy please provide an encryption key "
                  "that SecureDiaLog will use to encrypt your data "
                  "to keep it protected within your POD. Once provided "
                  "the key will be securely stored locally and available "
                  "within Settings."),
            ),
            BaseWidget.getPadding(2.5),
            RawKeyboardListener(
              focusNode: FocusNode(),
              onKey: (event) async {
                if (event.isKeyPressed(LogicalKeyboardKey.enter)) {
                  if (await keyPageService.checkAndSetEncKey(
                      widget.authData, encKeyController.text)) {
                    // await storage.write(key: 'encKey', value: encKeyController.text);
                    Global.isEncKeySet = true;
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              HomePage(widget.authData, Constants.indexPage)),
                    );
                  } else {
                    await showDialog<bool>(
                      context: context,
                      builder: (context) {
                        return BaseWidget.getNoticeDialog(
                            context,
                            "Warning",
                            "You didn't enter your enc-key or the key is not correct",
                            "Try again");
                      },
                    );
                    return;
                  }
                }
              },
              child: TextField(
                controller: encKeyController,
                onChanged: (value) {
                  //try this
                  value.isNotEmpty
                      ? setState(() => isIconVisible = true)
                      : setState(() => isIconVisible = false);
                  //or
                  setState(() => value.isNotEmpty
                      ? isIconVisible = true
                      : isIconVisible = false);
                  //the result is the same it's just a shortcode
                },
                obscureText: hidePassword,
                style: const TextStyle(fontSize: 18, fontFamily: "KleeOne"),
                textAlign: TextAlign.center,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: "Your Enc-Key",
                  suffixIcon: isIconVisible
                      ? IconButton(
                          onPressed: () {
                            setState(() => hidePassword = !hidePassword);
                          },
                          icon: Icon(
                            hidePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                        )
                      : null,
                ),
                onSubmitted: (value) async {
                  if (await keyPageService.checkAndSetEncKey(
                      widget.authData, encKeyController.text)) {
                    Global.isEncKeySet = true;
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              HomePage(widget.authData, Constants.indexPage)),
                    );
                  } else {
                    await showDialog<bool>(
                      context: context,
                      builder: (context) {
                        return BaseWidget.getNoticeDialog(
                            context,
                            "Warning",
                            "You didn't enter your enc-key or the key is not correct",
                            "Try again");
                      },
                    );
                    return;
                  }
                },
              ),
            ),
            BaseWidget.getPadding(15),
            BaseWidget.getElevatedButton(() async {
              if (await keyPageService.checkAndSetEncKey(
                  widget.authData, encKeyController.text)) {
                // await storage.write(key: 'encKey', value: encKeyController.text);
                Global.isEncKeySet = true;
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          HomePage(widget.authData, Constants.indexPage)),
                );
              } else {
                await showDialog<bool>(
                  context: context,
                  builder: (context) {
                    return BaseWidget.getNoticeDialog(
                        context,
                        "Warning",
                        "You didn't enter your enc-key or the key is not correct",
                        "Try again");
                  },
                );
                return;
              }
            }, "Start Now", MediaQuery.of(context).size.width / 1.25, 50),
            BaseWidget.getPadding(15),
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

            // // Button to trigger key recovery
            // BaseWidget.getPadding(15),
            // BaseWidget.getElevatedButton(() async {
            //   await recoverKey();
            // }, "Recover Key", MediaQuery.of(context).size.width / 1.25, 50),

            BaseWidget.getPadding(150),
          ],
        ),
      ),
      backgroundColor: Constants.backgroundColor,
    );
  }
}
