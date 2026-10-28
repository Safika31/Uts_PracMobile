
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const Color warnaStok = Color(0xFF5B8DEF);
const String kunciStok = 'laundryku_stok';

class StokPage extends StatefulWidget {
  const StokPage({super.key});

  @override
  State<StokPage> createState() => _StokPageState();
}

class _StokPageState extends State<StokPage> {
  List<Map<String, dynamic>> daftarStok = [];
  bool sedangMemuat = true;

  @override
  void initState() {
    super.initState();
    muatStok();
  }

  Future<void> muatStok() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(kunciStok);

    List<Map<String, dynamic>> hasil = [];

    if (data != null) {
      try {
        final decoded = jsonDecode(data) as List<dynamic>;
        hasil = decoded.map((item) {
          return Map<String, dynamic>.from(item as Map);
        }).toList();
      } catch (_) {
        hasil = [];
      }
    }

    // Barang contoh hanya ditambahkan saat data stok masih kosong.
    if (hasil.isEmpty && data == null) {
      hasil = [
        {
          'nama': 'Deterjen',
          'jumlah': 2,
          'satuan': 'Liter',
          'minimum': 3,
        },
        {
          'nama': 'Pewangi',
          'jumlah': 8,
          'satuan': 'Liter',
          'minimum': 3,
        },
        {
          'nama': 'Plastik Laundry',
          'jumlah': 5,
          'satuan': 'Pak',
          'minimum': 3,
        },
        {
          'nama': 'Kantong Laundry',
          'jumlah': 10,
          'satuan': 'Pak',
          'minimum': 3,
        },
      ];

      daftarStok = hasil;
      await simpanStok();
    }

    if (!mounted) return;

    setState(() {
      daftarStok = hasil;
      sedangMemuat = false;
    });
  }

  Future<void> simpanStok() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(kunciStok, jsonEncode(daftarStok));
  }

  Future<void> tambahBarang() async {
    final namaController = TextEditingController();
    final jumlahController = TextEditingController(text: '1');
    final minimumController = TextEditingController(text: '3');
    String satuan = 'Liter';

    final hasil = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, ubahDialog) {
            return AlertDialog(
              title: const Text('Tambah Barang'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: namaController,
                      decoration: const InputDecoration(
                        labelText: 'Nama barang',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: jumlahController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Jumlah stok',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: satuan,
                      decoration: const InputDecoration(
                        labelText: 'Satuan',
                        border: OutlineInputBorder(),
                      ),
                      items: ['Liter', 'Kg', 'Botol', 'Pak', 'Pcs']
                          .map((item) => DropdownMenuItem(
                        value: item,
                        child: Text(item),
                      ))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          ubahDialog(() => satuan = value);
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: minimumController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Batas minimum stok',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () =>
                      Navigator.pop(dialogContext, false),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final nama = namaController.text.trim();
                    final jumlah = int.tryParse(jumlahController.text);
                    final minimum =
                    int.tryParse(minimumController.text);

                    if (nama.isEmpty ||
                        jumlah == null ||
                        jumlah < 0 ||
                        minimum == null ||
                        minimum < 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Periksa kembali data barang.'),
                        ),
                      );
                      return;
                    }

                    Navigator.pop(dialogContext, true);
                  },
                  child: const Text('Simpan'),
                ),
              ],
            );
          },
        );
      },
    );

    if (hasil == true) {
      final nama = namaController.text.trim();
      final jumlah = int.parse(jumlahController.text);
      final minimum = int.parse(minimumController.text);

      final indeks = daftarStok.indexWhere(
            (item) =>
        item['nama'].toString().toLowerCase() ==
            nama.toLowerCase(),
      );

      if (indeks >= 0) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Barang sudah ada. Gunakan tombol Tambah Stok.',
            ),
          ),
        );
      } else {
        setState(() {
          daftarStok.add({
            'nama': nama,
            'jumlah': jumlah,
            'satuan': satuan,
            'minimum': minimum,
          });
        });
        await simpanStok();
      }
    }

    namaController.dispose();
    jumlahController.dispose();
    minimumController.dispose();
  }

  Future<void> tambahStok(int indeks) async {
    final controller = TextEditingController();

    final jumlah = await showDialog<int>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('Tambah Stok ${daftarStok[indeks]['nama']}'),
          content: TextField(
            controller: controller,
            autofocus: true,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Jumlah yang ditambahkan',
              hintText: 'Contoh: 10',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                final nilai = int.tryParse(controller.text);
                if (nilai == null || nilai <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Masukkan jumlah lebih dari 0.'),
                    ),
                  );
                  return;
                }
                Navigator.pop(dialogContext, nilai);
              },
              child: const Text('Tambahkan'),
            ),
          ],
        );
      },
    );

    controller.dispose();

    if (jumlah != null) {
      setState(() {
        daftarStok[indeks]['jumlah'] =
            (daftarStok[indeks]['jumlah'] as int) + jumlah;
      });
      await simpanStok();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Stok berhasil ditambah $jumlah.')),
      );
    }
  }

  Future<void> editBarang(int indeks) async {
    final barang = daftarStok[indeks];
    final namaController =
    TextEditingController(text: barang['nama'].toString());
    final jumlahController =
    TextEditingController(text: barang['jumlah'].toString());
    final minimumController =
    TextEditingController(text: barang['minimum'].toString());
    String satuan = barang['satuan'].toString();

    final hasil = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, ubahDialog) {
            return AlertDialog(
              title: const Text('Edit Barang'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: namaController,
                      decoration: const InputDecoration(
                        labelText: 'Nama barang',
                      ),
                    ),
                    TextField(
                      controller: jumlahController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Jumlah stok',
                      ),
                    ),
                    DropdownButtonFormField<String>(
                      value: satuan,
                      decoration:
                      const InputDecoration(labelText: 'Satuan'),
                      items: ['Liter', 'Kg', 'Botol', 'Pak', 'Pcs']
                          .map((item) => DropdownMenuItem(
                        value: item,
                        child: Text(item),
                      ))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          ubahDialog(() => satuan = value);
                        }
                      },
                    ),
                    TextField(
                      controller: minimumController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Batas minimum stok',
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () =>
                      Navigator.pop(dialogContext, false),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final jumlah = int.tryParse(jumlahController.text);
                    final minimum =
                    int.tryParse(minimumController.text);

                    if (namaController.text.trim().isEmpty ||
                        jumlah == null ||
                        jumlah < 0 ||
                        minimum == null ||
                        minimum < 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Periksa kembali data barang.'),
                        ),
                      );
                      return;
                    }

                    Navigator.pop(dialogContext, true);
                  },
                  child: const Text('Simpan'),
                ),
              ],
            );
          },
        );
      },
    );

    if (hasil == true) {
      setState(() {
        daftarStok[indeks] = {
          'nama': namaController.text.trim(),
          'jumlah': int.parse(jumlahController.text),
          'satuan': satuan,
          'minimum': int.parse(minimumController.text),
        };
      });
      await simpanStok();
    }

    namaController.dispose();
    jumlahController.dispose();
    minimumController.dispose();
  }

  Future<void> hapusBarang(int indeks) async {
    final setuju = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus Barang?'),
        content: Text(
          'Barang "${daftarStok[indeks]['nama']}" akan dihapus.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (setuju == true) {
      setState(() => daftarStok.removeAt(indeks));
      await simpanStok();
    }
  }

  @override
  Widget build(BuildContext context) {
    final stokMenipis = daftarStok.where((barang) {
      return (barang['jumlah'] as int) <=
          (barang['minimum'] as int);
    }).length;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FF),
      appBar: AppBar(
        title: const Text(
          'Stok Perlengkapan',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: warnaStok,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: tambahBarang,
        backgroundColor: warnaStok,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Tambah Barang'),
      ),
      body: sedangMemuat
          ? const Center(child: CircularProgressIndicator())
          : daftarStok.isEmpty
          ? const Center(
        child: Text('Belum ada barang. Tekan Tambah Barang.'),
      )
          : ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF78A5FF),
                  Color(0xFF4779DF),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.inventory_2_rounded,
                  size: 42,
                  color: Colors.white,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Ringkasan Stok',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '${daftarStok.length} jenis barang',
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Text(
                      '$stokMenipis',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'Menipis',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Daftar Barang',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF243451),
            ),
          ),
          const SizedBox(height: 10),
          ...List.generate(daftarStok.length, (indeks) {
            final barang = daftarStok[indeks];
            final jumlah = barang['jumlah'] as int;
            final minimum = barang['minimum'] as int;
            final menipis = jumlah <= minimum;

            return Card(
              color: Colors.white,
              elevation: 1,
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE7EEFF),
                            borderRadius:
                            BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.inventory_2_outlined,
                            color: warnaStok,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              Text(
                                barang['nama'].toString(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '$jumlah ${barang['satuan']}',
                                style: const TextStyle(
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                'Batas minimum: $minimum ${barang['satuan']}',
                                style: const TextStyle(
                                  color: Colors.blueGrey,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          children: [
                            Icon(
                              menipis
                                  ? Icons.warning_amber_rounded
                                  : Icons.check_circle_rounded,
                              color: menipis
                                  ? Colors.orange
                                  : Colors.green,
                            ),
                            Text(
                              menipis ? 'Menipis' : 'Aman',
                              style: TextStyle(
                                color: menipis
                                    ? Colors.orange.shade800
                                    : Colors.green.shade700,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => tambahStok(indeks),
                            icon: const Icon(
                              Icons.add_circle_outline,
                            ),
                            label: const Text('Tambah Stok'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: warnaStok,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          tooltip: 'Edit barang',
                          onPressed: () => editBarang(indeks),
                          icon: const Icon(Icons.edit_outlined),
                        ),
                        IconButton(
                          tooltip: 'Hapus barang',
                          onPressed: () => hapusBarang(indeks),
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 90),
        ],
      ),
    );
  }
}
