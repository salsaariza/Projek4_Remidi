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
            bottom: Radius.circular(20),
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
            // 🔹 Card Profil (tanpa outline)
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 3,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 45,
                      backgroundColor: student['jenis_kelamin'] == 'L'
                          ? Colors.blue
                          : student['jenis_kelamin'] == 'P'
                              ? Colors.pink
                              : kaiPrimary,
                      child: Text(
                        student['nama_lengkap']?.isNotEmpty == true
                            ? student['nama_lengkap'][0].toUpperCase()
                            : "?",
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      student['nama_lengkap'] ?? "-",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
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

            // 🔹 Detail Data (outline biru)
            _buildCard(Icons.badge, "NISN", student['nisn']),
            _buildCard(Icons.person, "Nama Lengkap", student['nama_lengkap']),
            _buildCard(Icons.book, "NIK", student['nik']),
            _buildCard(Icons.phone, "No Telp", student['no_telp_hp']),
            _buildCard(Icons.book, "Agama", student['agama']),
            _buildCard(Icons.home, "Dusun", student['alamat_dusun']),
            _buildCard(Icons.home_work, "Desa", student['alamat_desa']),
            _buildCard(Icons.map, "Kecamatan", student['alamat_kecamatan']),
            _buildCard(
                Icons.location_city, "Kabupaten", student['alamat_kabupaten']),
            _buildCard(Icons.public, "Provinsi", student['alamat_provinsi']),
            _buildCard(Icons.local_post_office, "Kode Pos",
                student['alamat_kode_pos']),
            _buildCard(Icons.cake, "Tanggal Lahir", student['tanggal_lahir']),
            _buildCard(Icons.man, "Nama Ayah", student['nama_ayah']),
            _buildCard(Icons.woman, "Nama Ibu", student['nama_ibu']),
            _buildCard(Icons.person, "Nama Wali", student['nama_wali']),
            _buildCard(Icons.home, "Alamat Orang Tua / Wali",
                student['alamat_ortu_wali']),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(IconData icon, String label, String? value) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: kaiPrimary, width: 1.2), //Outline biru
      ),
      child: ListTile(
        leading: Icon(icon, color: kaiPrimary, size: 24),
        title: Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        subtitle: Text(
          value ?? "-",
          style: const TextStyle(fontSize: 13, color: Colors.black87),
        ),
      ),
    );
  }
}
