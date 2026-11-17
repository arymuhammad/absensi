import 'dart:ui';
import 'package:absensi/app/data/helper/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:icons_flutter/icons_flutter.dart';
import 'widget/navbar_style/pulse_glow.dart';

class ModernBottomBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;

  const ModernBottomBar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // final bottomSafe = MediaQuery.of(context).padding.bottom;
    final width = MediaQuery.of(context).size.width;

    final fabSize = (width * 0.17).clamp(58.0, 68.0);
    const navBarHeight = 68.0;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      height: navBarHeight,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          // NAVBAR GLASS
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
                child: Container(
                  height: navBarHeight,
                  decoration: BoxDecoration(
                    color:
                        isDark
                            ? const Color(0xFF1E293B).withOpacity(0.78)
                            : Colors.white.withOpacity(0.82),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color:
                          isDark
                              ? Colors.white.withOpacity(0.10)
                              : Colors.white.withOpacity(0.85),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(isDark ? 0.12 : 0.07),
                        blurRadius: 18,
                        offset: const Offset(0, 7),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _item(context, FontAwesome.home, "Home", 0),
                      _item(context, FontAwesome.history, "History", 1),
                      SizedBox(width: fabSize),
                      _item(context, FontAwesome.gear, "Setting", 3),
                      _item(context, FontAwesome.user_circle_o, "Profile", 4),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // CAMERA BUTTON
          Positioned(
            top: -(fabSize / 3),
            child: GestureDetector(
              onTap: () => onTap(2),
              child: Container(
                width: fabSize,
                height: fabSize,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppColors.mainGradient(
                    context: context,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),

                  // const LinearGradient(
                  //   begin: Alignment.bottomLeft,
                  //   end: Alignment.topRight,
                  //   colors: [Color(0xFF2878F0), Color(0xFF65B5FF)],
                  // ),
                  border: Border.all(
                    color:
                        isDark
                            ? Colors.white.withOpacity(0.10)
                            : Colors.white.withOpacity(0.85),
                    width: 4,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(
                        0xFF3989F5,
                      ).withOpacity(isDark ? 0.30 : 0.12),
                      blurRadius: 18,
                      offset: const Offset(0, 7),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.camera_alt_rounded,
                  color: Colors.white,
                  size: 27,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _item(BuildContext context, IconData icon, String label, int index) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final active = selectedIndex == index;
    final activeColor = isDark ? Colors.white : const Color(0xFF2878F0);
    const inactiveColor = Color(0xFF9299A5);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onTap(index),
      child: SizedBox(
        width: 62,
        height: 60,
        child: Center(
          child: PulseGlow(
            active: active,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 23,
                  color: active ? activeColor : inactiveColor,
                ),
                const SizedBox(height: 3),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: active ? 14 : 11,
                    color: active ? activeColor : inactiveColor,
                    fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
