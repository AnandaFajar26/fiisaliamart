import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'halaman_detail.dart';

class HalamanPemesananAdmin extends StatefulWidget {
  const HalamanPemesananAdmin({super.key});

  @override
  State<HalamanPemesananAdmin> createState() => _HalamanPemesananAdminState();
}

class _HalamanPemesananAdminState extends State<HalamanPemesananAdmin> {
  final supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> _fetchOrders() async {
    final adminId = supabase.auth.currentUser?.id;

    if (adminId == null) {
      throw Exception("Admin belum login");
    }

    final response = await supabase
        .from('placed_orders')
        .select('*, profiles(full_name, profile_url)')
        .eq('admin_id', adminId)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pesanan Masuk")),
      body: FutureBuilder(
        future: _fetchOrders(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final data = snapshot.data!;
          if (data.isEmpty) {
            return const Center(child: Text("Belum ada pesanan."));
          }

          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              final order = data[index];
              return Card(
                child: ListTile(
                  leading:
                      order['profiles']['profile_url'] != null
                          ? CircleAvatar(
                            backgroundImage: NetworkImage(
                              order['profiles']['profile_url'],
                            ),
                          )
                          : const CircleAvatar(child: Icon(Icons.person)),
                  title: Text(
                    "Pemesan: ${order['profiles']['full_name'] ?? 'User'}",
                  ),
                  subtitle: Text("Total: Rp${order['total_price']}"),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap:
                      () => Get.to(
                        () => HalamanDetailPesanan(paymentId: order['id']),
                      ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
