// This file serves as a conditional entry point for the LocalInferenceService.
// It ensures that platform-incompatible libraries like dart:ffi are not
// imported when compiling for the Web.

export 'local_inference_service_web.dart' // Default to web/unsupported
    if (dart.library.io) 'local_inference_service_native.dart'; // Use native on IO-capable platforms
