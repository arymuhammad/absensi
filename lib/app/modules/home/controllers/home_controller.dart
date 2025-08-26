import 'dart:async';
import 'dart:convert';

import 'package:absensi/app/data/model/notif_model.dart';
import 'package:absensi/app/data/model/summary_absen_model.dart';
import 'package:absensi/app/services/service_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/helper/manual_sse_client.dart';
import '../../../data/model/login_model.dart';

class HomeController extends GetxController
    with GetSingleTickerProviderStateMixin {
  var currentPage = 0.obs;
  late TabController tabController;
  var summAttPerMonth = SummaryAbsenModel().obs;
  late Rx<Future<SummaryAbsenModel>> futureSummary =
      Rx<Future<SummaryAbsenModel>>(Future.value(SummaryAbsenModel()));
  var summPendApp = NotifModel().obs;
  late Rx<Future<NotifModel>> futurePendApp = Rx<Future<NotifModel>>(
    Future.value(NotifModel(totalRequest: 0)),
  );
  var summPendAdj = NotifModel().obs;
  late Rx<Future<NotifModel>> futurePendAdj = Rx<Future<NotifModel>>(
    Future.value(NotifModel(totalNotif: 0)),
  );

  var initDate = DateFormat('yyyy-MM-dd').format(
    DateTime.parse(
      DateTime(DateTime.now().year, DateTime.now().month, 1).toString(),
    ),
  );
  var endDate = DateFormat('yyyy-MM-dd').format(
    DateTime.parse(
      DateTime(DateTime.now().year, DateTime.now().month + 1, 0).toString(),
    ),
  );
  @override
  void onInit() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var dataUserLogin = Data.fromJson(
      jsonDecode(pref.getString('userDataLogin')!),
    );
    // var userID = Data.fromJson(jsonDecode(pref.getString('userDataLogin')!)).id!;
    tabController = TabController(length: 3, vsync: this);
    tabController.animation!.addListener(() {
      final value = tabController.animation!.value.round();
      if (value != currentPage.value) {
        changePage(value);
        // print(value);
      }
    });
    if (dataUserLogin.visit == "0") {
      futureSummary = Rx<Future<SummaryAbsenModel>>(
        getSummAttPerMonth(dataUserLogin.id!),
      );
    }
    futurePendApp = Rx<Future<NotifModel>>(
      getPendingApproval(
        idUser: dataUserLogin.id!,
        kodeCabang: dataUserLogin.kodeCabang!,
        level: dataUserLogin.level!,
        parentId: dataUserLogin.parentId!,
      ),
    );
    futurePendAdj = Rx<Future<NotifModel>>(
      getPendingAdj(idUser: dataUserLogin.id!, level: dataUserLogin.level!),
    );
    super.onInit();
  }

  void changePage(int newPage) {
    currentPage.value = newPage;
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  Stream<String> getTime() async* {
    while (true) {
      await Future<void>.delayed(const Duration(seconds: 1));
      DateTime now = DateTime.now();
      final hour = now.hour.toString().padLeft(2, '0');
      final minute = now.minute.toString().padLeft(2, '0');
      final second = now.second.toString().padLeft(2, '0');

      yield " $hour : $minute : $second";
    }
  }

  Future<SummaryAbsenModel> getSummAttPerMonth(String idUser) async {
    var data = {
      "type": "summ_month",
      "date1": initDate,
      "date2": endDate,
      "id_user": idUser,
    };
    return summAttPerMonth.value = await ServiceApi().getNotif(data);

    // StreamController<SummaryAbsenModel> controller = StreamController();

    // void connect() {
    //   final url = Uri.parse(
    //     '${dotenv.env['STREAM_NOTIF_URL']}?type=summ_month&date1=$initDate&date2=$endDate&id_user=$idUser',
    //   );
    // print( '${dotenv.env['STREAM_NOTIF_URL']}?type=summ_month&date1=$initDate&date2=$endDate&id_user=$idUser');
    // final sseClient = ManualSseClient(url);

    //   sseClient.connect().listen(
    //     (dataStr) {
    //       try {
    //         final jsonData = jsonDecode(dataStr);
    //         if (jsonData is Map<String, dynamic> &&
    //             jsonData['success'] == true &&
    //             jsonData['data'] != null) {
    //           final model = SummaryAbsenModel.fromJson(jsonData['data']);
    //           if (!controller.isClosed) controller.add(model);
    //         } else {
    //           if (!controller.isClosed) {
    //             controller.addError('Tidak berhasil mendapatkan data');
    //           }
    //         }
    //       } catch (e) {
    //         if (!controller.isClosed) {
    //           controller.addError('Parse JSON gagal: $e');
    //         }
    //       }
    //     },
    //     onError: (error) async {
    //       if (!controller.isClosed) controller.addError(error);
    //       // Reconnect after delay
    //       await Future.delayed(const Duration(seconds: 5));
    //       if (!controller.isClosed) connect();
    //     },
    //     onDone: () async {
    //       // Reconnect after delay
    //       await Future.delayed(const Duration(seconds: 5));
    //       if (!controller.isClosed) connect();
    //     },
    //     cancelOnError: true,
    //   );
    // }

    // connect();

    // controller.onCancel = () {
    //   controller.close();
    // };

    // return controller.stream;
  }

  // Fungsi ini untuk reload data dipanggil dari UI (refresh button)
  void reloadSummary(String idUser) {
    futureSummary.value = getSummAttPerMonth(idUser);
  }

  Future<NotifModel> getPendingApproval({
    required String idUser,
    required String kodeCabang,
    required String level,
    required String parentId,
  }) async {
    var data = {
      "type": "approval",
      "id_user": idUser,
      "kode_cabang": kodeCabang,
      "level": level,
      "parent_id": parentId,
    };
    return summPendApp.value = await ServiceApi().getNotif(data);
    // // StreamController<NotifModel> controller = StreamController();

    // // void connect() {
    // //   final url = Uri.parse(
    // //     '${dotenv.env['STREAM_NOTIF_URL']}?type=approval&kode_cabang=$kodeCabang&id_user=$idUser&level=$level&parent_id=$parentId',
    // //   );
    // //   // print( '${dotenv.env['STREAM_NOTIF_URL']}?type=approval&kode_cabang=$kodeCabang&id_user=$idUser&level=$level&parent_id=$parentId');
    // //   final sseClient = ManualSseClient(url);

    // //   sseClient.connect().listen(
    // //     (dataStr) {
    // //       //  print('Received raw data: $dataStr');
    // //       try {
    // //         final jsonData = jsonDecode(dataStr);
    // //         // print(jsonData);
    // //         if (jsonData is Map<String, dynamic> &&
    // //             jsonData['success'] == true &&
    // //             jsonData['data'] != null) {
    // //           final model = NotifModel.fromJson(jsonData['data']);
    // //           // print('---------');
    // //           // print(model);
    // //           if (!controller.isClosed) controller.add(model);
    // //         } else {
    // //           if (!controller.isClosed) {
    // //             controller.addError('Tidak berhasil mendapatkan data');
    // //           }
    // //         }
    // //       } catch (e) {
    // //         if (!controller.isClosed) {
    // //           controller.addError('Parse JSON gagal: $e');
    // //         }
    // //       }
    // //     },
    // //     onError: (error) async {
    // //       if (!controller.isClosed) controller.addError(error);
    // //       // Reconnect after delay
    // //       await Future.delayed(const Duration(seconds: 5));
    // //       if (!controller.isClosed) connect();
    // //     },
    // //     onDone: () async {
    // //       // Reconnect after delay
    // //       await Future.delayed(const Duration(seconds: 5));
    // //       if (!controller.isClosed) connect();
    // //     },
    // //     cancelOnError: true,
    // //   );
    // }

    // connect();

    // controller.onCancel = () {
    //   controller.close();
    // };

    // return controller.stream;
  }

  void reloadPendingApproval({
    required String idUser,
    required String kodeCabang,
    required String level,
    required String parentId,
  }) {
    futurePendApp.value = getPendingApproval(
      idUser: idUser,
      kodeCabang: kodeCabang,
      level: level,
      parentId: parentId,
    );
  }

  Future<NotifModel> getPendingAdj({
    required String idUser,
    required String level,
  }) async {
    var data = {
      "type": "adjusment",
      "id_user": idUser,
      "level": level,
      "date1": initDate,
      "date2": endDate,
    };
    return summPendApp.value = await ServiceApi().getNotif(data);
  }

  void reloadPendingAdj({required String idUser, required String level}) {
    futurePendAdj.value = getPendingAdj(idUser: idUser, level: level);
  }
}
