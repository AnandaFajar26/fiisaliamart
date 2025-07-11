import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PesananDiprosesPage extends StatefulWidget {
  const PesananDiprosesPage({super.key});

  @override
  State<PesananDiprosesPage> createState() => _PesananDiprosesPageState();
}

class _PesananDiprosesPageState extends State<PesananDiprosesPage> {
  final supabase = Supabase.instance.client;
  List<dynamic> pesanan = [];
  bool isLoading = true;

  Future<void> fetchPesanan() async {
    setState(() => isLoading = true);

    final userId = supabase.auth.currentUser?.id;
    if (userId == null) {
      setState(() {
        pesanan = [];
        isLoading = false;
      });
      return;
    }

    try {
      final response = await supabase
          .from('placed_orders')
          .select(
            'id, status, total_price, created_at, products:product_id(title, image_url, price)',
          )
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      setState(() {
        pesanan = response;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        pesanan = [];
        isLoading = false;
      });
      debugPrint('Gagal memuat pesanan: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchPesanan();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.teal[800],
        title: const Text(
          'Pesanan Anda',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: fetchPesanan,
            tooltip: 'Muat ulang',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: fetchPesanan,
        child:
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : pesanan.isEmpty
                ? const Center(child: Text('Belum ada pesanan.'))
                : ListView.builder(
                  itemCount: pesanan.length,
                  itemBuilder: (context, index) {
                    final item = pesanan[index];
                    final product = item['products'];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 3,
                      child: ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            product['image_url'] ?? '',
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (context, error, stackTrace) =>
                                    const Icon(Icons.image),
                          ),
                        ),
                        title: Text(
                          product['title'] ?? '',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Status: ${item['status']}'),
                            Text('Total: Rp${item['total_price']}'),
                          ],
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios_rounded),
                      ),
                    );
                  },
                ),
      ),
    );
  }
}
