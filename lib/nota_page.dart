import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NotaPage extends StatelessWidget {
  final String nomorNota;
  final String namaPelanggan;
  final String telepon;
  final String alamat;
  final String layanan;
  final String pengerjaan;
  final double berat;
  final int hargaPerKg;
  final String status;
  final String catatan;

  const NotaPage({
    super.key,
    required this.nomorNota,
    required this.namaPelanggan,
    required this.telepon,
    required this.alamat,
    required this.layanan,
    required this.pengerjaan,
    required this.berat,
    required this.hargaPerKg,
    required this.status,
    this.catatan = '-',
  });

  int get total => (berat * hargaPerKg).round();

  String rupiah(num angka) {
    final teks = angka.round().toString();
    final hasil = teks.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (cocok) => '.',
    );
    return 'Rp $hasil';
  }

  String get isiNota => '''
LAUNDRYKU
NOTA PESANAN
Nomor Nota: $nomorNota
Nama: $namaPelanggan
Telepon: $telepon
Alamat: $alamat
Layanan: $layanan
Pengerjaan: $pengerjaan
Berat: $berat kg
Harga/kg: ${rupiah(hargaPerKg)}
Total: ${rupiah(total)}
Status: $status
Catatan: $catatan
Terima kasih telah menggunakan LaundryKu.
''';

  // TAMBAHKAN FUNGSI PDF DI SINI
  Future<void> buatPdf(BuildContext context) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Text(
              'Nota Pesanan LaundryKu',
              style: pw.TextStyle(
                fontSize: 24,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          );
        },
      ),
    );

    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'nota_laundryku.pdf',
    );
  }

  @override
  Widget build(BuildContext context) {
    const biru = Color(0xFF3977C3);

    return Scaffold(
      backgroundColor: const Color(0xFFF2F6FC),
      appBar: AppBar(
        title: const Text('Nota Laundry'),
        backgroundColor: biru,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Column(
                    children: [
                      Icon(Icons.local_laundry_service,
                          size: 48, color: biru),
                      Text(
                        'LaundryKu',
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text('NOTA PESANAN LAUNDRY'),
                    ],
                  ),
                ),
                const Divider(height: 32),
                _baris('Nomor Nota', nomorNota),
                _baris('Nama Pelanggan', namaPelanggan),
                _baris('Telepon', telepon),
                _baris('Alamat', alamat),
                const Divider(height: 28),
                _baris('Layanan', layanan),
                _baris('Pengerjaan', pengerjaan),
                _baris('Berat', '$berat kg'),
                _baris('Harga per kg', rupiah(hargaPerKg)),
                _baris('Catatan', catatan),
                const Divider(height: 28),
                _baris('Status', status),
                _baris('TOTAL PEMBAYARAN', rupiah(total),
                    tebal: true, warna: biru),
                const SizedBox(height: 20),
                const Center(
                  child: Text(
                    'Terima kasih telah menggunakan LaundryKu.',
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () async {
              await Clipboard.setData(
                ClipboardData(text: isiNota),
              );
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Isi nota berhasil disalin.'),
                  ),
                );
              }
            },
            icon: const Icon(Icons.copy),
            label: const Text('Salin Isi Nota'),
          ),

          // Tombol PDF ditambahkan di sini
          const SizedBox(height: 12),

          FilledButton.icon(
            onPressed: () => buatPdf(context),
            icon: const Icon(Icons.picture_as_pdf),
            label: const Text('Buat / Bagikan Nota PDF'),
          ),
        ],
      ),
    );
  }

  Widget _baris(
      String label,
      String nilai, {
        bool tebal = false,
        Color? warna,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Colors.black54),
            ),
          ),
          const Text(': '),
          Expanded(
            child: Text(
              nilai,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontWeight:
                tebal ? FontWeight.bold : FontWeight.normal,
                color: warna ?? Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
