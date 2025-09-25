import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/stopwatch_controller.dart';
import '../../core/constants/app_colors.dart';

class StopwatchWidget extends StatelessWidget {
  const StopwatchWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Prefer the controller already registered by the caller (HomePage).
    // If it's not registered (defensive), register it here.
    final controller = Get.isRegistered<StopWatchController>()
        ? Get.find<StopWatchController>()
        : Get.put(StopWatchController());

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Obx(
            () => Text(
              controller.elapsed.value,
              style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 12),
          Obx(
            () => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: controller.isRunningRx.value
                      ? null
                      : controller.start,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryPurple,
                  ),
                  child: const Text('Start'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: controller.isRunningRx.value
                      ? controller.stop
                      : null,
                  child: const Text('Stop'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: controller.reset,
                  child: const Text('Reset'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
