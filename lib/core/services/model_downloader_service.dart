// This file serves as a conditional entry point for the ModelDownloaderService.
// It ensures that platform-incompatible libraries like dart:io are not
// imported when compiling for the Web.

export 'model_downloader_progress.dart';
export 'model_downloader_service_web.dart' 
    if (dart.library.io) 'model_downloader_service_native.dart';
