import 'dart:convert';
import 'dart:io';
import 'package:absensi/app/model/cabang_model.dart';
import 'package:absensi/app/model/cek_absen_model.dart';
import 'package:absensi/app/model/cek_stok_model.dart';
import 'package:absensi/app/model/cek_user_model.dart';
import 'package:absensi/app/model/level_model.dart';
import 'package:absensi/app/model/shift_kerja_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../helper/loading_dialog.dart';
import '../model/absen_model.dart';
import '../model/foto_profil_model.dart';
import '../model/login_model.dart';
import 'app_exceptions.dart';

class ServiceApi {
  var baseUrl = "https://attendance.urbanco.id/api/";
  var isLoading = false.obs;

  loginUser(data) async {
    try {
      final response =
          await http.post(Uri.parse('${baseUrl}auth'), body: data).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          return timeOut(data);
        },
      );
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
    } on FetchDataException catch (e) {
      // print('error caught: ${e.message}');
      showToast("${e.message}\nUsername atau Password salah!");
      isLoading.value = false;
    } on SocketException catch (_) {
      Get.defaultDialog(
          barrierDismissible: false,
          radius: 5,
          title: 'Peringatan',
          content: Column(
            children: [
              const Text('Periksa Koneksi Internet Anda '),
              const SizedBox(height: 15),
              ElevatedButton(
                  onPressed: () {
                    loginUser(data);
                    isLoading.value = true;
                    Get.back();
                  },
                  child: const Text('Refresh'))
            ],
          ));
      isLoading.value = false;
    }
  }

  timeOut(data) {
    Get.defaultDialog(
        radius: 5,
        title: 'Koneksi Terputus',
        content: Column(
          children: [
            const Center(
              child: Text('Server tidak merespon'),
            ),
            ElevatedButton(
                onPressed: () async {
                  loginUser(data);
                  isLoading.value = true;
                  Get.back();
                },
                child: const Text('Refresh'))
          ],
        ));
    isLoading.value = false;
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
      //post date
      // Map<String, String> headers = {
      //   'Content-Type': 'application/json; charset=UTF-8',
      // };
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

      final dataDecode = jsonDecode(responseString);
      // debugPrint(dataDecode.toString());

      if (res.statusCode == 200) {
        // return showDialogSuccess('Sukses', 'Event Berhasil Dibuat');
      } else {}
    } catch (e) {
      debugPrint('$e');
    }
  }

  submitAbsen(data) async {
    try {
      //post date
      // Map<String, String> headers = {
      //   'Content-Type': 'application/json; charset=UTF-8',
      // };
      var request = http.MultipartRequest('POST', Uri.parse('${baseUrl}absen'));

      // request.headers.addAll(headers);
      request.fields['status'] = data["status"];
      request.fields['id'] = data["id"];
      request.fields['tanggal'] = data["tanggal"];
      request.fields['nama'] = data["nama"];
      if (data["status"] == "add") {
        request.fields['kode_cabang'] = data["kode_cabang"];
        request.fields['id_shift'] = data["id_shift"];
        request.fields['jam_masuk'] = data["jam_masuk"];
        request.fields['jam_pulang'] = data["jam_pulang"];
        request.fields['jam_absen_masuk'] = data["jam_absen_masuk"];
        request.fields['lat_masuk'] = data["lat_masuk"];
        request.fields['long_masuk'] = data["long_masuk"];
        request.fields['device_info'] = data["device_info"];
      } else {
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
      // request.files.add(http.MultipartFile(
      //     'proposal',
      //     data["proposal"].readAsBytes().asStream(),
      //     data["proposal"].lengthSync(),
      //     filename: data["proposal"].path.split("/").last));

      var res = await request.send();
      var responseBytes = await res.stream.toBytes();
      var responseString = utf8.decode(responseBytes);

      //debug
      debugPrint("response code: ${res.statusCode}");
      debugPrint("response: $responseString");

      final dataDecode = jsonDecode(responseString);
      debugPrint(dataDecode.toString());

      if (res.statusCode == 200) {
        // return showDialogSuccess('Sukses', 'Event Berhasil Dibuat');
      } else {}
    } catch (e) {
      debugPrint('$e');
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

  getAbsen(paramAbsen) async {
    try {
      final response =
          await http.post(Uri.parse('${baseUrl}get_absen'), body: paramAbsen);
      switch (response.statusCode) {
        case 200:
          List<dynamic> result = json.decode(response.body)['data'];
          List<Absen> dataAbsen = result.map((e) => Absen.fromJson(e)).toList();
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

  getDataStok(data) async {
    try {
      final response =
          await http.post(Uri.parse('${baseUrl}cek_stok'), body: data);
      switch (response.statusCode) {
        case 200:
          List<dynamic> result = json.decode(response.body)['data'];
          // print(result);
          // print(data);
          // print('${baseUrl}cek_stok');
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
}
