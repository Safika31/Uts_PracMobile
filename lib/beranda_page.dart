import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'pesanan_page.dart';
import 'stok_page.dart';

const Color biru = Color(0xFF5B8DEF);
const Color latar = Color(0xFFF4F7FF);
const Color teksGelap = Color(0xFF243451);

class BerandaPage extends StatefulWidget {
  const BerandaPage({super.key});

  @override
  State<BerandaPage> createState() => _BerandaPageState();
}

class _BerandaPageState extends State<BerandaPage> {
  int totalPesanan = 0;
  int pesananDiproses = 0;
  int pesananSelesai = 0;


  Timer? timerRingkasan;

  @override
  void initState() {
    super.initState();
    muatRingkasan();

    timerRingkasan = Timer.periodic(
      const Duration(seconds: 1),
          (_) => muatRingkasan(),
    );
  }

  @override
  void dispose() {
    timerRingkasan?.cancel();
    super.dispose();
  }


  Future<void> muatRingkasan() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('laundryku_pesanan');

    List<dynamic> daftarPesanan = [];

    if (data != null && data.isNotEmpty) {
      try {
        daftarPesanan = jsonDecode(data) as List<dynamic>;
      } catch (_) {
        return;
      }
    }

    final total = daftarPesanan.length;
    final selesai = daftarPesanan.where((pesanan) {
      return pesanan['status']?.toString().toLowerCase() == 'selesai';
    }).length;

    if (!mounted) return;

    setState(() {
      totalPesanan = total;
      pesananDiproses = total - selesai;
      pesananSelesai = selesai;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: latar,
      appBar: AppBar(
        title: const Text(
          'LaundryKu',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: biru,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            tooltip: 'Keluar',
            icon: const Icon(Icons.logout_rounded),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Halo, Selamat Datang! 👋',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: teksGelap,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Biar urusan laundry jadi lebih praktis.',
                style: TextStyle(
                  color: Colors.blueGrey,
                  fontSize: 13,
                ),
              ),

              const SizedBox(height: 22),

              // Banner utama
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF78A5FF),
                      Color(0xFF4779DF),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: biru.withValues(alpha: 0.20),
                      blurRadius: 16,
                      offset: const Offset(0, 7),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.20),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.local_laundry_service_rounded,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Baju Bersih,\nHari Lebih Ceria!',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 21,
                              height: 1.3,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Perawatan pakaian lebih mudah '
                                'bersama LaundryKu.',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.dry_cleaning_rounded,
                      size: 72,
                      color: Color(0x99FFFFFF),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 26),

              // Ringkasan
              const Text(
                'Ringkasan Pesanan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: teksGelap,
                ),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _ringkasan(
                      Icons.receipt_long_rounded,
                      totalPesanan.toString(),
                      'Total',
                      const Color(0xFFE7EEFF),
                      biru,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _ringkasan(
                      Icons.hourglass_top_rounded,
                      pesananDiproses.toString(),
                      'Diproses',
                      const Color(0xFFFFF0D8),
                      const Color(0xFFE6A23C),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _ringkasan(
                      Icons.check_circle_outline_rounded,
                      pesananSelesai.toString(),
                      'Selesai',
                      const Color(0xFFDDF7EB),
                      const Color(0xFF28A879),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 26),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Layanan Kami',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: teksGelap,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE3ECFF),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      '4 Layanan',
                      style: TextStyle(
                        color: biru,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 13),

              _layanan(
                Icons.local_laundry_service_rounded,
                'Cuci Kering',
                'Rp5.000/kg',
                'Pakaian bersih dan siap digunakan',
              ),
              _layanan(
                Icons.dry_cleaning_rounded,
                'Cuci Kering Setrika',
                'Rp6.000/kg',
                'Bersih, rapi, dan bebas kusut',
              ),
              _layanan(
                Icons.checkroom_rounded,
                'Lipat Saja',
                'Rp4.000/kg',
                'Pakaian dilipat dengan rapi',
              ),
              _layanan(
                Icons.iron_rounded,
                'Setrika Saja',
                'Rp5.000/kg',
                'Pakaian lebih halus dan rapi',
              ),


              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFFE0E8FA),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.inventory_2_rounded,
                          color: biru,
                          size: 28,
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Stok Perlengkapan',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: teksGelap,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Pantau persediaan deterjen, pewangi, '
                          'plastik laundry, dan perlengkapan lainnya.',
                      style: TextStyle(
                        color: Colors.blueGrey,
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute<void>(
                              builder: (context) => const StokPage(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.inventory_2_outlined),
                        label: const Text('Kelola Stok Barang'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: biru,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),


              const Center(
                child: Text(
                  'LaundryKu',
                  style: TextStyle(
                    color: biru,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              const Center(
                child: Text(
                  'Praktis • Bersih • Terpercaya',
                  style: TextStyle(
                    color: Colors.blueGrey,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Kartu ringkasan
Widget _ringkasan(
    IconData ikon,
    String jumlah,
    String label,
    Color warnaLatar,
    Color warnaIkon,
    ) {
  return Container(
    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: const Color(0xFFE8EDF7)),
    ),
    child: Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: warnaLatar,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(ikon, color: warnaIkon, size: 22),
        ),
        const SizedBox(height: 9),
        Text(
          jumlah,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: teksGelap,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: Colors.blueGrey,
          ),
        ),
      ],
    ),
  );
}

// Kartu layanan
Widget _layanan(
    IconData ikon,
    String nama,
    String harga,
    String deskripsi,
    ) {
  return Container(
    margin: const EdgeInsets.only(bottom: 11),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: const Color(0xFFE8EDF7)),
    ),
    child: Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFFEAF0FF),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(ikon, size: 26, color: biru),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                nama,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: teksGelap,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                deskripsi,
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.blueGrey,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Mulai $harga',
                style: const TextStyle(
                  fontSize: 12,
                  color: biru,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const Icon(
          Icons.arrow_forward_ios_rounded,
          size: 14,
          color: Color(0xFF9AA8BD),
        ),
      ],
    ),
  );
}
