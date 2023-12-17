// ignore: avoid_web_libraries_in_flutter
/// The method for saving and sharing CSV on web
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

import 'dart:html' as html;
import 'dart:typed_data';

void saveAndShareCsv(String csv, String fileName) {
  final bytes = Uint8List.fromList(csv.codeUnits);
  final blob = html.Blob([bytes], 'text/plain', 'native');
  final url = html.Url.createObjectUrlFromBlob(blob);
  // ignore: unused_local_variable
  final anchor = html.AnchorElement(href: url)
    ..setAttribute("download", '$fileName.csv')
    ..click();
  html.Url.revokeObjectUrl(url);
}
