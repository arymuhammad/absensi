import 'package:get/get.dart';

import '../modules/absen/views/absen_view.dart';
import '../modules/add_pegawai/bindings/add_pegawai_binding.dart';
import '../modules/add_pegawai/views/add_pegawai_view.dart';
import '../modules/cek_stok/bindings/cek_stok_binding.dart';
import '../modules/cek_stok/views/cek_stok_view.dart';
import '../modules/detail_absen/bindings/detail_absen_binding.dart';
import '../modules/detail_absen/views/detail_absen_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/login/bindings/login_binding.dart';
import '../modules/login/views/login_view.dart';
import '../modules/profil/bindings/profil_binding.dart';
import '../modules/profil/views/profil_view.dart';
import '../modules/semua_absen/bindings/semua_absen_binding.dart';
import '../modules/semua_absen/views/semua_absen_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.HOME;

  static final routes = [
    GetPage(
        name: _Paths.HOME,
        page: () => HomeView(),
        binding: HomeBinding(),
        transition: Transition.fadeIn),
    GetPage(
        name: _Paths.ADD_PEGAWAI,
        page: () => const AddPegawaiView(),
        binding: AddPegawaiBinding(),
        transition: Transition.cupertino),
    GetPage(
        name: _Paths.LOGIN,
        page: () => const LoginView(),
        binding: LoginBinding(),
        transition: Transition.fadeIn),
    GetPage(
        name: _Paths.PROFIL,
        page: () => ProfilView(),
        binding: ProfilBinding(),
        transition: Transition.fadeIn),
    GetPage(
        name: _Paths.DETAIL_ABSEN,
        page: () => DetailAbsenView(),
        binding: DetailAbsenBinding(),
        transition: Transition.fadeIn),
    GetPage(
        name: _Paths.SEMUA_ABSEN,
        page: () => SemuaAbsenView(),
        binding: SemuaAbsenBinding(),
        transition: Transition.fadeIn),
    GetPage(
      name: _Paths.CEK_STOK,
      page: () => CekStokView(),
      binding: CekStokBinding(),
    ),
    GetPage(
      name: _Paths.ABSEN,
      page: () => AbsenView(),
      
    ),
  ];
}
