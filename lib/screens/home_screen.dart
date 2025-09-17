import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'form_screen.dart';

// Warna KAI Access
const kaiPrimary = Color(0xFF005BAC);
const kaiBackground = Color(0xFFF5F7FA);

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _students = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    setState(() => _isLoading = true);
    try {
      final res = await supabase.from('data_siswa').select('*').order('created_at', ascending: false);
      setState(() {
        _students = List<Map<String, dynamic>>.from(res);
        _isLoading = false;
      });
      print('Loaded students: ${_students.length}');
    } catch (e) {
      print('Error loading students: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Gagal memuat data: $e")),
      );
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kaiBackground,
      appBar: AppBar(
        title: const Text(
          "Daftar Siswa",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: kaiPrimary,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _students.isEmpty
              ? const Center(
                  child: Text(
                    "Belum ada data siswa",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadStudents,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: _students.length,
                    itemBuilder: (context, index) {
                      final student = _students[index];

                      return Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        color: Colors.white,
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: CircleAvatar(
                            backgroundColor: kaiPrimary,
                            child: Text(
                              student['nama_lengkap']?.isNotEmpty == true
                                  ? student['nama_lengkap'][0].toUpperCase()
                                  : '?',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                          ),
                          title: Text(
                            student['nama_lengkap'] ?? '-',
                            style: const TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 16),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text("NISN: ${student['nisn'] ?? '-'}"),
                              Text(
                                  "${student['jenis_kelamin'] == 'L' ? 'Laki-laki' : student['jenis_kelamin'] == 'P' ? 'Perempuan' : '-'}, ${student['agama'] ?? '-'}"),
                              Text("Dusun: ${student['alamat_dusun'] ?? '-'}"),
                              Text("Desa: ${student['alamat_desa'] ?? '-'}"),
                              Text("Kecamatan: ${student['alamat_kecamatan'] ?? '-'}"),
                              Text("Kabupaten: ${student['alamat_kabupaten'] ?? '-'}"),
                              Text("Provinsi: ${student['alamat_provinsi'] ?? '-'}"),
                              Text("Kode Pos: ${student['alamat_kode_pos'] ?? '-'}"),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const FormScreen(student: {},)),
          );
          if (result == true) _loadStudents(); // refresh data setelah tambah siswa
        },
        backgroundColor: kaiPrimary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}
