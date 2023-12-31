/// Check for environment variable for DEBUG_PRINT.
///
/// Copyright (C) 2023, Togaware Pty Ltd.
///
/// License: GNU General Public License, Version 3 (the "License")
/// https://www.gnu.org/licenses/gpl-3.0.en.html
//
// Time-stamp: <Wednesday 2023-11-01 08:41:01 +1100 Graham Williams>
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
/// Authors: Graham Williams

/// Allow debugPrint() behaviour to be controled from the environment.
///
/// We use debugPrint() to print trace messages and backtraces in preference to
/// print(), leaving print() for human readable messages to the console for
/// errors, like login credentials error. The debugPrint() output is then able to
/// be globally suppressed with a noop redefinition like:
///
/// ```
/// import 'package:rattle/utils/utils.dart';
///
/// if (DebugPrintConfig.debugPrint == 'FALSE') {
///   debugPrint = (String? message, {int? wrapWidth}) {};
/// }
/// ```

class DebugPrintConfig {
  static const String debugPrint = String.fromEnvironment("DEBUG_PRINT");
}
