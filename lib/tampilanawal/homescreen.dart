import 'package:fiisaliamart/halamanadmin/halaman_detail.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../profil/profil_screen.dart';
import '../halaman-checkout/checkout_screen.dart';
import '../halaman-checkout/pesanan_diproses.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Color primaryBlue = const Color(0xFF045D72);
  int selectedIndex = 0;
  final GlobalKey<CheckoutPageState> _checkoutKey =
      GlobalKey<CheckoutPageState>();

  void _onAddToCheckout(Map<String, dynamic> product) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    try {
      await Supabase.instance.client.from('orders').insert({
        'user_id': user.id,
        'product_id': product['id'],
        'admin_id': product['admin_id'],
        'product_title': product['title'],
        'product_price': product['price'],
        'product_image': product['image_url'],
        'status': 'pending',
        'created_at': DateTime.now().toIso8601String(),
      });

      // Panggil refresh orders di Checkout
      _checkoutKey.currentState?.fetchOrders();

      setState(() {
        selectedIndex = 1; // Pindah ke tab Checkout
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Produk ditambahkan ke Checkout')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menambahkan ke Checkout: $e')),
      );
    }
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
      body: IndexedStack(
        index: selectedIndex,
        children: [
          HomeContent(onAddToCheckout: _onAddToCheckout),
          CheckoutPage(key: _checkoutKey),
          const PesananDiprosesPage(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        selectedItemColor: primaryBlue,
        onTap: (index) {
          setState(() {
            selectedIndex = index;
          });

          // Auto-refresh saat tab Checkout dipilih
          if (index == 1) {
            _checkoutKey.currentState?.fetchOrders();
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: "Checkout",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: "Pesanan",
          ),
        ],
      ),
    );
  }
}

class HomeContent extends StatefulWidget {
  final Function(Map<String, dynamic>) onAddToCheckout;
  const HomeContent({super.key, required this.onAddToCheckout});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
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

  @override
  Widget build(BuildContext context) {
    return isLoading
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
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Column(
                              children: [
                                CircleAvatar(
                                  radius: 22,
                                  backgroundColor: Colors.grey[300],
                                  child: const Icon(Icons.devices),
                                ),
                                const SizedBox(height: 4),
                                Text(e, style: const TextStyle(fontSize: 12)),
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
                    errorBuilder:
                        (_, __, ___) => const Icon(Icons.image_not_supported),
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
            GridView.builder(
              itemCount: products.length,
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 3 / 4,
              ),
              itemBuilder: (context, index) {
                final product = products[index];
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            product['image_url'] ?? '',
                            fit: BoxFit.cover,
                            width: double.infinity,
                            errorBuilder:
                                (_, __, ___) => const Icon(Icons.broken_image),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        product['title'] ?? '',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "Rp ${product['price']}",
                        style: const TextStyle(color: Colors.green),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: IconButton(
                          icon: const Icon(Icons.add_circle_outline),
                          onPressed: () => widget.onAddToCheckout(product),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            const ListTile(
              leading: Icon(Icons.local_offer_outlined, color: Colors.orange),
              title: Text("Special Offers"),
              subtitle: Text("We make sure you get the best prices."),
            ),
          ],
        );
  }
}
