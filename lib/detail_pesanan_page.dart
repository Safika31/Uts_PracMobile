import 'detail_pesanan_page.dart';
import 'package:flutter/material.dart';

class DetailPesananPage extends StatelessWidget {
  final Map<String, dynamic> pesanan;

  const DetailPesananPage({
    super.key,
    required this.pesanan,
  });

  static const biru = Color(0xFF5B8DEF);
  static const tahapan = [
    'Pesanan diterima',
    'Sedang dicuci',
    'Siap diambil',
    'Selesai',
  ];

  int get tahapAktif {
    final status = pesanan['status']?.toString() ?? 'Diproses';

    if (status == 'Pesanan diterima') return 0;
    if (status == 'Sedang dicuci' || status == 'Diproses') return 1;
    if (status == 'Siap diambil') return 2;
    if (status == 'Selesai') return 3;

    return 0;
  }

  String rupiah(num angka) {
    final teks = angka.round().toString();
    final hasil = teks.replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]}.',
    );
    return 'Rp$hasil';
  }

  @override
  Widget build(BuildContext context) {
    final tahap = tahapAktif;
    final selesai = tahap == 3;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FF),
      appBar: AppBar(
        title: const Text(
          'Detail Pesanan',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: biru,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF78A5FF), Color(0xFF4779DF)],
              ),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.local_laundry_service_rounded,
                  color: Colors.white,
                  size: 38,
                ),
                const SizedBox(height: 12),
                Text(
                  '${pesanan['id']}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  selesai
                      ? 'Laundry sudah selesai!'
                      : 'Pantau progres laundry kamu.',
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    tahapan[tahap],
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          const Text(
            'Progres Laundry',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF243451),
            ),
          ),
          const SizedBox(height: 18),
          ...List.generate(tahapan.length, (i) {
            final sudahLewat = i <= tahap;
            final warna = sudahLewat
                ? biru
                : const Color(0xFFB8C3D3);

            return IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 34,
                    child: Column(
                      children: [
                        Icon(
                          sudahLewat
                              ? Icons.check_circle
                              : Icons.circle_outlined,
                          color: warna,
                          size: 26,
                        ),
                        if (i < tahapan.length - 1)
                          Expanded(
                            child: Container(
                              width: 2,
                              constraints:
                              const BoxConstraints(minHeight: 38),
                              color: i < tahap
                                  ? biru
                                  : const Color(0xFFDCE4F0),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 25),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tahapan[i],
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: sudahLewat
                                  ? const Color(0xFF243451)
                                  : Colors.blueGrey,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            [
                              'Pesanan sudah dicatat.',
                              'Pakaian sedang dibersihkan.',
                              'Cucian sudah siap diambil.',
                              'Pesanan telah selesai.',
                            ][i],
                            style: const TextStyle(
                              color: Colors.blueGrey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (i == tahap)
                    const Icon(
                      Icons.radio_button_checked,
                      color: biru,
                      size: 18,
                    ),
                ],
              ),
            );
          }),
          const SizedBox(height: 4),
          const Text(
            'Informasi Pelanggan',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF243451),
            ),
          ),
          const SizedBox(height: 12),
          _info(Icons.person_outline, 'Nama', '${pesanan['nama']}'),
          _info(Icons.phone_outlined, 'Nomor HP', '${pesanan['hp']}'),
          _info(
            Icons.location_on_outlined,
            'Alamat',
            (pesanan['alamat'] ?? '').toString().isEmpty
                ? '-'
                : '${pesanan['alamat']}',
          ),
          _info(
            Icons.local_laundry_service_outlined,
            'Layanan',
            '${pesanan['layanan']} • ${pesanan['paket']}',
          ),
          _info(
            Icons.scale_outlined,
            'Berat cucian',
            '${pesanan['berat']} kg',
          ),
          _info(
            Icons.payments_outlined,
            'Total biaya',
            rupiah((pesanan['total'] as num?) ?? 0),
          ),
          if ((pesanan['catatan'] ?? '').toString().isNotEmpty)
            _info(
              Icons.notes_rounded,
              'Catatan',
              '${pesanan['catatan']}',
            ),
        ],
      ),
    );
  }

  Widget _info(IconData ikon, String judul, String isi) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE8EDF7)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(ikon, color: biru),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  judul,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.blueGrey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isi,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF243451),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
