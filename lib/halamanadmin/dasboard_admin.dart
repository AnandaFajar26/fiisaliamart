import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'halaman_profil.dart';
import 'halaman_pesanan.dart';
import 'halaman_produk.dart';

class HalamanUtamaAdmin extends StatefulWidget {
  const HalamanUtamaAdmin({super.key});

  @override
  State<HalamanUtamaAdmin> createState() => _HalamanUtamaAdminState();
}

class _HalamanUtamaAdminState extends State<HalamanUtamaAdmin> {
  final supabase = Supabase.instance.client;
  String selectedFilter = 'Bulanan';
  int currentIndex = 0;

  List<Map<String, dynamic>> orders = [];
  int totalPendapatan = 0;
  Map<String, int> penjualanPerHari = {};
  Map<String, int> produkTerlaris = {};
  final formatRupiah = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  final List<String> filterOptions = [
    'Harian',
    'Mingguan',
    'Bulanan',
    'Tahunan',
  ];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    final now = DateTime.now();
    late DateTime startDate;

    switch (selectedFilter) {
      case 'Harian':
        startDate = DateTime(now.year, now.month, now.day);
        break;
      case 'Mingguan':
        startDate = now.subtract(const Duration(days: 7));
        break;
      case 'Bulanan':
        startDate = DateTime(now.year, now.month, 1);
        break;
      case 'Tahunan':
        startDate = DateTime(now.year, 1, 1);
        break;
    }

    final response = await supabase
        .from('placed_orders')
        .select()
        .eq('admin_id', userId)
        .gte('created_at', startDate.toIso8601String());

    orders = List<Map<String, dynamic>>.from(response);

    totalPendapatan = orders.fold(0, (sum, order) {
      final total = int.tryParse(order['total_price'].toString()) ?? 0;
      return sum + total;
    });

    penjualanPerHari.clear();
    for (var order in orders) {
      final date = DateTime.parse(order['created_at']).toLocal();
      final key = '${date.month}/${date.day}';
      final total = int.tryParse(order['total_price'].toString()) ?? 0;
      penjualanPerHari[key] = (penjualanPerHari[key] ?? 0) + total;
    }

    produkTerlaris.clear();
    for (var order in orders) {
      final productId = order['product_id'];
      final quantity = int.tryParse(order['quantity'].toString()) ?? 0;
      produkTerlaris[productId] = (produkTerlaris[productId] ?? 0) + quantity;
    }

    for (var id in produkTerlaris.keys.toList()) {
      final res =
          await supabase
              .from('products')
              .select('title')
              .eq('id', id)
              .maybeSingle();
      final title = res?['title'] ?? 'Unknown';
      final qty = produkTerlaris.remove(id);
      produkTerlaris[title] = qty!;
    }

    if (mounted) setState(() {});
  }

  Widget _buildDashboard() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Menu Utama Admin",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.person),
                    onPressed: () {
                      Get.to(() => const ());
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Dropdown Filter
              Row(
                children: [
                  const Text("Filter: "),
                  const SizedBox(width: 8),
                  DropdownButton<String>(
                    value: selectedFilter,
                    items:
                        filterOptions
                            .map(
                              (e) => DropdownMenuItem(value: e, child: Text(e)),
                            )
                            .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          selectedFilter = value;
                        });
                        fetchData();
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Grafik Penjualan
              Container(
                height: 200,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child:
                    penjualanPerHari.isEmpty
                        ? const Center(child: Text("Tidak ada data"))
                        : LineChart(
                          LineChartData(
                            lineBarsData: [
                              LineChartBarData(
                                spots:
                                    penjualanPerHari.entries
                                        .toList()
                                        .asMap()
                                        .entries
                                        .map(
                                          (e) => FlSpot(
                                            e.key.toDouble(),
                                            e.value.value.toDouble(),
                                          ),
                                        )
                                        .toList(),
                                isCurved: true,
                                barWidth: 3,
                                dotData: FlDotData(show: true),
                              ),
                            ],
                            titlesData: FlTitlesData(show: false),
                            borderData: FlBorderData(show: false),
                          ),
                        ),
              ),

              const SizedBox(height: 20),

              // Total Pendapatan
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Total Pendapatan",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      formatRupiah.format(totalPendapatan),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Produk Terlaris
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Produk Terlaris",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 10),
              ...produkTerlaris.entries.map((e) {
                return Card(
                  child: ListTile(
                    title: Text(e.key),
                    trailing: Text('${e.value} pcs'),
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }

  // Ubah tab berdasarkan index bottom nav
  Widget _getPage(int index) {
    switch (index) {
      case 0:
        return _buildDashboard();
      case 1:
        return const HalamanPemesananAdmin();
      case 2:
        return const HalamanProdukAdmin();
      default:
        return _buildDashboard();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _getPage(currentIndex),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) => setState(() => currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.receipt), label: 'Pesanan'),
          BottomNavigationBarItem(icon: Icon(Icons.fastfood), label: 'Produk'),
        ],
      ),
    );
  }
}
