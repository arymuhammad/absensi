import 'package:get/get.dart';

import '../modules/absen/views/absen_view.dart';
import '../modules/add_pegawai/bindings/add_pegawai_binding.dart';
import '../modules/add_pegawai/views/add_pegawai_view.dart';
import '../modules/adjust_presence/bindings/adjust_presence_binding.dart';
import '../modules/adjust_presence/views/adjust_presence_view.dart';
import '../modules/detail_absen/bindings/detail_absen_binding.dart';
import '../modules/detail_absen/views/detail_absen_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/leave/bindings/leave_binding.dart';
import '../modules/leave/views/leave_view.dart';
import '../modules/login/bindings/login_binding.dart';
import '../modules/login/views/login_view.dart';
import '../modules/pay_slip/bindings/pay_slip_binding.dart';
import '../modules/pay_slip/views/pay_slip_view.dart';
import '../modules/profil/bindings/profil_binding.dart';
import '../modules/profil/views/profil_view.dart';
import '../modules/semua_absen/bindings/semua_absen_binding.dart';
import '../modules/semua_absen/views/semua_absen_view.dart';
import '../modules/settings/bindings/settings_binding.dart';
import '../modules/settings/views/settings_view.dart';

// import '../modules/alarm/bindings/alarm_binding.dart';
// import '../modules/alarm/views/alarm_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.HOME;

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => HomeView(),
      binding: HomeBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: _Paths.ADD_PEGAWAI,
      page: () => const AddPegawaiView(),
      binding: AddPegawaiBinding(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: _Paths.LOGIN,
      page: () => const LoginView(),
      binding: LoginBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: _Paths.PROFIL,
      page: () => ProfilView(),
      binding: ProfilBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: _Paths.DETAIL_ABSEN,
      page: () => DetailAbsenView(const {}),
      binding: DetailAbsenBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: _Paths.SEMUA_ABSEN,
      page: () => SemuaAbsenView(),
      binding: SemuaAbsenBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(name: _Paths.ABSEN, page: () => AbsenView()),
    GetPage(
      name: _Paths.SETTINGS,
      page: () => SettingsView(),
      binding: SettingsBinding(),
    ),
    // GetPage(
    //   name: _Paths.ALARM,
    //   page: () => AlarmView(),
    //   binding: AlarmBinding(),
    // ),
    GetPage(
      name: _Paths.ADJUST_PRESENCE,
      page: () => AdjustPresenceView(),
      binding: AdjustPresenceBinding(),
    ),
    GetPage(
      name: _Paths.LEAVE,
      page: () => LeaveView(),
      binding: LeaveBinding(),
    ),
    GetPage(
      name: _Paths.PAY_SLIP,
      page: () => PaySlipView(),
      binding: PaySlipBinding(),
    ),
  ];
}
