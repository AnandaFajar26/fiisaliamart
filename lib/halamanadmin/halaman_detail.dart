import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HalamanDetailPesanan extends StatefulWidget {
  final String paymentId;

  const HalamanDetailPesanan({super.key, required this.paymentId});

  @override
  State<HalamanDetailPesanan> createState() => _HalamanDetailPesananState();
}

class _HalamanDetailPesananState extends State<HalamanDetailPesanan> {
  final supabase = Supabase.instance.client;
  Map<String, dynamic>? pesanan;
  Map<String, dynamic>? user;
  Map<String, dynamic>? product;
  bool loading = true;

  Future<void> fetchDetail() async {
    try {
      final data =
          await supabase
              .from('placed_orders')
              .select()
              .eq('id', widget.paymentId)
              .single();

      if (data != null) {
        final userData =
            await supabase
                .from('profiles')
                .select('full_name, profile_url')
                .eq('id', data['user_id'])
                .single();

        final productData =
            await supabase
                .from('products')
                .select('title, price, image_url')
                .eq('id', data['product_id'])
                .single();

        setState(() {
          pesanan = data;
          user = userData;
          product = productData;
          loading = false;
        });
      } else {
        setState(() {
          pesanan = null;
          loading = false;
        });
      }
    } catch (e) {
      setState(() {
        pesanan = null;
        loading = false;
      });
    }
  }

  Future<void> updateStatus(String statusBaru) async {
    await supabase
        .from('placed_orders')
        .update({'status': statusBaru})
        .eq('id', widget.paymentId);
    fetchDetail();
  }

  @override
  void initState() {
    super.initState();
    fetchDetail();
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (pesanan == null || user == null || product == null) {
      return const Scaffold(body: Center(child: Text("Data tidak ditemukan")));
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Detail Pesanan")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Nama: ${user!['full_name']}"),
            Text("Alamat: ${pesanan!['alamat_pengiriman'] ?? '-'}"),
            const SizedBox(height: 12),
            Row(
              children: [
                Image.network(product!['image_url'], width: 80),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product!['title']),
                    Text("Harga: Rp${product!['price']}"),
                    Text("Qty: ${pesanan!['quantity']}"),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text("Total Harga: Rp${pesanan!['total_price']}"),
            Text("Metode Bayar: ${pesanan!['payment_method'] ?? '-'}"),
            const SizedBox(height: 10),
            Row(
              children: [
                const Text("Status: "),
                Text(
                  pesanan!['status'] ?? "masuk",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              children:
                  ['masuk', 'diproses', 'dikirim', 'selesai']
                      .map(
                        (status) => ElevatedButton(
                          onPressed: () => updateStatus(status),
                          child: Text(status),
                        ),
                      )
                      .toList(),
            ),
          ],
        ),
      ),
    );
  }
}
