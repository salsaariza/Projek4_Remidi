import 'dart:io'; // untuk cek internet
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'form_screen.dart';
import 'detail_screen.dart';

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
      final res = await supabase
          .from('data_siswa')
          .select('*')
          .order('created_at', ascending: false);

      setState(() {
        _students = List<Map<String, dynamic>>.from(res as List);
        _isLoading = false;
      });
    } on SocketException {
      // 🔴 Tidak ada koneksi internet
      setState(() => _isLoading = false);
      _showError("❌ Tidak ada koneksi internet");
    } catch (e) {
      // 🔴 Error dari Supabase atau error lain
      setState(() => _isLoading = false);
      _showError("❌ Masalah koneksi Supabase atau error lain: $e");
    }
  }

  Future<void> _deleteStudent(int id) async {
    try {
      await supabase.from('data_siswa').delete().eq('id', id);
      _showSuccess("✅ Data siswa berhasil dihapus");
      await _loadStudents();
    } on SocketException {
      _showError("❌ Tidak ada koneksi internet");
    } catch (e) {
      _showError("❌ Masalah koneksi Supabase atau error lain: $e");
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kaiBackground,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(20), // radius bawah AppBar
          ),
          child: AppBar(
            title: const Text(
              "Daftar Siswa",
              style: TextStyle(fontWeight: FontWeight.normal),
            ),
            centerTitle: true,
            backgroundColor: kaiPrimary,
            foregroundColor: Colors.white,
            elevation: 4,
          ),
        ),
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

                      return InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  DetailScreen(student: student),
                            ),
                          );
                        },
                        child: Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          color: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                CircleAvatar(
                                  radius: 28,
                                  backgroundColor:
                                      student['jenis_kelamin'] == 'L'
                                          ? Colors.blue
                                          : student['jenis_kelamin'] == 'P'
                                              ? Colors.pink
                                              : Colors.grey,
                                  child: Text(
                                    student['nama_lengkap']?.isNotEmpty == true
                                        ? student['nama_lengkap'][0]
                                            .toUpperCase()
                                        : '?',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        student['nama_lengkap'] ?? '-',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "${student['jenis_kelamin'] == 'L' ? 'Laki-laki' : student['jenis_kelamin'] == 'P' ? 'Perempuan' : '-'}",
                                      ),
                                      Text(
                                        "Dusun : ${student['alamat_dusun'] ?? '-'}",
                                      ),
                                      Text(
                                        "Desa : ${student['alamat_desa'] ?? '-'}",
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.edit,
                                        color: Colors.blue,
                                      ),
                                      onPressed: () async {
                                        final result = await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                FormScreen(student: student),
                                          ),
                                        );
                                        if (result == true) _loadStudents();
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.blue,
                                      ),
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: const Text(
                                                "Konfirmasi Hapus"),
                                            content: Text(
                                              "Apakah anda yakin ingin menghapus data ${student['nama_lengkap']}?",
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(context),
                                                child: const Text("Batal"),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                  _deleteStudent(
                                                      student['id']);
                                                },
                                                child: const Text(
                                                  "Hapus",
                                                  style: TextStyle(
                                                    color: Colors.red,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
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
            MaterialPageRoute(builder: (context) => const FormScreen()),
          );
          if (result == true) _loadStudents();
        },
        backgroundColor: kaiPrimary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}
