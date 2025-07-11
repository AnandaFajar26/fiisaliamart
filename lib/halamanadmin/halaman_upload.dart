import 'dart:io' if (dart.library.html) 'dart:html' as html; // Conditional import
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart'; // Import image_picker

class UploadProdukAdmin extends StatefulWidget {
  const UploadProdukAdmin({super.key});

  @override
  State<UploadProdukAdmin> createState() => _UploadProdukAdminState();
}

class _UploadProdukAdminState extends State<UploadProdukAdmin> {
  final supabase = Supabase.instance.client;

  final _namaController = TextEditingController();
  final _hargaController = TextEditingController();
  final _deskripsiController = TextEditingController();
  final _hargaLamaController = TextEditingController();

  String? imageUrl;
  Uint8List? _imageBytes; // To store image bytes for upload

  Future<void> _pilihGambar() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      if (kIsWeb) {
        // For web, we can directly read bytes from XFile
        _imageBytes = await image.readAsBytes();
      } else {
        // For mobile, we can also read bytes from XFile
        _imageBytes = await image.readAsBytes();
      }
      
      final fileName = DateTime.now().millisecondsSinceEpoch.toString();

      try {
        if (_imageBytes != null) {
          // Upload gambar
          await supabase.storage
              .from('produk')
              .uploadBinary('images/$fileName.jpg', _imageBytes!);

          // Ambil URL publik
          final url = supabase.storage
              .from('produk')
              .getPublicUrl('images/$fileName.jpg');

          setState(() => imageUrl = url);
        }
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Gagal upload gambar: $e")));
      }
    }
  }

  void _uploadProduk() async {
    final nama = _namaController.text.trim();
    final harga = _hargaController.text.trim();
    final deskripsi = _deskripsiController.text.trim();
    final hargaLama = _hargaLamaController.text.trim();
    final adminId = supabase.auth.currentUser?.id;

    if (nama.isEmpty ||
        harga.isEmpty ||
        deskripsi.isEmpty ||
        imageUrl == null ||
        adminId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Semua data (kecuali harga lama) wajib diisi"),
        ),
      );
      return;
    }

    try {
      await supabase.from('products').insert({
        'title': nama,
        'price': harga,
        'description': deskripsi,
        'old_price': hargaLama.isEmpty ? null : hargaLama,
        'image_url': imageUrl,
        'admin_id': adminId,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Produk berhasil diunggah")),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Gagal unggah produk: $e")));
    }
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
              controller: _namaController,
              decoration: const InputDecoration(labelText: "Nama Produk"),
            ),
            TextField(
              controller: _hargaController,
              decoration: const InputDecoration(labelText: "Harga"),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _deskripsiController,
              decoration: const InputDecoration(labelText: "Deskripsi"),
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _pilihGambar,
              child: const Text("Pilih Gambar"),
            ),
            const SizedBox(height: 12),
            if (imageUrl != null) // Show preview if image is selected
              Image.network(imageUrl!, height: 200),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _uploadProduk,
              child: const Text("Upload"),
            ),
          ],
        ),
      ),
    );
  }
}