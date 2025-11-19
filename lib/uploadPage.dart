import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../storage_services.dart';


class UploadPage extends StatefulWidget {
  const UploadPage({super.key});

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  File? _selectedFile;
  final picker = ImagePicker();
  final storageService = StorageService();
  List<FileObject> files = [];

  @override
  void initState() {
    super.initState();
    loadFiles();
  }

  // --------------------------
  // PICK IMAGE OR PDF
  // --------------------------
  Future pickFile() async {
    final XFile? picked = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (picked != null) {
      setState(() => _selectedFile = File(picked.path));
    }
  }

  // --------------------------
  // LOAD FILES FROM STORAGE
  // --------------------------
  Future loadFiles() async {
    final list = await storageService.listFiles();
    setState(() => files = list);
  }

  // --------------------------
  // UPLOAD FILE
  // --------------------------
  Future uploadFile() async {
    if (_selectedFile == null) return;

    final path = await storageService.uploadFile(_selectedFile!);

    if (path != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("File Uploaded")));
      loadFiles();
    }
  }

  // --------------------------
  // DELETE FILE
  // --------------------------
  Future deleteFile(String filePath) async {
    final ok = await storageService.deleteFile(filePath);

    if (ok) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("File Deleted")));
      loadFiles();
    }
  }

  // --------------------------
  // UPDATE FILE
  // --------------------------
  Future updateFile(String oldPath) async {
    if (_selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pick a file first")),
      );
      return;
    }

    final ok = await storageService.updateFile(oldPath, _selectedFile!);

    if (ok) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("File Updated")));
      loadFiles();
    }
  }

  // --------------------------
  // DOWNLOAD FILE
  // --------------------------
  Future<void> downloadFile(String url, String filename) async {
    await Permission.storage.request();
    Directory? dir = await getExternalStorageDirectory();

    if (dir == null) return;

    String savePath = "${dir.path}/$filename";

    try {
      await Dio().download(url, savePath);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Downloaded to $savePath")),
      );
    } catch (e) {
      print("Download error: $e");
    }
  }

  // --------------------------
  // BUILD UI
  // --------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("File CRUD")),
      body: Column(
        children: [
          const SizedBox(height: 10),

          // File preview (only images)
          _selectedFile != null
              ? Image.file(_selectedFile!, height: 150)
              : const Text("No File Selected"),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: pickFile,
                child: const Text("Pick File"),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: uploadFile,
                child: const Text("Upload"),
              ),
            ],
          ),

          const Divider(),

          const Text(
            "Stored Files",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          Expanded(
            child: ListView.builder(
              itemCount: files.length,
              itemBuilder: (context, index) {
                final file = files[index];
                final path = "uploads/${file.name}";
                final url = storageService.getPublicUrl(path);

                bool isPdf = file.name.toLowerCase().endsWith(".pdf");

                return ListTile(
                  leading: isPdf
                      ? const Icon(Icons.picture_as_pdf,
                          size: 40, color: Colors.red)
                      : Image.network(url, width: 50, height: 50),

                  title: Text(file.name),

                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // UPDATE BUTTON
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.orange),
                        onPressed: () => updateFile(path),
                      ),

                      // DOWNLOAD BUTTON
                      IconButton(
                        icon: const Icon(Icons.download, color: Colors.blue),
                        onPressed: () {
                          downloadFile(url, file.name);
                        },
                      ),

                      // DELETE BUTTON
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => deleteFile(path),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
