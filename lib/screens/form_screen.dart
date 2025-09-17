import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/input_field.dart';
import '../widgets/gender_select.dart';
import '../widgets/dropdown_field.dart';
import '../widgets/autocomplete_field.dart';

// Warna mirip KAI Access
const kaiPrimary = Color(0xFF005BAC); // Biru tua
const kaiAccent = Color(0xFF00AEEF); // Biru muda/aksen
const kaiBackground = Color(0xFFF5F7FA); // Background abu muda

class FormScreen extends StatefulWidget {
  const FormScreen({super.key, required Map<String, dynamic> student});

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

  // Get all dusun
  Future<List<String>> _getAllDusun() async {
    try {
      final response = await supabase
          .from('locations')
          .select('dusun')
          .order('dusun');
      return response.map((item) => item['dusun'] as String).toList();
    } catch (e) {
      print('Error fetching dusun: $e');
      return [];
    }
  }

  // Update location from dusun
  Future<void> _updateLocationFromDusun(String dusun) async {
    try {
      final response = await supabase
          .from('locations')
          .select('*')
          .eq('dusun', dusun)
          .limit(1);

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
          const SnackBar(content: Text("❌ Dusun tidak ditemukan")),
        );
      }
    } catch (e) {
      print('Error updating location: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("❌ Gagal memuat lokasi: $e")));
    }
  }

  void saveData() async {
    print('Starting saveData...'); // Debug: Awal fungsi
    if (_formKey.currentState!.validate()) {
      print('Form validation passed'); // Debug: Validasi form berhasil
      print(
        'Location data: dusun=$_selectedDusun, desa=$_selectedDesa, kecamatan=$_selectedKecamatan, kabupaten=$_selectedKabupaten, kode_pos=$_selectedKodePos',
      );

      if (_selectedDusun == null ||
          _selectedDesa == null ||
          _selectedKecamatan == null ||
          _selectedKabupaten == null) {
        print(
          'Location validation failed: Missing location data',
        ); // Debug: Validasi lokasi gagal
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("❌ Pilih alamat lengkap terlebih dahulu"),
          ),
        );
        return;
      }

      try {
        // Split RT/RW if provided
        String? rt;
        String? rw;
        if (_rtRwController.text.isNotEmpty) {
          final rtRw = _rtRwController.text.split('/');
          rt = rtRw.isNotEmpty ? rtRw[0].trim() : null;
          rw = rtRw.length > 1 ? rtRw[1].trim() : null;
          print('RT/RW parsed: rt=$rt, rw=$rw'); // Debug: Parsing RT/RW
        } else {
          print('RT/RW empty'); // Debug: RT/RW kosong
        }

        // Parse tanggal_lahir to DateTime
        DateTime? tanggalLahir;
        try {
          final dateParts = _tanggalLahirController.text.split('-');
          print('Date parts: $dateParts'); // Debug: Bagian tanggal
          if (dateParts.length == 3) {
            tanggalLahir = DateTime(
              int.parse(dateParts[2]), // year
              int.parse(dateParts[1]), // month
              int.parse(dateParts[0]), // day
            );
            print(
              'Parsed tanggal_lahir: ${tanggalLahir.toIso8601String()}',
            ); // Debug: Tanggal berhasil diparse
          } else {
            print(
              'Invalid date format: ${dateParts.length} parts found',
            ); // Debug: Format tanggal salah
            throw Exception('Invalid date format');
          }
        } catch (e) {
          print(
            'Error parsing tanggal_lahir: $e',
          ); // Debug: Error parsing tanggal
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("❌ Format tanggal lahir tidak valid")),
          );
          return;
        }

        // Data to be inserted
        final data = {
          'nisn': _nisnController.text,
          'nama_lengkap': _namaController.text,
          'jenis_kelamin': _jenisKelamin == 'Laki-laki' ? 'L' : 'P',
          'agama': _agama,
          'tempat_lahir': _tempatLahirController.text,
          'tanggal_lahir': tanggalLahir.toIso8601String(),
          'no_telp_hp': _noHpController.text.isEmpty
              ? null
              : _noHpController.text,
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
          'nama_ayah': _ayahController.text.isEmpty
              ? null
              : _ayahController.text,
          'nama_ibu': _ibuController.text.isEmpty ? null : _ibuController.text,
          'nama_wali': _waliController.text.isEmpty
              ? null
              : _waliController.text,
          'alamat_ortu_wali': _alamatOrtuController.text.isEmpty
              ? null
              : _alamatOrtuController.text,
        };

        // Debug: Print data before insert
        print('Data to insert: $data');

        // Insert data into data_siswa table
        print('Sending insert to Supabase...'); // Debug: Sebelum insert
        await supabase.from('data_siswa').insert(data);
        print('Insert successful'); // Debug: Insert berhasil

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Data berhasil disimpan")),
        );
        Navigator.pop(context, true);
      } catch (e) {
        print('Error saving data: $e'); // Debug: Error saat insert
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("❌ Gagal simpan: $e")));
      }
    } else {
      print('Form validation failed'); // Debug: Validasi form gagal
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Isi semua kolom wajib dengan benar")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kaiBackground,
      appBar: AppBar(
        title: const Text("Form Pendaftaran"),
        backgroundColor: kaiPrimary,
        foregroundColor: Colors.white,
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
                controlsBuilder: (context, details) {
                  return const SizedBox.shrink();
                },
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

  // Wrap content in card with shadow
  Widget _buildCard(Widget child) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      color: Colors.white,
      child: Padding(padding: const EdgeInsets.all(16.0), child: child),
    );
  }

  // --- Data Diri ---
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
          validator: (val) => val == null || val.isEmpty ? 'Wajib diisi' : null,
        ),
        const SizedBox(height: 12),
        GenderSelector(onChanged: (val) => _jenisKelamin = val),
        const SizedBox(height: 12),
        DropdownField(
          label: "Agama",
          value: _agama,
          items: const ["Islam", "Kristen", "Katolik", "Hindu", "Buddha"],
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
                suffixIcon: const Icon(Icons.calendar_today, color: kaiPrimary),
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
            if (val == null || val.isEmpty) return null; // No HP opsional
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
          validator: (val) => val == null || val.isEmpty ? 'Wajib diisi' : null,
        ),
      ],
    );
  }

  // --- Alamat ---
  Widget _buildAlamat() {
    return Column(
      children: [
        InputField(
          controller: _jalanController,
          label: "Jalan",
          validator: (val) => val == null || val.isEmpty ? 'Wajib diisi' : null,
        ),
        const SizedBox(height: 12),
        InputField(
          controller: _rtRwController,
          label: "RT/RW",
          validator: (val) => val == null || val.isEmpty ? 'Wajib diisi' : null,
        ),
        const SizedBox(height: 12),
        FutureBuilder<List<String>>(
          future: _getAllDusun(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              print('Error in FutureBuilder: ${snapshot.error}');
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

  // --- Orang Tua/Wali ---
  Widget _buildOrtu() {
    return Column(
      children: [
        InputField(
          controller: _ayahController,
          label: "Nama Ayah",
          validator: (val) => val == null || val.isEmpty ? 'Wajib diisi' : null,
        ),
        const SizedBox(height: 12),
        InputField(
          controller: _ibuController,
          label: "Nama Ibu",
          validator: (val) => val == null || val.isEmpty ? 'Wajib diisi' : null,
        ),
        const SizedBox(height: 12),
        InputField(controller: _waliController, label: "Nama Wali"),
        const SizedBox(height: 12),
        InputField(
          controller: _alamatOrtuController,
          label: "Alamat Orang Tua / Wali",
          validator: (val) => val == null || val.isEmpty ? 'Wajib diisi' : null,
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
