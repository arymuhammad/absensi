import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OvertimeTab extends StatelessWidget {
  final RxString selected;

  const OvertimeTab({super.key, required this.selected});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: CupertinoSlidingSegmentedControl<String>(
          groupValue: selected.value,
          thumbColor: Theme.of(context).cardColor,
          backgroundColor: Colors.transparent,
          children: const {
            'all': Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Text('All'),
            ),
            'approved': Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Text('Approved'),
            ),
            'pending': Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Text('Pending'),
            ),
            'rejected': Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Text('Rejected'),
            ),
          },
          onValueChanged: (val) {
            if (val != null) selected.value = val;
          },
        ),
      );
    });
  }
}
