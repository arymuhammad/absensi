import 'dart:convert';

import 'package:absensi/app/data/helper/custom_dialog.dart';
import 'package:absensi/app/data/model/leave_model.dart';
import 'package:absensi/app/data/model/login_model.dart';
import 'package:absensi/app/data/model/user_model.dart';
import 'package:absensi/app/modules/login/controllers/login_controller.dart';
import 'package:absensi/app/services/service_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signature/signature.dart';
import 'package:startapp_sdk/startapp.dart';
import 'package:step_progress/step_progress.dart';
import 'package:uuid/uuid.dart';

class LeaveController extends GetxController {
  var isLoading = true.obs;
  var listLeaveReq = <LeaveModel>[].obs;
  var datePick1 = TextEditingController();
  var datePick2 = TextEditingController();
  var nikUser = TextEditingController();
  var levelUser = TextEditingController();
  var listLeaves = ["", "Hak Cuti Tahunan", "Lain-lain, sebutkan"];
  var otherLeave = TextEditingController();
  var reasonLeave = TextEditingController();
  var addrLeave = TextEditingController();
  var phone = TextEditingController();
  var amtTkn = TextEditingController();
  var remainDays = 0.obs;
  var selectedLeave = "".obs;
  var uId = "";
  var idUser = "";
  var selectedIdUser = "".obs;
  var selectedLevelUser = "".obs;
  var selectednamaLevel = "".obs;
  final SignatureController ctrSign = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );
  int currentStep = 0;
  late StepProgressController stepProgressController;
  int retryCount = 0;
  final int maxRetry = 3;
  final StartAppSdk startAppSdk = StartAppSdk();
  Rx<StartAppBannerAd?> bannerAdStartApp = Rx<StartAppBannerAd?>(null);

  @override
  void onInit() async {
    super.onInit();
    SharedPreferences pref = await SharedPreferences.getInstance();
    var dataUser = Data.fromJson(jsonDecode(pref.getString('userDataLogin')!));
    idUser = dataUser.id!;

    stepProgressController = StepProgressController(
      initialStep: currentStep,
      totalSteps: 3,
    );
    // print('username : ${dataUser.username!}');
    var newUsr = await ServiceApi().fetchCurrentUser({
      "username": dataUser.username!,
      "password": dataUser.password!,
    });
    if (Get.isRegistered<LoginController>()) {
      final logC = Get.find<LoginController>();
      logC.logUser.update((val) {
        val!.leaveBalance = newUsr.leaveBalance!;
      });
      logC.refresh();
    }

    startAppSdk.setTestAdsEnabled(false); // Aktifkan saat development
    loadBannerAd();
  }

  Future<void> loadBannerAd() async {
    try {
      bannerAdStartApp.value = await startAppSdk.loadBannerAd(
        StartAppBannerType.BANNER,
      );
      retryCount = 0; // Reset jika berhasil
      // simpan bannerAd ke state/store supaya bisa dipakai di widget
    } on PlatformException catch (_) {
      if (retryCount < maxRetry) {
        retryCount++;
        Future.delayed(const Duration(seconds: 3), () {
          loadBannerAd();
        });
      } else {
        showToast('Gagal memuat iklan banner setelah $maxRetry kali percobaan');
      }
    } catch (e) {
      // print('Unexpected error: $e');
      showToast('Gagal memuat iklan banner');
      // loadBannerAd();
    }
  }

  @override
  void onClose() {
    datePick1.dispose();
    datePick2.dispose();
    nikUser.dispose();
    levelUser.dispose();
    otherLeave.dispose();
    reasonLeave.dispose();
    addrLeave.dispose();
    phone.dispose();
    bannerAdStartApp.value?.dispose();
    super.onClose();
  }

  Future<List<User>> getUserCabang(String kodeCabang, String parentId) async {
    return await ServiceApi().getUserCabang(kodeCabang, parentId);
  }

  generateUid() {
    var uid = const Uuid();
    return uId = 'UID_${uid.v4()}';
  }

  getLeaveReq(Map<String, dynamic> param) async {
    final response = await ServiceApi().leave(param);

    listLeaveReq.value = response;
    isLoading.value = false;
    return listLeaveReq;
  }

  submitLeaveReq({
    required String idUser,
    required String level,
    required String nama,
    required String cabang,
    required String jenisCuti,
    required String jumlahCuti,
    required String saldoCuti,
    required String alasanCuti,
    required String alamatCuti,
    required String telp,
    required String userPengganti,
    required String levelUserPengganti,
    required String parentId,
  }) async {
    Get.back();
    loadingDialog("Mengirim pengajuan cuti...", "");
    final signatureBytes = await ctrSign.toPngBytes();
    if (signatureBytes == null) return;

    String base64SignImage = base64Encode(signatureBytes);

    var data = {
      "type": "add_leave",
      "uid": uId,
      "date1": datePick1.text,
      "date2": datePick2.text,
      "id_user": idUser,
      "nama": nama,
      "kode_cabang": cabang,
      "level_user": level,
      "jenis_cuti": jenisCuti,
      "saldo_cuti": saldoCuti,
      "jumlah_cuti": jumlahCuti,
      "alasan_cuti": alasanCuti,
      "alamat_cuti": alamatCuti,
      "phone": telp,
      "user_pengganti": userPengganti,
      "level_user_pengganti": levelUserPengganti,
      "parent_id": parentId,
      "signature": base64SignImage,
    };
    await ServiceApi().leave(data);
    datePick1.clear();
    datePick2.clear();
    selectedLeave.value = "";
    otherLeave.clear();
    amtTkn.clear();
    reasonLeave.clear();
    addrLeave.clear();
    phone.clear();
    selectedIdUser.value = "";
    nikUser.clear();
    selectedLevelUser.value = "";
    selectednamaLevel.value = "";
    ctrSign.clear();
    Get.back();
    Get.back();
    isLoading.value = true;
    getLeaveReq({"type": "", "id_user": idUser});
    // print(data);
  }

  approveLeave(BuildContext context, Data? userData, String uid) async {
    Get.back();
    loadingDialog("Menyetujui pengajuan cuti...", "");
    final signatureBytes = await ctrSign.toPngBytes();
    if (signatureBytes == null) return;

    String base64SignImage = base64Encode(signatureBytes);
    var param = {
      "type": "update",
      "uid": uid,
      "level": userData!.level,
      "acc_name": userData.nama,
      "sign": base64SignImage,
    };
    await ServiceApi().leave(param);
    ctrSign.clear();
    Get.back();
    isLoading.value = true;
    var reload = {
      "type": "get_pending_req_leave",
      "kode_cabang": userData.kodeCabang!,
      "id_user": userData.id!,
      "level": userData.level!,
      "parent_id": userData.parentId!,
    };
    getLeaveReq(reload);
  }

  remainingOff(String a, String b) {
    int total = int.parse(a);
    int input = int.parse(b.isNotEmpty ? b : '0');

    return remainDays.value = total - input;
  }

  leaveBalanceCheck(Data dataUser) async {
    var newUser = await ServiceApi().fetchCurrentUser({
      "username": dataUser.username!,
      "password": dataUser.password!,
    });
    if (Get.isRegistered<LoginController>()) {
      final logC = Get.find<LoginController>();
      logC.logUser.update((val) {
        val!.leaveBalance = newUser.leaveBalance!;
      });
      logC.refresh();
    }
  }
}
