import 'package:absensi/app/helper/toast.dart';
import 'package:get/get.dart';

import '../routes/app_pages.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class PageIndexController extends GetxController {
  var pageIndex = 0.obs;
  var lokasi = "".obs;
  void changePage(int i) async {
    switch (i) {
      case 1:
        Get.defaultDialog(
          title: 'Absen'
        );
        print('Absen');
        Position position = await determinePosition();
        // print('${position.latitude} , ${position.longitude}');
        List<Placemark> placemarks = await placemarkFromCoordinates(
            position.latitude, position.longitude);
        // print(placemarks);
        lokasi.value =
            '${placemarks[0].street!}, ${placemarks[0].subLocality!}\n${placemarks[0].subAdministrativeArea!}, ${placemarks[0].administrativeArea!}';
        // pageIndex.value = i;
        // Get.offAllNamed(Routes.HOME);
        break;
      case 2:
        pageIndex.value = i;
        Get.offAllNamed(Routes.PROFIL);
        break;
      default:
        pageIndex.value = i;
        Get.offAllNamed(Routes.HOME);
    }
  }

  Future<void> updatePosition() async {}

  Future<Position> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      showToast("Lokasi belum diaktifkan");
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }
}
