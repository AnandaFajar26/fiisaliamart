import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart'; // untuk kIsWeb
import 'admin_login.dart';

class HalamanProfilAdmin extends StatefulWidget {
  const HalamanProfilAdmin({super.key});

  @override
  State<HalamanProfilAdmin> createState() => _HalamanProfilAdminState();
}

class _HalamanProfilAdminState extends State<HalamanProfilAdmin> {
  final supabase = Supabase.instance.client;
  final _namaController = TextEditingController();
  final _alamatController = TextEditingController();
  String? fotoUrl;
  String? email;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final userId = user.id;
    email = user.email;

    final data =
        await supabase
            .from('admin_profiles')
            .select()
            .eq('id', userId)
            .maybeSingle();

    if (data != null) {
      _namaController.text = data['full_name'] ?? '';
      _alamatController.text = data['alamat'] ?? '';
      fotoUrl = data['profile_url'];
    }

    setState(() {
      loading = false;
    });
  }

  Future<void> simpanPerubahan() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    await supabase.from('admin_profiles').upsert({
      'id': userId,
      'full_name': _namaController.text.trim(),
      'alamat': _alamatController.text.trim(),
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Profil berhasil diperbarui")));
  }

  Future<void> uploadFoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';

      Uint8List fileBytes;
      if (kIsWeb) {
        fileBytes = await pickedFile.readAsBytes();
      } else {
        fileBytes =
            await pickedFile.readAsBytes(); // Bisa dioptimalkan lagi jika perlu
      }

      await supabase.storage.from('avatars').uploadBinary(fileName, fileBytes);
      final publicUrl = supabase.storage.from('avatars').getPublicUrl(fileName);

      await supabase
          .from('admin_profiles')
          .update({'profile_url': publicUrl})
          .eq('id', userId);

      setState(() {
        fotoUrl = publicUrl;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Foto profil berhasil diunggah")),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Gagal upload foto: $e")));
    }
  }

  Future<void> logout() async {
    await supabase.auth.signOut();
    Get.offAll(() => const AdminLoginScreen());
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Profil Admin")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Center(
              child: GestureDetector(
                onTap: uploadFoto,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage:
                      fotoUrl != null ? NetworkImage(fotoUrl!) : null,
                  child:
                      fotoUrl == null
                          ? const Icon(Icons.person, size: 50)
                          : null,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                email ?? '',
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _namaController,
              decoration: const InputDecoration(
                labelText: "Nama Lengkap",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _alamatController,
              decoration: const InputDecoration(
                labelText: "Alamat",
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: simpanPerubahan,
              icon: const Icon(Icons.save),
              label: const Text("Simpan Perubahan"),
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: logout,
              icon: const Icon(Icons.logout),
              label: const Text("Logout"),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
