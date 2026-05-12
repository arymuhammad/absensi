import 'dart:convert';
import 'dart:io';
import 'package:absensi/app/data/helper/custom_dialog.dart';
import 'package:absensi/app/data/model/req_leave_model.dart';
import 'package:absensi/app/data/model/login_model.dart';
import 'package:absensi/app/data/model/user_model.dart';
import 'package:absensi/app/modules/login/controllers/login_controller.dart';
import 'package:absensi/app/services/service_api.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signature/signature.dart';
import 'package:step_progress/step_progress.dart';
import 'package:uuid/uuid.dart';

import '../../../data/model/leave_model.dart';

class LeaveController extends GetxController {
  var isLoading = true.obs;
  var listLeaveReq = <ReqLeaveModel>[].obs;
  var datePick1 = TextEditingController();
  var datePick2 = TextEditingController();
  var nikUser = TextEditingController();
  var levelUser = TextEditingController();
  var leaveType = ["", "Hak Cuti Tahunan", "Lainnya"];
  var leaveList = <LeaveModel>[].obs;
  var reasonLeave = TextEditingController();
  var addrLeave = TextEditingController();
  var phone = TextEditingController();
  var amtTkn = TextEditingController();
  var remainDays = 0.obs;
  var selectedLeaveType = "".obs;
  var selectedLeave = "".obs;
  var selectedIdUser = "".obs;
  var uId = "";
  var idUser = "";
  var statusReqLeave = [
    {"pending": "Pending"},
    {"reject": "Rejected"},
    {"approved": "Approved"},
  ];
  var selectedStatus = "".obs;

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
  XFile? image;
  final ImagePicker picker = ImagePicker();
  late Future<List<LeaveModel>> futureLeave;

  @override
  void onInit() {
    super.onInit();
    _init();
  }

  Future<void> _init() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var dataUser = Data.fromJson(jsonDecode(pref.getString('userDataLogin')!));

    idUser = dataUser.id!;

    leaveBalanceCheck(dataUser);

    stepProgressController = StepProgressController(
      initialStep: currentStep,
      totalSteps: 3,
    );

    getLeaveList();
  }

  @override
  void onClose() {
    datePick1.dispose();
    datePick2.dispose();
    nikUser.dispose();
    levelUser.dispose();

    reasonLeave.dispose();
    addrLeave.dispose();
    phone.dispose();
    super.onClose();
  }

  Future<List<User>> getUserCabang(String kodeCabang, String parentId) async {
    return await ServiceApi().getUserCabang(kodeCabang, parentId);
  }

  generateUid() {
    var uid = const Uuid();
    return uId = 'UID_${uid.v4()}';
  }

  Future<void> getLeaveList() async {
    isLoading.value = true;

    final res = await ServiceApi().leave({"type": ""});
    leaveList.value = res;

    isLoading.value = false;
  }

  getLeaveReq(Map<String, dynamic> param) async {
    final response = await ServiceApi().reqLeave(param);

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
    // required String userPengganti,
    // required String levelUserPengganti,
    required String parentId,
  }) async {
    /*
  |--------------------------------------------------------------------------
  | CLOSE BOTTOM SHEET / PAGE BEFORE LOADING
  |--------------------------------------------------------------------------
  */

    Get.back();

    loadingDialog("Mengirim pengajuan cuti...", "");

    final signatureBytes = await ctrSign.toPngBytes();

    if (signatureBytes == null) {
      Get.back();

      return;
    }

    final String base64SignImage = base64Encode(signatureBytes);

    final Map<String, dynamic> data = {
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

      // "user_pengganti": userPengganti,
      // "level_user_pengganti": levelUserPengganti,
      "parent_id": parentId,
      "signature": base64SignImage,

      /*
    |--------------------------------------------------------------------------
    | OPTIONAL FILE
    |--------------------------------------------------------------------------
    */
      "attach_file": image != null ? File(image!.path) : null,
    };

    /*
  |--------------------------------------------------------------------------
  | SEND API
  |--------------------------------------------------------------------------
  */

    final success = await ServiceApi().reqLeaveAdd(data);

    /*
  |--------------------------------------------------------------------------
  | CLOSE LOADING
  |--------------------------------------------------------------------------
  */

    Get.back();

    /*
  |--------------------------------------------------------------------------
  | FAILED
  |--------------------------------------------------------------------------
  */

    if (!success) {
      failedDialog(Get.context!, 'ERROR', 'Pengajuan gagal dikirim');

      return;
    }

    /*
  |--------------------------------------------------------------------------
  | RESET FORM
  |--------------------------------------------------------------------------
  */

    datePick1.clear();
    datePick2.clear();

    selectedLeave.value = "";
    leaveList.clear();

    amtTkn.clear();
    reasonLeave.clear();
    addrLeave.clear();
    phone.clear();

    selectedIdUser.value = "";
    nikUser.clear();

    selectedLevelUser.value = "";
    selectednamaLevel.value = "";

    ctrSign.clear();

    image = null;

    /*
  |--------------------------------------------------------------------------
  | REFRESH DATA
  |--------------------------------------------------------------------------
  */

    isLoading.value = true;

    getLeaveReq({"type": "", "id_user": idUser});

    /*
  |--------------------------------------------------------------------------
  | SUCCESS DIALOG
  |--------------------------------------------------------------------------
  */

    succesDialog(
      context: Get.context!,
      pageAbsen: 'N',
      desc: 'Pengajuan berhasil dibuat',
      type: DialogType.success,
      title: 'SUKSES',

      btnOkOnPress: () {
        Get.back();
      },
    );
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
    await ServiceApi().reqLeave(param);
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
    //
  }

  void uploadFile() async {
    image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxHeight: 600,
      maxWidth: 600,
    );
    if (image != null) {
      update();
    }
  }
}
