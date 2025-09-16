import 'package:flutter/material.dart';
import '../widgets/input_field.dart';
import '../widgets/gender_select.dart';
import '../widgets/dropdown_field.dart';
import '../utils/validator.dart';
import '../models/data_siswa.dart';
import '../services/siswa_services.dart';
import 'home_screen.dart';

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

  String? _dusun;
  String? _desa;
  String? _kecamatan;
  String? _kabupaten;
  String? _provinsi = "Jawa Timur";

  final _kodePosController = TextEditingController();
  final _ayahController = TextEditingController();
  final _ibuController = TextEditingController();
  final _waliController = TextEditingController();

  String _jenisKelamin = "Laki-laki";
  String _agama = "Islam";

  void saveData() {
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
        jalan: "-", // ✅ opsional
        rtRw: "-",
        dusun: _dusun ?? "",
        desa: _desa ?? "",
        kecamatan: _kecamatan ?? "",
        provinsi: _provinsi ?? "",
        kodePos: _kodePosController.text,
        namaAyah: _ayahController.text,
        namaIbu: _ibuController.text,
        namaWali: _waliController.text,
      );

      _service.addStudent(student);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("✅ Data berhasil disimpan")));

      Navigator.pop(context, true);
    }
  }

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
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Stepper(
              type: StepperType.vertical,
              currentStep: _currentStep,
              onStepTapped: (step) {
                setState(() => _currentStep = step);
              },
              controlsBuilder: (context, details) {
                return const SizedBox.shrink();
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
                          items: [
                            "Islam",
                            "Kristen",
                            "Katolik",
                            "Hindu",
                            "Buddha",
                          ],
                          onChanged: (val) => _agama = val,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: InputField(
                                label: "Tempat Lahir",
                                controller: _tempatLahirController,
                                validator: Validators.requiredField,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: InputField(
                                label: "Tanggal Lahir",
                                controller: _tanggalLahirController,
                                readOnly: true,
                                validator: Validators.requiredField,
                                suffixIcon: const Icon(Icons.calendar_today),
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
                                      _tanggalLahirController.text =
                                          formattedDate;
                                    });
                                  }
                                },
                              ),
                            ),
                          ],
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
                      // ✅ Autocomplete Dusun
                      Autocomplete<String>(
                        optionsBuilder: (TextEditingValue textEditingValue) {
                          if (textEditingValue.text.isEmpty)
                            return const Iterable<String>.empty();
                          return [
                            "Dusun Bedali",
                            "Dusun Duren",
                            "Dusun Kopral",
                            "Dusun Krajan",
                            "Dusun Mbandung",
                            "Dusun Rancah",
                            "Dusun Sambigede",
                            "Dusun Sidomulyo",
                            "Dusun Suko",
                            "Dusun Sumberagung",
                          ].where(
                            (dusun) => dusun.toLowerCase().contains(
                              textEditingValue.text.toLowerCase(),
                            ),
                          );
                        },
                        onSelected: (val) {
                          setState(() => _dusun = val);
                        },
                        fieldViewBuilder:
                            (
                              context,
                              controller,
                              focusNode,
                              onEditingComplete,
                            ) {
                              return TextFormField(
                                controller: controller,
                                focusNode: focusNode,
                                decoration: const InputDecoration(
                                  labelText: "Dusun",
                                  border: OutlineInputBorder(),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty)
                                    return 'Dusun harus diisi';
                                  return null;
                                },
                                onEditingComplete: onEditingComplete,
                              );
                            },
                      ),
                      const SizedBox(height: 12),
                      DropdownField(
                        label: "Desa",
                        items: [
                          "Karangkates",
                          "Ngadirejo",
                          "Sumberpucung",
                          "Kromengan",
                          "Jatikerto",
                          "Arjowilangun",
                          "Sumberagung",
                          "Sidomulyo",
                          "Sukowilangun",
                          "Senggreng",
                        ],
                        onChanged: (val) => setState(() => _desa = val),
                      ),
                      const SizedBox(height: 12),
                      DropdownField(
                        label: "Kecamatan",
                        items: [
                          "Selorejo",
                          "Kalipare",
                          "Sumberpucung",
                          "Kromengan",
                        ],
                        onChanged: (val) => setState(() => _kecamatan = val),
                      ),
                      const SizedBox(height: 12),
                      DropdownField(
                        label: "Kabupaten",
                        items: ["Malang", "Blitar"],
                        onChanged: (val) => setState(() => _kabupaten = val),
                      ),
                      const SizedBox(height: 12),
                      DropdownField(
                        label: "Provinsi",
                        items: ["Jawa Timur"],
                        onChanged: (val) => setState(() => _provinsi = val),
                      ),
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
                      InputField(
                        label: "Nama Ayah",
                        controller: _ayahController,
                      ),
                      const SizedBox(height: 12),
                      InputField(label: "Nama Ibu", controller: _ibuController),
                      const SizedBox(height: 12),
                      InputField(
                        label: "Nama Wali",
                        controller: _waliController,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              onPressed: saveData,
              icon: const Icon(Icons.save),
              label: const Text("Simpan Data"),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
