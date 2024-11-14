import 'dart:async';
import 'dart:convert';
// import 'dart:developer';
import 'dart:io';
import 'package:absensi/app/data/model/cabang_model.dart';
import 'package:absensi/app/data/model/cek_absen_model.dart';
import 'package:absensi/app/data/model/cek_stok_model.dart';
import 'package:absensi/app/data/model/cek_user_model.dart';
import 'package:absensi/app/data/model/cek_visit_model.dart';
import 'package:absensi/app/data/model/level_model.dart';
import 'package:absensi/app/data/model/report_sales_model.dart';
import 'package:absensi/app/data/model/shift_kerja_model.dart';
import 'package:absensi/app/data/model/user_model.dart';
import 'package:absensi/app/data/model/visit_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../data/helper/loading_dialog.dart';
import '../data/model/absen_model.dart';
import '../data/model/dept_model.dart';
import '../data/model/foto_profil_model.dart';
import '../data/model/login_model.dart';
import '../data/model/users_model.dart';
import 'app_exceptions.dart';

class ServiceApi {
  var baseUrl = "https://attendance.urbanco.id/api/"; // poduction
  // var baseUrl = "http://103.156.15.60/absensi/"; // dev
  // var baseUrl = "https://88.222.214.157/"; // dev
  var isLoading = false.obs;

  Future<Login> loginUser(data) async {
    var result = Login();
    try {
      loadingWithIcon();

      final response =
          await http.post(Uri.parse('${baseUrl}auth'), body: data).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          SmartDialog.dismiss();
          Get.back();
          return dialogMsg("Time Out", "Koneksi server timeout");
        },
      );
      SmartDialog.dismiss();

      switch (response.statusCode) {
        case 200:
          final data = json.decode(response.body);
          return result = Login.fromJson(data);
        case 400:
        case 401:
        case 402:
        case 404:
          final result = json.decode(response.body);
          throw FetchDataException(result["message"]);
        default:
          throw FetchDataException(
            'Something went wrong.',
          );
      }
    } on FetchDataException catch (_) {
      showToast("Username atau Password salah");
      isLoading.value = false;
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
      isLoading.value = false;
    }
    return result;
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
      final response =
          await http.post(Uri.parse('${baseUrl}cabang'), body: data);
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

  getShift() async {
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

  addUpdatePegawai(data) async {
    try {
      var request =
          http.MultipartRequest('POST', Uri.parse('${baseUrl}add_user'));

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
            request.files.add(http.MultipartFile(
                "foto", data["foto"].readStream, data["foto"].size,
                filename: data["foto"].name));
          } else {
            request.files.add(http.MultipartFile(
                'foto',
                data["foto"].readAsBytes().asStream(),
                data["foto"].lengthSync(),
                filename: data["foto"].path.split("/").last));
          }
        } else {}
      } else {
        request.fields['id'] = data["id"];
        request.fields['nama'] = data["nama"];
        request.fields['no_telp'] = data["no_telp"];
        request.fields['kode_cabang'] = data["kode_cabang"];
        request.fields['level'] = data["level"];
        if (data["foto"] != null) {
          if (kIsWeb) {
            // print(data["foto"]);
            // print(data["foto"]["img"]);
            request.files.add(http.MultipartFile(
                "foto", data["foto"].readStream, data["foto"].size,
                filename: data["foto"].name));
            // String imageFilePath = "name";
            // PickedFile imageFile = PickedFile(data["foto"]["path"]);
            // var stream =
            //     http.ByteStream(DelegatingStream(imageFile.openRead()));
            // request.files.add(http.MultipartFile(
            //     "foto", stream, data["foto"]["img"].length,
            //     filename: "data[foto].name"));
            // request.files.add(http.MultipartFile.fromBytes('foto', data["foto"],
            //     filename: "Profile.jpg"));
          } else {
            request.files.add(http.MultipartFile(
                'foto',
                data["foto"].readAsBytes().asStream(),
                data["foto"].lengthSync(),
                filename: data["foto"].path.split("/").last));
          }
        } else {}
      }

      var res = await request.send();
      var responseBytes = await res.stream.toBytes();
      var responseString = utf8.decode(responseBytes);

      //debug
      // debugPrint("response code: ${res.statusCode}");
      // debugPrint("response: $responseString");

      // ignore: unused_local_variable
      final dataDecode = jsonDecode(responseString);
      // debugPrint(dataDecode.toString());

      if (res.statusCode == 200) {
        // return showDialogSuccess('Sukses', 'Event Berhasil Dibuat');
      } else {}
    } catch (e) {
      debugPrint('$e');
    }
  }

  deleteAbsVst(Map<String, dynamic> data) async {
    try {
      final response = await http
          .post(Uri.parse('${baseUrl}delete_abs_vst'), body: data)
          .timeout(const Duration(minutes: 3));
      if (response.statusCode == 200) {
        showToast('Data berhasil di hapus');
        Get.back();
      }
    } on TimeoutException catch (_) {
      showToast('Waktu koneksi ke server habis\nData gagal di hapus');
      Get.back();
    }
    on Exception catch (_) {
      showToast('Data gagal di hapus');
      Get.back();
    }
  }

  submitAbsen(data, bool isOnInit) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('${baseUrl}absen'));

      // request.headers.addAll(headers);
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
        // request.fields['foto_masuk'] = data["foto_masuk"];
      } else {
        request.fields['tanggal_masuk'] = data["tanggal_masuk"];
        request.fields['tanggal_pulang'] = data["tanggal_pulang"];
        request.fields['jam_absen_pulang'] = data["jam_absen_pulang"];
        request.fields['lat_pulang'] = data["lat_pulang"];
        request.fields['long_pulang'] = data["long_pulang"];
        // request.fields['foto_pulang'] = data["foto_pulang"];
        request.fields['device_info2'] = data["device_info2"];
      }

      if (data["status"] == "add") {
        // if (kIsWeb) {
        //   // print(data["foto_masuk"]);
        //   request.files.add(http.MultipartFile("foto_masuk",
        //       data["foto_masuk"].readStream, data["foto_masuk"].size,
        //       filename: data["foto_masuk"].name));
        // } else {
        request.files.add(http.MultipartFile(
            "foto_masuk",
            data["foto_masuk"].readAsBytes().asStream(),
            data["foto_masuk"].lengthSync(),
            filename: data["foto_masuk"].path.split("/").last));
        // }
      } else {
        // if (kIsWeb) {
        //   request.files.add(http.MultipartFile("foto_pulang",
        //       data["foto_pulang"].readStream, data["foto_pulang"].size,
        //       filename: data["foto_pulang"].name));
        // } else {
        request.files.add(http.MultipartFile(
            'foto_pulang',
            data["foto_pulang"].readAsBytes().asStream(),
            data["foto_pulang"].lengthSync(),
            filename: data["foto_pulang"].path.split("/").last));
        // }
      }

      await request.send().timeout(const Duration(minutes: 3)).then((value) {
        if (!isOnInit) {
          Get.back();
          succesDialog(Get.context, "Y",
              "Harap tidak menutup aplikasi selama proses syncron data absensi");
        } else {
          showToast('data sukses dikirim');
        }
      });
      // var responseBytes = await res.stream.toBytes();
      // var responseString = utf8.decode(responseBytes);

      //debug
      // debugPrint("response code: ${res.statusCode}");
      // debugPrint("response: $responseString");

      // final dataDecode = jsonDecode(responseString);
      // debugPrint(dataDecode.toString());
    } on SocketException {
      if (!isOnInit) {
        Get.back();
        failedDialog(Get.context, 'ERROR',
            'Tidak ada koneksi internet\nHarap mencoba kembali');
      }
    } on TimeoutException {
      Get.back();
      failedDialog(
          Get.context, 'ERROR', 'Waktu habis. Silahkan mencoba kembali');
    } catch (e) {
      if (!isOnInit) {
        Get.back();
        showToast('Terjadi kesalahan saat mengirim data');
      } else {
        showToast('Terjadi kesalahan saat mengirim data\n$e');
        // failedDialog(Get.context, 'ERROR', e.toString());
      }
    }
  }

  reSubmitAbsen(data) async {
    try {
      var request =
          http.MultipartRequest('POST', Uri.parse('${baseUrl}reabsen'));

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
      request.files.add(http.MultipartFile(
          'foto_masuk',
          data["foto_masuk"].readAsBytes().asStream(),
          data["foto_masuk"].lengthSync(),
          filename: data["foto_masuk"].path.split("/").last));
      request.files.add(http.MultipartFile(
          'foto_pulang',
          data["foto_pulang"].readAsBytes().asStream(),
          data["foto_pulang"].lengthSync(),
          filename: data["foto_pulang"].path.split("/").last));

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
      final response =
          await http.post(Uri.parse('${baseUrl}cek_absen'), body: data);
      // log('${baseUrl}cek_absen');
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
          throw FetchDataException(
            'Something went wrong.',
          );
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

        case 400:
        case 401:
        case 402:
        case 404:
          final result = json.decode(response.body);
          throw FetchDataException(result["message"]);
        default:
          throw FetchDataException(
            'Something went wrong.',
          );
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
    try {
      final response =
          await http.post(Uri.parse('${baseUrl}get_absen'), body: paramAbsen);
      switch (response.statusCode) {
        case 200:
          List<dynamic> result = json.decode(response.body)['data'];
          dataAbsen = result.map((e) => Absen.fromJson(e)).toList();
        // log('${baseUrl}get_absen', name: 'GET ABSEN');
        // log(paramAbsen.toString());
        // log(result.toString());
        case 400:
        case 401:
        case 402:
        case 404:
          final result = json.decode(response.body);
          throw FetchDataException(result["message"]);
        default:
          throw FetchDataException(
            'Something went wrong.',
          );
      }
    } on FetchDataException catch (e) {
      // print('error caught: ${e.message}');
      showToast("${e.message}");
    }
    return dataAbsen;
  }

  getFotoProfil(idUser) async {
    try {
      final response =
          await http.post(Uri.parse('${baseUrl}get_foto_profil'), body: idUser);
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
          throw FetchDataException(
            'Something went wrong.',
          );
      }
    } on FetchDataException catch (e) {
      // print('error caught: ${e.message}');
      showToast("${e.message}");
    }
  }

  getUser() async {
    try {
      final response = await http.get(Uri.parse('${baseUrl}get_user'));
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
          throw FetchDataException(
            'Something went wrong.',
          );
      }
    } on FetchDataException catch (e) {
      // print('error caught: ${e.message}');
      showToast("${e.message}");
    }
  }

  cekUser(Map<String, String> data) async {
    try {
      final response =
          await http.post(Uri.parse('${baseUrl}cek_user'), body: data);
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
          throw FetchDataException(
            'Something went wrong.',
          );
      }
    } on FetchDataException catch (e) {
      // print('error caught: ${e.message}');
      showToast("${e.message}");
    }
  }

  updatePasswordUser(Map<String, String> data) async {
    try {
      final response =
          await http.post(Uri.parse('${baseUrl}update_password'), body: data);
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
          throw FetchDataException(
            'Something went wrong.',
          );
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
          throw FetchDataException(
            'Something went wrong.',
          );
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
          throw FetchDataException(
            'Something went wrong.',
          );
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
      final response =
          await http.post(Uri.parse('${baseUrl}cek_stok'), body: data);
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
      final response =
          await http.post(Uri.parse('${baseUrl}cek_visit'), body: data);
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
          throw FetchDataException(
            'Something went wrong.',
          );
      }
    } on FetchDataException catch (e) {
      // print('error caught: ${e.message}');
      showToast("${e.message}");
    }
  }

  submitVisit(Map<String, dynamic> data, bool isOnInit) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('${baseUrl}visit'));
      // request.headers.addAll(headers);
      request.fields['status'] = data["status"];
      request.fields['id'] = data["id"];
      request.fields['nama'] = data["nama"];
      if (data["status"] == "add") {
        request.fields['tgl_visit'] = data["tgl_visit"];
        request.fields['visit_in'] = data["visit_in"];
        request.fields['jam_in'] = data["jam_in"];
        request.fields['lat_in'] = data["lat_in"];
        request.fields['long_in'] = data["long_in"];
        request.fields['device_info'] = data["device_info"];
        request.fields['is_rnd'] = data["is_rnd"];
        // request.fields['foto_in'] = data["foto_in"];
      } else {
        request.fields['visit_in'] = data["visit_in"];
        request.fields['tgl_visit'] = data["tgl_visit"];
        request.fields['visit_out'] = data["visit_out"];
        request.fields['jam_out'] = data["jam_out"];
        request.fields['lat_out'] = data["lat_out"];
        request.fields['long_out'] = data["long_out"];
        request.fields['device_info2'] = data["device_info2"];
        // request.fields['foto_out'] = data["foto_out"];
      }

      if (data["status"] == "add") {
        request.files.add(http.MultipartFile(
            'foto_in',
            data["foto_in"].readAsBytes().asStream(),
            data["foto_in"].lengthSync(),
            filename: data["foto_in"].path.split("/").last));
      } else {
        request.files.add(http.MultipartFile(
            'foto_out',
            data["foto_out"].readAsBytes().asStream(),
            data["foto_out"].lengthSync(),
            filename: data["foto_out"].path.split("/").last));
      }

      await request.send().timeout(const Duration(minutes: 3)).then((value) {
        if (!isOnInit) {
          Get.back();
          succesDialog(Get.context, "Y",
              "Harap tidak menutup aplikasi selama proses syncron data absensi");
        } else {
          showToast('data sukses dikirim');
        }
      });

      // var responseBytes = await res.stream.toBytes();
      // var responseString = utf8.decode(responseBytes);

      //debug
      // debugPrint("response code: ${res.statusCode}");
      // debugPrint("response: $responseString");

      // final dataDecode = jsonDecode(responseString);
      // debugPrint(dataDecode.toString());
    } on SocketException {
      if (!isOnInit) {
        Get.back();
        failedDialog(Get.context, 'ERROR',
            'Tidak ada koneksi internet\nHarap mencoba kembali');
      }
    } on TimeoutException {
      Get.back();
      failedDialog(
          Get.context, 'ERROR', 'Waktu habis. Silahkan mencoba kembali');
    } catch (e) {
      if (!isOnInit) {
        Get.back();
        showToast('Terjadi kesalahan saat mengirim data');
      } else {
        showToast('Terjadi kesalahan saat mengirim data');
        // failedDialog(Get.context, 'ERROR', e.toString());
      }
    }
  }

  reSubmitVisit(Map<String, dynamic> data) async {
    try {
      var request =
          http.MultipartRequest('POST', Uri.parse('${baseUrl}revisit'));
      // request.headers.addAll(headers);
      request.fields['id'] = data["id"];
      request.fields['nama'] = data["nama"];
      request.fields['tgl_visit'] = data["tgl_visit"];
      request.fields['visit_in'] = data["visit_in"];
      request.fields['jam_in'] = data["jam_in"];
      request.fields['visit_out'] = data["visit_out"];
      request.fields['jam_out'] = data["jam_out"];
      request.files.add(http.MultipartFile(
          'foto_in',
          data["foto_in"].readAsBytes().asStream(),
          data["foto_in"].lengthSync(),
          filename: data["foto_in"].path.split("/").last));
      request.fields['lat_in'] = data["lat_in"];
      request.fields['long_in'] = data["long_in"];
      request.files.add(http.MultipartFile(
          'foto_out',
          data["foto_out"].readAsBytes().asStream(),
          data["foto_out"].lengthSync(),
          filename: data["foto_out"].path.split("/").last));
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

  getVisit(Map<String, dynamic> paramSingleVisit) async {
    // List<Visit> dataVisit = [];
    try {
      final response = await http
          .post(Uri.parse('${baseUrl}get_visit'), body: paramSingleVisit)
          .timeout(const Duration(seconds: 10));
      switch (response.statusCode) {
        case 200:
          List<dynamic> result = json.decode(response.body)['data'];
          // if (result.isNotEmpty) {
          List<Visit> dataVisit = result.map((e) => Visit.fromJson(e)).toList();
          // } else {
          // showToast("data tidak ditemukan.");
          // }

          return dataVisit;
        case 400:
        case 401:
        case 402:
        case 404:
          final result = json.decode(response.body);
          throw FetchDataException(result["message"]);
        default:
          throw FetchDataException(
            'Something went wrong.',
          );
      }
    } on FetchDataException catch (e) {
      // print('error caught: ${e.message}');
      showToast("${e.message}");
    } on TimeoutException catch (_) {
      // Get.back();
      showToast("waktu koneksi ke server habis");
    }
  }

  Future<List<Visit>> getLimitVisit(
      Map<String, dynamic> paramLimitVisit) async {
    List<Visit> dataVisit = [];
    try {
      final response = await http.post(Uri.parse('${baseUrl}get_visit'),
          body: paramLimitVisit);
      switch (response.statusCode) {
        case 200:
          List<dynamic> result = json.decode(response.body)['data'];
          dataVisit = result.map((e) => Visit.fromJson(e)).toList();
        // print(result);

        case 400:
        case 401:
        case 402:
        case 404:
          final result = json.decode(response.body);
          throw FetchDataException(result["message"]);
        default:
          throw FetchDataException(
            'Something went wrong.',
          );
      }
    } on FetchDataException catch (e) {
      // print('error caught: ${e.message}');
      showToast("${e.message}");
    }
    return dataVisit;
  }

  getUserCabang(idStore) async {
    var param = {"idCabang": idStore};
    try {
      final response =
          await http.post(Uri.parse('${baseUrl}get_user_cabang'), body: param);
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
          throw FetchDataException(
            'Something went wrong.',
          );
      }
    } on FetchDataException catch (e) {
      // print('error caught: ${e.message}');
      showToast("${e.message}");
    }
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
          throw FetchDataException(
            'Something went wrong.',
          );
      }
    } on FetchDataException catch (e) {
      // print('error caught: ${e.message}');
      showToast("${e.message}");
    }
  }

  getUserVisit(idDept) async {
    var data = {"idDept": idDept};
    try {
      final response =
          await http.post(Uri.parse('${baseUrl}get_user_visit'), body: data);

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
          throw FetchDataException(
            'Something went wrong.',
          );
      }
    } on FetchDataException catch (e) {
      // print('error caught: ${e.message}');
      showToast("${e.message}");
    }
  }

  sendDataToXmor(data) async {
    String url = "https://xmor.urbanco.id/api";
    // final response = 
    await http.post(Uri.parse('$url/attendance/create'),
        headers: {
          "Accept": "application/json",
          "Authorization":
              "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJuaWsiOiIyMDI0MDcwMDAxIiwicGFzc3dvcmQiOiJhc2Q5OTkiLCJpZCI6MjY1LCJ1c2VyX2lkIjoyfQ.s7rw000BPNeJjrH7z-5pkxw4LZ8eixiXE9Cp913ItBE"
        },
        body: data);
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
}
