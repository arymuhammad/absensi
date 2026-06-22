import 'dart:async';
import 'dart:convert';
// import 'dart:developer';
import 'dart:io';
import 'package:absensi/app/data/model/cabang_model.dart';
import 'package:absensi/app/data/model/cek_absen_model.dart';
import 'package:absensi/app/data/model/cek_stok_model.dart';
import 'package:absensi/app/data/model/cek_user_model.dart';
import 'package:absensi/app/data/model/cek_visit_model.dart';
import 'package:absensi/app/data/model/overtime_model.dart';
import 'package:absensi/app/data/model/permission_model.dart';
import 'package:absensi/app/data/model/req_leave_model.dart';
import 'package:absensi/app/data/model/level_model.dart';
import 'package:absensi/app/data/model/notif_model.dart';
import 'package:absensi/app/data/model/report_sales_model.dart';
import 'package:absensi/app/data/model/req_app_model.dart';
import 'package:absensi/app/data/model/shift_kerja_model.dart';
import 'package:absensi/app/data/model/summary_absen_model.dart';
import 'package:absensi/app/data/model/user_model.dart';
import 'package:absensi/app/data/model/visit_model.dart';
import 'package:absensi/app/modules/semua_absen/views/widget/form_filter.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../data/helper/custom_dialog.dart';
import '../data/model/PayslipStoreModel.dart';
import '../data/model/absen_model.dart';
import '../data/model/dept_model.dart';
import '../data/model/foto_profil_model.dart';
import '../data/model/leave_model.dart';
import '../data/model/login_model.dart';
// import '../data/model/server_api_model.dart';
import '../data/model/payslip_model.dart';
import '../data/model/payslip_result_model.dart';
import '../data/model/users_model.dart';
import 'app_exceptions.dart';

class ServiceApi {
  // var baseUrlPath = "https://attendance.urbanco.id/api/"; // poduction
  // var baseUrlPath = "https://88.222.214.157/"; // dev
  var baseUrl = dotenv.env['API_URL']; // dev
  // var baseUrlPath = BASEURL.PATH; // dev

  var isLoading = false.obs;
  String lastMessage = '';
  String lastType = '';

  Future<Login> loginUser(data) async {
    // var result = Login();
    try {
      loadingWithIcon();

      final response = await http
          .post(Uri.parse('${baseUrl}auth'), body: data)
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              SmartDialog.dismiss();
              Get.back();
              return dialogMsg("Time Out", "Koneksi server timeout");
            },
          );
// print(data);
      SmartDialog.dismiss();

      final body = json.decode(response.body);
      // ✅ Semua response yang punya body JSON kita return
      if ([200, 400, 401, 402, 403, 404].contains(response.statusCode)) {
        return Login.fromJson(body);
      }

      // ❌ selain itu baru dianggap error teknis
      throw FetchDataException('Server error (${response.statusCode})');
    } on SocketException catch (_) {
      SmartDialog.dismiss();
      Get.defaultDialog(
        radius: 5,
        title: 'Peringatan',
        content: const Column(
          children: [
            Text(
              'Terjadi kesalahan saat menghubungkan\n ke server. Silahkan mencoba kembali',
              textAlign: TextAlign.center,
            ),
          ],
        ),
        onCancel: () => Get.back(),
        textCancel: 'Tutup',
      );
      rethrow;
      // isLoading.value = false;
    }
    // return result;
  }

  Future<Map<String, dynamic>> validateQr({
    required String kode,
    required String token,
  }) async {
    final response = await http.post(
      Uri.parse('${baseUrl}validate_qr'),
      body: {'kode': kode, 'token': token},
    );

    return jsonDecode(response.body);
  }

  Future<Data?> fetchCurrentUser(data) async {
    // var user = Data();
    try {
      final response = await http
          .post(Uri.parse('${baseUrl}auth'), body: data)
          .timeout(const Duration(minutes: 1));

      // if (response.statusCode == 200) {
      return Data.fromJson(jsonDecode(response.body)['data']);

      // }
      // } on TimeoutException catch (e) {
      //   Get.back();
      //   showToast('$e');
      // }
    } catch (_) {
      Get.back();
      showToast('No Internet Connection, Try Again');
      return null;
    }
    // return user;
  }

  getBrandCabang() async {
    try {
      final response = await http.get(Uri.parse('${baseUrl}brand_cabang'));
      // log('${baseUrl}brand_cabang');
      switch (response.statusCode) {
        case 200:
          List<dynamic> result = json.decode(response.body)['data'];
          List<Cabang> data = result.map((e) => Cabang.fromJson(e)).toList();
          return data;
        default:
          throw Exception(response.reasonPhrase);
      }
    } on SocketException catch (_) {
      rethrow;
    }
  }

  getCabang(Map<String, dynamic>? data) async {
    try {
      final response = await http.post(
        Uri.parse('${baseUrl}cabang'),
        body: data,
      );

      switch (response.statusCode) {
        case 200:
          List<dynamic> result = json.decode(response.body)['data'];
          List<Cabang> data = result.map((e) => Cabang.fromJson(e)).toList();
          return data;
        default:
          throw Exception(response.reasonPhrase);
      }
    } on SocketException catch (_) {
      rethrow;
    }
  }

  getLevel() async {
    try {
      final response = await http.get(Uri.parse('${baseUrl}level'));

      switch (response.statusCode) {
        case 200:
          List<dynamic> result = json.decode(response.body)['data'];

          List<Level> data = result.map((e) => Level.fromJson(e)).toList();
          return data;
        default:
          throw Exception(response.reasonPhrase);
      }
    } on SocketException catch (_) {
      rethrow;
    }
  }

  Future<List<ShiftKerja>> getShift() async {
    try {
      final response = await http.get(Uri.parse('${baseUrl}get_shift'));
      switch (response.statusCode) {
        case 200:
          List<dynamic> result = json.decode(response.body)['data'];
          List<ShiftKerja> data =
              result.map((e) => ShiftKerja.fromJson(e)).toList();
          return data;
        default:
          throw Exception(response.reasonPhrase);
      }
    } on SocketException catch (_) {
      rethrow;
    }
  }

  Future<bool> addUpdatePegawai(Map<String, dynamic> data, String mode) async {
    try {
      // print("DATA KIRIM:");
      // print(data);
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${baseUrl}add_user'),
      );

      // request.headers.addAll(headers);
      request.fields['status'] = data["status"];
      if (data["username"] != null) {
        request.fields['username'] = data["username"];
      } else {}
      if (data["status"] == "add") {
        request.fields['id'] = data["id"];
        request.fields['password'] = data["password"];
        request.fields['nama'] = data["nama"];
        request.fields['no_telp'] = data["no_telp"];
        request.fields['kode_cabang'] = data["kode_cabang"];
        request.fields['level'] = data["level"];
        if (data["foto"] != null) {
          if (kIsWeb) {
            request.files.add(
              http.MultipartFile(
                "foto",
                data["foto"].readStream,
                data["foto"].size,
                filename: data["foto"].name,
              ),
            );
          } else {
            request.files.add(
              http.MultipartFile(
                'foto',
                data["foto"].readAsBytes().asStream(),
                data["foto"].lengthSync(),
                filename: data["foto"].path.split("/").last,
              ),
            );
          }
        } else {}
      } else {
        request.fields['id'] = data["id"];
        request.fields['nama'] = data["nama"];
        request.fields['no_telp'] = data["no_telp"];
        request.fields['kode_cabang'] = data["kode_cabang"];
        request.fields['level'] = data["level"];
        if (data["ktp"] != null) {
          request.files.add(
            await http.MultipartFile.fromPath(
              'ktp',
              data["ktp"].path,
              filename: data["ktp"].name,
            ),
          );
        }
        if (data["kk"] != null) {
          request.files.add(
            await http.MultipartFile.fromPath(
              "kk",
              data["kk"].path,
              filename: data["kk"].name,
            ),
          );
        }

        if (data["npwp"] != null) {
          request.files.add(
            await http.MultipartFile.fromPath(
              "npwp",
              data["npwp"].path,
              filename: data["npwp"].name,
            ),
          );
        }

        if (data["vaksin"] != null) {
          request.files.add(
            await http.MultipartFile.fromPath(
              "vaksin",
              data["vaksin"].path,
              filename: data["vaksin"].name,
            ),
          );
        }

        if (data["sertifikat"] != null) {
          request.files.add(
            await http.MultipartFile.fromPath(
              "sertifikat",
              data["sertifikat"].path,
              filename: data["sertifikat"].name,
            ),
          );
        }

        if (data["created_at"] != null) {
          request.fields['created_at'] = data["created_at"];
        }
        if (data["foto"] != null) {
          if (kIsWeb) {
            // print(data["foto"]);
            // print(data["foto"]["img"]);
            request.files.add(
              http.MultipartFile(
                "foto",
                data["foto"].readStream,
                data["foto"].size,
                filename: data["foto"].name,
              ),
            );
          } else {
            request.files.add(
              http.MultipartFile(
                'foto',
                data["foto"].readAsBytes().asStream(),
                data["foto"].lengthSync(),
                filename: data["foto"].path.split("/").last,
              ),
            );
          }
        } else {}
      }

      var res = await request.send().timeout(const Duration(seconds: 20));
      var responseBytes = await res.stream.toBytes();
      var responseString = utf8.decode(responseBytes);

      //debug
      // debugPrint("response code: ${res.statusCode}");
      // debugPrint("response: $responseString");

      // print("RAW RESPONSE:");
      // print(responseString);
      // ignore: unused_local_variable
      print("RAW RESPONSE:");
      print(responseString);
      final dataDecode = jsonDecode(responseString);
      lastMessage = dataDecode['message'] ?? '';
      lastType = dataDecode['type'] ?? '';
      // debugPrint(dataDecode.toString());

      if (res.statusCode == 200) {
        return dataDecode['success'] == true;
      }
      return false;
    } on TimeoutException {
      lastMessage = "Request timeout";
      return false;
    } catch (e, stacktrace) {
      // print("ERROR API:");
      // print(e);

      // print("STACKTRACE:");
      print(stacktrace);
      lastMessage = e.toString();
      return false;
    }
  }

  Future<bool> deleteAbsVst(Map<String, dynamic> data) async {
    try {
      final response = await http
          .post(Uri.parse('${baseUrl}delete_abs_vst'), body: data)
          .timeout(const Duration(minutes: 3));
      if (response.statusCode != 200) {
        showToast('Data gagal di hapus');
        return false;
      }
      final result = jsonDecode(response.body);

      if (result['success'] == true) {
        showToast(result['message']);
        return true;
      }
      showToast(result['message'] ?? 'Data gagal di hapus');
      return false;
    } on TimeoutException {
      showToast('Waktu koneksi ke server habis\nData gagal di hapus');
      return false;
    } catch (e) {
      showToast('Data gagal di hapus');
      return false;
    }
  }

  submitAbsen(data, bool isSync) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('${baseUrl}absen'));

      request.fields['status'] = data["status"];
      request.fields['id'] = data["id"];
      request.fields['nama'] = data["nama"];

      if (data["status"] == "add") {
        request.fields['tanggal_masuk'] = data["tanggal_masuk"];
        request.fields['kode_cabang'] = data["kode_cabang"];
        request.fields['id_shift'] = data["id_shift"];
        request.fields['jam_masuk'] = data["jam_masuk"];
        request.fields['jam_pulang'] = data["jam_pulang"];
        request.fields['jam_absen_masuk'] = data["jam_absen_masuk"];
        request.fields['lat_masuk'] = data["lat_masuk"];
        request.fields['long_masuk'] = data["long_masuk"];
        request.fields['device_info'] = data["device_info"];

        request.files.add(
          await http.MultipartFile.fromPath(
            "foto_masuk",
            data["foto_masuk"].path,
          ),
        );
      } else {
        request.fields['tanggal_masuk'] = data["tanggal_masuk"];
        request.fields['tanggal_pulang'] = data["tanggal_pulang"];
        request.fields['jam_absen_pulang'] = data["jam_absen_pulang"];
        request.fields['lat_pulang'] = data["lat_pulang"];
        request.fields['long_pulang'] = data["long_pulang"];
        request.fields['device_info2'] = data["device_info2"];

        request.files.add(
          await http.MultipartFile.fromPath(
            "foto_pulang",
            data["foto_pulang"].path,
          ),
        );
      }

      /// =========================
      /// 🚀 SEND REQUEST
      /// =========================
      final streamedResponse = await request.send().timeout(
        const Duration(minutes: 1),
      );

      /// =========================
      /// 📥 READ RESPONSE
      /// =========================
      final response = await http.Response.fromStream(streamedResponse);

      // print("STATUS CODE: ${response.statusCode}");
      // print("BODY: ${response.body}");

      /// =========================
      /// ❌ HTTP ERROR
      /// =========================
      if (response.statusCode != 200) {
        throw Exception("HTTP ${response.statusCode}: ${response.body}");
      }

      /// =========================
      /// ✅ PARSE JSON
      /// =========================
      final decoded = jsonDecode(response.body);

      /// =========================
      /// ✅ SUCCESS UI
      /// =========================
      if (!isSync) {
        showToast('Attendance data sent successfully');
      }

      return decoded;
    } on SocketException {
      if (!isSync) {
        if (Get.isDialogOpen ?? false) {
          Get.back();
        }

        failedDialog(
          Get.context,
          'ERROR',
          'No internet connection\nPlease try again',
        );
      }

      return {"success": false, "message": "No internet connection"};
    } on TimeoutException {
      if (!isSync) {
        if (Get.isDialogOpen ?? false) {
          Get.back();
        }

        failedDialog(Get.context, 'ERROR', 'Time out. Please try again.');
      }

      return {"success": false, "message": "Timeout"};
    } catch (e) {
      print("SUBMIT ABSEN ERROR: $e");

      if (!isSync) {
        if (Get.isDialogOpen ?? false) {
          Get.back();
        }

        showToast('An error occurred while sending data');
      }

      return {"success": false, "message": e.toString()};
    }
  }

  reSubmitAbsen(data) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${baseUrl}reabsen'),
      );

      request.fields['tanggal_masuk'] = data["tanggal_masuk"];
      request.fields['tanggal_pulang'] = data["tanggal_pulang"];
      request.fields['id'] = data["id"];
      request.fields['kode_cabang'] = data["kode_cabang"];
      request.fields['nama'] = data["nama"];
      request.fields['id_shift'] = data["id_shift"];
      request.fields['jam_masuk'] = data["jam_masuk"];
      request.fields['jam_pulang'] = data["jam_pulang"];
      request.fields['jam_absen_masuk'] = data["jam_absen_masuk"];
      request.fields['jam_absen_pulang'] = data["jam_absen_pulang"];
      request.files.add(
        http.MultipartFile(
          'foto_masuk',
          data["foto_masuk"].readAsBytes().asStream(),
          data["foto_masuk"].lengthSync(),
          filename: data["foto_masuk"].path.split("/").last,
        ),
      );
      request.files.add(
        http.MultipartFile(
          'foto_pulang',
          data["foto_pulang"].readAsBytes().asStream(),
          data["foto_pulang"].lengthSync(),
          filename: data["foto_pulang"].path.split("/").last,
        ),
      );

      request.fields['lat_masuk'] = data["lat_masuk"];
      request.fields['long_masuk'] = data["long_masuk"];
      request.fields['lat_pulang'] = data["lat_pulang"];
      request.fields['long_pulang'] = data["long_pulang"];
      request.fields['device_info'] = data["device_info"];
      request.fields['device_info2'] = data["device_info2"];

      var res = await request.send();
      var responseBytes = await res.stream.toBytes();
      var responseString = utf8.decode(responseBytes);

      //debug
      // debugPrint("response code: ${res.statusCode}");
      // debugPrint("response: $responseString");

      final dataDecode = jsonDecode(responseString);
      debugPrint(dataDecode.toString());
    } on SocketException {
      showToast('Tidak ada koneksi internet\nHarap mencoba kembali');
    } catch (e) {
      showToast('Tidak ada koneksi internet\nHarap mencoba kembali');
      // debugPrint('$e');
    }
  }

  cekDataAbsen(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('${baseUrl}cek_absen'),
        body: data,
      );
      // log('${baseUrl}cek_absen');
      // log(data.toString());
      switch (response.statusCode) {
        case 200:
          final result = json.decode(response.body)['data'];
          // log(result.toString());
          return CekAbsen.fromJson(result);
        case 400:
        case 401:
        case 402:
        case 404:
          final result = json.decode(response.body);
          throw FetchDataException(result["message"]);
        default:
          throw FetchDataException('Something went wrong.');
      }
    } on FetchDataException catch (e) {
      // print('error caught: ${e.message}');
      showToast("${e.message}");
    }
  }

  Future<Absen> getDataAdjust(paramAbsen) async {
    var dataAbsen = Absen();
    try {
      final response = await http
          .post(Uri.parse('${baseUrl}get_adjust'), body: paramAbsen)
          .timeout(const Duration(seconds: 5));
      switch (response.statusCode) {
        case 200:
          var result = json.decode(response.body)['data'];
          if (result != null) {
            dataAbsen = Absen.fromJson(result);
          } else {
            showToast("data tidak ditemukan.");
          }
          break;
        case 400:
        case 401:
        case 402:
        case 404:
          final result = json.decode(response.body);
          throw FetchDataException(result["message"]);
        default:
          throw FetchDataException('Something went wrong.');
      }
    } on FetchDataException catch (e) {
      // print('error caught: ${e.message}');
      showToast("${e.message}");
    } on TimeoutException catch (_) {
      // Get.back();
      showToast("waktu koneksi ke server habis");
    }
    return dataAbsen;
  }

  Future<List<Absen>> getAbsen(paramAbsen) async {
    List<Absen> dataAbsen = [];
    if (absenC.isOffline.value) {
      return []; // skip API
    }
    try {
      final response = await http
          .post(Uri.parse('${baseUrl}get_absen'), body: paramAbsen)
          .timeout(const Duration(seconds: 10));
      switch (response.statusCode) {
        case 200:
          List<dynamic> result = json.decode(response.body)['data'];
          dataAbsen = result.map((e) => Absen.fromJson(e)).toList();
          break;
        case 400:
        case 401:
        case 402:
        case 404:
          final result = json.decode(response.body);
          absenC.isLoading.value = false;
          throw FetchDataException(result["message"]);
        default:
          absenC.isLoading.value = false;
          throw FetchDataException('Something went wrong.');
      }
    } on FetchDataException catch (e) {
      // print('error caught: ${e.message}');
      absenC.isLoading.value = false;
      showToast("${e.message}");
    } on TimeoutException {
      absenC.isLoading.value = false;
      showToast("Connection timeout");
      return []; // fallback
    } catch (e) {
      absenC.isLoading.value = false;

      /// 🔥 handle semua error (offline dll)
      showToast("No internet / server error");

      return [];
    }
    return dataAbsen;
  }

  getFotoProfil(idUser) async {
    try {
      final response = await http.post(
        Uri.parse('${baseUrl}get_foto_profil'),
        body: idUser,
      );
      switch (response.statusCode) {
        case 200:
          final result = json.decode(response.body)['data'];
          // FotoProfil foto = result.map((e) =>
          // print(result);
          return FotoProfil.fromJson(result);
        case 400:
        case 401:
        case 402:
        case 404:
          final result = json.decode(response.body);
          throw FetchDataException(result["message"]);
        default:
          throw FetchDataException('Something went wrong.');
      }
    } on FetchDataException catch (e) {
      // print('error caught: ${e.message}');
      showToast("${e.message}");
    }
  }

  getUser() async {
    try {
      final response = await http
          .get(Uri.parse('${baseUrl}get_user'))
          .timeout(const Duration(seconds: 60));
      switch (response.statusCode) {
        case 200:
          List<dynamic> result = json.decode(response.body)['data'];
          List<CekUser> dataUser =
              result.map((e) => CekUser.fromJson(e)).toList();
          return dataUser;
        case 400:
        case 401:
        case 402:
        case 404:
          final result = json.decode(response.body);
          throw FetchDataException(result["message"]);
        default:
          throw FetchDataException('Something went wrong.');
      }
    } on FetchDataException catch (e) {
      // print('error caught: ${e.message}');
      showToast("${e.message}");
    } on Exception catch (e) {
      showToast("$e");
    }
  }

  cekUser(Map<String, String> data) async {
    try {
      final response = await http.post(
        Uri.parse('${baseUrl}cek_user'),
        body: data,
      );
      switch (response.statusCode) {
        case 200:
          List<dynamic> result = json.decode(response.body)['data'];
          List<CekUser> dataUser =
              result.map((e) => CekUser.fromJson(e)).toList();
          return dataUser;
        case 400:
        case 401:
        case 402:
        case 404:
          final result = json.decode(response.body);
          throw FetchDataException(result["message"]);
        default:
          throw FetchDataException('Something went wrong.');
      }
    } on FetchDataException catch (e) {
      // print('error caught: ${e.message}');
      showToast("${e.message}");
    }
  }

  updatePasswordUser(Map<String, String> data) async {
    try {
      final response = await http.post(
        Uri.parse('${baseUrl}update_password'),
        body: data,
      );
      switch (response.statusCode) {
        case 200:
          List<dynamic> result = json.decode(response.body)['data'];
          List<CekUser> dataUser =
              result.map((e) => CekUser.fromJson(e)).toList();
          return dataUser;
        case 400:
        case 401:
        case 402:
        case 404:
          final result = json.decode(response.body);
          throw FetchDataException(result["message"]);
        default:
          throw FetchDataException('Something went wrong.');
      }
    } on FetchDataException catch (e) {
      // print('error caught: ${e.message}');
      showToast("${e.message}");
    }
  }

  getFilteredAbsen(Map<String, dynamic> data) async {
    try {
      final response = await http
          .post(Uri.parse('${baseUrl}get_absen'), body: data)
          .timeout(const Duration(minutes: 1));
      switch (response.statusCode) {
        case 200:
          List<dynamic> result = json.decode(response.body)['data'];
          List<Absen> dataUser = result.map((e) => Absen.fromJson(e)).toList();
          return dataUser;
        case 400:
        case 401:
        case 402:
        case 404:
          final result = json.decode(response.body);
          throw FetchDataException(result["message"]);
        default:
          throw FetchDataException('Something went wrong.');
      }
    } on FetchDataException catch (e) {
      // print('error caught: ${e.message}');
      Get.back();
      showToast("${e.message}");
    } on TimeoutException catch (_) {
      Get.back();
      showToast("waktu koneksi ke server habis.\nharap mencoba kembali");
    }
  }

  getFilteredVisit(Map<String, dynamic> data) async {
    try {
      final response = await http
          .post(Uri.parse('${baseUrl}get_visit'), body: data)
          .timeout(const Duration(minutes: 1));
      // print(data);
      switch (response.statusCode) {
        case 200:
          List<dynamic> result = json.decode(response.body)['data'];
          List<Visit> dataUser = result.map((e) => Visit.fromJson(e)).toList();
          return dataUser;
        case 400:
        case 401:
        case 402:
        case 404:
          final result = json.decode(response.body);
          throw FetchDataException(result["message"]);
        default:
          throw FetchDataException('Something went wrong.');
      }
    } on FetchDataException catch (e) {
      // print('error caught: ${e.message}');
      Get.back();
      showToast("${e.message}");
    } on TimeoutException catch (_) {
      Get.back();
      // print('error caught: ${e.message}');
      showToast("Waktu permintaan ke server telah habis, silahkan dicoba lagi");
    }
  }

  getDataStok(data) async {
    try {
      final response = await http.post(
        Uri.parse('${baseUrl}cek_stok'),
        body: data,
      );
      switch (response.statusCode) {
        case 200:
          List<dynamic> result = json.decode(response.body)['data'];
          List<CekStok> dataUser =
              result.map((e) => CekStok.fromJson(e)).toList();
          return dataUser;
        case 400:
        case 401:
        case 402:
        case 404:
          final result = json.decode(response.body);
          throw FetchDataException(result["message"]);
        default:
          final result = json.decode(response.body);
          throw FetchDataException(result["message"]);
      }
    } on FetchDataException catch (e) {
      // print('error caught: ${e.message}');
      showToast("${e.message}");
    }
  }

  Future<List<ReportSales>> fetchSalesReport(data) async {
    var dataSales = <ReportSales>[];
    try {
      final response = await http
          .post(Uri.parse('${baseUrl}report_sales'), body: data)
          .timeout(const Duration(minutes: 5));
      switch (response.statusCode) {
        case 200:
          List<dynamic> result = json.decode(response.body)['data'];
          // print(result);

          dataSales = result.map((e) => ReportSales.fromJson(e)).toList();
          break;

        case 400:
        case 401:
        case 402:
        case 404:
          final result = json.decode(response.body);
          throw FetchDataException(result["message"]);
        default:
          final result = json.decode(response.body);
          throw FetchDataException(result["message"]);
      }
    } on FetchDataException catch (e) {
      // print('error caught: ${e.message}');
      showToast("${e.message}");
    } on TimeoutException catch (_) {
      Get.defaultDialog(
        title: 'Connection Time Out',
        middleText: 'Server tidak merespon',
        textCancel: 'Tutup',
        onCancel: () {
          Get.back();
          Get.back();
        },
      );
    }
    return dataSales;
  }

  cekDataVisit(Map<String, String> data) async {
    try {
      final response = await http.post(
        Uri.parse('${baseUrl}cek_visit'),
        body: data,
      );
      // log('${baseUrl}cek_visit', name: 'LINK');
      // log(data.toString());
      switch (response.statusCode) {
        case 200:
          // dynamic result;
          final result = json.decode(response.body)['data'];
          // result ??= {"total":"0","tgl_visit":"","visit_in":"","is_rnd":""};
          return CekVisit.fromJson(result);
        case 400:
        case 401:
        case 402:
        case 404:
          final result = json.decode(response.body);
          throw FetchDataException(result["message"]);
        default:
          throw FetchDataException('Something went wrong.');
      }
    } on FetchDataException catch (e) {
      // print('error caught: ${e.message}');
      showToast("${e.message}");
    }
  }

  submitVisit(Map<String, dynamic> data, bool isSync) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${baseUrl}visit'),
      );

      /// =========================
      /// 📝 COMMON FIELDS
      /// =========================
      request.fields['status'] = data["status"];
      request.fields['id'] = data["id"];
      request.fields['nama'] = data["nama"];

      /// =========================
      /// ✅ VISIT IN
      /// =========================
      if (data["status"] == "add") {
        request.fields['tgl_visit'] = data["tgl_visit"];
        request.fields['visit_in'] = data["visit_in"];
        request.fields['jam_in'] = data["jam_in"];
        request.fields['lat_in'] = data["lat_in"];
        request.fields['long_in'] = data["long_in"];
        request.fields['device_info'] = data["device_info"];
        request.fields['is_rnd'] = data["is_rnd"]?.toString() ?? "0";

        request.files.add(
          await http.MultipartFile.fromPath('foto_in', data["foto_in"].path),
        );
      }
      /// =========================
      /// 🔄 VISIT OUT
      /// =========================
      else {
        request.fields['visit_in'] = data["visit_in"];
        request.fields['tgl_visit'] = data["tgl_visit"];
        request.fields['visit_out'] = data["visit_out"];
        request.fields['jam_out'] = data["jam_out"];
        request.fields['lat_out'] = data["lat_out"];
        request.fields['long_out'] = data["long_out"];
        request.fields['device_info2'] = data["device_info2"];

        request.files.add(
          await http.MultipartFile.fromPath('foto_out', data["foto_out"].path),
        );
      }

      /// =========================
      /// 🚀 SEND REQUEST
      /// =========================
      final streamedResponse = await request.send().timeout(
        const Duration(minutes: 1),
      );

      final response = await http.Response.fromStream(streamedResponse);

      // print("========== VISIT RESPONSE ==========");
      // print("STATUS CODE: ${response.statusCode}");
      // print("BODY: ${response.body}");
      // print("====================================");

      /// =========================
      /// ❌ HTTP ERROR
      /// =========================
      if (response.statusCode != 200) {
        throw Exception("HTTP ${response.statusCode}: ${response.body}");
      }

      /// =========================
      /// ⚠️ EMPTY RESPONSE
      /// =========================
      if (response.body.trim().isEmpty) {
        return {"success": true};
      }

      /// =========================
      /// ✅ PARSE JSON
      /// =========================
      final decoded = jsonDecode(response.body);

      /// =========================
      /// ✅ SUCCESS TOAST
      /// =========================
      if (!isSync) {
        showToast('Visit data sent successfully');
      }

      return decoded;
    } on SocketException {
      if (!isSync) {
        if (Get.isDialogOpen ?? false) {
          Get.back();
        }

        failedDialog(
          Get.context,
          'ERROR',
          'No internet connection\nPlease try again',
        );
      }

      return {"success": false, "message": "No internet connection"};
    } on TimeoutException {
      if (!isSync) {
        if (Get.isDialogOpen ?? false) {
          Get.back();
        }

        failedDialog(Get.context, 'ERROR', 'Time out. Please try again.');
      }

      return {"success": false, "message": "Timeout"};
    } catch (e) {
      print("SUBMIT VISIT ERROR: $e");

      if (!isSync) {
        if (Get.isDialogOpen ?? false) {
          Get.back();
        }

        showToast('Failed to send visit data');
      }

      return {"success": false, "message": e.toString()};
    }
  }

  reSubmitVisit(Map<String, dynamic> data) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${baseUrl}revisit'),
      );
      // request.headers.addAll(headers);
      request.fields['id'] = data["id"];
      request.fields['nama'] = data["nama"];
      request.fields['tgl_visit'] = data["tgl_visit"];
      request.fields['visit_in'] = data["visit_in"];
      request.fields['jam_in'] = data["jam_in"];
      request.fields['visit_out'] = data["visit_out"];
      request.fields['jam_out'] = data["jam_out"];
      request.files.add(
        http.MultipartFile(
          'foto_in',
          data["foto_in"].readAsBytes().asStream(),
          data["foto_in"].lengthSync(),
          filename: data["foto_in"].path.split("/").last,
        ),
      );
      request.fields['lat_in'] = data["lat_in"];
      request.fields['long_in'] = data["long_in"];
      request.files.add(
        http.MultipartFile(
          'foto_out',
          data["foto_out"].readAsBytes().asStream(),
          data["foto_out"].lengthSync(),
          filename: data["foto_out"].path.split("/").last,
        ),
      );
      request.fields['lat_out'] = data["lat_out"];
      request.fields['long_out'] = data["long_out"];
      request.fields['device_info'] = data["device_info"];
      request.fields['device_info2'] = data["device_info2"];
      request.fields['is_rnd'] = data["is_rnd"];

      var res = await request.send();

      var responseBytes = await res.stream.toBytes();
      var responseString = utf8.decode(responseBytes);

      //debug
      debugPrint("response code: ${res.statusCode}");
      debugPrint("response: $responseString");

      final dataDecode = jsonDecode(responseString);
      debugPrint(dataDecode.toString());
    } on SocketException {
      showToast('Tidak ada koneksi internet\nHarap mencoba kembali');
    } catch (e) {
      // print('a');
      // log('print ini');
      failedDialog(Get.context, 'ERROR', e.toString());
      // showToast('Tidak ada koneksi internet\nHarap mencoba kembali');
      // debugPrint('$e');
    }
  }

  Future<List<Visit>> getVisit(Map<String, dynamic> paramSingleVisit) async {
    List<Visit> dataVisit = [];
    try {
      final response = await http
          .post(Uri.parse('${baseUrl}get_visit'), body: paramSingleVisit)
          .timeout(const Duration(seconds: 10));
      switch (response.statusCode) {
        case 200:
          List<dynamic> result = json.decode(response.body)['data'];
          // if (result.isNotEmpty) {
          dataVisit = result.map((e) => Visit.fromJson(e)).toList();
          // } else {
          // showToast("data tidak ditemukan.");
          // }
          break;
        case 400:
        case 401:
        case 402:
        case 404:
          final result = json.decode(response.body);
          throw FetchDataException(result["message"]);
        default:
          throw FetchDataException('Something went wrong.');
      }
    } on FetchDataException catch (e) {
      // print('error caught: ${e.message}');
      showToast("${e.message}");
    } on TimeoutException catch (_) {
      // Get.back();
      showToast("waktu koneksi ke server habis");
    }
    return dataVisit;
  }

  Future<List<Visit>> getLimitVisit(
    Map<String, dynamic> paramLimitVisit,
  ) async {
    List<Visit> dataVisit = [];
    try {
      final response = await http.post(
        Uri.parse('${baseUrl}get_visit'),
        body: paramLimitVisit,
      );
      switch (response.statusCode) {
        case 200:
          List<dynamic> result = json.decode(response.body)['data'];
          dataVisit = result.map((e) => Visit.fromJson(e)).toList();
          // print(result);
          break;
        case 400:
        case 401:
        case 402:
        case 404:
          final result = json.decode(response.body);
          throw FetchDataException(result["message"]);
        default:
          throw FetchDataException('Something went wrong.');
      }
    } on FetchDataException catch (e) {
      // print('error caught: ${e.message}');
      showToast("${e.message}");
    }
    return dataVisit;
  }

  getUserCabang(String idStore, String parentId) async {
    var param = {"idCabang": idStore, "parentId": parentId};

    try {
      final response = await http
          .post(Uri.parse('${baseUrl}get_user_cabang'), body: param)
          .timeout(const Duration(seconds: 10));
      switch (response.statusCode) {
        case 200:
          List<dynamic> result = json.decode(response.body)['data'];
          List<User> dataAbsen = result.map((e) => User.fromJson(e)).toList();
          // print(result);
          return dataAbsen;
        case 400:
        case 401:
        case 402:
        case 404:
          final result = json.decode(response.body);
          throw FetchDataException(result["message"]);
        default:
          throw FetchDataException('Something went wrong.');
      }
    } on FetchDataException catch (e) {
      // print('error caught: ${e.message}');
      // Get.back();
      showToast("${e.message}");
    } on Exception catch (e) {
      showToast("$e");
    }
    // finally {
    //   Get.back();
    // }
  }

  updateAbsen(Map<String, dynamic> data) async {
    try {
      await http
          .post(Uri.parse('${baseUrl}get_adjust'), body: data)
          .timeout(const Duration(seconds: 5));
    } on FetchDataException catch (e) {
      // print('error caught: ${e.message}');
      showToast("${e.message}");
    } on TimeoutException catch (_) {
      showToast("waktu koneksi ke server habis");
    }
  }

  getDeptVisit() async {
    try {
      final response = await http.get(Uri.parse('${baseUrl}get_dept_visit'));

      switch (response.statusCode) {
        case 200:
          List<dynamic> result = json.decode(response.body)['data'];
          List<Dept> dataDept = result.map((e) => Dept.fromJson(e)).toList();
          return dataDept;
        case 400:
        case 401:
        case 402:
        case 404:
          final result = json.decode(response.body);
          throw FetchDataException(result["message"]);
        default:
          throw FetchDataException('Something went wrong.');
      }
    } on FetchDataException catch (e) {
      // print('error caught: ${e.message}');
      showToast("${e.message}");
    }
  }

  getUserVisit(idDept) async {
    var data = {"idDept": idDept};
    try {
      final response = await http.post(
        Uri.parse('${baseUrl}get_user_visit'),
        body: data,
      );

      switch (response.statusCode) {
        case 200:
          List<dynamic> result = json.decode(response.body)['data'];
          List<Users> dataUser = result.map((e) => Users.fromJson(e)).toList();
          return dataUser;
        case 400:
        case 401:
        case 402:
        case 404:
          final result = json.decode(response.body);
          throw FetchDataException(result["message"]);
        default:
          throw FetchDataException('Something went wrong.');
      }
    } on FetchDataException catch (e) {
      // print('error caught: ${e.message}');
      showToast("${e.message}");
    }
  }

  sendDataToXmor(data) async {
    String url = "https://xmor.urbanco.id/api";
    // final response =
    await http.post(
      Uri.parse('$url/attendance/create'),
      headers: {
        "Accept": "application/json",
        "Authorization":
            "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJuaWsiOiIyMDI0MDcwMDAxIiwicGFzc3dvcmQiOiJhc2Q5OTkiLCJpZCI6MjY1LCJ1c2VyX2lkIjoyfQ.s7rw000BPNeJjrH7z-5pkxw4LZ8eixiXE9Cp913ItBE",
      },
      body: data,
    );
    // if (response.statusCode == 200) {
    //   log('$url/attendance/create', name: 'LINK');
    //   // print(data);
    //   log("kirim data sukses", name: "XMOR");
    // } else {
    //   log('$url/attendance/create', name: 'LINK');
    //   // print(data);
    //   log("gagal kirim data", name: "XMOR");
    // }
  }

  // faceData(Map<String, String>? data, mode) async {
  //   switch (mode) {
  //     case 'post':
  //       try {
  //         await http
  //             .post(Uri.parse('${baseUrl}post_face_data'), body: data!)
  //             .timeout(const Duration(seconds: 30));
  //       } on FetchDataException catch (e) {
  //         // print('error caught: ${e.message}');
  //         showToast("${e.message}");
  //       } on TimeoutException catch (_) {
  //         showToast("waktu koneksi ke server habis");
  //       }
  //       break;
  //     default:
  //       try {
  //         var response = await http.get(
  //           Uri.parse('${baseUrl}get_face_data?id_user=${data!['id_user']}'),
  //         );
  //         dynamic result = json.decode(response.body)['data'];
  //         DataWajah face = DataWajah.fromJson(result);
  //         return face;
  //       } on FormatException catch (e) {
  //         showToast(e.toString());
  //       } catch (e) {
  //         showToast(e.toString());
  //       }
  //       break;
  //   }
  // }

  reqUpdateAbs(Map<String, dynamic> data) async {
    try {
      Map<String, String> headers = {
        'Content-Type': 'application/json; charset=UTF-8',
      };

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${baseUrl}req_update_data'),
      );

      request.headers.addAll(headers);

      request.fields['status'] = data["status"];
      request.fields['id_user'] = data["id_user"];
      request.fields['kode_cabang'] = data["kode_cabang"];
      request.fields['level'] = data["level"];
      request.fields['nama'] = data["nama"];
      request.fields['alasan'] = data["alasan"];

      if (data["status"] == "update_masuk") {
        request.fields['tgl_masuk'] = data["tgl_masuk"];
        request.fields['jam_absen_masuk'] = data["jam_absen_masuk"];
      } else if (data["status"] == "update_masuk_cst") {
        request.fields['tgl_masuk'] = data["tgl_masuk"];
        request.fields['jam_masuk'] = data["jam_masuk"];
        request.fields['jam_absen_masuk'] = data["jam_absen_masuk"];
        request.fields['jam_pulang'] = data["jam_pulang"];
      } else if (data["status"] == "update_pulang") {
        request.fields['tgl_masuk'] = data["tgl_masuk"];
        request.fields['tgl_pulang'] = data["tgl_pulang"];
        request.fields['jam_absen_pulang'] = data["jam_absen_pulang"];
        request.fields['lat_out'] = data["lat_out"];
        request.fields['long_out'] = data["long_out"];
        request.fields['device_info2'] = data["device_info2"];
      } else if (data["status"] == "update_data_absen") {
        request.fields['tgl_masuk'] = data["tgl_masuk"];
        request.fields['tgl_pulang'] = data["tgl_pulang"];
        request.fields['jam_absen_masuk'] = data["jam_absen_masuk"];
        request.fields['jam_absen_pulang'] = data["jam_absen_pulang"];
        request.fields['lat_out'] = data["lat_out"];
        request.fields['long_out'] = data["long_out"];
        request.fields['device_info2'] = data["device_info2"];
      } else {
        request.fields['tgl_masuk'] = data["tgl_masuk"];
        request.fields['id_shift'] = data["id_shift"];
        request.fields['jam_masuk'] = data["jam_masuk"];
        request.fields['jam_pulang'] = data["jam_pulang"];
      }

      // ================= FILE =================

      File? fotoMasuk = data["foto_masuk"];
      File? fotoPulang = data["foto_pulang"];

      if (data["status"] == "update_masuk" ||
          data["status"] == "update_masuk_cst") {
        request.files.add(
          http.MultipartFile(
            "foto_masuk",
            fotoMasuk!.readAsBytes().asStream(),
            fotoMasuk.lengthSync(),
            filename: fotoMasuk.path.split("/").last,
          ),
        );
      } else if (data["status"] == "update_pulang") {
        request.files.add(
          http.MultipartFile(
            "foto_pulang",
            fotoPulang!.readAsBytes().asStream(),
            fotoPulang.lengthSync(),
            filename: fotoPulang.path.split("/").last,
          ),
        );
      } else if (data["status"] == "update_data_absen") {
        request.files.add(
          http.MultipartFile(
            "foto_masuk",
            fotoMasuk!.readAsBytes().asStream(),
            fotoMasuk.lengthSync(),
            filename: fotoMasuk.path.split("/").last,
          ),
        );
        request.files.add(
          http.MultipartFile(
            "foto_pulang",
            fotoPulang!.readAsBytes().asStream(),
            fotoPulang.lengthSync(),
            filename: fotoPulang.path.split("/").last,
          ),
        );
      }

      // ================= SEND =================

      print(request.fields);
      print(request.files.map((e) => e.field).toList());

      final streamedResponse = await request.send().timeout(
        const Duration(minutes: 1),
      );

      final response = await http.Response.fromStream(streamedResponse);

      Get.back();

      // ================= SUCCESS =================

      if (response.statusCode == 200) {
        final res = jsonDecode(response.body);

        if (res['success'] == true) {
          succesDialog(
            context: Get.context!,
            pageAbsen: 'N',
            desc:
                res['message'] ??
                'Waiting for approval from\nSM/ASM -> Area Manager -> Ops -> HR',
            type: DialogType.success,
            title: 'SUKSES',
            btnOkOnPress: () => Get.back(),
          );
        } else {
          failedDialog(
            Get.context!,
            'ERROR',
            res['message'] ?? 'Gagal mengirim data',
          );
        }
      }
      // ================= ERROR STATUS =================
      else {
        failedDialog(
          Get.context!,
          'ERROR',
          '${response.statusCode}\n${response.reasonPhrase}',
        );
      }
    }
    // ================= TIMEOUT =================
    on TimeoutException catch (_) {
      Get.back();

      failedDialog(
        Get.context!,
        'ERROR',
        'The connection to the server has timed out\nPlease try again later',
      );
    }
    // ================= ERROR =================
    catch (e) {
      Get.back();

      failedDialog(Get.context!, 'ERROR', e.toString());
    }
  }

  getReqUptAbs(
    String? accept,
    String? type,
    String? level,
    String? idUser,
    String? branchCode,
    String? date1,
    String? date2,
  ) async {
    try {
      final response = await http
          .get(
            Uri.parse(
              '${baseUrl}get_reqUptAbs?accept=$accept&type=$type&level=$level&id_user=$idUser&kode_cabang=$branchCode&date1=$date1&date2=$date2',
            ),
          )
          .timeout(const Duration(minutes: 1));
  //     print(
  // '${baseUrl}get_reqUptAbs?accept=$accept&type=$type&level=$level&id_user=$idUser&kode_cabang=$branchCode&date1=$date1&date2=$date2',
  //     );
      final res = json.decode(response.body);
      switch (response.statusCode) {
        case 200:
          if (res['data'] != null) {
            List<dynamic> listData = res['data'];
            List<ReqApp> result =
                listData.map((e) => ReqApp.fromJson(e)).toList();
            return result;
          } else {
            showToast(res['message']);
            return <ReqApp>[];
          }

        case 400:
        case 401:
        case 402:
        case 404:
          final result = json.decode(response.body);
          throw FetchDataException(result["message"]);
        default:
          throw FetchDataException('Something went wrong.');
      }
    } on FetchDataException catch (e) {
      // print('error caught: ${e.message}');
      showToast("${e.message}");
    } on TimeoutException catch (e) {
      failedDialog(Get.context!, 'Kesalahan', e.toString());
    }
  }

  updateIsreadNotif(Map<String, dynamic> data) async {
    try {
      final response = await http
          .post(Uri.parse('${baseUrl}update_isread_notif'), body: data)
          .timeout(const Duration(minutes: 1));
      if (response.statusCode == 200) {
      } else {
        showToast('Terjadi kesalahan\n${response.body}');
      }
    } on TimeoutException catch (_) {
      // Get.back();
      showToast('Timeout to updating status is read');
    } on Exception catch (_) {
      showToast('Failed to update status is read');
      // showToast(e.toString());
    }
  }

  updateReqApp(Map<String, dynamic> data) async {
    try {
      final response = await http
          .post(Uri.parse('${baseUrl}update_reqapp'), body: data)
          .timeout(const Duration(minutes: 1));
      if (response.statusCode == 200) {
      } else {
        failedDialog(
          Get.context!,
          'ERROR',
          'Terjadi kesalahan\n${response.body}',
        );
      }
    } on TimeoutException catch (_) {
      // Get.back();
      failedDialog(
        Get.context!,
        'ERROR',
        'Waktu koneksi ke server telah habis\nSilahkan coba lagi nanti',
      );
    } on Exception catch (e) {
      showToast(e.toString());
    }
  }

  updateReqAdjAbs(Map<String, dynamic> data) async {
    try {
      await http
          .post(Uri.parse('${baseUrl}update_presence_data'), body: data)
          .timeout(const Duration(minutes: 1));
    } on TimeoutException catch (_) {
      Get.back();
      failedDialog(
        Get.context!,
        'ERROR',
        'Waktu koneksi ke server telah habis\nSilahkan coba lagi nanti',
      );
    } on Exception catch (e) {
      showToast(e.toString());
    }
  }

  reqLeaveAdd(Map<String, dynamic> data) async {
    try {
      Map<String, String> headers = {
        'Content-Type': 'application/json; charset=UTF-8',
      };

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${baseUrl}req_leave'),
      );

      request.headers.addAll(headers);

      request.fields['type'] = data["type"];
      request.fields['uid'] = data["uid"];
      request.fields['date1'] = data["date1"];
      request.fields['date2'] = data["date2"];
      request.fields['id_user'] = data["id_user"];
      request.fields['nama'] = data["nama"];
      request.fields['kode_cabang'] = data["kode_cabang"];
      request.fields['level_user'] = data["level_user"];
      request.fields['jenis_cuti'] = data["jenis_cuti"];
      request.fields['saldo_cuti'] = data["saldo_cuti"];
      request.fields['jumlah_cuti'] = data["jumlah_cuti"];
      request.fields['alasan_cuti'] = data["alasan_cuti"];
      request.fields['alamat_cuti'] = data["alamat_cuti"];
      request.fields['phone'] = data["phone"];
      request.fields['parent_id'] = data["parent_id"];
      request.fields['signature'] = data["signature"];

      File? file = data["attach_file"];

      if (file != null && await file.exists()) {
        request.files.add(
          http.MultipartFile(
            "attach_file",
            file.readAsBytes().asStream(),
            file.lengthSync(),
            filename: file.path.split("/").last,
          ),
        );
      }

      final response = await request.send().timeout(const Duration(minutes: 1));

      return response.statusCode == 200;
    } on TimeoutException {
      return false;
    } catch (e) {
      return false;
    }
  }

  reqLeave(Map<String, dynamic> param) async {
    try {
      final response = await http
          .post(Uri.parse('${baseUrl}req_leave'), body: param)
          .timeout(const Duration(minutes: 1));

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        final type = param['type'];

        if (type == "" || type == "get_pending_req_leave") {
          List<dynamic> result = responseBody['data'];
          List<ReqLeaveModel> data =
              result.map((e) => ReqLeaveModel.fromJson(e)).toList();
          return data;
        }

        if (type == "update") {
          showToast("Pengajuan berhasil disetujui");
        } else if (type == "add_leave") {
          showToast("Pengajuan berhasil dibuat");
        } else {
          showToast("Pengajuan berhasil dicancel");
        }
      } else {
        // Bisa juga handle error atau status selain 200 di sini jika perlu
        showToast("Terjadi kesalahan: Status code ${response.statusCode}");
      }
    } catch (e) {
      // Tangani error jaringan, timeout, atau parsing json

      showToast("Gagal terhubung ke server: $e");
    }
  }

  leave(Map<String, dynamic> param) async {
    try {
      final response = await http
          .post(Uri.parse('${baseUrl}leave'), body: param)
          .timeout(const Duration(minutes: 1));

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        final type = param['type'];

        if (type == "") {
          List<dynamic> result = responseBody['data'];
          List<LeaveModel> data =
              result.map((e) => LeaveModel.fromJson(e)).toList();
          return data;
        }

        if (type == "update") {
          showToast("Pengajuan berhasil disetujui");
        } else if (type == "add_leave") {
          showToast("Data berhasil dibuat");
        } else {
          showToast("Pengajuan berhasil dicancel");
        }
      } else {
        // Bisa juga handle error atau status selain 200 di sini jika perlu
        showToast("Terjadi kesalahan: Status code ${response.statusCode}");
      }
    } catch (e) {
      // Tangani error jaringan, timeout, atau parsing json

      showToast("Gagal terhubung ke server: $e");
    }
  }

  genEmpId(Map<String, String?> data) async {
    try {
      final response = await http
          .post(Uri.parse('${baseUrl}gen_emp_id'), body: data)
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        showToast("generate employee ID has been successful");
      } else {
        final result = jsonDecode(response.body)['message'];
        showToast(result);
      }
    } on Exception catch (_) {
      showToast('Terjadi kesalahan');
    }
  }

  getNotif(Map<String, dynamic> param) async {
    try {
      final response = await http
          .post(
            Uri.parse('${baseUrl}get_notif'),
            // headers: {'Content-Type': 'application/json'},
            body: jsonEncode(param),
          )
          .timeout(const Duration(seconds: 60));
      // print('${baseUrl}get_notif');
      // print(param);
      if (param['type'] == "summ_month") {
        if (response.statusCode == 200) {
          final decoded = jsonDecode(response.body);
          if (decoded['data'] == null) {
            throw Exception('Response data is null');
          }
          SummaryAbsenModel notif = SummaryAbsenModel.fromJson(decoded['data']);

          return notif;
        } else {
          throw Exception(
            'Failed to load doclang data, status: ${response.statusCode}',
          );
        }
      }
      // else if (param['type'] == "approval") {
      else {
        if (response.statusCode == 200) {
          final decoded = jsonDecode(response.body);
          if (decoded['data'] == null) {
            throw Exception('Response data is null');
          }
          NotifModel notif = NotifModel.fromJson(decoded['data']);

          return notif;
        } else {
          throw Exception(
            'Failed to load dobol data, status: ${response.statusCode}',
          );
        }
      }
    } catch (e) {
      showToast(e.toString());
      // print(param);
      if (param['type'] == "summ_month") {
        return SummaryAbsenModel(); // fallback kosong untuk mencegah crash UI
      } else {
        // else if (param['type'] == "approval") {
        return NotifModel(); // fallback kosong untuk mencegah crash UI
      }
    }
  }

  Future<PayslipResult?> getPaySlip(Map<String, dynamic> data) async {
    try {
      final response = await http
          .post(Uri.parse('${baseUrl}payslip'), body: data)
          .timeout(const Duration(seconds: 60));
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded['data'] == null || decoded['data'].isEmpty) {
          // Jika data kosong, return null atau objek PayslipModel dengan status khusus
          return null;
        }
        if (data['branch'] == "HO000") {
          return PayslipResult(
            payslipModel: PayslipModel.fromJson(decoded['data']),
          );
        } else {
          return PayslipResult(
            payslipStoreModel: PayslipStoreModel.fromJson(decoded['data']),
          );
        }
      } else {
        throw Exception(
          'Failed to load dobleh data, status: ${response.statusCode}',
        );
      }
    } on Exception catch (e) {
      throw Exception(e.toString());
    }
  }

  uptStsUsr(Map<String, String?> data) async {
    try {
      return await http
          .post(Uri.parse('${baseUrl}add_user'), body: data)
          .timeout(const Duration(seconds: 10));
    } on Exception catch (e) {
      Get.back();
      showToast("$e");
    }
    // finally {
    //   Get.back();
    // }
  }

  overtime(Map<String, String> data) async {
    try {
      final response = await http
          .post(Uri.parse('${baseUrl}overtime'), body: data)
          .timeout(const Duration(seconds: 10));

      final res = json.decode(response.body);
      // print(res);

      if (response.statusCode == 200) {
        if (data['type'] == "" || data['type'] == "get_by_id") {
          if (res['data'] != null) {
            List<dynamic> listOvr = res['data'];
            List<OvertimeModel> result =
                listOvr.map((e) => OvertimeModel.fromJson(e)).toList();
            return result;
          } else {
            showToast(res['message']);
          }
        } else {
          // print(res);
          return res; // ✅ WAJIB return
        }
      } else {
        return {'success': false};
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  permissionAdd(Map<String, dynamic> data) async {
    try {
      Map<String, String> headers = {
        'Content-Type': 'application/json; charset=UTF-8',
      };

      var request = http.MultipartRequest('POST', Uri.parse('${baseUrl}perm'));

      request.headers.addAll(headers);

      // print(data);

      request.fields['type'] = data["type"];
      request.fields['id'] = data["id"];
      request.fields['branch_code'] = data["branch_code"];
      request.fields['name'] = data["name"];
      request.fields['level'] = data["level"];
      request.fields['init_date'] = data["init_date"];
      request.fields['end_date'] = data["end_date"];
      request.fields['remark'] = data["remark"];

      File? file = data["attach"];

      if (file != null && await file.exists()) {
        request.files.add(
          http.MultipartFile(
            "attach",
            file.readAsBytes().asStream(),
            file.lengthSync(),
            filename: file.path.split("/").last,
          ),
        );
      }

      final streamedResponse = await request.send();

      final response = await http.Response.fromStream(streamedResponse);

      return jsonDecode(response.body);
    } on TimeoutException {
      return false;
    } catch (e) {
      return false;
    }
  }

  permission(Map<String, String> data) async {
    try {
      final response = await http
          .post(Uri.parse('${baseUrl}perm'), body: data)
          .timeout(const Duration(seconds: 10));

      final res = json.decode(response.body);
      // print(res);

      if (response.statusCode == 200) {
        if (data['type'] == "" ||
            data['type'] == "get_pending_req_permission") {
          if (res['data'] != null) {
            List<dynamic> listPrm = res['data'];
            List<PermissionModel> result =
                listPrm.map((e) => PermissionModel.fromJson(e)).toList();
            return result;
          } else {
            showToast(res['message']);
          }
        } else {
          // print(res);
          return res; // ✅ WAJIB return
        }
      } else {
        return {'success': false};
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<bool> saveFcmToken(Map<String, String?> map) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/save_token'),
        body: map,
      );

      if (response.statusCode != 200) {
        return false;
      }

      final result = jsonDecode(response.body);
      return result['success'] == true;
    } catch (e) {
      debugPrint('saveFcmToken error: $e');
      return false;
    }
  }

  Future<bool> deleteToken(Map<String, String?> map) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/delete_token'),
        body: map,
      );

      if (response.statusCode != 200) {
        return false;
      }

      final result = jsonDecode(response.body);
      return result['success'] == true;
    } catch (e) {
      debugPrint('deleteFcmToken error: $e');
      return false;
    }
  }
}
