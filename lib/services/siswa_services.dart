import '../models/data_siswa.dart';

class StudentService {
  final List<Student> _students = [];

  void addStudent(Student student) {
    _students.add(student);
  }

  List<Student> getAllStudents() {
    return _students;
  }
}
