import 'package:flutter/material.dart';
import '../widgets/input_field.dart';
import '../widgets/gender_select.dart';
import '../widgets/dropdown_field.dart';
import '../utils/validator.dart';
import '../models/data_siswa.dart';
import '../services/siswa_services.dart';
import 'splash_screen.dart';

class FormScreen extends StatefulWidget {
  const FormScreen({super.key});

  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = StudentService();

  int _currentStep = 0;

  // Controllers
  final _nisnController = TextEditingController();
  final _namaController = TextEditingController();
  final _tempatLahirController = TextEditingController();
  final _tanggalLahirController = TextEditingController();
  final _nikController = TextEditingController();
  final _noHpController = TextEditingController();
  final _jalanController = TextEditingController();
  final _rtRwController = TextEditingController();
  final _dusunController = TextEditingController();
  final _desaController = TextEditingController();
  final _kecamatanController = TextEditingController();
  final _provinsiController = TextEditingController();
  final _kodePosController = TextEditingController();
  final _ayahController = TextEditingController();
  final _ibuController = TextEditingController();
  final _waliController = TextEditingController();

  String _jenisKelamin = "Laki-laki";
  String _agama = "Islam";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Form Pendaftaran"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const SplashScreen()),
            );
          },
        ),
      ),
      body: Stepper(
        type: StepperType.vertical,
        currentStep: _currentStep,
        onStepContinue: () {
          if (_currentStep < 2) {
            setState(() => _currentStep += 1);
          } else {
            if (_formKey.currentState!.validate()) {
              final student = Student(
                nisn: _nisnController.text,
                namaLengkap: _namaController.text,
                jenisKelamin: _jenisKelamin,
                agama: _agama,
                tempatTanggalLahir:
                    "${_tempatLahirController.text}, ${_tanggalLahirController.text}",
                nik: _nikController.text,
                noHp: _noHpController.text,
                jalan: _jalanController.text,
                rtRw: _rtRwController.text,
                dusun: _dusunController.text,
                desa: _desaController.text,
                kecamatan: _kecamatanController.text,
                provinsi: _provinsiController.text,
                kodePos: _kodePosController.text,
                namaAyah: _ayahController.text,
                namaIbu: _ibuController.text,
                namaWali: _waliController.text,
              );
              _service.addStudent(student);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Data berhasil disimpan")),
              );
            }
          }
        },
        onStepCancel: () {
          if (_currentStep > 0) {
            setState(() => _currentStep -= 1);
          }
        },
        steps: [
          Step(
            title: const Text("Data Pribadi"),
            content: Form(
              key: _formKey,
              child: Column(
                children: [
                  InputField(
                    label: "NISN",
                    controller: _nisnController,
                    validator: Validators.validateNumber,
                  ),
                  const SizedBox(height: 12),
                  InputField(
                    label: "Nama Lengkap",
                    controller: _namaController,
                    validator: Validators.requiredField,
                  ),
                  const SizedBox(height: 12),
                  GenderSelector(onChanged: (val) => _jenisKelamin = val),
                  const SizedBox(height: 12),
                  DropdownField(
                    label: "Agama",
                    items: ["Islam", "Kristen", "Katolik", "Hindu", "Buddha"],
                    onChanged: (val) => _agama = val,
                  ),
                  const SizedBox(height: 12),
                  // Tempat lahir biasa (input teks)
                  InputField(
                    label: "Tempat Lahir",
                    controller: _tempatLahirController,
                    validator: Validators.requiredField,
                  ),
                  const SizedBox(height: 12),
                  // Tanggal lahir dengan datepicker
                  InputField(
                    label: "Tanggal Lahir",
                    controller: _tanggalLahirController,
                    readOnly: true,
                    validator: Validators.requiredField,
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(1990),
                        lastDate: DateTime(2100),
                      );

                      if (pickedDate != null) {
                        String formattedDate =
                            "${pickedDate.day}-${pickedDate.month}-${pickedDate.year}";
                        setState(() {
                          _tanggalLahirController.text = formattedDate;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  InputField(
                    label: "NIK",
                    controller: _nikController,
                    validator: Validators.validateNumber,
                  ),
                  const SizedBox(height: 12),
                  InputField(
                    label: "No HP",
                    controller: _noHpController,
                    validator: Validators.validateNumber,
                  ),
                ],
              ),
            ),
          ),
          Step(
            title: const Text("Alamat Lengkap"),
            content: Column(
              children: [
                InputField(label: "Jalan", controller: _jalanController),
                const SizedBox(height: 12),
                InputField(label: "RT/RW", controller: _rtRwController),
                const SizedBox(height: 12),
                InputField(label: "Dusun", controller: _dusunController),
                const SizedBox(height: 12),
                InputField(label: "Desa", controller: _desaController),
                const SizedBox(height: 12),
                InputField(label: "Kecamatan", controller: _kecamatanController),
                const SizedBox(height: 12),
                InputField(label: "Provinsi", controller: _provinsiController),
                const SizedBox(height: 12),
                InputField(
                  label: "Kode Pos",
                  controller: _kodePosController,
                  validator: Validators.validateNumber,
                ),
              ],
            ),
          ),
          Step(
            title: const Text("Orang Tua / Wali"),
            content: Column(
              children: [
                InputField(label: "Nama Ayah", controller: _ayahController),
                const SizedBox(height: 12),
                InputField(label: "Nama Ibu", controller: _ibuController),
                const SizedBox(height: 12),
                InputField(label: "Nama Wali", controller: _waliController),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
