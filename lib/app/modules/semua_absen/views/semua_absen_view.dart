import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:icons_plus/icons_plus.dart';

import 'package:absensi/app/data/helper/app_colors.dart';
import 'package:absensi/app/data/helper/const.dart';
import 'package:absensi/app/data/helper/custom_dialog.dart';
import 'package:absensi/app/modules/absen/controllers/absen_controller.dart';
import 'package:intl/intl.dart';

import '../../../data/helper/duration_count.dart';
import '../../../data/helper/format_waktu.dart';
import '../../detail_absen/views/detail_absen_view.dart';
import '../../login/controllers/login_controller.dart';
import '../../shared/history_card.dart';
import '../../shared/history_card_shimmer.dart';

class SemuaAbsenView extends GetView {
  SemuaAbsenView({super.key});

  final auth = Get.find<LoginController>();
  final absenC = Get.find<AbsenController>();
  final Rxn<DateTimeRange> pickedRange = Rxn<DateTimeRange>();
  final Rx<DateTime> pickedMonth = DateTime.now().obs;
  final RxInt selectedTab = 0.obs;
  final scrollC = ScrollController();

  @override
  Widget build(BuildContext context) {
    final data = auth.logUser.value;
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'History',
              style: titleTextStyle.copyWith(
                fontSize: 18,
                color: AppColors.contentColorWhite,
              ),
            ),
            GestureDetector(
              onTap: () async {
                final range = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2100),
                  initialDateRange: DateTimeRange(
                    start: pickedMonth.value,
                    end: pickedMonth.value,
                  ),
                  builder: (context, child) {
                    final isDark =
                        Theme.of(context).brightness == Brightness.dark;
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme:
                            isDark
                                ? const ColorScheme.dark(
                                  primary:
                                      Colors
                                          .blueAccent, // 🔥 warna selection (range highlight)
                                  onPrimary:
                                      Colors
                                          .white, // 🔥 warna text di tanggal terpilih
                                  secondary:
                                      Colors
                                          .blueAccent, // 🔥 untuk hover / range
                                  onSurface: Colors.white, // text normal
                                  surface: Color(0xFF121212),
                                )
                                : ColorScheme.light(
                                  primary: Theme.of(context).primaryColor,
                                  onPrimary: Colors.white,
                                  onSurface: Colors.black,
                                  surface:
                                      Theme.of(context).secondaryHeaderColor,
                                ),
                      ),
                      child: child!,
                    );
                  },
                );

                if (range != null) {
                  loadingDialog("memuat data...", "");
                  await absenC.getAllAbsen(
                    data.id!,
                    DateFormat('yyyy-MM-dd').format(range.start),
                    DateFormat('yyyy-MM-dd').format(range.end),
                  );
                  Get.back();

                  pickedRange.value = range;
                  selectedTab.value = 1;
                }
              },
              child: const Icon(CupertinoIcons.calendar, color: Colors.white),
            ),
          ],
        ),
        backgroundColor: AppColors.itemsBackground,
        elevation: 0.0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: AppColors.mainGradient(
              context: context,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        // iconTheme: const IconThemeData(color: Colors.black,),
      ),
      body: CustomMaterialIndicator(
        onRefresh: () async {
          absenC.resetFilter();
          pickedRange.value = null;
          // selectedTab.value = 0;
          absenC.isLoading.value = true;
          await absenC.getAllAbsen(
            data.id!,
            absenC.initDate1,
            absenC.initDate2,
          );
          showToast("Page Refreshed");
        },
        backgroundColor: Colors.white,
        indicatorBuilder: (context, controller) {
          return Padding(
            padding: const EdgeInsets.all(6.0),
            child:
                Platform.isAndroid
                    ? CircularProgressIndicator(
                      color: AppColors.itemsBackground,
                      value:
                          controller.state.isLoading
                              ? null
                              : math.min(controller.value, 1.0),
                    )
                    : const CupertinoActivityIndicator(),
          );
        },
        child: CustomScrollView(
          controller: scrollC,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            /// 🔥 STICKY TAB
            SliverPersistentHeader(
              pinned: true,
              delegate: HistoryTabHeaderDelegate(
                height: 62, // ⬅️ HARUS SAMA
                child: HistoryRangeTab(
                  selectedIndex: selectedTab,
                  scrollController: scrollC,
                  onSearch: (q) => absenC.searchKeyword.value = q,
                ),
              ),
            ),

            /// 🔹 CONTENT
            SliverPadding(
              padding: const EdgeInsets.all(12),
              sliver: Obx(() {
                final now = DateTime.now();

                DateTime start;
                DateTime end;

                if (selectedTab.value == 0) {
                  /// MINGGU INI
                  final monday = now.subtract(Duration(days: now.weekday - 1));

                  start = DateTime(monday.year, monday.month, monday.day);
                  end = start.add(const Duration(days: 6));
                } else if (selectedTab.value == 1) {
                  /// BULAN DIPILIH
                  if (pickedRange.value != null) {
                    start = pickedRange.value!.start;
                    end = pickedRange.value!.end;
                  } else {
                    start = DateTime(now.year, now.month, 1);
                    end = DateTime(
                      now.year,
                      now.month + 1,
                      1,
                    ).subtract(const Duration(days: 1));
                  }
                } else {
                  /// Search (ALL)
                  start = DateTime(2000);
                  end = DateTime(2100);
                }

                // final filtered =
                //     absenC.searchAbsen.where((e) {
                //       final date = DateTime.parse(e.tanggalMasuk ?? '');
                //       return !date.isBefore(start) && !date.isAfter(end);
                //     }).toList();
                final list =
                    absenC.filterDataAbsen.where((e) {
                      if (e.tanggalMasuk == null || e.tanggalMasuk!.isEmpty) {
                        return false;
                      }

                      DateTime? d;
                      try {
                        d = DateTime.parse(e.tanggalMasuk!);
                      } catch (_) {
                        return false;
                      }

                      final date = DateTime(d.year, d.month, d.day);
                      final s = DateTime(start.year, start.month, start.day);
                      final en = DateTime(end.year, end.month, end.day);

                      return !date.isBefore(s) && !date.isAfter(en);
                    }).toList();

                if (absenC.isLoading.value) {
                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => const HistoryCardShimmer(),
                      childCount: 5, // jumlah shimmer tampil
                    ),
                  );
                }

                if (list.isEmpty) {
                  return const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.only(top: 40),
                      child: Center(child: Text('Data not found')),
                    ),
                  );
                }

                return SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final item = list[index];

                    final jamMasuk = safe(item.jamAbsenMasuk);
                    final jamPulang = safe(item.jamAbsenPulang);
                    final tglMasuk = safe(item.tanggalMasuk);
                    final tglPulang = safe(item.tanggalPulang);
                    final jamShiftMasuk = safe(item.jamMasuk);
                    final jamShiftPulang = safe(item.jamPulang);

                    /// =====================
                    /// STATUS MASUK
                    /// =====================
                    var stsMasuk = "-";

                    if (jamMasuk.isNotEmpty && jamShiftMasuk.isNotEmpty) {
                      try {
                        final jm = FormatWaktu.formatJamMenit(
                          jamMenit: jamMasuk,
                        );
                        final jm2 = FormatWaktu.formatJamMenit(
                          jamMenit: jamShiftMasuk,
                        );

                        if (jm.isBefore(jm2)) {
                          stsMasuk = "Early";
                        } else if (jm.isAtSameMomentAs(jm2)) {
                          stsMasuk = "On Time";
                        } else {
                          stsMasuk = "Late";
                        }
                      } catch (_) {}
                    }

                    /// =====================
                    /// STATUS PULANG
                    /// =====================
                    var stsPulang = "Absent";

                    if (jamPulang.isNotEmpty &&
                        tglPulang.isNotEmpty &&
                        tglMasuk.isNotEmpty) {
                      try {
                        final tp = DateTime.parse(tglPulang);
                        final tm = DateTime.parse(tglMasuk);

                        final jp = FormatWaktu.formatJamMenit(
                          jamMenit: jamPulang,
                        );
                        final jm = FormatWaktu.formatJamMenit(
                          jamMenit: jamMasuk,
                        );
                        final shiftOut = FormatWaktu.formatJamMenit(
                          jamMenit: jamShiftPulang,
                        );

                        if (tp.isAfter(tm) &&
                            jp.isAfter(jm.add(const Duration(hours: 8)))) {
                          stsPulang = "Over Time";
                        } else if (tp.isAtSameMomentAs(tm) &&
                            jp.isBefore(shiftOut)) {
                          stsPulang = "Minus Time";
                        } else if (jp.isAtSameMomentAs(shiftOut)) {
                          stsPulang = "On Time";
                        } else if (jp.isAfter(
                          shiftOut.add(const Duration(hours: 1)),
                        )) {
                          stsPulang = "Overtime";
                        } else {
                          stsPulang = "Extra Time";
                        }
                      } catch (_) {
                        stsPulang = "Invalid";
                      }
                    }

                    return AnimatedHistoryCard(
                      index: index,
                      child: InkWell(
                        onTap: () {
                          var detailData = {
                            "foto_profil":
                                data.foto != "" ? data.foto : data.nama,
                            "nama": item.nama,
                            "id_shift": item.idShift,
                            "nama_shift": item.namaShift,
                            "id_user": item.idUser,
                            "kode_cabang": item.kodeCabang,
                            "tanggal_masuk": tglMasuk,
                            "tanggal_pulang": tglPulang,
                            "sts_masuk": stsMasuk,
                            "sts_pulang": stsPulang,
                            "jam_masuk": jamShiftMasuk,
                            "jam_pulang": jamShiftPulang,
                            "jam_absen_masuk": jamMasuk,
                            "jam_absen_pulang": jamPulang,
                            "foto_masuk": item.fotoMasuk,
                            "foto_pulang": item.fotoPulang,
                            "lat_masuk": item.latMasuk,
                            "long_masuk": item.longMasuk,
                            "lat_pulang": item.latPulang,
                            "long_pulang": item.longPulang,
                            "device_info": item.devInfo,
                            "device_info2": item.devInfo2,
                          };

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DetailAbsenView(detailData),
                            ),
                          );
                        },
                        child: HistoryCard(
                          date:
                              tglMasuk.isNotEmpty
                                  ? DateTime.parse(tglMasuk)
                                  : DateTime.now(),
                          checkIn: jamMasuk,
                          checkOut: jamPulang,
                          duration: hitungDurasiFull(
                            tglMasuk: tglMasuk,
                            jamMasuk: jamMasuk,
                            tglPulang: tglPulang,
                            jamPulang: jamPulang,
                          ),
                          location: safe(item.namaCabang),
                          stsM: stsMasuk,
                          stsP: stsPulang,
                        ),
                      ),
                    );
                  }, childCount: list.length),
                );
              }),
            ),
          ],
        ),
      ),

      /// 🔹 PDF BUTTON
      floatingActionButton: Obx(
        () => Visibility(
          visible: absenC.searchAbsen.isNotEmpty,
          child: FloatingActionButton(
            heroTag: 'pdf',
            backgroundColor: Colors.redAccent[700],
            onPressed: () async {
              loadingDialog('Please wait until', 'Data is ready to print');
              await absenC.exportPdf();
              Get.back();
            },
            child: const Icon(FontAwesome.file_pdf_solid, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

class HistoryRangeTab extends StatefulWidget {
  final RxInt selectedIndex;
  final ScrollController scrollController;
  final Function(String) onSearch;

  const HistoryRangeTab({
    super.key,
    required this.selectedIndex,
    required this.scrollController,
    required this.onSearch,
  });

  @override
  State<HistoryRangeTab> createState() => _HistoryRangeTabState();
}

class _HistoryRangeTabState extends State<HistoryRangeTab> {
  final RxBool isSearching = false.obs;
  final TextEditingController searchC = TextEditingController();
  Timer? _debounce;

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      widget.onSearch(value);
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    searchC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Obx(() {
      return ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Container(
            height: 52,
            margin: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.65),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withOpacity(.4)),
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: isSearching.value ? _searchField(isDark) : _segmentedIOS(),
            ),
          ),
        ),
      );
    });
  }

  // ================= CUPERTINO SEGMENTED =================
  Widget _segmentedIOS() {
    return CupertinoSlidingSegmentedControl<int>(
      key: const ValueKey('segmented'),
      groupValue: widget.selectedIndex.value,
      thumbColor: Theme.of(context).cardColor,
      backgroundColor: Colors.transparent,
      children: const {
        0: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text('This Week'),
        ),
        1: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text('This Month'),
        ),
        2: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Icon(CupertinoIcons.search, size: 18),
        ),
      },
      onValueChanged: (v) {
        if (v == 2) {
          isSearching.value = true;

          /// 🧲 AUTO SCROLL KE ATAS
          widget.scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOut,
          );
        } else {
          widget.selectedIndex.value = v!;
        }
      },
    );
  }

  // ================= SEARCH EXPAND =================
  Widget _searchField(bool isDark) {
    return Row(
      key: const ValueKey('search'),
      children: [
        Expanded(
          child: CupertinoTextField(
            controller: searchC,
            autofocus: true,
            placeholder: 'Search data...',
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            prefix: const Padding(
              padding: EdgeInsets.only(left: 8),
              child: Icon(
                CupertinoIcons.search,
                size: 18,
                color: CupertinoColors.systemGrey,
              ),
            ),
            decoration: BoxDecoration(
              color: isDark ? Theme.of(context).cardColor : Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            style: TextStyle(color: isDark ? Colors.white : Colors.black),
            onChanged: _onSearchChanged,
          ),
        ),

        const SizedBox(width: 6),

        GestureDetector(
          onTap: () {
            isSearching.value = false;
            searchC.clear();
            widget.onSearch('');
          },
          child: const Icon(
            CupertinoIcons.clear_circled_solid,
            size: 22,
            color: CupertinoColors.systemGrey,
          ),
        ),
      ],
    );
  }
}

class HistoryTabHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double height;

  HistoryTabHeaderDelegate({required this.child, required this.height});

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return SizedBox(height: height, child: child);
  }

  @override
  bool shouldRebuild(covariant HistoryTabHeaderDelegate oldDelegate) {
    return oldDelegate.height != height || oldDelegate.child != child;
  }
}

/// 🔥 ANIMATED CARD
class AnimatedHistoryCard extends StatelessWidget {
  final Widget child;
  final int index;

  const AnimatedHistoryCard({
    super.key,
    required this.child,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      duration: Duration(milliseconds: 300 + (index * 40)),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, _) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
    );
  }
}

String safe(String? v, [String fallback = '']) {
  if (v == null || v.isEmpty) return fallback;
  return v;
}
