import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'form_screen.dart';
import 'detail_screen.dart';
import 'error_screen.dart';

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
  List<Map<String, dynamic>> _allStudents = [];

  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = "";
  ErrorType _errorType = ErrorType.generalError;

  final TextEditingController _searchController = TextEditingController();

  // versi 7.0.0 connectivity_plus pakai List<ConnectivityResult>
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  @override
  void initState() {
    super.initState();
    _loadStudents();

    // Pantau koneksi internet real-time
    _subscription = Connectivity().onConnectivityChanged.listen((results) {
      final result = results.isNotEmpty ? results.first : ConnectivityResult.none;
      if (result == ConnectivityResult.none) {
        setState(() {
          _hasError = true;
          _errorType = ErrorType.noInternet;
          _errorMessage = "Tidak ada koneksi internet";
        });
      } else {
        _loadStudents();
      }
    });

    // Refresh UI kalau isi search berubah (untuk suffixIcon)
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadStudents() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult.contains(ConnectivityResult.none)) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorType = ErrorType.noInternet;
          _errorMessage = "Tidak ada koneksi internet";
        });
        return;
      }

      final res = await supabase
          .from('data_siswa')
          .select('*')
          .order('created_at', ascending: false);

      setState(() {
        _allStudents = List<Map<String, dynamic>>.from(res as List);
        _students = List.from(_allStudents);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorType = ErrorType.supabaseError;
        _errorMessage = "Gagal memuat data: $e";
      });
    }
  }

  void _filterStudents(String keyword) {
    if (keyword.isEmpty) {
      setState(() => _students = List.from(_allStudents));
    } else {
      setState(() {
        _students = _allStudents.where((student) {
          final name = (student['nama_lengkap'] ?? '').toLowerCase();
          final searchLower = keyword.toLowerCase();
          return name.contains(searchLower);
        }).toList();
      });
    }
  }

  Future<void> _deleteStudent(int id) async {
    try {
      await supabase.from('data_siswa').delete().eq('id', id);
      _showSuccess("Data siswa berhasil dihapus");
      await _loadStudents();
    } catch (e) {
      _showError("Gagal menghapus data: $e");
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
            bottom: Radius.circular(20),
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
      body: Column(
        children: [
          // 🔎 Search bar dengan tombol clear/kembali
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: _filterStudents,
              decoration: InputDecoration(
                hintText: "Cari nama siswa",
                prefixIcon: const Icon(Icons.search, color: kaiPrimary),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close, color: Colors.grey),
                        onPressed: () {
                          _searchController.clear();
                          _filterStudents(""); // reset daftar
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: Colors.grey.shade400,
                    width: 1.2,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: kaiPrimary, width: 2),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: Colors.grey, width: 1),
                ),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _hasError
                    ? ErrorScreen(
                        errorType: _errorType,
                        message: _errorMessage,
                        onRetry: _loadStudents,
                      )
                    : _students.isEmpty
                        ? const Center(
                            child: Text(
                              "Belum ada data siswa",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          CircleAvatar(
                                            radius: 28,
                                            backgroundColor:
                                                student['jenis_kelamin'] == 'L'
                                                    ? Colors.blue
                                                    : student['jenis_kelamin'] ==
                                                            'P'
                                                        ? Colors.pink
                                                        : Colors.grey,
                                            child: Text(
                                              student['nama_lengkap']
                                                          ?.isNotEmpty ==
                                                      true
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
                                                  final result =
                                                      await Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          FormScreen(
                                                              student: student),
                                                    ),
                                                  );
                                                  if (result == true) {
                                                    _loadStudents();
                                                  }
                                                },
                                              ),
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.delete,
                                                  color: Colors.red,
                                                ),
                                                onPressed: () {
                                                  showDialog(
                                                    context: context,
                                                    builder: (context) =>
                                                        AlertDialog(
                                                      title: const Text(
                                                        "Konfirmasi Hapus",
                                                      ),
                                                      content: Text(
                                                        "Apakah anda yakin ingin menghapus data ${student['nama_lengkap']}?",
                                                      ),
                                                      actions: [
                                                        TextButton(
                                                          onPressed: () =>
                                                              Navigator.pop(
                                                                  context),
                                                          child: const Text(
                                                              "Batal"),
                                                        ),
                                                        TextButton(
                                                          onPressed: () {
                                                            Navigator.pop(
                                                                context);
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
          ),
        ],
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
