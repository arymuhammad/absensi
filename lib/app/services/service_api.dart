import 'dart:async';
import 'dart:convert';
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
import '../data/model/foto_profil_model.dart';
import '../data/model/login_model.dart';
import 'app_exceptions.dart';

class ServiceApi {
  var baseUrl = "https://attendance.urbanco.id/api/";
  var isLoading = false.obs;

  loginUser(data) async {
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
          final result = json.decode(response.body);
          return Login.fromJson(result);
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
  }

  getBrandCabang() async {
    try {
      final response = await http.get(Uri.parse('${baseUrl}brand_cabang'));
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
      } else {
        request.fields['tanggal_masuk'] = data["tanggal_masuk"];
        request.fields['tanggal_pulang'] = data["tanggal_pulang"];
        request.fields['jam_absen_pulang'] = data["jam_absen_pulang"];
        request.fields['lat_pulang'] = data["lat_pulang"];
        request.fields['long_pulang'] = data["long_pulang"];
        request.fields['device_info2'] = data["device_info2"];
      }

      if (data["status"] == "add") {
        if (kIsWeb) {
          // print(data["foto_masuk"]);
          request.files.add(http.MultipartFile("foto_masuk",
              data["foto_masuk"].readStream, data["foto_masuk"].size,
              filename: data["foto_masuk"].name));
        } else {
          request.files.add(http.MultipartFile(
              'foto_masuk',
              data["foto_masuk"].readAsBytes().asStream(),
              data["foto_masuk"].lengthSync(),
              filename: data["foto_masuk"].path.split("/").last));
        }
      } else {
        if (kIsWeb) {
          request.files.add(http.MultipartFile("foto_pulang",
              data["foto_pulang"].readStream, data["foto_pulang"].size,
              filename: data["foto_pulang"].name));
        } else {
          request.files.add(http.MultipartFile(
              'foto_pulang',
              data["foto_pulang"].readAsBytes().asStream(),
              data["foto_pulang"].lengthSync(),
              filename: data["foto_pulang"].path.split("/").last));
        }
      }

      var res = await request.send();
      var responseBytes = await res.stream.toBytes();
      var responseString = utf8.decode(responseBytes);

      //debug
      // debugPrint("response code: ${res.statusCode}");
      // debugPrint("response: $responseString");

      final dataDecode = jsonDecode(responseString);
      debugPrint(dataDecode.toString());
      if (!isOnInit) {
        Get.back();
        succesDialog(Get.context, "Y", "Anda berhasil Absen");
      }
    } on SocketException {
      if (!isOnInit) {
        Get.back();
        failedDialog(Get.context, 'ERROR',
            'Tidak ada koneksi internet\nHarap mencoba kembali');
      }
    } catch (e) {
      if (!isOnInit) {
        Get.back();
        showToast('Terjadi kesalahan saat mengirim data');
      }
      // debugPrint('$e');
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
      switch (response.statusCode) {
        case 200:
          final result = json.decode(response.body)['data'];
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

  Future<List<Absen>> getAbsen(paramAbsen) async {
    List<Absen> dataAbsen = [];
    try {
      final response =
          await http.post(Uri.parse('${baseUrl}get_absen'), body: paramAbsen);
      switch (response.statusCode) {
        case 200:
          List<dynamic> result = json.decode(response.body)['data'];
          dataAbsen = result.map((e) => Absen.fromJson(e)).toList();
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
      final response =
          await http.post(Uri.parse('${baseUrl}get_absen'), body: data);
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
      showToast("${e.message}");
    }
  }

  getFilteredVisit(Map<String, dynamic> data) async {
    try {
      final response =
          await http.post(Uri.parse('${baseUrl}get_visit'), body: data);
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
      showToast("${e.message}");
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
      switch (response.statusCode) {
        case 200:
          final result = json.decode(response.body)['data'];
          // print(result);
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
      } else {
        request.fields['visit_in'] = data["visit_in"];
        request.fields['tgl_visit'] = data["tgl_visit"];
        request.fields['visit_out'] = data["visit_out"];
        request.fields['jam_out'] = data["jam_out"];
        request.fields['lat_out'] = data["lat_out"];
        request.fields['long_out'] = data["long_out"];
        request.fields['device_info2'] = data["device_info2"];
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

      var res = await request.send();

      var responseBytes = await res.stream.toBytes();
      var responseString = utf8.decode(responseBytes);

      //debug
      // debugPrint("response code: ${res.statusCode}");
      // debugPrint("response: $responseString");

      final dataDecode = jsonDecode(responseString);
      debugPrint(dataDecode.toString());

      if (!isOnInit) {
        Get.back();
        succesDialog(Get.context, "Y", "Anda berhasil Absen");
      }
    } on SocketException {
      if (!isOnInit) {
        Get.back();
        failedDialog(Get.context, 'ERROR',
            'Tidak ada koneksi internet\nHarap mencoba kembali');
      }
    } catch (e) {
      if (!isOnInit) {
        Get.back();
       showToast('Terjadi kesalahan saat mengirim data');
        debugPrint('$e');
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
      showToast('Tidak ada koneksi internet\nHarap mencoba kembali');
      // debugPrint('$e');
    }
  }

  getVisit(Map<String, dynamic> paramSingleVisit) async {
    try {
      final response = await http.post(Uri.parse('${baseUrl}get_visit'),
          body: paramSingleVisit);
      switch (response.statusCode) {
        case 200:
          List<dynamic> result = json.decode(response.body)['data'];
          // print(result);
          List<Visit> dataVisit = result.map((e) => Visit.fromJson(e)).toList();
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
    }
  }

  getLimitVisit(Map<String, dynamic> paramLimitVisit) async {
    try {
      final response = await http.post(Uri.parse('${baseUrl}get_visit'),
          body: paramLimitVisit);
      switch (response.statusCode) {
        case 200:
          List<dynamic> result = json.decode(response.body)['data'];
          List<Visit> dataAbsen = result.map((e) => Visit.fromJson(e)).toList();
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
}
