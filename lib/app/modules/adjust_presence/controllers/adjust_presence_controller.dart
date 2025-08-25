import 'dart:async';
import 'dart:convert';

import 'package:absensi/app/data/helper/custom_dialog.dart';
import 'package:absensi/app/data/model/absen_model.dart';
import 'package:absensi/app/data/model/req_app_model.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../data/helper/db_helper.dart';
import '../../../data/helper/manual_sse_client.dart';
import '../../../data/model/cabang_model.dart';
import '../../../data/model/dept_model.dart';
import '../../../data/model/login_model.dart';
import '../../../data/model/notif_model.dart';
import '../../../data/model/shift_kerja_model.dart';
import '../../../data/model/user_model.dart';
import '../../../data/model/users_model.dart';
import '../../../data/model/visit_model.dart';
import '../../../services/service_api.dart';

class AdjustPresenceController extends GetxController
    with GetTickerProviderStateMixin {
  var isLoading = true.obs;
  var cabang = <Cabang>[].obs;
  var selectedCabang = "".obs;
  var selectedUserCabang = "".obs;
  var selectedUserDept = "".obs;
  var userCabang = <User>[].obs;
  // var userMonitor = "".obs;
  // var dataAllAbsen = <Absen>[].obs;
  var dataVisit = <Visit>[].obs;
  var selectedShift = "".obs;
  var selectedDept = "".obs;
  var jamMasuk = "".obs;
  var jamPulang = "".obs;
  var timeNow = "";
  var dateNowServer = "";
  var listTarget = ["", "absen", "visit"];
  var target = "".obs;
  var idUser = "".obs;
  var levelUser = "".obs;

  late final TextEditingController date1,
      datePulangupd,
      store,
      userCab,
      jamMasukUpdate,
      jamPulangUpdate,
      jamIn,
      jamOut,
      foto,
      lat,
      long,
      dept,
      userDept,
      visit,
      device,
      keteranganApp,
      dateInput1,
      dateInput2;

  var resultData = Absen().obs;
  var shiftKerja = <ShiftKerja>[].obs;
  late TabController tabController;
  var listReqUpt = <ReqApp>[].obs;
  var selectedType = "".obs;
  var typeReqApp = [
    {"update_masuk": "Update Masuk"},
    {"update_pulang": "Update Pulang"},
    {"update_data_absen": "Update Data Absen"},
    {"update_shift": "Update Shift"},
  ];

  var selectedStatus = "".obs;
  var statusReqApp = [
    {"": "Unconfirmed"},
    {"0": "Canceled"},
    {"1": "Approved"},
  ];

  var initDate =
      DateFormat('yyyy-MM-dd')
          .format(
            DateTime.parse(
              DateTime(DateTime.now().year, DateTime.now().month, 1).toString(),
            ),
          )
          .toString();
  var lastDate =
      DateFormat('yyyy-MM-dd')
          .format(
            DateTime.parse(
              DateTime(
                DateTime.now().year,
                DateTime.now().month + 1,
                0,
              ).toString(),
            ),
          )
          .toString();

  @override
  Future<void> onInit() async {
    super.onInit();
    tabController = TabController(length: 2, vsync: this);

    date1 = TextEditingController();
    dateInput1 = TextEditingController();
    dateInput2 = TextEditingController();
    datePulangupd = TextEditingController();
    jamMasukUpdate = TextEditingController();
    jamPulangUpdate = TextEditingController();
    jamIn = TextEditingController();
    jamOut = TextEditingController();
    foto = TextEditingController();
    lat = TextEditingController();
    long = TextEditingController();
    store = TextEditingController();
    device = TextEditingController();
    userCab = TextEditingController();
    dept = TextEditingController();
    userDept = TextEditingController();
    visit = TextEditingController();
    keteranganApp = TextEditingController();
    // getCabang();
    // getReqAppUpt('', '', '', '', initDate, lastDate);
    SharedPreferences pref = await SharedPreferences.getInstance();
    var dataUserLogin = Data.fromJson(
      jsonDecode(pref.getString('userDataLogin')!),
    );
    // var userID = Data.fromJson(jsonDecode(pref.getString('userDataLogin')!)).id!;
    idUser.value = dataUserLogin.id!;
    levelUser.value = dataUserLogin.level!;
  }

  @override
  void dispose() {
    super.dispose();
    tabController.dispose();
  }

  getReqAppUpt(
    String? accept,
    String? type,
    String? level,
    String? idUser,
    String? date1,
    String? date2,
  ) async {
    final response = await ServiceApi().getReqUptAbs(
      accept,
      type,
      level,
      idUser,
      date1,
      date2,
    );
    listReqUpt.value = response;
    isLoading.value = false;
    return listReqUpt;
  }

  Future<List<Cabang>> getCabang() async {
    var tempCabang = await SQLHelper.instance.getCabang();
    if (tempCabang.isNotEmpty) {
      return cabang.value = tempCabang;
    } else {
      final response = await ServiceApi().getCabang({});
      cabang.value = response;
      cabang
          .map(
            (e) async => await SQLHelper.instance.insertCabang(
              Cabang(
                kodeCabang: e.kodeCabang,
                brandCabang: e.brandCabang,
                namaCabang: e.namaCabang,
                lat: e.lat,
                long: e.long,
              ),
            ),
          )
          .toList();
      return cabang;
    }
  }

  Future<List<User>> getUserCabang(String idStore, String parentId) async {
    final response = await ServiceApi().getUserCabang(idStore, parentId);
    return userCabang.value = response;
  }

  Future<List<ShiftKerja>> getShift() async {
    var tempShift = await SQLHelper.instance.getShift();
    if (tempShift.isNotEmpty) {
      return shiftKerja.value = tempShift;
    } else {
      final response = await ServiceApi().getShift();
      shiftKerja.value = response;
      shiftKerja
          .map(
            (e) async => await SQLHelper.instance.insertShift(
              ShiftKerja(
                id: e.id,
                namaShift: e.namaShift,
                jamMasuk: e.jamMasuk,
                jamPulang: e.jamPulang,
              ),
            ),
          )
          .toList();

      return shiftKerja;
    }
  }

  getDataAbsen(idUser) async {
    if (date1.text != "") {
      var data = {};
      if (target.value == "absen") {
        data = {
          "mode": "get_${target.value}",
          "id_user": idUser,
          "tanggal_masuk": date1.text,
        };
      } else {
        data = {
          "mode": "get_${target.value}",
          "id_user": idUser,
          "tgl_visit": date1.text,
        };
      }

      loadingDialog("Sedang memuat data...", "");
      final response = await ServiceApi().getDataAdjust(data);
      resultData.value = response;
      isLoading.value = false;

      Get.back();
    } else {
      showToast("Harap masukkan tanggal untuk mencari data");
    }
    return resultData;
  }

  updateDataAbsen(idUser, tglMasuk) async {
    loadingDialog("Sedang memuat data...", "");

    var data = {
      "mode": "update_${target.value}",
      "tgl_pulang": datePulangupd.text,
      "id_shift": selectedShift.value,
      "jam_masuk": jamMasuk.value,
      "jam_pulang": jamPulang.value,
      "jam_absen_masuk": jamMasukUpdate.text,
      "jam_absen_pulang": jamPulangUpdate.text,
      "foto_pulang": foto.text,
      "lat_pulang": lat.text,
      "long_pulang": long.text,
      "device_info2": device.text,
      "id_user": idUser,
      "tgl_masuk": tglMasuk,
    };
    await ServiceApi().updateAbsen(data);
    selectedShift.value = "";
    succesDialog(
      context: Get.context!,
      pageAbsen: 'N',
      desc: 'Data berhasil diupdate',
      type: DialogType.success,
      title: 'SUKSES',
      btnOkOnPress: () => Get.back(),
    );
  }

  Future<List<Dept>> getDeptVisit() async {
    final response = await ServiceApi().getDeptVisit();
    return response;
  }

  Future<List<Users>> getUserVisit(idDept) async {
    final response = await ServiceApi().getUserVisit(idDept);
    return response;
  }

  Future<List<Visit>> getDataVisit(date1, date2, idDept, idUser) async {
    var data = {
      "mode": "filter",
      "id_dept": idDept,
      "id_user": idUser,
      "tanggal1": date1,
      "tanggal2": date2,
    };

    loadingDialog("Sedang memuat data...", "");
    final response = await ServiceApi().getVisit(data);
    dataVisit.value = response;
    isLoading.value = false;
    Get.back();
    return dataVisit;
  }

  updateDataVisit(String? id, String? tglVisit, String? visitIn) async {
    var data = {
      "mode": "update_visit",
      "id_user": id,
      "tgl_visit": tglVisit,
      "visit_in": visitIn,
      "visit_out": visitIn,
      "jam_in": jamIn.text,
      "jam_out": jamOut.text,
      "foto_out": foto.text,
      "lat_out": lat.text,
      "long_out": long.text,
      "device_info2": device.text,
    };
    if (data.isNotEmpty) {
      await ServiceApi().updateAbsen(data);
      succesDialog(
        context: Get.context!,
        pageAbsen: 'N',
        desc: 'Data berhasil diupdate',
        type: DialogType.success,
        title: 'SUKSES',
        btnOkOnPress: () => Get.back(),
      );
    }
  }

  updateStatIsReadNotif({required String id, required String idUser}) async {
    var data = {"id": id, "id_user": idUser, "is_read": "1"};
    await ServiceApi().updateIsreadNotif(data);
  }

  appAbs(
    Map<String, dynamic> dataUptApp,
    Map<String, dynamic>? dataUptAbs,
  ) async {
    // print(dataUptApp['accept']);
    if (dataUptApp['accept'] == "1") {
      await ServiceApi().updateReqApp(dataUptApp);
      await ServiceApi().updateReqAdjAbs(dataUptAbs!);
      dialogMsg('INFO', 'Data berhasil diupdate');
      await getReqAppUpt(
        '',
        '',
        levelUser.value,
        idUser.value,
        initDate,
        lastDate,
      );
    } else {
      await ServiceApi().updateReqApp(dataUptApp);
      dialogMsg('INFO', 'Data berhasil diupdate');
      await getReqAppUpt(
        '',
        '',
        levelUser.value,
        idUser.value,
        initDate,
        lastDate,
      );
    }
    keteranganApp.clear();
  }

  Stream<NotifModel> getAdjusmentData({
    required String idUser,
    required String level,
  }) {
    StreamController<NotifModel> controller = StreamController();

    void connect() {
      final url = Uri.parse(
        '${dotenv.env['STREAM_NOTIF_URL']}?type=adjusment&id_user=$idUser&level=$level&date1=$initDate&date2=$lastDate',
      );
      // print(
      //   '${dotenv.env['STREAM_NOTIF_URL']}?type=adjusment&id_user=$idUser&level=$level&date1=$initDate&date2=$lastDate',
      // );
      final sseClient = ManualSseClient(url);

      sseClient.connect().listen(
        (dataStr) {
          //  print('Received raw data: $dataStr');
          try {
            final jsonData = jsonDecode(dataStr);
            // print(jsonData);
            if (jsonData is Map<String, dynamic> &&
                jsonData['success'] == true &&
                jsonData['data'] != null) {
              final model = NotifModel.fromJson(jsonData['data']);
              // print('---------');
              // print(model);
              if (!controller.isClosed) controller.add(model);
            } else {
              if (!controller.isClosed) {
                controller.addError('Tidak berhasil mendapatkan data');
              }
            }
          } catch (e) {
            if (!controller.isClosed) {
              controller.addError('Parse JSON gagal: $e');
            }
          }
        },
        onError: (error) async {
          if (!controller.isClosed) controller.addError(error);
          // Reconnect after delay
          await Future.delayed(const Duration(seconds: 5));
          if (!controller.isClosed) connect();
        },
        onDone: () async {
          // Reconnect after delay
          await Future.delayed(const Duration(seconds: 5));
          if (!controller.isClosed) connect();
        },
        cancelOnError: true,
      );
    }

    connect();

    controller.onCancel = () {
      controller.close();
    };

    return controller.stream;
  }
}
