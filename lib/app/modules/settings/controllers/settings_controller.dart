import 'package:absensi/app/data/model/server_api_model.dart';
import 'package:absensi/app/services/service_api.dart';
import 'package:get/get.dart';

class SettingsController extends GetxController {
  var serverList = <ServerApi>[].obs;
  var serverSelected = "".obs;

  @override
  void onInit() {
    super.onInit();
    getServerList();
  }

  // @override
  // void onReady() {
  //   super.onReady();
  // }

  // @override
  // void onClose() {
  //   super.onClose();
  // }

  Future<List<ServerApi>> getServerList() async {
    final response = await ServiceApi().getServer();
    serverList.value = response;
    return serverList;
  }
}
