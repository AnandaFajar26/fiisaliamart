import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'placeorder_screen.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final supabase = Supabase.instance.client;
  List<dynamic> orders = [];
  bool isLoading = true;
  String? address;
  String? phone;

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final orderResponse = await supabase
        .from('orders')
        .select()
        .eq('user_id', user.id)
        .order('created_at', ascending: false);

    final profileResponse =
        await supabase
            .from('profiles')
            .select('address, phone_number')
            .eq('id', user.id)
            .single();

    setState(() {
      orders = orderResponse;
      address = profileResponse['address'] ?? '-';
      phone = profileResponse['phone_number'] ?? '-';
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    double totalPrice = 0;
    for (var order in orders) {
      final price = double.tryParse(order['product_price'].toString()) ?? 0;
      totalPrice += price;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Checkout", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Alamat Pengiriman
                    const Text(
                      "Delivery Address",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.grey[200],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Address: $address"),
                          Text("Contact: $phone"),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Daftar Produk
                    const Text(
                      "Shopping List",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: ListView.builder(
                        itemCount: orders.length,
                        itemBuilder: (_, index) {
                          final item = orders[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  Image.network(
                                    item['product_image'] ?? '',
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (_, __, ___) => const Icon(Icons.image),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item['product_title'] ?? '',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        const Text(
                                          "Variations: Default",
                                          style: TextStyle(fontSize: 12),
                                        ),
                                        const SizedBox(height: 4),
                                        const Row(
                                          children: [
                                            Icon(
                                              Icons.star,
                                              color: Colors.orange,
                                              size: 16,
                                            ),
                                            Text(
                                              "4.7",
                                              style: TextStyle(fontSize: 12),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Text(
                                              "Rp${item['product_price']}",
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            const Text(
                                              "Rp999.000",
                                              style: TextStyle(
                                                decoration:
                                                    TextDecoration.lineThrough,
                                                color: Colors.grey,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Total Order",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "Rp${totalPrice.toStringAsFixed(0)}",
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.payment),
                        label: const Text("Bayar Sekarang"),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(14),
                        ),
                        onPressed: () {
                          Get.to(() => const PlaceOrderScreen());
                        },
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}
