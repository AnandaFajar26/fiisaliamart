import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'placeorder_screen.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({Key? key}) : super(key: key);

  @override
  CheckoutPageState createState() => CheckoutPageState();
}

class CheckoutPageState extends State<CheckoutPage> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> mergedOrders = [];
  List<bool> selected = [];
  List<int> quantity = [];
  bool isLoading = true;
  String? address;
  String? phone;

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    setState(() {
      isLoading = true;
    });

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
            .maybeSingle();

    // Gabungkan berdasarkan product_id
    Map<String, Map<String, dynamic>> grouped = {};
    for (var item in orderResponse) {
      final productId = item['product_id'];
      final key = productId ?? item['product_title'];

      if (!grouped.containsKey(key)) {
        grouped[key] = {
          ...item,
          'quantity': 1,
          'all_ids': [item['id']],
        };
      } else {
        grouped[key]!['quantity'] += 1;
        grouped[key]!['all_ids'].add(item['id']);
      }
    }

    setState(() {
      mergedOrders = grouped.values.toList();
      selected = List<bool>.filled(mergedOrders.length, true);
      quantity =
          mergedOrders.map<int>((item) => item['quantity'] ?? 1).toList();
      address = profileResponse?['address'] ?? '-';
      phone = profileResponse?['phone_number'] ?? '-';
      isLoading = false;
    });
  }

  Future<void> deleteProductFromCheckout(List orderIds) async {
    await supabase.from('orders').delete().inFilter('id', orderIds);
    await fetchOrders();
  }

  double calculateTotal() {
    double total = 0;
    for (int i = 0; i < mergedOrders.length; i++) {
      if (selected[i]) {
        final price =
            double.tryParse(mergedOrders[i]['product_price'].toString()) ?? 0;
        total += price * quantity[i];
      }
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final totalPrice = calculateTotal();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Checkout", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                    const Text(
                      "Shopping List",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: ListView.builder(
                        itemCount: mergedOrders.length,
                        itemBuilder: (_, index) {
                          final item = mergedOrders[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Checkbox(
                                        value: selected[index],
                                        onChanged: (value) {
                                          setState(() {
                                            selected[index] = value!;
                                          });
                                        },
                                      ),
                                      Expanded(
                                        child: Row(
                                          children: [
                                            Image.network(
                                              item['product_image'] ?? '',
                                              width: 80,
                                              height: 80,
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (_, __, ___) =>
                                                      const Icon(Icons.image),
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
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  const Text(
                                                    "Variations: Default",
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                  Row(
                                                    children: [
                                                      const Icon(
                                                        Icons.star,
                                                        color: Colors.orange,
                                                        size: 16,
                                                      ),
                                                      const Text(
                                                        "4.7",
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Row(
                                                    children: [
                                                      Text(
                                                        "Rp${item['product_price']}",
                                                        style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 10),
                                                      const Text(
                                                        "Rp999.000",
                                                        style: TextStyle(
                                                          decoration:
                                                              TextDecoration
                                                                  .lineThrough,
                                                          color: Colors.grey,
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                            IconButton(
                                              icon: const Icon(
                                                Icons.delete,
                                                color: Colors.red,
                                              ),
                                              onPressed:
                                                  () =>
                                                      deleteProductFromCheckout(
                                                        item['all_ids'],
                                                      ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                          Icons.remove_circle_outline,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            if (quantity[index] > 1)
                                              quantity[index]--;
                                          });
                                        },
                                      ),
                                      Text(quantity[index].toString()),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.add_circle_outline,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            quantity[index]++;
                                          });
                                        },
                                      ),
                                    ],
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
                        label: const Text("Bayar Sekarang juga"),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(14),
                        ),
                        onPressed:
                            totalPrice == 0
                                ? null
                                : () {
                                  Get.to(
                                    () => PlaceOrderScreen(
                                      selectedOrders: [
                                        for (
                                          int i = 0;
                                          i < mergedOrders.length;
                                          i++
                                        )
                                          if (selected[i])
                                            {
                                              ...mergedOrders[i],
                                              'quantity': quantity[i],
                                            },
                                      ],
                                      quantities: quantity,
                                    ),
                                  );
                                },
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}
