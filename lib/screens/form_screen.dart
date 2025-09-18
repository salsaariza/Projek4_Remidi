import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/input_field.dart';
import '../widgets/gender_select.dart';
import '../widgets/dropdown_field.dart';
import '../widgets/autocomplete_field.dart';

// Warna mirip KAI Access
const kaiPrimary = Color(0xFF005BAC);
const kaiAccent = Color(0xFF00AEEF);
const kaiBackground = Color(0xFFF5F7FA);

class FormScreen extends StatefulWidget {
  final Map<String, dynamic>? student; // Parameter opsional untuk edit

  const FormScreen({super.key, this.student});

  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  final _formKey = GlobalKey<FormState>();
  final supabase = Supabase.instance.client;

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
  final _ayahController = TextEditingController();
  final _ibuController = TextEditingController();
  final _waliController = TextEditingController();
  final _alamatOrtuController = TextEditingController();

  // Location variables
  String? _selectedKabupaten;
  String? _selectedKecamatan;
  String? _selectedDesa;
  String? _selectedDusun;
  String? _selectedKodePos;

  // Other variables
  String _jenisKelamin = "Laki-laki";
  String _agama = "Islam";

  @override
  void initState() {
    super.initState();
    _loadStudentData();
  }

  void _loadStudentData() {
    final student = widget.student;
    if (student != null) {
      _nisnController.text = student['nisn'] ?? '';
      _namaController.text = student['nama_lengkap'] ?? '';
      _jenisKelamin =
          student['jenis_kelamin'] == 'L' ? 'Laki-laki' : 'Perempuan';
      _agama = student['agama'] ?? 'Islam';
      _tempatLahirController.text = student['tempat_lahir'] ?? '';
      if (student['tanggal_lahir'] != null) {
        DateTime tgl = DateTime.parse(student['tanggal_lahir']);
        _tanggalLahirController.text = "${tgl.day}-${tgl.month}-${tgl.year}";
      }
      _noHpController.text = student['no_telp_hp'] ?? '';
      _nikController.text = student['nik'] ?? '';
      _jalanController.text = student['alamat_jalan'] ?? '';
      _rtRwController.text =
          "${student['alamat_rt'] ?? ''}/${student['alamat_rw'] ?? ''}";
      _selectedDusun = student['alamat_dusun'];
      _selectedDesa = student['alamat_desa'];
      _selectedKecamatan = student['alamat_kecamatan'];
      _selectedKabupaten = student['alamat_kabupaten'];
      _selectedKodePos = student['alamat_kode_pos'];
      _ayahController.text = student['nama_ayah'] ?? '';
      _ibuController.text = student['nama_ibu'] ?? '';
      _waliController.text = student['nama_wali'] ?? '';
      _alamatOrtuController.text = student['alamat_ortu_wali'] ?? '';
    }
  }

  Future<List<String>> _getAllDusun() async {
    try {
      final response =
          await supabase.from('locations').select('dusun').order('dusun');
      return response.map((item) => item['dusun'] as String).toList();
    } catch (e) {
      debugPrint('Error fetching dusun: $e');
      return [];
    }
  }

  Future<void> _updateLocationFromDusun(String dusun) async {
    try {
      final response =
          await supabase.from('locations').select('*').eq('dusun', dusun).limit(1);

      if (response.isNotEmpty) {
        final location = response.first;
        setState(() {
          _selectedDusun = dusun;
          _selectedDesa = location['desa'] as String?;
          _selectedKecamatan = location['kecamatan'] as String?;
          _selectedKabupaten = location['kabupaten'] as String?;
          _selectedKodePos = location['kode_pos'] as String?;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Dusun tidak ditemukan")),
        );
      }
    } catch (e) {
      debugPrint('Error updating location: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal memuat lokasi: $e")),
      );
    }
  }

  void saveData() async {
    bool isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Mohon lengkapi semua data")),
      );
      return;
    }

    if (_selectedDusun == null ||
        _selectedDesa == null ||
        _selectedKecamatan == null ||
        _selectedKabupaten == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pilih alamat lengkap terlebih dahulu")),
      );
      return;
    }

    String? rt;
    String? rw;
    if (_rtRwController.text.isNotEmpty) {
      final parts = _rtRwController.text.split('/');
      rt = parts.isNotEmpty ? parts[0].trim() : null;
      rw = parts.length > 1 ? parts[1].trim() : null;
    }

    DateTime? tanggalLahir;
    try {
      final parts = _tanggalLahirController.text.split('-');
      if (parts.length == 3) {
        tanggalLahir = DateTime(
          int.parse(parts[2]),
          int.parse(parts[1]),
          int.parse(parts[0]),
        );
      }
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Format tanggal lahir salah")),
      );
      return;
    }

    final data = {
      'nisn': _nisnController.text,
      'nama_lengkap': _namaController.text,
      'jenis_kelamin': _jenisKelamin == 'Laki-laki' ? 'L' : 'P',
      'agama': _agama,
      'tempat_lahir': _tempatLahirController.text,
      'tanggal_lahir': tanggalLahir?.toIso8601String(),
      'no_telp_hp':
          _noHpController.text.isEmpty ? null : _noHpController.text,
      'nik': _nikController.text,
      'alamat_jalan': _jalanController.text,
      'alamat_rt': rt,
      'alamat_rw': rw,
      'alamat_dusun': _selectedDusun,
      'alamat_desa': _selectedDesa,
      'alamat_kecamatan': _selectedKecamatan,
      'alamat_kabupaten': _selectedKabupaten,
      'alamat_provinsi': 'Jawa Timur',
      'alamat_kode_pos': _selectedKodePos,
      'nama_ayah':
          _ayahController.text.isEmpty ? null : _ayahController.text,
      'nama_ibu':
          _ibuController.text.isEmpty ? null : _ibuController.text,
      'nama_wali':
          _waliController.text.isEmpty ? null : _waliController.text,
      'alamat_ortu_wali':
          _alamatOrtuController.text.isEmpty ? null : _alamatOrtuController.text,
    };

    try {
      if (widget.student == null) {
        await supabase.from('data_siswa').insert(data);
      } else {
        await supabase
            .from('data_siswa')
            .update(data)
            .eq('id', widget.student!['id']);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Data berhasil disimpan")),
      );
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal simpan: $e")),
      );
    }
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
            title: Text(
              widget.student == null
                  ? "Form Pendaftaran"
                  : "Edit Data Siswa",
            ),
            backgroundColor: kaiPrimary,
            foregroundColor: Colors.white,
            elevation: 4,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Stepper(
                type: StepperType.vertical,
                currentStep: _currentStep,
                onStepTapped: (step) => setState(() => _currentStep = step),
                controlsBuilder: (context, details) =>
                    const SizedBox.shrink(),
                steps: [
                  Step(
                    title: const Text("Data Diri"),
                    isActive: _currentStep == 0,
                    content: _buildCard(_buildDataDiri()),
                  ),
                  Step(
                    title: const Text("Alamat"),
                    isActive: _currentStep == 1,
                    content: _buildCard(_buildAlamat()),
                  ),
                  Step(
                    title: const Text("Orang Tua / Wali"),
                    isActive: _currentStep == 2,
                    content: _buildCard(_buildOrtu()),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: saveData,
                icon: const Icon(Icons.save),
                label: const Text("Simpan Data"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kaiPrimary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard(Widget child) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: child,
      ),
    );
  }

  Widget _buildDataDiri() {
    return Column(
      children: [
        InputField(
          controller: _nisnController,
          label: "NISN",
          validator: (val) {
            if (val == null || val.isEmpty) return 'NISN wajib diisi';
            if (val.length != 10) return 'NISN harus 10 digit';
            return null;
          },
        ),
        const SizedBox(height: 12),
        InputField(
          controller: _namaController,
          label: "Nama Lengkap",
          validator: (val) =>
              val == null || val.isEmpty ? 'Wajib diisi' : null,
        ),
        const SizedBox(height: 12),
        GenderSelector(onChanged: (val) => _jenisKelamin = val),
        const SizedBox(height: 12),
        DropdownField(
          label: "Agama",
          value: _agama,
          items: const [
            "Islam",
            "Kristen",
            "Katolik",
            "Hindu",
            "Buddha"
          ],
          onChanged: (val) => setState(() => _agama = val),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: InputField(
                controller: _tempatLahirController,
                label: "Tempat Lahir",
                validator: (val) =>
                    val == null || val.isEmpty ? 'Wajib diisi' : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: InputField(
                controller: _tanggalLahirController,
                label: "Tanggal Lahir",
                readOnly: true,
                suffixIcon:
                    const Icon(Icons.calendar_today, color: kaiPrimary),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Wajib diisi' : null,
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime(2010),
                    firstDate: DateTime(1990),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    _tanggalLahirController.text =
                        "${date.day}-${date.month}-${date.year}";
                  }
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        InputField(
          controller: _noHpController,
          label: "No HP",
          validator: (val) {
            if (val == null || val.isEmpty) return null;
            if (!RegExp(r'^\d{10,15}$').hasMatch(val)) {
              return 'No HP harus 10-15 angka';
            }
            return null;
          },
        ),
        const SizedBox(height: 12),
        InputField(
          controller: _nikController,
          label: "NIK",
          validator: (val) =>
              val == null || val.isEmpty ? 'Wajib diisi' : null,
        ),
      ],
    );
  }

  Widget _buildAlamat() {
    return Column(
      children: [
        InputField(
          controller: _jalanController,
          label: "Jalan",
          validator: (val) =>
              val == null || val.isEmpty ? 'Wajib diisi' : null,
        ),
        const SizedBox(height: 12),
        InputField(
          controller: _rtRwController,
          label: "RT/RW",
          validator: (val) =>
              val == null || val.isEmpty ? 'Wajib diisi' : null,
        ),
        const SizedBox(height: 12),
        FutureBuilder<List<String>>(
          future: _getAllDusun(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Text('Tidak ada data dusun tersedia');
            }

            return AutocompleteField(
              label: "Dusun",
              options: snapshot.data!,
              initialValue: _selectedDusun,
              onSelected: (val) => _updateLocationFromDusun(val),
              validator: (val) =>
                  val == null || val.isEmpty ? 'Pilih dusun' : null,
            );
          },
        ),
        const SizedBox(height: 12),
        _buildInfo("Desa", _selectedDesa),
        const SizedBox(height: 12),
        _buildInfo("Kecamatan", _selectedKecamatan),
        const SizedBox(height: 12),
        _buildInfo("Kabupaten", _selectedKabupaten),
        const SizedBox(height: 12),
        _buildInfo("Provinsi", "Jawa Timur", fixed: true),
        const SizedBox(height: 12),
        _buildInfo("Kode Pos", _selectedKodePos),
      ],
    );
  }

  Widget _buildOrtu() {
    return Column(
      children: [
        InputField(
          controller: _ayahController,
          label: "Nama Ayah",
          validator: (val) =>
              val == null || val.isEmpty ? 'Wajib diisi' : null,
        ),
        const SizedBox(height: 12),
        InputField(
          controller: _ibuController,
          label: "Nama Ibu",
          validator: (val) =>
              val == null || val.isEmpty ? 'Wajib diisi' : null,
        ),
        const SizedBox(height: 12),
        InputField(controller: _waliController, label: "Nama Wali"),
        const SizedBox(height: 12),
        InputField(
          controller: _alamatOrtuController,
          label: "Alamat Orang Tua / Wali",
          validator: (val) =>
              val == null || val.isEmpty ? 'Wajib diisi' : null,
        ),
      ],
    );
  }

  Widget _buildInfo(String label, String? value, {bool fixed = false}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey.shade50,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.location_on, color: kaiPrimary, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value ?? (fixed ? "Jawa Timur" : "Pilih dusun terlebih dahulu"),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: (value != null || fixed)
                  ? Colors.black87
                  : Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nisnController.dispose();
    _namaController.dispose();
    _tempatLahirController.dispose();
    _tanggalLahirController.dispose();
    _nikController.dispose();
    _noHpController.dispose();
    _jalanController.dispose();
    _rtRwController.dispose();
    _ayahController.dispose();
    _ibuController.dispose();
    _waliController.dispose();
    _alamatOrtuController.dispose();
    super.dispose();
  }
}
