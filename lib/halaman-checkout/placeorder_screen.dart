import 'package:flutter/material.dart';

class PlaceOrderScreen extends StatefulWidget {
  const PlaceOrderScreen({super.key}); // Menggunakan super.key

  @override
  _PlaceOrderScreenState createState() => _PlaceOrderScreenState();
}

class _PlaceOrderScreenState extends State<PlaceOrderScreen> {
  // Contoh data untuk dropdown Size dan Qty
  String? _selectedSize = '42';
  int _selectedQty = 1;

  final List<String> _sizes = ['42', '43', '44', '45'];
  final List<int> _quantities = [1, 2, 3, 4, 5];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Shopping Bag',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border, color: Colors.black),
            onPressed: () {
              // Handle favorite
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Item
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.0),
                boxShadow: [
                  BoxShadow(
                    color: Color.fromARGB((255 * 0.1).round(), 128, 128, 128),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Gambar dinonaktifkan, diganti dengan SizedBox kosong
                  const SizedBox(
                    width: 100,
                    height: 100,
                    // child: ClipRRect(
                    //   borderRadius: BorderRadius.circular(8.0),
                    //   child: Image.asset(
                    //     'assets/product_image.png', // Ganti dengan path gambar Anda
                    //     fit: BoxFit.cover,
                    //   ),
                    // ),
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Lorem ipsum',
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4.0),
                        const Text(
                          'Neque porro quisquam est qui dolorem ipsum quia',
                          style: TextStyle(fontSize: 12.0, color: Colors.grey),
                        ),
                        const SizedBox(height: 8.0),
                        Row(
                          children: [
                            const Text('Size '),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8.0,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey[300]!),
                                borderRadius: BorderRadius.circular(4.0),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _selectedSize,
                                  icon: const Icon(
                                    Icons.keyboard_arrow_down,
                                    size: 20,
                                  ),
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      _selectedSize = newValue;
                                    });
                                  },
                                  items:
                                      _sizes.map<DropdownMenuItem<String>>((
                                        String value,
                                      ) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(value),
                                        );
                                      }).toList(),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16.0),
                            const Text('Qty '),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8.0,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey[300]!),
                                borderRadius: BorderRadius.circular(4.0),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<int>(
                                  value: _selectedQty,
                                  icon: const Icon(
                                    Icons.keyboard_arrow_down,
                                    size: 20,
                                  ),
                                  onChanged: (int? newValue) {
                                    setState(() {
                                      _selectedQty = newValue!;
                                    });
                                  },
                                  items:
                                      _quantities.map<DropdownMenuItem<int>>((
                                        int value,
                                      ) {
                                        return DropdownMenuItem<int>(
                                          value: value,
                                          child: Text('$value'),
                                        );
                                      }).toList(),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8.0),
                        const Text(
                          'Delivery by 10 May 2XXX',
                          style: TextStyle(
                            fontSize: 12.0,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24.0),

            // Apply Coupons Section
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.0),
                boxShadow: [
                  BoxShadow(
                    color: Color.fromARGB((255 * 0.1).round(), 128, 128, 128),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.local_activity_outlined,
                    color: Colors.black,
                  ),
                  const SizedBox(width: 12.0),
                  const Text(
                    'Apply Coupons',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      // Handle select coupon
                    },
                    child: const Text(
                      'Select',
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24.0),

            // Order Payment Details Section
            const Text(
              'Order Payment Details',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16.0),
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.0),
                boxShadow: [
                  BoxShadow(
                    color: Color.fromARGB((255 * 0.1).round(), 128, 128, 128),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Order Amounts',
                        style: TextStyle(fontSize: 15.0),
                      ),
                      const Text(
                        '₹ 7,000.00',
                        style: TextStyle(
                          fontSize: 15.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Convenience',
                            style: TextStyle(fontSize: 15.0),
                          ),
                          const SizedBox(width: 4.0),
                          GestureDetector(
                            onTap: () {
                              // Handle Know More
                            },
                            child: const Text(
                              'Know More',
                              style: TextStyle(
                                fontSize: 13.0,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: () {
                          // Handle Apply Coupon
                        },
                        child: const Text(
                          'Apply Coupon',
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Delivery Fee',
                        style: TextStyle(fontSize: 15.0),
                      ),
                      const Text(
                        'Free',
                        style: TextStyle(
                          fontSize: 15.0,
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24.0),

            // Order Total Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Order Total',
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                ),
                const Text(
                  '₹ 7,000.00',
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            Row(
              children: [
                const Text('EMI Available', style: TextStyle(fontSize: 14.0)),
                const SizedBox(width: 8.0),
                GestureDetector(
                  onTap: () {
                    // Handle Details for EMI
                  },
                  child: const Text(
                    'Details',
                    style: TextStyle(fontSize: 14.0, color: Colors.blue),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 100.0), // Spacer untuk ruang di bawah
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Color.fromARGB(
                (255 * 0.1).round(),
                0,
                0,
                0,
              ), // Hitam dengan opacity 0.1
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '₹ 7,000.00',
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                ),
                GestureDetector(
                  onTap: () {
                    // Handle View Details
                  },
                  child: const Text(
                    'View Details',
                    style: TextStyle(fontSize: 12.0, color: Colors.blue),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 20.0),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  // Handle Proceed to Payment
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E528A), // Warna biru gelap
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: const Text(
                  'Proceed to Payment',
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
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
