// Contains function that directly calls Go function
//
// It should be used from a Dart or Flutter app
import 'dart:typed_data';
import 'dart:convert';

import 'dart:ffi';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:ffi/ffi.dart';

/// Define the GoSlice structure
///
/// This makes it easier to work with a `[]byte` directly
final class _GoSlice extends Struct {
  external Pointer<Uint8> data;
  @Int64()
  external int len;
  @Int64()
  external int cap;
}

/// CGO function signature
///
/// Dart FFI expects the function signature to match a valid C function signature
typedef _ParseDataFunc = Pointer<Utf8> Function(Pointer<_GoSlice>);

/// Dart function signature
///
/// Dart FFI expects the function signature to be equivalent to the C function signature
/// defined above
typedef _ParseData = Pointer<Utf8> Function(Pointer<_GoSlice>);

/// This function takes the raw byte array
/// and returns a json map of the returned bytes
/// of readings
Map<dynamic, dynamic> processData(Uint8List data) {
  final readingsString = _parseData(data);
  if (readingsString != null) {
    return _stringToMap(readingsString);
  }
  return {};
}

/// This function directly calls the `Parser` package from
/// `"github.com/erh/gonmea/analyzer"`
String? _parseData(Uint8List data) {
  final dynamicLibraryPath = _getDynamicLibraryPath();

  final dyLib = DynamicLibrary.open(dynamicLibraryPath);

  /// Perform function lookup and ensure that the function name passed in
  /// the string matches the name of the Go function
  /// Note: The lookup is case sensitive
  final parseDataFunc =
      dyLib.lookup<NativeFunction<_ParseDataFunc>>('ParseData');

  /// This is a dart copy of the Go function we want to call directly
  final parseData = parseDataFunc.asFunction<_ParseData>();

  final rawDataPtr = calloc<Uint8>(data.length);
  final rawDataList = rawDataPtr.asTypedList(data.length);
  rawDataList.setAll(0, data);

  final goSlicePtr = calloc<_GoSlice>();
  goSlicePtr.ref.data = rawDataPtr;
  goSlicePtr.ref.len = data.length;
  goSlicePtr.ref.cap = data.length;

  final resultPtr = parseData(goSlicePtr);

  String? result;
  if (resultPtr != nullptr) {
    result = resultPtr.toDartString();
    calloc.free(resultPtr);
  }

  /// Free remaining allocated memory
  calloc.free(goSlicePtr);
  calloc.free(rawDataPtr);

  return result;
}

/// Function to get the Dynamic Library Path
///
/// The dynamic library is path is determined by the client's Platform(OS)
String _getDynamicLibraryPath() {
  String os;
  if (Platform.isMacOS) {
    os = 'darwin';
  } else if (Platform.isWindows) {
    os = 'windows';
  } else if (Platform.isLinux) {
    os = 'linux';
  } else {
    throw UnsupportedError('Unsupported operating system');
  }

  String arch;
  if (Platform.version.contains('x64')) {
    arch = 'x86_64';
  } else if (Platform.version.contains('arm64')) {
    arch = 'arm64';
  } else {
    throw UnsupportedError('Unsupported architecture');
  }

  return path.join(Directory.current.path, 'bin', 'bin_${os}_$arch');
}

Map<dynamic, dynamic> _stringToMap(String dartString) {
  try {
    final jsonString = json.decode(dartString);
    return jsonString;
  } catch (e) {
    print("Error: $dartString");
    return {};
  }
}
