import 'package:flutter/material.dart';

const kaiPrimary = Color(0xFF005BAC);
const kaiBackground = Color(0xFFF5F7FA);

class DetailScreen extends StatelessWidget {
  final Map<String, dynamic> student;

  const DetailScreen({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kaiBackground,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(20), // 🔹 Border radius bawah AppBar
          ),
          child: AppBar(
            title: Text(student['nama_lengkap'] ?? "Detail Siswa"),
            backgroundColor: kaiPrimary,
            foregroundColor: Colors.white,
            elevation: 4,
            centerTitle: true,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 🔹 Heading dalam Card
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: student['jenis_kelamin'] == 'L'
                          ? Colors.blue
                          : student['jenis_kelamin'] == 'P'
                              ? Colors.pink
                              : kaiPrimary,
                      child: Text(
                        student['nama_lengkap']?.isNotEmpty == true
                            ? student['nama_lengkap'][0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 32,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      student['nama_lengkap'] ?? "-",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      student['jenis_kelamin'] == 'L'
                          ? "Laki-laki"
                          : student['jenis_kelamin'] == 'P'
                              ? "Perempuan"
                              : "-",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 🔹 Card data detail
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  children: [
                    _buildTile(Icons.badge, "NISN", student['nisn']),
                    _buildTile(Icons.person, "Nama Lengkap", student['nama_lengkap']),
                    _buildTile(Icons.book, "Agama", student['agama']),
                    _buildTile(Icons.home, "Dusun", student['alamat_dusun']),
                    _buildTile(Icons.home_work, "Desa", student['alamat_desa']),
                    _buildTile(Icons.map, "Kecamatan", student['alamat_kecamatan']),
                    _buildTile(Icons.location_city, "Kabupaten", student['alamat_kabupaten']),
                    _buildTile(Icons.public, "Provinsi", student['alamat_provinsi']),
                    _buildTile(Icons.local_post_office, "Kode Pos", student['alamat_kode_pos']),
                    _buildTile(Icons.cake, "Tanggal Lahir", student['tanggal_lahir']),
                    _buildTile(Icons.man, "Nama Ayah", student['nama_ayah']),
                    _buildTile(Icons.woman, "Nama Ibu", student['nama_ibu']),
                    _buildTile(Icons.person, "Nama Wali", student['nama_wali']),
                    _buildTile(Icons.home, "Alamat Orang Tua / Wali", student['alamat_ortu_wali']),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTile(IconData icon, String label, String? value) {
    return ListTile(
      leading: Icon(icon, color: kaiPrimary),
      title: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(value ?? "-"),
      dense: true,
    );
  }
}
