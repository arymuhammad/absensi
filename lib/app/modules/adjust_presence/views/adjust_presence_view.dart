
import 'package:absensi/app/modules/adjust_presence/views/widget/adjust_data.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/adjust_presence_controller.dart';
import 'widget/req_app_update.dart';

class AdjustPresenceView extends GetView<AdjustPresenceController> {
  AdjustPresenceView({super.key});
  final ctrl = Get.put(AdjustPresenceController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ADJUST PRESENCE'),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/image/new_bg_app.jpg'),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Container(
              height: 45,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(
                  25.0,
                ),
              ),
              child: TabBar(
                controller: ctrl.tabController,
                // give the indicator a decoration (color and border radius)
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                    25.0,
                  ),
                  color: Colors.green,
                ),
                labelColor: Colors.white,
                unselectedLabelColor: Colors.black,
                tabs: const [
                  // first tab [you can add an icon using the icon property]
                  Tab(
                    text: 'Adjust Presence Data',
                  ),

                  // second tab [you can add an icon using the icon property]
                  Tab(
                    text: 'Request Approval ',
                  ),
                ],
              ),
            ),
             Expanded(
              child: TabBarView(
                controller: ctrl.tabController,
                children: [
                  // first tab bar view widget 
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8.0, 12, 8.0,8.0),
                    child: Center(
                      child: AdjustData()
                    ),
                  ),

                  // second tab bar view widget
                  Center(
                    child: ReqAppUpdate(),
                  ),
                ],
              ),
            ),
            
          ],
        ),
      ),
    );
  }
}
