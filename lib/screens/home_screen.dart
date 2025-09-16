import 'package:flutter/material.dart';
import '../models/data_siswa.dart';
import '../services/siswa_services.dart';
import 'form_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final StudentService _service = StudentService();
  List<Student> _students = [];

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  void _loadStudents() {
    setState(() {
      _students = _service.getStudents();
    });
  }

  Future<void> _navigateToForm() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const FormScreen()),
    );

    if (result == true) {
      _loadStudents();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Daftar Siswa"),
        centerTitle: true,
        automaticallyImplyLeading: false, // ✅ hapus tombol back
      ),
      body: _students.isEmpty
          ? const Center(child: Text("Belum ada data siswa"))
          : ListView.builder(
              itemCount: _students.length,
              itemBuilder: (context, index) {
                final student = _students[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text(
                        student.namaLengkap[0].toUpperCase(),
                      ),
                    ),
                    title: Text(student.namaLengkap),
                    subtitle: Text(
                      "NISN: ${student.nisn}\n${student.jenisKelamin}, ${student.agama}",
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToForm,
        child: const Icon(Icons.add),
      ),
    );
  }
}
