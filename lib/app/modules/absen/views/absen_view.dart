import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:latlong2/latlong.dart';

import '../../../controllers/absen_controller.dart';

class AbsenView extends GetView<AbsenController> {
  AbsenView({super.key, this.data});
  final List? data;
  final absenC = Get.put(AbsenController());

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
          appBar: AppBar(
            title: const Text('Absen'),
            automaticallyImplyLeading: false,
            centerTitle: true,
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                      'assets/image/bgapp.jpg'), // Gantilah dengan path gambar Anda
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          body: Stack(
            children: [
              FlutterMap(
                options: MapOptions(
                    center:
                        LatLng(double.parse(data![6]), double.parse(data![7])),
                    zoom: 17,
                    maxZoom: 18.4,
                    minZoom: 17),
                nonRotatedChildren: [
                  RichAttributionWidget(
                    attributions: [
                      TextSourceAttribution(
                        'OpenStreetMap contributors',
                        onTap: () {},
                      )
                    ],
                  ),
                ],
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'dev.fleaflet.flutter_map.example',
                  ),
                  MarkerLayer(markers: [
                    Marker(
                        // width: 80,
                        // height: 80,
                        point: LatLng(
                            absenC.userPostLat.value != 0.0
                                ? absenC.userPostLat.value
                                : 0.0,
                            absenC.userPostLong.value != 0.0
                                ? absenC.userPostLong.value
                                : 0.0),
                        builder: (ctx) => Icon(
                              Icons.location_pin,
                              color: Colors.redAccent[700],
                              size: 70,
                            ),
                        rotate: true),
                  ]),
                  CircleLayer(
                    circles: [
                      CircleMarker(
                          point: LatLng(
                              double.parse(data![6]), double.parse(data![7])),
                          radius: 100,
                          useRadiusInMeter: true,
                          color: const Color.fromARGB(94, 76, 166, 240),
                          borderStrokeWidth: 4,
                          borderColor: const Color.fromARGB(255, 4, 97, 173)),
                    ],
                  )
                ],
              ),
              Positioned(
                bottom: 28, // Mengatur posisi di bagian bawah
                left: 0,
                right: 0,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    child: Container(
                      height: 100,
                      child: Row(
                        children: [
                          Icon(
                            Iconsax.map,
                            color: Colors.blueAccent[700],
                            size: 80,
                          ),
                          Obx(() => Text(absenC.lokasi.value)),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            ],
          )),
    );
  }
}
