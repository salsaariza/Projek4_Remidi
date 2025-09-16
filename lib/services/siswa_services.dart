import '../models/data_siswa.dart';

class StudentService {
  // ✅ Simpan data siswa sementara di list lokal
  static final List<Student> _students = [];

  /// Tambah data siswa
  void addStudent(Student student) {
    _students.add(student);
  }

  /// Ambil semua data siswa
  List<Student> getStudents() {
    return _students;
  }
}
