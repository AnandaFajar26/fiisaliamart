import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'halaman_upload.dart';

class HalamanProdukAdmin extends StatefulWidget {
  const HalamanProdukAdmin({super.key});

  @override
  State<HalamanProdukAdmin> createState() => _HalamanProdukAdminState();
}

class _HalamanProdukAdminState extends State<HalamanProdukAdmin> {
  final supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> _getProdukAdmin() async {
    final adminId = supabase.auth.currentUser?.id;
    final res = await supabase
        .from('products')
        .select('*')
        .eq('admin_id', adminId ?? '')
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(res);
  }

  Future<void> _hapusProduk(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Hapus Produk'),
            content: const Text('Yakin ingin menghapus produk ini?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Hapus'),
              ),
            ],
          ),
    );

    if (confirm == true) {
      await supabase.from('products').delete().eq('id', id);
      setState(() {}); // refresh daftar produk
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Produk")),
      body: FutureBuilder(
        future: _getProdukAdmin(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return const Center(child: CircularProgressIndicator());

          if (snapshot.hasError)
            return Center(child: Text("Error: ${snapshot.error}"));

          final data = snapshot.data ?? [];
          if (data.isEmpty)
            return const Center(child: Text("Belum ada produk."));

          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              final item = data[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: ListTile(
                  leading:
                      item['image_url'] != null
                          ? Image.network(
                            item['image_url'],
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          )
                          : const Icon(Icons.image),
                  title: Text(item['title'] ?? 'Tanpa Judul'),
                  subtitle: Text("Rp${item['price'] ?? 0}"),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _hapusProduk(item['id']),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const UploadProdukAdmin()),
          ).then((_) => setState(() {})); // refresh saat kembali
        },
        child: const Icon(Icons.add),
        tooltip: 'Upload Produk Baru',
      ),
    );
  }
}
