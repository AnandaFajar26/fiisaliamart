import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'payment_screen.dart';

class PlaceOrderScreen extends StatefulWidget {
  final List<dynamic> selectedOrders;
  final List<int> quantities;

  const PlaceOrderScreen({
    super.key,
    required this.selectedOrders,
    required this.quantities,
  });

  @override
  State<PlaceOrderScreen> createState() => _PlaceOrderScreenState();
}

class _PlaceOrderScreenState extends State<PlaceOrderScreen> {
  final supabase = Supabase.instance.client;
  bool isLoading = false;
  String? buyerName;
  String? buyerAddress;
  String? buyerPhone;
  String? userId;

  @override
  void initState() {
    super.initState();
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final response =
        await supabase
            .from('profiles')
            .select('full_name, address, phone_number')
            .eq('id', user.id)
            .single();

    setState(() {
      buyerName = response['full_name'] ?? '-';
      buyerAddress = response['address'] ?? '-';
      buyerPhone = response['phone_number'] ?? '-';
      userId = user.id;
    });
  }

  double getTotalPrice() {
    double total = 0;
    for (int i = 0; i < widget.selectedOrders.length; i++) {
      final raw = widget.selectedOrders[i]['product_price']
          .toString()
          .replaceAll(RegExp(r'[^\d]'), '');
      final price = double.tryParse(raw) ?? 0;
      total += price * widget.quantities[i];
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final totalPrice = getTotalPrice();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Place Order"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Detail Produk",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: widget.selectedOrders.length,
                itemBuilder: (_, index) {
                  final item = widget.selectedOrders[index];
                  return Card(
                    child: ListTile(
                      leading: Image.network(
                        item['product_image'] ?? '',
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (_, __, ___) =>
                                const Icon(Icons.image_not_supported),
                      ),
                      title: Text(item['product_title'] ?? ''),
                      subtitle: Text(
                        "Rp${item['product_price']} x ${widget.quantities[index]}",
                      ),
                    ),
                  );
                },
              ),
            ),
            const Divider(),
            const SizedBox(height: 10),
            const Text(
              "Informasi Pembeli",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 6),
            buyerName == null
                ? const CircularProgressIndicator()
                : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Nama: $buyerName"),
                    Text("Alamat: $buyerAddress"),
                    Text("Telepon: $buyerPhone"),
                  ],
                ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.grey.shade100,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Total Harga:",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "Rp${totalPrice.toStringAsFixed(0)}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed:
                    isLoading || totalPrice == 0 || userId == null
                        ? null
                        : () {
                          final List<Map<String, dynamic>> finalOrders = [];
                          for (
                            int i = 0;
                            i < widget.selectedOrders.length;
                            i++
                          ) {
                            final product = widget.selectedOrders[i];
                            finalOrders.add({
                              'product_id': product['product_id'],
                              'product_title': product['product_title'],
                              'product_image': product['product_image'],
                              'price':
                                  double.tryParse(
                                    product['product_price']
                                        .toString()
                                        .replaceAll(RegExp(r'[^\d]'), ''),
                                  ) ??
                                  0,
                              'quantity': widget.quantities[i],
                              'admin_id': product['admin_id'],
                            });
                          }

                          Get.to(
                            () => PaymentScreen(
                              selectedOrders: finalOrders,
                              totalPrice: totalPrice,
                              userId: userId!,
                              name: buyerName ?? '-',
                              address: buyerAddress ?? '-',
                              phone: buyerPhone ?? '-',
                            ),
                          );
                        },
                icon: const Icon(Icons.payment),
                label:
                    isLoading
                        ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                        : const Text("Lanjutkan Pembayaran"),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      totalPrice == 0 ? Colors.grey.shade400 : Colors.indigo,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
