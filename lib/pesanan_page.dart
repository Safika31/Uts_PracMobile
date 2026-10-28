import 'detail_pesanan_page.dart';
import 'pesanan_page.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PesananPage extends StatefulWidget {
  const PesananPage({super.key});

  @override
  State<PesananPage> createState() => _PesananPageState();
}

class _PesananPageState extends State<PesananPage> {
  static const biru = Color(0xFF5B8DEF);
  static const kunciData = 'laundryku_pesanan';

  List<Map<String, dynamic>> pesanan = [];
  bool memuat = true;

  final namaC = TextEditingController();
  final hpC = TextEditingController();
  final alamatC = TextEditingController();
  final beratC = TextEditingController();
  final catatanC = TextEditingController();

  String layanan = 'Cuci Kering';
  String paket = 'Reguler';

  final Map<String, Map<String, int>> hargaLayanan = {
    'Cuci Kering': {'Reguler': 5000, 'Express': 7000},
    'Cuci Kering Setrika': {'Reguler': 6000, 'Express': 8000},
    'Lipat Saja': {'Reguler': 4000, 'Express': 6000},
    'Setrika Saja': {'Reguler': 5000, 'Express': 8000},
  };

  @override
  void initState() {
    super.initState();
    muatData();
  }

  @override
  void dispose() {
    namaC.dispose();
    hpC.dispose();
    alamatC.dispose();
    beratC.dispose();
    catatanC.dispose();
    super.dispose();
  }

  String rupiah(num angka) {
    final teks = angka.round().toString();
    final hasil = teks.replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]}.',
    );
    return 'Rp$hasil';
  }

  Future<void> muatData() async {
    final prefs = await SharedPreferences.getInstance();
    final isi = prefs.getString(kunciData);

    if (isi != null) {
      final List data = jsonDecode(isi);
      pesanan = data
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }

    if (mounted) {
      setState(() => memuat = false);
    }
  }

  Future<void> simpanData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(kunciData, jsonEncode(pesanan));
  }

  double get berat {
    return double.tryParse(beratC.text.replaceAll(',', '.')) ?? 0;
  }

  int get hargaPerKg => hargaLayanan[layanan]![paket]!;

  int get totalHarga => (berat * hargaPerKg).round();

  String buatId() {
    return 'LK${DateTime.now().millisecondsSinceEpoch}';
  }

  void kosongkanForm() {
    namaC.clear();
    hpC.clear();
    alamatC.clear();
    beratC.clear();
    catatanC.clear();
    layanan = 'Cuci Kering';
    paket = 'Reguler';
  }

  void bukaForm({int? indeks}) {
    final sedangEdit = indeks != null;

    if (sedangEdit) {
      final d = pesanan[indeks];
      namaC.text = d['nama'] ?? '';
      hpC.text = d['hp'] ?? '';
      alamatC.text = d['alamat'] ?? '';
      beratC.text = '${d['berat'] ?? 1}';
      catatanC.text = d['catatan'] ?? '';
      layanan = d['layanan'] ?? 'Cuci Kering';
      paket = d['paket'] ?? 'Reguler';
    } else {
      kosongkanForm();
    }

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (contextDialog, setDialog) {
            final beratSekarang =
                double.tryParse(beratC.text.replaceAll(',', '.')) ?? 0;
            final harga = hargaLayanan[layanan]![paket]!;
            final total = (beratSekarang * harga).round();

            return AlertDialog(
              title: Text(
                sedangEdit ? 'Edit Pesanan' : 'Tambah Pesanan',
              ),
              content: SizedBox(
                width: 500,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: namaC,
                        decoration: const InputDecoration(
                          labelText: 'Nama customer *',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                      ),
                      TextField(
                        controller: hpC,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'Nomor HP *',
                          prefixIcon: Icon(Icons.phone_outlined),
                        ),
                      ),
                      TextField(
                        controller: alamatC,
                        decoration: const InputDecoration(
                          labelText: 'Alamat',
                          prefixIcon: Icon(Icons.location_on_outlined),
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: layanan,
                        decoration: const InputDecoration(
                          labelText: 'Jenis layanan',
                        ),
                        items: hargaLayanan.keys.map((nama) {
                          return DropdownMenuItem(
                            value: nama,
                            child: Text(nama),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setDialog(() => layanan = value);
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: paket,
                        decoration: const InputDecoration(
                          labelText: 'Paket layanan',
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'Reguler',
                            child: Text('Reguler'),
                          ),
                          DropdownMenuItem(
                            value: 'Express',
                            child: Text('Express'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setDialog(() => paket = value);
                          }
                        },
                      ),
                      TextField(
                        controller: beratC,
                        keyboardType:
                        const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Berat laundry (kg) *',
                          hintText: 'Contoh: 2.5',
                        ),
                        onChanged: (_) => setDialog(() {}),
                      ),
                      TextField(
                        controller: catatanC,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          labelText: 'Catatan pesanan',
                        ),
                      ),
                      const SizedBox(height: 18),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEAF1FF),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Harga per kg: ${rupiah(harga)}'),
                            const SizedBox(height: 6),
                            Text(
                              'TOTAL: ${rupiah(total)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: biru,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final nama = namaC.text.trim();
                    final hp = hpC.text.trim();
                    final beratInput = double.tryParse(
                      beratC.text.replaceAll(',', '.'),
                    ) ??
                        0;

                    if (nama.isEmpty || hp.isEmpty || beratInput <= 0) {
                      ScaffoldMessenger.of(this.context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Isi nama, nomor HP, dan berat yang valid.',
                          ),
                        ),
                      );
                      return;
                    }

                    final lama = sedangEdit ? pesanan[indeks] : null;

                    final dataBaru = <String, dynamic>{
                      'id': lama?['id'] ?? buatId(),
                      'tanggal': lama?['tanggal'] ??
                          DateTime.now().toIso8601String(),
                      'nama': nama,
                      'hp': hp,
                      'alamat': alamatC.text.trim(),
                      'layanan': layanan,
                      'paket': paket,
                      'berat': beratInput,
                      'harga': hargaLayanan[layanan]![paket]!,
                      'total': (beratInput *
                          hargaLayanan[layanan]![paket]!)
                          .round(),
                      'catatan': catatanC.text.trim(),
                      'status': lama?['status'] ?? 'Diproses',
                    };

                    setState(() {
                      if (sedangEdit) {
                        pesanan[indeks] = dataBaru;
                      } else {
                        pesanan.insert(0, dataBaru);
                      }
                    });

                    await simpanData();

                    if (!dialogContext.mounted) return;
                    Navigator.pop(dialogContext);

                    if (!mounted) return;
                    ScaffoldMessenger.of(this.context).showSnackBar(
                      SnackBar(
                        content: Text(
                          sedangEdit
                              ? 'Pesanan berhasil diperbarui.'
                              : 'Pesanan berhasil ditambahkan.',
                        ),
                      ),
                    );
                  },
                  child: Text(sedangEdit ? 'Simpan Perubahan' : 'Simpan'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> ubahStatus(int indeks, String status) async {
    setState(() {
      pesanan[indeks]['status'] = status;
    });
    await simpanData();
  }

  Future<void> hapusPesanan(int indeks) async {
    final setuju = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus pesanan?'),
        content: Text(
          'Pesanan ${pesanan[indeks]['nama']} akan dihapus.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (setuju == true) {
      setState(() => pesanan.removeAt(indeks));
      await simpanData();
    }
  }

  String tanggalSingkat(String iso) {
    final d = DateTime.tryParse(iso)?.toLocal() ?? DateTime.now();
    return '${d.day.toString().padLeft(2, '0')}/'
        '${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  Future<void> buatNota(Map<String, dynamic> d) async {
    final doc = pw.Document();

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a5,
        margin: const pw.EdgeInsets.all(28),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text(
                      'LaundryKu',
                      style: pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text('NOTA PEMESANAN LAUNDRY'),
                    pw.SizedBox(height: 12),
                  ],
                ),
              ),
              pw.Divider(),
              pw.Text('Nomor: ${d['id']}'),
              pw.Text('Tanggal: ${tanggalSingkat(d['tanggal'])}'),
              pw.SizedBox(height: 12),
              pw.Text(
                'DATA CUSTOMER',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 5),
              pw.Text('Nama: ${d['nama']}'),
              pw.Text('Nomor HP: ${d['hp']}'),
              pw.Text('Alamat: ${d['alamat'] ?? '-'}'),
              pw.SizedBox(height: 12),
              pw.Text(
                'RINCIAN PESANAN',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 6),
              pw.TableHelper.fromTextArray(
                headers: ['Keterangan', 'Detail'],
                data: [
                  ['Layanan', '${d['layanan']}'],
                  ['Paket', '${d['paket']}'],
                  ['Berat', '${d['berat']} kg'],
                  ['Harga/kg', rupiah(d['harga'] as num)],
                  ['Status', '${d['status']}'],
                ],
                border: pw.TableBorder.all(
                  color: PdfColors.grey400,
                ),
                headerDecoration: const pw.BoxDecoration(
                  color: PdfColors.blue100,
                ),
                cellPadding: const pw.EdgeInsets.all(6),
              ),
              pw.SizedBox(height: 12),
              if ((d['catatan'] ?? '').toString().isNotEmpty)
                pw.Text('Catatan: ${d['catatan']}'),
              pw.SizedBox(height: 10),
              pw.Divider(),
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Text(
                  'TOTAL: ${rupiah(d['total'] as num)}',
                  style: pw.TextStyle(
                    fontSize: 17,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.Spacer(),
              pw.Center(
                child: pw.Text(
                  'Terima kasih telah menggunakan LaundryKu.',
                  textAlign: pw.TextAlign.center,
                ),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => doc.save(),
      name: 'Nota_LaundryKu_${d['id']}.pdf',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FF),
      appBar: AppBar(
        title: const Text(
          'Data Pesanan Laundry',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: biru,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => bukaForm(),
        backgroundColor: biru,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Tambah Pesanan'),
      ),
      body: memuat
          ? const Center(child: CircularProgressIndicator())
          : pesanan.isEmpty
          ? const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.local_laundry_service_outlined,
                size: 70,
                color: biru,
              ),
              SizedBox(height: 16),
              Text(
                'Belum ada pesanan laundry',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Tekan Tambah Pesanan untuk memasukkan data customer.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
        itemCount: pesanan.length,
        itemBuilder: (context, indeks) {
          final d = pesanan[indeks];
          final selesai = d['status'] == 'Selesai';

          return Card(
            color: Colors.white,
            margin: const EdgeInsets.only(bottom: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        backgroundColor:
                        biru.withValues(alpha: 0.13),
                        child: const Icon(
                          Icons.person,
                          color: biru,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${d['nama']}',
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text('${d['hp']}'),
                            Text(
                              '${d['id']} • ${tanggalSingkat(d['tanggal'])}',
                              style: const TextStyle(
                                color: Colors.blueGrey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      PopupMenuButton<String>(
                        onSelected: (pilihan) {
                          if (pilihan == 'edit') {
                            bukaForm(indeks: indeks);
                          } else if (pilihan == 'hapus') {
                            hapusPesanan(indeks);
                          } else if (pilihan == 'nota') {
                            buatNota(d);
                          }
                        },
                        itemBuilder: (context) => const [
                          PopupMenuItem(
                            value: 'edit',
                            child: Text('Edit pesanan'),
                          ),
                          PopupMenuItem(
                            value: 'nota',
                            child: Text('Buat / cetak nota PDF'),
                          ),
                          PopupMenuItem(
                            value: 'hapus',
                            child: Text('Hapus pesanan'),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Text('${d['layanan']} • ${d['paket']}'),
                  Text('Berat: ${d['berat']} kg'),
                  if ((d['catatan'] ?? '').toString().isNotEmpty)
                    Text('Catatan: ${d['catatan']}'),
                  const SizedBox(height: 8),
                  Text(
                    'Total: ${rupiah(d['total'] as num)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: biru,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Text(
                        'Status:',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: selesai ? 'Selesai' : 'Diproses',
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: selesai
                                ? const Color(0xFFE2F7E9)
                                : const Color(0xFFFFF0D6),
                            contentPadding:
                            const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            border: OutlineInputBorder(
                              borderRadius:
                              BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'Diproses',
                              child: Text('Diproses'),
                            ),
                            DropdownMenuItem(
                              value: 'Selesai',
                              child: Text('Selesai'),
                            ),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              ubahStatus(indeks, value);
                            }
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => buatNota(d),
                      icon: const Icon(Icons.picture_as_pdf),
                      label: const Text('Buat Nota PDF'),
                    ),
                  ),

// Tombol Detail Progres
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => DetailPesananPage(
                              pesanan: Map<String, dynamic>.from(d),
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.timeline_rounded),
                      label: const Text('Lihat Detail Progres'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE7EEFF),
                        foregroundColor: const Color(0xFF4779DF),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
