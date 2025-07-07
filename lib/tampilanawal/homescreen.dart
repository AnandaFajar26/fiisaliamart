import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../tampilanawal.dart/checkout_screen.dart';
import '../tampilanawal.dart/profil_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Color primaryBlue = const Color(0xFF045D72);
  List<dynamic> products = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    final response = await Supabase.instance.client
        .from('products')
        .select()
        .order('created_at', ascending: false);

    setState(() {
      products = response;
      isLoading = false;
    });
  }

  Future<void> addToCheckout(Map<String, dynamic> product) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    await Supabase.instance.client.from('orders').insert({
      'user_id': user.id,
      'product_title': product['title'],
      'product_price': product['price'],
      'product_image': product['image_url'],
      'status': 'pending',
      'created_at': DateTime.now().toIso8601String(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Produk ditambahkan ke Checkout')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: primaryBlue,
        title: const Row(
          children: [
            Icon(Icons.flash_on, color: Colors.white),
            SizedBox(width: 8),
            Text("Fisalia Mart"),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => Get.to(() => const ProfilScreen()),
          ),
        ],
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                padding: const EdgeInsets.all(12),
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const TextField(
                      decoration: InputDecoration(
                        hintText: "Search any product...",
                        border: InputBorder.none,
                        prefixIcon: Icon(Icons.search),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 70,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children:
                          ['laptop', 'komputer', 'kabel', 'monitor']
                              .map(
                                (e) => Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                  child: Column(
                                    children: [
                                      CircleAvatar(
                                        radius: 22,
                                        backgroundColor: Colors.grey[300],
                                        child: const Icon(Icons.devices),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        e,
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                              .toList(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.pink[100],
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                "50-40% OFF",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text("Now in greatest discount"),
                              SizedBox(height: 10),
                              ElevatedButton(
                                onPressed: null,
                                child: Text("Shop Now"),
                              ),
                            ],
                          ),
                        ),
                        Image.asset(
                          "assets/shopping_girl.png",
                          height: 100,
                          errorBuilder: (_, __, ___) {
                            return const Icon(Icons.image_not_supported);
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Deal of the Day",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  ...products.map((product) {
                    return Card(
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        leading: Image.network(
                          product['image_url'] ?? '',
                          width: 50,
                          height: 50,
                          errorBuilder:
                              (_, __, ___) => const Icon(Icons.broken_image),
                        ),
                        title: Text(product['title'] ?? ''),
                        subtitle: Text(product['description'] ?? '-'),
                        trailing: IconButton(
                          icon: const Icon(Icons.add_circle_outline),
                          onPressed: () => addToCheckout(product),
                        ),
                      ),
                    );
                  }).toList(),
                  const SizedBox(height: 20),
                  const ListTile(
                    leading: Icon(
                      Icons.local_offer_outlined,
                      color: Colors.orange,
                    ),
                    title: Text("Special Offers"),
                    subtitle: Text("We make sure you get the best prices."),
                  ),
                ],
              ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: primaryBlue,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: "Checkout",
          ),
        ],
        onTap: (index) {
          if (index == 1) {
            Get.to(() => const CheckoutPage());
          }
        },
      ),
    );
  }
}