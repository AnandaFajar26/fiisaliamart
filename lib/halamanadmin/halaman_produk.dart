import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'halaman_upload.dart';

class HalamanProduk extends StatefulWidget {
  const HalamanProduk({super.key});

  @override
  State<HalamanProduk> createState() => _HalamanProdukState();
}

class _HalamanProdukState extends State<HalamanProduk> {
  final supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getProdukAdmin() async {
    final user = supabase.auth.currentUser;
    final response = await supabase
        .from('products')
        .select()
        .eq('admin_id', user!.id)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Produk Saya")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const HalamanUpload()),
                ).then((_) => setState(() {})); // refresh saat kembali
              },
              icon: const Icon(Icons.add),
              label: const Text("Buat Produk Baru"),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: getProdukAdmin(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final data = snapshot.data ?? [];

                if (data.isEmpty) {
                  return const Center(
                    child: Text("Belum ada produk yang diupload"),
                  );
                }

                return ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    final item = data[index];
                    return Card(
                      margin: const EdgeInsets.all(8),
                      child: ListTile(
                        leading: Image.network(
                          item['image_url'] ?? '',
                          width: 60,
                          height: 60,
                          errorBuilder:
                              (ctx, err, _) =>
                                  const Icon(Icons.image_not_supported),
                          fit: BoxFit.cover,
                        ),
                        title: Text(item['title'] ?? ''),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Harga: Rp${item['price']}"),
                            if (item['old_price'] != null &&
                                item['old_price'] != '')
                              Text(
                                "Sebelumnya: Rp${item['old_price']}",
                                style: const TextStyle(
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
