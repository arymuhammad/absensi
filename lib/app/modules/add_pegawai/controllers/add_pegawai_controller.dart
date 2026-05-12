import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:absensi/app/data/model/login_model.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:crypto/crypto.dart';
import 'package:absensi/app/data/helper/db_helper.dart';
import 'package:absensi/app/services/service_api.dart';
import 'package:absensi/app/data/model/level_model.dart';
import 'package:absensi/app/modules/profil/views/update_password.dart';
// import 'package:device_info_null_safety/device_info_null_safety.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sqflite/sqflite.dart';
// import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/helper/custom_dialog.dart';
import '../../../data/model/cabang_model.dart';
import '../../../data/model/cek_user_model.dart';
import '../../../data/model/foto_profil_model.dart';
import '../../../data/model/user_model.dart';
import '../../login/controllers/login_controller.dart';
// import 'package:google_ml_vision/google_ml_vision.dart';

class AddPegawaiController extends GetxController {
  late TextEditingController nip,
      name,
      username,
      pass,
      store,
      telp,
      level,
      joinDate,
      filterUser;
  final RxString searchKeyword = ''.obs;
  final FocusNode focusNodecabang = FocusNode();
  final FocusNode focusNodelevel = FocusNode();
  final GlobalKey autocompleteKeyBrand = GlobalKey();
  final GlobalKey autocompleteKey = GlobalKey();
  final GlobalKey autocompleteKeyLevel = GlobalKey();
  final ImagePicker picker = ImagePicker();
  XFile? image;
  FilePickerResult? fileResult;
  File file = File("zz");
  Map<String, dynamic> imgUpl = {};
  Uint8List webImage = Uint8List(0);
  String fileName = "";
  var isLoading = false.obs;
  // var faceDatas = DataWajah().obs;
  var cabang = <Cabang>[].obs;
  var levelUser = <Level>[].obs;
  var selectedCabang = "".obs;
  var cabangName = "".obs;
  var selectedLevel = "".obs;
  var levelName = "".obs;
  var vst = "".obs;
  var cvrArea = "".obs;
  var lat = "".obs;
  var long = "".obs;
  var cekStok = "".obs;
  var cekDataUser = <CekUser>[].obs;
  var fotoProfil = "".obs;
  var newPhone = "".obs;
  var listBrand = <Cabang>[].obs;
  var brandCabang = "".obs;
  var downloadProgress = 0.0.obs;
  var updateList = [];
  var currVer = "";
  var latestVer = "";
  var backup = false.obs;
  var restore = false.obs;
  var listUser = <User>[].obs;
  RxList<User> searchUser = RxList<User>([]);

  var initDate1 =
      DateFormat('yyyy-MM-dd')
          .format(
            DateTime.parse(
              DateTime(DateTime.now().year, DateTime.now().month, 1).toString(),
            ),
          )
          .toString();
  var initDate2 =
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
  // var supportedAbi = "";

  @override
  void onInit() async {
    super.onInit();
    nip = TextEditingController();
    name = TextEditingController();
    username = TextEditingController();
    pass = TextEditingController();
    store = TextEditingController();
    telp = TextEditingController();
    level = TextEditingController();
    joinDate = TextEditingController();
    filterUser = TextEditingController();
    getBrandCabang();
    getLevel();

    PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
      // String appName = packageInfo.appName;
      // String packageName = packageInfo.packageName;
      currVer = packageInfo.version;
      // String buildNumber = packageInfo.buildNumber;
    });
    // if (Platform.isAndroid) {
    //   final DeviceInfoNullSafety deviceInfoNullSafety = DeviceInfoNullSafety();
    //   Map<String, dynamic> abiInfo = await deviceInfoNullSafety.abiInfo;
    //   var abi = abiInfo.entries.toList();
    //   supportedAbi = abi[1].value;
    // }
  }

  @override
  void onClose() {
    super.dispose();
    nip.dispose();
    name.dispose();
    username.dispose();
    pass.dispose();
    store.dispose();
    telp.dispose();
    level.dispose();
    joinDate.dispose();
    filterUser.dispose();
  }

  getBrandCabang() async {
    final response = await ServiceApi().getBrandCabang();
    return listBrand.value = response;
  }

  Future<List<User>> getUser(String branchCode, String parentId) async {
    final response = await ServiceApi().getUserCabang(branchCode, parentId);
    isLoading.value = false;
    searchUser.value = response;
    return listUser.value = response;
  }

  List<User> get filterDataUser {
    final q = searchKeyword.value.toLowerCase();

    if (q.isEmpty) return listUser;

    return listUser.where((e) {
      return e.nama!.toLowerCase().contains(q);
    }).toList();
  }

  Future<List<Cabang>> getCabang() async {
    var data = {"brand": brandCabang.value};
    final response = await ServiceApi().getCabang(data);
    return cabang.value = response;
  }

  Future<List<Level>> getLevel() async {
    final response = await ServiceApi().getLevel();
    return levelUser.value = response;
  }

  void uploadImageProfile() async {
    if (kIsWeb) {
      fileResult = await FilePicker.platform.pickFiles(
        compressionQuality: 60,
        allowedExtensions: ['jpg', 'jpeg', 'png'],
        withReadStream: true,
        // // this will return PlatformFile object with read stream
        allowCompression: true,
      );
    } else {
      image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 60,
        maxHeight: 600,
        maxWidth: 600,
      );
      if (image != null) {
        update();
      }
    }
  }

  Future<bool> addUpdatePegawai(context, String mode, Data dataUser) async {
    Random random = Random();
    int randomNumber = random.nextInt(100);
    final response = await ServiceApi().getUser();
    cekDataUser.value = response;

    // var lstUser = [];
    // cekDataUser.map((e) {
    //   lstUser.add(e.username!);
    // }).toList();
    // var lstPhone = [];
    // cekDataUser.map((e) {
    //   lstPhone.add(e.notelp!);
    // }).toList();
    final isUsrExist = cekDataUser.any(
      (dt) => dt.username?.trim() == username.text.trim(),
    );
    final inputTelp = telp.text.trim();
    final oldTelp = dataUser.noTelp?.trim() ?? '';

    // // hanya validasi kalau user isi field
    // if (inputTelp.isNotEmpty) {
    //   final isNumExist = cekDataUser.any(
    //     (dt) => (dt.notelp ?? '').trim() == inputTelp,
    //   );
    // }
    if (mode == "add") {
      loadingDialog("Registering user", "Please wait");
      if (selectedCabang.isNotEmpty &&
          username.text != "" &&
          pass.text != "" &&
          name.text != "" &&
          telp.text != "" &&
          selectedCabang.isNotEmpty &&
          selectedLevel.isNotEmpty) {
        if (image != null &&
                (image!.name.endsWith("jpg") ||
                    image!.name.endsWith("jpeg") ||
                    image!.name.endsWith("png")) ||
            fileResult != null) {
          var data = {
            "status": mode,
            "id": '${selectedCabang.value}000$randomNumber',
            "username": username.text,
            "password": pass.text,
            "nama": name.text,
            "no_telp": telp.text,
            "kode_cabang": selectedCabang.value,
            "level": selectedLevel.value,
            "foto":
                kIsWeb
                    ? fileResult!.files.single
                    : File(image!.path.toString()),
          };

          if (isUsrExist && isPhoneExist(inputTelp)) {
            _showWarning(
              "Username and Phone Number are already registered\nPlease change both",
            );
            return false;
          } else if (isUsrExist) {
            _showWarning(
              "Username is already registered\nPlease change it to another username",
            );
            return false;
          } else if (isPhoneExist(inputTelp)) {
            _showWarning(
              "This phone number is already registered\nPlease enter another phone number",
            );
            return false;
          } else {
            // succesDialog(context, "N", "Data berhasil disimpan", DialogType.success, 'SUKSES');
            final isSuccess = await ServiceApi().addUpdatePegawai(data, mode);
            if (!isSuccess) {
              Get.back(); // tutup loading
              warningDialog(
                Get.context!,
                "Error",
                "Failed to update data. Please try again",
              );
              isLoading.value = false;
              return false;
            }
            selectedCabang.value = "";
            username.clear();
            store.clear();
            level.clear();
            pass.clear();
            name.clear();
            telp.clear();
            selectedLevel.value = "";
            brandCabang.value = "";
            // lstUser.clear();

            image = null;
            return true;
          }
        } else {
          var data = {
            "status": mode,
            "id": '${selectedCabang.value}000$randomNumber',
            "username": username.text,
            "password": pass.text,
            "nama": name.text,
            "no_telp": telp.text,
            "kode_cabang": selectedCabang.value,
            "level": selectedLevel.value,
          };

          if (isUsrExist && isPhoneExist(inputTelp)) {
            _showWarning(
              "Username and Phone Number are already registered\nPlease change both",
            );
            return false;
          } else if (isUsrExist) {
            _showWarning(
              "Username is already registered\nPlease change it to another username",
            );
            return false;
          } else if (isPhoneExist(inputTelp)) {
            _showWarning(
              "This phone number is already registered\nPlease enter another phone number",
            );
            return false;
          } else {
            final isSuccess = await ServiceApi().addUpdatePegawai(data, mode);
            if (!isSuccess) {
              Get.back(); // tutup loading
              warningDialog(
                Get.context!,
                "Error",
                "Failed to update data. Please try again",
              );
              isLoading.value = false;
              return false;
            }
            selectedCabang.value = "";
            username.clear();
            store.clear();
            level.clear();
            pass.clear();
            name.clear();
            telp.clear();
            selectedLevel.value = "";
            brandCabang.value = "";
            // lstUser.clear();
            image = null;
            return true;
          }
        }
      } else {
        Get.back();
        warningDialog(
          Get.context!,
          "Warning",
          "Please fill in the data in all columns",
        );
        return false;
      }
    } else {
      loadingDialog("Updating data", "Please wait");

      if (image != null &&
              (image!.name.endsWith("jpg") ||
                  image!.name.endsWith("jpeg") ||
                  image!.name.endsWith("png")) ||
          fileResult != null) {
        var data = {
          "status": mode,
          "id": dataUser.id,
          "username": dataUser.username,
          "nama": name.text != "" ? name.text : dataUser.nama,
          "no_telp": inputTelp.isNotEmpty ? inputTelp : oldTelp,
          "kode_cabang":
              selectedCabang.value != ""
                  ? selectedCabang.value
                  : dataUser.kodeCabang,
          "level":
              selectedLevel.value != "" ? selectedLevel.value : dataUser.level,
          "foto":
              kIsWeb ? fileResult!.files.single : File(image!.path.toString()),
          "created_at": joinDate.text.isNotEmpty ? joinDate.text : null,
        };

        if (inputTelp.isNotEmpty && isPhoneExist(inputTelp)) {
          Get.back();
          warningDialog(
            Get.context!,
            "Warning",
            "This phone number is already registered\nPlease enter another phone number",
          );
          isLoading.value = false;
          return false;
        } else {
          final isSuccess = await ServiceApi().addUpdatePegawai(data, mode);

          if (!isSuccess) {
            Get.back(); // tutup loading
            warningDialog(
              Get.context!,
              "Error",
              "Failed to update data. Please try again",
            );
            isLoading.value = false;
            return false;
          }
          // langsung update sharedpref tanpa harus re login
          var newUsr = await ServiceApi().fetchCurrentUser({
            "username": dataUser.username!,
            "password": dataUser.password!,
          });
          if (Get.isRegistered<LoginController>()) {
            final logC = Get.find<LoginController>();

            // update sharedpreff
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('userDataLogin', jsonEncode(newUsr.toJson()));
            logC.logUser.value = newUsr;

            logC.refresh();
          }
          //start update local db for tbl_user
          SQLHelper.instance.updateDataUser(
            {
              "nama": name.text != "" ? name.text : dataUser.nama,
              "no_telp": inputTelp.isNotEmpty ? inputTelp : oldTelp,
              "kode_cabang":
                  selectedCabang.value != ""
                      ? selectedCabang.value
                      : dataUser.kodeCabang,
              "nama_cabang":
                  cabangName.value != ""
                      ? cabangName.value
                      : dataUser.namaCabang,
              "lat": newUsr.lat!,
              "long": newUsr.long!,
              "area_coverage": newUsr.areaCover!,
              "level":
                  selectedLevel.value != ""
                      ? selectedLevel.value
                      : dataUser.level,
              "level_user":
                  levelName.value != "" ? levelName.value : dataUser.levelUser,
              "foto": image!.path,
              "visit": newUsr.visit!,
              "parent_id": newUsr.parentId!,
              "cek_stok":
                  cekStok.value != "" ? cekStok.value : dataUser.cekStok,
              "created_at":
                  joinDate.text.isNotEmpty ? joinDate.text : dataUser.createdAt,
            },
            dataUser.id!,
            dataUser.username!,
          );
          //end of update

          // Get.back();
          // dialogMsgScsUpd(
          //     "Sukses", "Data berhasil disimpan\nSilahkan login ulang");
          newPhone.value = telp.text;

          var idUser = {"id": dataUser.id};
          FotoProfil foto = await ServiceApi().getFotoProfil(idUser);
          SharedPreferences pref = await SharedPreferences.getInstance();
          await pref.setString("fotoProfil", foto.foto!);
          // fotoProfil.value = pref.getString("fotoProfil")!;
          selectedCabang.value = "";
          cvrArea.value = "";
          lat.value = "";
          long.value = "";
          cabangName.value = "";
          levelName.value = "";
          cekStok.value = "";
          username.clear();
          store.clear();
          level.clear();
          pass.clear();
          name.clear();
          telp.clear();
          joinDate.clear();
          selectedLevel.value = "";
          brandCabang.value = "";

          isLoading.value = false;
          image = null;
          return true;
        }
        // Get.back();
      } else {
        // if (lstPhone.contains(telp.text)) {
        if (inputTelp.isNotEmpty && isPhoneExist(inputTelp)) {
          Get.back();
          warningDialog(
            Get.context!,
            "Warning",
            "This phone number is already registered\nPlease enter another phone number",
          );
          isLoading.value = false;
          return false;
        } else {
          var data = {
            "status": mode,
            "id": dataUser.id,
            "nama": name.text != "" ? name.text : dataUser.nama,
            "no_telp": inputTelp.isNotEmpty ? inputTelp : oldTelp,
            "kode_cabang":
                selectedCabang.value != ""
                    ? selectedCabang.value
                    : dataUser.kodeCabang,
            "level":
                selectedLevel.value != ""
                    ? selectedLevel.value
                    : dataUser.level,
            "created_at": joinDate.text.isNotEmpty ? joinDate.text : null,
          };
          // loadingDialog("updating data", "");
          // print(data);
          final isSuccess = await ServiceApi().addUpdatePegawai(data, mode);
          if (!isSuccess) {
            Get.back(); // tutup loading
            warningDialog(
              Get.context!,
              "Error",
              "Failed to update data. Please try again",
            );
            isLoading.value = false;
            return false;
          }
          // langsung update sharedpref tanpa harus re login
          var newUsr = await ServiceApi().fetchCurrentUser({
            "username": dataUser.username!,
            "password": dataUser.password!,
          });
          if (Get.isRegistered<LoginController>()) {
            final logC = Get.find<LoginController>();

            // update sharedpreff
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('userDataLogin', jsonEncode(newUsr.toJson()));
            logC.logUser.value = newUsr;

            logC.refresh();
          }
          //start update local db for tbl_user
          SQLHelper.instance.updateDataUser(
            {
              "nama": name.text != "" ? name.text : dataUser.nama,
              "no_telp": inputTelp.isNotEmpty ? inputTelp : oldTelp,
              "kode_cabang":
                  selectedCabang.value != ""
                      ? selectedCabang.value
                      : dataUser.kodeCabang,
              "nama_cabang":
                  cabangName.value != ""
                      ? cabangName.value
                      : dataUser.namaCabang,
              "lat": newUsr.lat!,
              "long": newUsr.long!,
              "area_coverage": newUsr.areaCover!,
              "level":
                  selectedLevel.value != ""
                      ? selectedLevel.value
                      : dataUser.level,
              "level_user":
                  levelName.value != "" ? levelName.value : dataUser.levelUser,
              "visit": newUsr.visit!,
              "parent_id": newUsr.parentId!,
              "cek_stok":
                  cekStok.value != "" ? cekStok.value : dataUser.cekStok,
              "created_at":
                  joinDate.text.isNotEmpty ? joinDate.text : newUsr.createdAt,
            },
            dataUser.id!,
            dataUser.username!,
          );
          //end of update

          newPhone.value = telp.text;
          selectedCabang.value = "";
          cvrArea.value = "";
          lat.value = "";
          long.value = "";
          cabangName.value = "";
          levelName.value = "";
          cekStok.value = "";
          username.clear();
          store.clear();
          level.clear();
          pass.clear();
          name.clear();
          telp.clear();
          joinDate.clear();
          selectedLevel.value = "";
          brandCabang.value = "";

          isLoading.value = false;
          image = null;
          return true;
        }
      }
    }
  }

  bool isPhoneExist(String inputTelp) {
    final val = inputTelp.trim();

    return cekDataUser.any((dt) => (dt.notelp ?? '').trim() == val);
  }

  void cekUser(context) async {
    var data = {"no_telp": telp.text};
    if (telp.text != "") {
      loadingDialog("Looking for user data", "");
      final response = await ServiceApi().cekUser(data);
      cekDataUser.value = response;
      Get.back();
      if (cekDataUser.isNotEmpty) {
        telp.clear();

        Get.to(
          () => UpdatePassword(),
          arguments: {
            "id_user": cekDataUser[0].id,
            "username": cekDataUser[0].username,
            "nama": cekDataUser[0].nama,
            "no_telp": cekDataUser[0].notelp,
            "foto": cekDataUser[0].foto,
          },
        );
      } else {
        warningDialog(
          context,
          "Warning",
          "No user found with phone number ${telp.text}. Make sure the phone number entered is correct",
        );
      }
    } else {
      showToast("You must fill in the Phone Column");
    }
  }

  updatePassword(context, String id, String username) async {
    var data = {"id": id, "username": username, "password": pass.text};
    if (pass.text != "") {
      loadingDialog("Updating user data...", "");

      SQLHelper.instance.updateDataUser(
        {"password": md5.convert(utf8.encode(pass.text)).toString()},
        id,
        username,
      );

      await ServiceApi().updatePasswordUser(data);
      // Future.delayed(Duration.zero, () {
      Get.back();
      succesDialog(
        context: context,
        pageAbsen: "N",
        desc: "Password updated successfully\nPlease re-login",
        type: DialogType.success,
        title: 'SUCCESS',
        btnOkOnPress: () {
          // Future.delayed(const Duration(seconds: 1), () {
          auth.logout();
          Get.back(closeOverlays: true);
          // });
        },
      );
      // });
      // cekDataUser.value = response;

      pass.clear();
      // Get.back();
      // if (cekDataUser.isNotEmpty) {
      // } else {
      //   dialogMsg(
      //     "An error occurred",
      //     "Unable to update password. Please try again.",
      //   );
      // }
    } else {
      showToast("You have not filled in the Password field");
    }
  }

  Future<void> uploadFaceData() async {
    image = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 70,
      maxHeight: 600,
      maxWidth: 600,
    );

    if (image != null) {
      // var img = base64.encode(File(image!.path).readAsBytesSync());
      // log(image!.path, name: 'PATH');
      update();
    } else {
      return;
    }
  }

  Future<void> generateEmpId(Data? userData) async {
    var data = {
      "id": userData!.id,
      "kode_cabang": userData.kodeCabang,
      "thn": DateFormat('yy').format(DateTime.parse(userData.createdAt!)),
      "bln": DateFormat('MM').format(DateTime.parse(userData.createdAt!)),
      "tgl": DateFormat('dd').format(DateTime.parse(userData.createdAt!)),
    };
    // print(data);
    await ServiceApi().genEmpId(data);
    // isLoading.value = false;
    var newUsr = await ServiceApi().fetchCurrentUser({
      "username": userData.username!,
      "password": userData.password!,
    });
    if (Get.isRegistered<LoginController>()) {
      final logC = Get.find<LoginController>();

      // update sharedpreff
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userDataLogin', jsonEncode(newUsr.toJson()));
      logC.logUser.value = newUsr;

      logC.refresh();
    }
    //start update local db for tbl_user
    SQLHelper.instance.updateDataUser(
      {
        // "nama": name.text != "" ? name.text : userData.nama,
        // "no_telp": telp.text != "" ? telp.text : userData.noTelp,
        // "kode_cabang":
        //     selectedCabang.value != ""
        //         ? selectedCabang.value
        //         : userData.kodeCabang,
        // "nama_cabang":
        //     cabangName.value != ""
        //         ? cabangName.value
        //         : userData.namaCabang,
        // "lat": newUsr.lat!,
        // "long": newUsr.long!,
        // "area_coverage": newUsr.areaCover!,
        // "level":
        //     selectedLevel.value != ""
        //         ? selectedLevel.value
        //         : userData.level,
        // "level_user":
        //     levelName.value != "" ? levelName.value : userData.levelUser,
        // "visit": newUsr.visit!,
        // "parent_id": newUsr.parentId!,
        // "cek_stok":
        //     cekStok.value != "" ? cekStok.value : userData.cekStok,
        "nik": newUsr.nik,
      },
      userData.id!,
      userData.username!,
    );
  }

  Future<void> getLastUserData({required Data dataUser}) async {
    var newUser = await ServiceApi().fetchCurrentUser({
      "username": dataUser.username!,
      "password": dataUser.password!,
    });
    if (Get.isRegistered<LoginController>()) {
      final logC = Get.find<LoginController>();
      logC.logUser.value = newUser;
      // update sharedpreff
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userDataLogin', jsonEncode(newUser.toJson()));

      SQLHelper.instance.updateDataUser(
        newUser.toJson(),
        newUser.id!,
        newUser.username!,
      );
      logC.refresh();
    }
  }

  void _showWarning(String msg) {
    Get.back();
    warningDialog(Get.context!, "Warning", msg);
  }

  updateUsrState({String? id, required bool active}) async {
    final sts = active == true ? '1' : '0';
    var data = {"status": "update_status", "id_user": id, "active": sts};
    // print(data);
    return await ServiceApi().uptStsUsr(data);
  }

  Future<void> backupDatabase() async {
    try {
      backup.value = true;

      final dbPath = await getDatabasesPath();
      final source = File('$dbPath/absensi.db');

      if (!await source.exists()) {
        throw 'Database tidak ditemukan';
      }

      final bytes = await source.readAsBytes();

      if (Platform.isAndroid) {
        // ✅ ANDROID → Save File dialog
        String? outputFile = await FilePicker.platform.saveFile(
          dialogTitle: 'Simpan Backup Database',
          fileName: 'absensi.db',
          bytes: bytes,
        );

        if (outputFile == null) {
          backup.value = false;
          return;
        }

        await File(outputFile).writeAsBytes(bytes);

        showToast('Backup berhasil disimpan');
      } else if (Platform.isIOS) {
        // 🍎 iOS → Share / Save to Files
        final dir = await getTemporaryDirectory();
        final backupFile = File('${dir.path}/absensi_backup.db');

        await backupFile.writeAsBytes(bytes);

        showToast('Pilih "Save to Files" untuk menyimpan backup');

        await SharePlus.instance.share(
          ShareParams(files: [XFile(backupFile.path)]),
        );
      }

      backup.value = false;
    } catch (e) {
      backup.value = false;
      showToast('Backup gagal: $e');
    }
  }

  Future<void> restoreDatabase() async {
    try {
      restore.value = true;
      showToast('Pilih file backup dengan ekstensi .db');
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.any,
      );

      if (result == null) {
        restore.value = false;
        return;
      }

      final path = result.files.single.path;

      if (path == null) {
        restore.value = false;
        throw 'Path file tidak valid';
      }

      // ✅ VALIDASI
      if (!path.toLowerCase().endsWith('.db')) {
        restore.value = false;
        throw 'File harus database (.db)';
      }

      final pickedFile = File(path);

      if (!await pickedFile.exists()) {
        restore.value = false;
        throw 'File tidak ditemukan';
      }

      final dbPath = await getDatabasesPath();

      // 🔴 penting: tutup DB dulu
      await SQLHelper.instance.close();

      // 🔴 hapus DB lama
      await deleteDatabase('$dbPath/absensi.db');

      // 🔴 copy file baru
      final newDb = File('$dbPath/absensi.db');
      await newDb.writeAsBytes(await pickedFile.readAsBytes());

      // 🔴 buka ulang DB
      await SQLHelper.instance.database;

      restore.value = false;
      showToast('Restore berhasil');
    } catch (e) {
      restore.value = false;
      showToast('Restore gagal: $e');
    }
  }
}
