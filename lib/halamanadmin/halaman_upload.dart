import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class UploadProdukPage extends StatefulWidget {
  const UploadProdukPage({super.key});

  @override
  State<UploadProdukPage> createState() => _UploadProdukPageState();
}

class _UploadProdukPageState extends State<UploadProdukPage> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _oldPriceController = TextEditingController();
  File? _imageFile;

  final picker = ImagePicker();
  final supabase = Supabase.instance.client;

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadProduk() async {
    final user = supabase.auth.currentUser;
    if (user == null || _imageFile == null) return;

    final fileName = const Uuid().v4();
    final storageResponse = await supabase.storage
        .from('produk-images') // pastikan sudah buat bucket 'produk-images'
        .upload('public/$fileName.jpg', _imageFile!);

    final imageUrl = supabase.storage
        .from('produk-images')
        .getPublicUrl('public/$fileName.jpg');

    await supabase.from('products').insert({
      'title': _titleController.text,
      'description': _descriptionController.text,
      'price': _priceController.text,
      'old_price': _oldPriceController.text,
      'image_url': imageUrl,
      'admin_id': user.id,
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Produk berhasil diunggah")));

    _titleController.clear();
    _descriptionController.clear();
    _priceController.clear();
    _oldPriceController.clear();
    setState(() {
      _imageFile = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Upload Produk")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Nama Produk'),
            ),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Deskripsi'),
            ),
            TextField(
              controller: _priceController,
              decoration: const InputDecoration(labelText: 'Harga'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _oldPriceController,
              decoration: const InputDecoration(labelText: 'Harga Sebelumnya'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.image),
              label: const Text('Pilih Gambar'),
            ),
            if (_imageFile != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Image.file(_imageFile!, height: 150),
              ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _uploadProduk,
              child: const Text('Upload Produk'),
            ),
          ],
        ),
      ),
    );
  }
}
