/// The method for saving and sharing CSV on mobile
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

import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

void saveAndShareCsv(String csv, String fileName) async {
  Directory? directory;
  directory = await getApplicationDocumentsDirectory();
  final path = directory.path;
  final file = File("$path/$fileName.csv");
  await file.writeAsString(csv);

  // Use the share plugin to share the file
  Share.shareXFiles([XFile('$path/$fileName.csv')]);
}
