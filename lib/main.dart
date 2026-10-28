
import 'package:flutter/material.dart';
import 'login_page.dart';
import 'beranda_page.dart';
import 'pesanan_page.dart';

const Color warnaBiru = Color(0xFF5B8DEF);
const Color warnaLatar = Color(0xFFF4F7FF);

void main() {
  runApp(const LaundryKuApp());
}

class LaundryKuApp extends StatelessWidget {
  const LaundryKuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LaundryKu',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: warnaBiru),
        scaffoldBackgroundColor: warnaLatar,
      ),
      home: const HalamanLogin(),
    );
  }
}

class HalamanLogin extends StatelessWidget {
  const HalamanLogin({super.key});

  @override
  Widget build(BuildContext context) {
    return LoginPage(
      onLoginSuccess: () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => const NavigasiUtama(),
          ),
        );
      },
    );
  }
}

class NavigasiUtama extends StatefulWidget {
  const NavigasiUtama({super.key});

  @override
  State<NavigasiUtama> createState() => _NavigasiUtamaState();
}

class _NavigasiUtamaState extends State<NavigasiUtama> {
  int halamanAktif = 0;

  final List<Widget> halaman = const [
    BerandaPage(),
    PesananPage(),
    HalamanHarga(),
    HalamanProfil(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: halamanAktif,
        children: halaman,
      ),
      bottomNavigationBar: NavigationBar(
        height: 70,
        selectedIndex: halamanAktif,
        onDestinationSelected: (index) {
          setState(() {
            halamanAktif = index;
          });
        },
        backgroundColor: Colors.white,
        indicatorColor: const Color(0xFFE4ECFF),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Beranda',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long_rounded),
            label: 'Pesanan',
          ),
          NavigationDestination(
            icon: Icon(Icons.sell_outlined),
            selectedIcon: Icon(Icons.sell_rounded),
            label: 'Harga',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}

// HALAMAN HARGA
class HalamanHarga extends StatelessWidget {
  const HalamanHarga({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Daftar Harga',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: warnaBiru,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Pilih layanan sesuai kebutuhanmu',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF243451),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Harga dihitung berdasarkan berat laundry.',
            style: TextStyle(color: Colors.blueGrey),
          ),
          const SizedBox(height: 20),
          _kartuHarga(
            Icons.local_laundry_service_rounded,
            'Cuci Kering',
            'Rp5.000/kg',
            'Rp7.000/kg',
          ),
          _kartuHarga(
            Icons.dry_cleaning_rounded,
            'Cuci Kering Setrika',
            'Rp6.000/kg',
            'Rp8.000/kg',
          ),
          _kartuHarga(
            Icons.checkroom_rounded,
            'Lipat Saja',
            'Rp4.000/kg',
            'Rp6.000/kg',
          ),
          _kartuHarga(
            Icons.iron_rounded,
            'Setrika Saja',
            'Rp5.000/kg',
            'Rp8.000/kg',
          ),
          const SizedBox(height: 12),
          const Text(
            '* Reguler dan Express memiliki harga berbeda.',
            style: TextStyle(
              color: Colors.blueGrey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _kartuHarga(
      IconData ikon,
      String nama,
      String reguler,
      String express,
      ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5EBF5)),
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
            child: Icon(ikon, color: warnaBiru, size: 26),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nama,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Reguler\n$reguler',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Express\n$express',
                        style: const TextStyle(
                          fontSize: 12,
                          color: warnaBiru,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// HALAMAN PROFIL
class HalamanProfil extends StatelessWidget {
  const HalamanProfil({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profil LaundryKu',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: warnaBiru,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 12),
          Center(
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: const Color(0xFFE2EBFF),
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Icon(
                Icons.local_laundry_service_rounded,
                size: 58,
                color: warnaBiru,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Center(
            child: Text(
              'LaundryKu',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: Color(0xFF243451),
              ),
            ),
          ),
          const SizedBox(height: 6),
          const Center(
            child: Text(
              'Praktis, Bersih, Terpercaya',
              style: TextStyle(color: Colors.blueGrey),
            ),
          ),
          const SizedBox(height: 28),
          _infoProfil(
            Icons.info_outline_rounded,
            'Tentang Aplikasi',
            'Aplikasi untuk mengelola data pelanggan, '
                'pesanan, dan informasi harga layanan laundry.',
          ),
          _infoProfil(
            Icons.local_offer_outlined,
            'Layanan',
            'Cuci Kering, Cuci Kering Setrika, '
                'Lipat Saja, dan Setrika Saja.',
          ),
          _infoProfil(
            Icons.payments_outlined,
            'Paket Layanan',
            'Tersedia paket Reguler dan Express.',
          ),
          const SizedBox(height: 20),
          const Center(
            child: Text(
              'LaundryKu • Versi 1.0',
              style: TextStyle(
                color: Colors.blueGrey,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoProfil(
      IconData ikon,
      String judul,
      String deskripsi,
      ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5EBF5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(ikon, color: warnaBiru, size: 26),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  judul,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  deskripsi,
                  style: const TextStyle(
                    color: Colors.blueGrey,
                    height: 1.5,
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
