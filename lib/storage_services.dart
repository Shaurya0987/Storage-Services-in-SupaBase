import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class StorageService {
  final SupabaseClient _supabase = Supabase.instance.client;

  final String bucket = 'images'; // your bucket name
  final String basePath = 'uploads'; // folder inside bucket

  // -------------------------------
  // UPLOAD FILE (image/pdf/etc.)
  // -------------------------------
  Future<String?> uploadFile(File file) async {
    try {
      final fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final ext = file.path.split('.').last; // detect pdf/jpg/png
      final path = '$basePath/$fileName.$ext';

      await _supabase.storage.from(bucket).upload(path, file);

      return path; // return the file path inside bucket
    } catch (e) {
      print("Upload error: $e");
      return null;
    }
  }

  // -------------------------------
  // READ / LIST FILES
  // -------------------------------
  Future<List<FileObject>> listFiles() async {
    try {
      final files = await _supabase.storage.from(bucket).list(
            path: basePath,
          );

      return files;
    } catch (e) {
      print("List error: $e");
      return [];
    }
  }

  // -------------------------------
  // DELETE FILE
  // -------------------------------
  Future<bool> deleteFile(String filePath) async {
    try {
      await _supabase.storage.from(bucket).remove([filePath]);
      return true;
    } catch (e) {
      print("Delete error: $e");
      return false;
    }
  }

  // -------------------------------
  // UPDATE FILE (replace)
  // -------------------------------
  Future<bool> updateFile(String oldPath, File newFile) async {
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
