import 'package:absensi/app/data/helper/const.dart';
import 'package:flutter/material.dart';
import 'package:expansion_tile_group/expansion_tile_group.dart';
import 'package:icons_flutter/icons_flutter.dart';

class FaqView extends StatelessWidget {
  const FaqView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Frequently Asked Questions'),
        flexibleSpace: Container(
          // height: 400,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(
                isDark
                    ? 'assets/image/bg-hd-drk.png'
                    : 'assets/image/bg-hd.png',
              ),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(12.0, 8.0, 12.0, 8.0),
        child: ListView(
          padding: EdgeInsets.only(
            bottom: 68 + MediaQuery.of(context).padding.bottom + 24,
          ),
          children: [
            ExpansionTileGroup(
              toggleType: ToggleType.expandOnlyCurrent,
              spaceBetweenItem: 5,
              children: [
                ExpansionTileItem(
                  // key: Key('faq'), // key unik per item penting!
                  controlAffinity: ListTileControlAffinity.trailing,
                  tilePadding: const EdgeInsets.fromLTRB(8, 2, 8, 2),
                  childrenPadding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                  isHasBottomBorder: true,
                  isHasTopBorder: true,
                  isHasLeftBorder: true,
                  isHasRightBorder: true,
                  borderRadius: BorderRadius.circular(5),
                  backgroundColor:
                      isDark
                          ? const Color(0xFF1E293B).withOpacity(0.78)
                          : Colors.white.withOpacity(0.82),
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          const Icon(
                            Typicons.clock,
                            color: Colors.blue,
                            size: 20,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            'Edit Jam Masuk',
                            style: titleTextStyle.copyWith(
                              fontSize: 15,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  subtitle: Text('Tap for detail', style: subtitleTextStyle),
                  children: [
                    Image.asset('assets/image/edit_masuk.jpg'),

                    const SizedBox(height: 10),
                    const Text(
                      'Petunjuk pengisian form berdasarkan gambar diatas',
                    ),
                    const SizedBox(height: 10),
                    const Text('1. Isi kolom jam Check In'),
                    const Text('2. Lampirkan bukti foto absen masuk'),
                    const Text('3. Isi kolom alasan edit data absen'),
                    const Text('4. Tekan tombol Request Approval'),
                  ],
                ),
                ExpansionTileItem(
                  // key: Key('faq'), // key unik per item penting!
                  controlAffinity: ListTileControlAffinity.trailing,
                  tilePadding: const EdgeInsets.fromLTRB(8, 2, 8, 2),
                  childrenPadding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                  isHasBottomBorder: true,
                  isHasTopBorder: true,
                  isHasLeftBorder: true,
                  isHasRightBorder: true,
                  borderRadius: BorderRadius.circular(5),
                  backgroundColor:
                      isDark
                          ? const Color(0xFF1E293B).withOpacity(0.78)
                          : Colors.white.withOpacity(0.82),
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          const Icon(
                            Typicons.clock,
                            color: Colors.blue,
                            size: 20,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            'Edit Jam Pulang',
                            style: titleTextStyle.copyWith(
                              fontSize: 15,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  subtitle: Text('Tap for detail', style: subtitleTextStyle),
                  children: [
                    Image.asset('assets/image/edit_pulang.jpg'),

                    const SizedBox(height: 10),
                    const Text(
                      'Petunjuk pengisian form berdasarkan gambar diatas',
                    ),
                    const SizedBox(height: 10),
                    const Text('1. Isi kolom Return Date'),
                    const Text('2. Isi kolom jam Check Out'),
                    const Text('3. Lampirkan bukti foto absen pulang'),
                    const Text('4. Isi kolom alasan edit data absen'),
                    const Text('5. Tekan tombol Request Approval'),
                  ],
                ),
                ExpansionTileItem(
                  // key: Key('faq'), // key unik per item penting!
                  controlAffinity: ListTileControlAffinity.trailing,
                  tilePadding: const EdgeInsets.fromLTRB(8, 2, 8, 2),
                  childrenPadding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                  isHasBottomBorder: true,
                  isHasTopBorder: true,
                  isHasLeftBorder: true,
                  isHasRightBorder: true,
                  borderRadius: BorderRadius.circular(5),
                  backgroundColor:
                      isDark
                          ? const Color(0xFF1E293B).withOpacity(0.78)
                          : Colors.white.withOpacity(0.82),
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          const Icon(
                            Typicons.shuffle,
                            color: Colors.blue,
                            size: 20,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            'Edit Shift',
                            style: titleTextStyle.copyWith(
                              fontSize: 15,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  subtitle: Text('Tap for detail', style: subtitleTextStyle),
                  children: [
                    Image.asset('assets/image/edit_shift.jpg'),

                    const SizedBox(height: 10),
                    const Text(
                      'Petunjuk pengisian form berdasarkan gambar diatas',
                    ),
                    const SizedBox(height: 10),
                    const Text('1. Pilih shift yang sesuai'),
                    const Text('2. Isi kolom alasan edit data absen'),
                    const Text('3. Tekan tombol Request Approval'),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
