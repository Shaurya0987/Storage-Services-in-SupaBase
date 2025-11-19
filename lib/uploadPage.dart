import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:storage/storage_services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


class UploadPage extends StatefulWidget {
  const UploadPage({super.key});

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  File? _selectedImage;
  final picker = ImagePicker();
  final storageService = StorageService();
  List<FileObject> images = [];

  @override
  void initState() {
    super.initState();
    loadImages();
  }

  // --------------------------
  // PICK IMAGE
  // --------------------------
  Future pickImage() async {
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() => _selectedImage = File(image.path));
    }
  }

  // --------------------------
  // LOAD IMAGES FROM STORAGE
  // --------------------------
  Future loadImages() async {
    final list = await storageService.listImages();
    setState(() => images = list);
  }

  // --------------------------
  // UPLOAD IMAGE
  // --------------------------
  Future uploadImage() async {
    if (_selectedImage == null) return;

    final path = await storageService.uploadImage(_selectedImage!);

    if (path != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Image Uploaded")),
      );
      loadImages();
    }
  }

  // --------------------------
  // DELETE IMAGE
  // --------------------------
  Future deleteImage(String filePath) async {
    final ok = await storageService.deleteImage(filePath);

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Image Deleted")),
      );
      loadImages();
    }
  }

  // --------------------------
  // UPDATE IMAGE
  // --------------------------
  Future updateImage(String oldPath) async {
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pick an image first")),
      );
      return;
    }

    final ok = await storageService.updateImage(oldPath, _selectedImage!);

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Image Updated")),
      );
      loadImages();
    }
  }

  // --------------------------
  // BUILD UI
  // --------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Image CRUD")),
      body: Column(
        children: [
          const SizedBox(height: 10),

          // Selected Image Preview
          _selectedImage != null
              ? Image.file(_selectedImage!, height: 150)
              : const Text("No Image Selected"),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: pickImage,
                child: const Text("Pick Image"),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: uploadImage,
                child: const Text("Upload"),
              ),
            ],
          ),

          const Divider(),

          const Text(
            "Stored Images",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          Expanded(
            child: ListView.builder(
              itemCount: images.length,
              itemBuilder: (context, index) {
                final file = images[index];
                final path = "uploads/${file.name}";
                final url = storageService.getPublicUrl(path);

                return ListTile(
                  leading: Image.network(url, width: 50, height: 50),
                  title: Text(file.name),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // UPDATE BUTTON
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.orange),
                        onPressed: () => updateImage(path),
                      ),
                      // DELETE BUTTON
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => deleteImage(path),
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
