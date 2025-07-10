import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HalamanUpload extends StatefulWidget {
  const HalamanUpload({super.key});

  @override
  State<HalamanUpload> createState() => _HalamanUploadState();
}

class _HalamanUploadState extends State<HalamanUpload> {
  final TextEditingController titleC = TextEditingController();
  final TextEditingController priceC = TextEditingController();
  final TextEditingController oldPriceC = TextEditingController();
  final TextEditingController descriptionC = TextEditingController();
  final TextEditingController imageUrlC = TextEditingController();

  final supabase = Supabase.instance.client;

  Future<void> uploadProduk() async {
    final user = supabase.auth.currentUser;

    if (user == null) return;

    await supabase.from('products').insert({
      'title': titleC.text,
      'price': priceC.text,
      'old_price': oldPriceC.text,
      'description': descriptionC.text,
      'image_url': imageUrlC.text,
      'admin_id': user.id,
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Produk berhasil diupload!')),
      );
      Navigator.pop(context); // kembali ke halaman produk
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Upload Produk")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: titleC,
                decoration: const InputDecoration(labelText: 'Nama Produk'),
              ),
              TextField(
                controller: priceC,
                decoration: const InputDecoration(labelText: 'Harga'),
              ),
              TextField(
                controller: oldPriceC,
                decoration: const InputDecoration(
                  labelText: 'Harga Sebelumnya',
                ),
              ),
              TextField(
                controller: descriptionC,
                decoration: const InputDecoration(labelText: 'Deskripsi'),
              ),
              TextField(
                controller: imageUrlC,
                decoration: const InputDecoration(labelText: 'URL Gambar'),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: uploadProduk,
                icon: const Icon(Icons.upload),
                label: const Text("Upload Produk"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
