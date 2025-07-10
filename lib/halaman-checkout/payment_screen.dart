import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PaymentScreen extends StatefulWidget {
  final List<dynamic> selectedOrders;
  final double totalPrice;
  final String? userId;
  final String? name;
  final String? address;
  final String? phone;

  const PaymentScreen({
    super.key,
    required this.selectedOrders,
    required this.totalPrice,
    required this.userId,
    required this.name,
    required this.address,
    required this.phone,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final supabase = Supabase.instance.client;
  String selectedMethod = 'COD';

  final List<Map<String, String>> paymentMethods = [
    {'label': 'COD', 'icon': '💵'},
    {'label': 'DANA', 'icon': '📱'},
    {'label': 'GOPAY', 'icon': '💳'},
    {'label': 'BCA', 'icon': '🏦'},
  ];

  Future<void> onPay() async {
    final userId = widget.userId;
    if (userId == null) {
      Get.snackbar("Error", "User tidak ditemukan");
      return;
    }

    try {
      for (int i = 0; i < widget.selectedOrders.length; i++) {
        final item = widget.selectedOrders[i];

        // Validasi wajib
        if (item['product_id'] == null || item['admin_id'] == null) {
          Get.snackbar(
            "Error",
            "Data produk tidak lengkap pada item ke-${i + 1}",
          );
          return;
        }

        final rawPrice = item['product_price'].toString();
        final price =
            int.tryParse(rawPrice.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
        final qty = item['quantity'] ?? 1;

        await supabase.from('placed_orders').insert({
          'user_id': userId,
          'product_id': item['product_id'],
          'admin_id': item['admin_id'],
          'quantity': qty,
          'total_price': price * qty,
          'payment_method': selectedMethod,
          'status': 'diproses',
          'created_at': DateTime.now().toIso8601String(),
        });
      }

      // Jika sukses
      Get.defaultDialog(
        title: "Berhasil",
        middleText: "Pesanan berhasil dibuat!",
        textConfirm: "OK",
        onConfirm: () {
          Get.back();
          Get.offAllNamed('/');
        },
      );
    } catch (e) {
      Get.snackbar("Gagal", "Pesanan gagal disimpan: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Checkout")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Order Summary",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Order"),
                Text("Rp${widget.totalPrice.toStringAsFixed(0)}"),
              ],
            ),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [Text("Shipping"), Text("Rp0")],
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Total",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  "Rp${widget.totalPrice.toStringAsFixed(0)}",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              "Metode Pembayaran",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...paymentMethods.map((method) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedMethod = method['label']!;
                  });
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color:
                        selectedMethod == method['label']
                            ? Colors.lightBlue.shade50
                            : Colors.grey.shade100,
                    border: Border.all(
                      color:
                          selectedMethod == method['label']
                              ? Colors.blue
                              : Colors.transparent,
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Text(
                        method['icon']!,
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          method['label']!,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                      const Text(
                        "********2109",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onPay,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  "Bayar Sekarang",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
