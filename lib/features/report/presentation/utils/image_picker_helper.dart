import 'dart:io';
import 'package:image_picker/image_picker.dart';

/// Helper service for image picking functionality
///
/// Provides methods to pick images from camera or gallery
/// with consistent configuration and error handling.
class ImagePickerHelper {
  final ImagePicker _picker = ImagePicker();

  /// Standard image quality settings
  static const double _maxWidth = 1920.0;
  static const double _maxHeight = 1080.0;
  static const int _imageQuality = 85;

  /// Pick a single image from camera
  ///
  /// Returns the image file or null if cancelled/failed
  Future<File?> pickFromCamera() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: _maxWidth,
        maxHeight: _maxHeight,
        imageQuality: _imageQuality,
        preferredCameraDevice: CameraDevice.rear,
      );

      if (photo != null) {
        final imageFile = File(photo.path);
        if (await imageFile.exists()) {
          return imageFile;
        }
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  /// Pick a single image from gallery
  ///
  /// Returns the image file or null if cancelled/failed
  Future<File?> pickFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: _maxWidth,
        maxHeight: _maxHeight,
        imageQuality: _imageQuality,
      );

      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  /// Pick multiple images from gallery
  ///
  /// Returns list of image files (empty list if cancelled)
  Future<List<File>> pickMultipleFromGallery() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(
        maxWidth: _maxWidth,
        maxHeight: _maxHeight,
        imageQuality: _imageQuality,
      );

      return images.map((xFile) => File(xFile.path)).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Pick image from specified source
  ///
  /// [source] - Either ImageSource.camera or ImageSource.gallery
  /// Returns the image file or null if cancelled/failed
  Future<File?> pickFromSource(ImageSource source) async {
    return source == ImageSource.camera
        ? await pickFromCamera()
        : await pickFromGallery();
  }
}
