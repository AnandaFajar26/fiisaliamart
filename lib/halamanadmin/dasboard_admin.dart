import 'package:flutter/material.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text(
                'Menu',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('Utama'),
              onTap: () {}, // TODO: Navigasi ke halaman utama
            ),
            ListTile(
              leading: const Icon(Icons.shopping_bag),
              title: const Text('Produk'),
              onTap: () {}, // TODO: Navigasi ke halaman produk
            ),
            ListTile(
              leading: const Icon(Icons.receipt_long),
              title: const Text('Orderan'),
              onTap: () {}, // TODO: Navigasi ke halaman orderan
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: const Text('Dashboard Admin'),
        leading: Builder(
          builder:
              (context) => IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              backgroundImage: AssetImage(
                'assets/avatar.png',
              ), // Ganti sesuai asetmu
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Grafik Penjualan Placeholder
              Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.blue[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text('Grafik Penjualan (Chart Placeholder)'),
                ),
              ),
              const SizedBox(height: 20),

              // Total Pendapatan Bulanan
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Total Pendapatan Bulan Ini",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Rp 12.000.000",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Total Order Per Barang
              const Text(
                "Total Order per Barang",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ...[
                {"nama": "Produk A", "jumlah": 120},
                {"nama": "Produk B", "jumlah": 85},
                {"nama": "Produk C", "jumlah": 42},
              ].map((item) {
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: ListTile(
                    title: Text(item['nama'].toString()),
                    trailing: Text('${item['jumlah']} order'),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
