import 'dart:typed_data';
import 'dart:html' as html; // WAJIB untuk Flutter Web

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

  void _pilihGambar() async {
    final input = html.FileUploadInputElement()..accept = 'image/*';
    input.click();

    input.onChange.listen((event) async {
      final file = input.files!.first;
      final reader = html.FileReader();
      reader.readAsArrayBuffer(file);
      await reader.onLoad.first;

      final bytes = reader.result as Uint8List;
      final fileName = DateTime.now().millisecondsSinceEpoch.toString();

      try {
        // Upload gambar
        await supabase.storage
            .from('produk')
            .uploadBinary('images/$fileName.jpg', bytes);

        // Ambil URL publik
        final url = supabase.storage
            .from('produk')
            .getPublicUrl('images/$fileName.jpg');

        setState(() => imageUrl = url);
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Gagal upload gambar: $e")));
      }
    });
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
