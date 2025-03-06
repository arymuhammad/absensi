import 'package:absensi/app/data/helper/const.dart';
import 'package:absensi/app/data/model/login_model.dart';
import 'package:absensi/app/modules/adjust_presence/views/widget/req_app_update.dart';
import 'package:absensi/app/modules/shared/background_image_header.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ReqAppUserView extends GetView {
  const ReqAppUserView({super.key, this.userData});
  final Data? userData;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('NOTIFICATIONS',
            style: titleTextStyle.copyWith(
              fontSize: 20,
            )),
        backgroundColor: Colors.transparent.withOpacity(0.4),
        elevation: 0.0,
        // iconTheme: const IconThemeData(color: Colors.black,),
        centerTitle: true,
      ),
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          const CsBgImg(),
          Padding(
            padding: const EdgeInsets.fromLTRB(8.0,100,8,8),
            child: Card(child: Container(
              // height: 400,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(10),color: Colors.white,),
              child: ReqAppUpdate(dataUser: userData!,))),
          )
          
        ],
      ),
    );
  }
}
