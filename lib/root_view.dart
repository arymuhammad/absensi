  import 'package:flutter/material.dart';
  import 'package:get/get.dart';

  import 'app/data/helper/navigator_helper.dart';
  import 'app/modules/home/views/bottom_navbar.dart';
  import 'app/modules/login/controllers/login_controller.dart';
  import 'app/modules/login/views/login_view.dart';
  import 'main.dart';
  import 'splash.dart';

  class RootView extends GetView<LoginController> {
    const RootView({super.key});

    @override
    Widget build(BuildContext context) {
      return Obx(() {
        if (!controller.isReady.value) {
          return const SplashView();
        }

   

        if (!launchPayloadHandled &&
            controller.isAuth.value &&
            pendingLaunchPayload != null) {
          launchPayloadHandled = true;
          // debugPrint("NOTIF_DEBUG: ROOT RECEIVE PAYLOAD = $pendingLaunchPayload");
          final payload = pendingLaunchPayload!;

          pendingLaunchPayload = null;

          WidgetsBinding.instance.addPostFrameCallback((_) {
            NotificationNavigation.handleNotificationMap(payload);
          });
        }

        return controller.isAuth.value ? BottomNavBar() : const LoginView();
      });
    }
  }
