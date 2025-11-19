import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class StorageService {
  final SupabaseClient _supabase = Supabase.instance.client;

  final String bucket = 'images'; // change if needed
  final String basePath = 'uploads';

  // -------------------------------
  // UPLOAD IMAGE
  // -------------------------------
  Future<String?> uploadImage(File file) async {
    try {
      final fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final path = '$basePath/$fileName';

      await _supabase.storage.from(bucket).upload(path, file);

      return path; // return path so UI can save/display it
    } catch (e) {
      print("Upload error: $e");
      return null;
    }
  }

  // -------------------------------
  // READ / LIST IMAGES
  // -------------------------------
  Future<List<FileObject>> listImages() async {
    try {
      final files = await _supabase.storage.from(bucket).list(path: basePath);

      return files;
    } catch (e) {
      print("List error: $e");
      return [];
    }
  }

  // -------------------------------
  // DELETE IMAGE
  // -------------------------------
  Future<bool> deleteImage(String filePath) async {
    try {
      await _supabase.storage.from(bucket).remove([filePath]);
      return true;
    } catch (e) {
      print("Delete error: $e");
      return false;
    }
  }

  // -------------------------------
  // UPDATE IMAGE (replace file)
  // -------------------------------
  Future<bool> updateImage(String oldPath, File newFile) async {
    try {
      await _supabase.storage.from(bucket).update(oldPath, newFile);

      return true;
    } catch (e) {
      print("Update error: $e");
      return false;
    }
  }

  // -------------------------------
  // GET PUBLIC URL
  // -------------------------------
  String getPublicUrl(String filePath) {
    return _supabase.storage.from(bucket).getPublicUrl(filePath);
  }
}
