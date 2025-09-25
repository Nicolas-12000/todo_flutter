import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/app_colors.dart';
import '../controllers/task_controller.dart';
import '../widgets/date_selector.dart';
import '../widgets/task_card.dart';
import '../widgets/stopwatch_widget.dart';
import '../controllers/stopwatch_controller.dart';
import 'add_task_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<TaskController>()
        ? Get.find<TaskController>()
        : Get.put(TaskController());

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Purple header section
            Container(
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Top bar with menu and timer icons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Material(
                          color: Colors.transparent,
                          child: IconButton(
                            padding: const EdgeInsets.all(8),
                            visualDensity: VisualDensity.compact,
                            onPressed: () {
                              showModalBottomSheet(
                                context: context,
                                backgroundColor: Colors.white,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(12),
                                  ),
                                ),
                                builder: (ctx) {
                                  return SafeArea(
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Obx(() {
                                        final hasSelection =
                                            controller.selectedTaskId != null;
                                        return Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                          children: [
                                            ElevatedButton.icon(
                                              onPressed: () {
                                                // Debug: header Add pressed
                                                // ignore: avoid_print
                                                print(
                                                  'Header menu: Add pressed',
                                                );
                                                Navigator.of(ctx).pop();
                                                Get.to(
                                                  () => const AddTaskPage(),
                                                );
                                              },
                                              icon: const Icon(Icons.add),
                                              label: const Text('Add'),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    AppColors.primaryPurple,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            ElevatedButton.icon(
                                              onPressed: hasSelection
                                                  ? () {
                                                      // Debug: header Edit pressed
                                                      // ignore: avoid_print
                                                      print(
                                                        'Header menu: Edit pressed for ${controller.selectedTaskId}',
                                                      );
                                                      Navigator.of(ctx).pop();
                                                      Get.to(
                                                        () => AddTaskPage(
                                                          taskToEdit: controller
                                                              .selectedTask,
                                                        ),
                                                      );
                                                    }
                                                  : null,
                                              icon: const Icon(Icons.edit),
                                              label: const Text('Edit'),
                                            ),
                                            const SizedBox(height: 8),
                                            ElevatedButton.icon(
                                              onPressed: hasSelection
                                                  ? () async {
                                                      // Debug: header Delete pressed
                                                      // ignore: avoid_print
                                                      print(
                                                        'Header menu: Delete pressed for ${controller.selectedTaskId}',
                                                      );
                                                      final confirm = await showDialog<bool>(
                                                        context: ctx,
                                                        builder: (dctx) => AlertDialog(
                                                          title: const Text(
                                                            'Delete task',
                                                          ),
                                                          content: const Text(
                                                            'Delete the selected task?',
                                                          ),
                                                          actions: [
                                                            TextButton(
                                                              onPressed: () =>
                                                                  Navigator.of(
                                                                    dctx,
                                                                  ).pop(false),
                                                              child: const Text(
                                                                'Cancel',
                                                              ),
                                                            ),
                                                            TextButton(
                                                              onPressed: () =>
                                                                  Navigator.of(
                                                                    dctx,
                                                                  ).pop(true),
                                                              child: const Text(
                                                                'Delete',
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      );

                                                      if (confirm == true) {
                                                        // Debug: header confirmed delete
                                                        // ignore: avoid_print
                                                        print(
                                                          'Header menu: Confirm delete for ${controller.selectedTaskId}',
                                                        );
                                                        await controller
                                                            .deleteTask(
                                                              controller
                                                                  .selectedTaskId!,
                                                            );
                                                        controller
                                                            .clearSelection();
                                                        Navigator.of(ctx).pop();
                                                      }
                                                    }
                                                  : null,
                                              icon: const Icon(Icons.delete),
                                              label: const Text('Delete'),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    Colors.redAccent,
                                              ),
                                            ),
                                            const SizedBox(height: 12),
                                          ],
                                        );
                                      }),
                                    ),
                                  );
                                },
                              );
                            },
                            icon: const Icon(
                              Icons.menu,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                        Obx(
                          () => GestureDetector(
                            onTap: () {
                              // Aquí puedes agregar lógica adicional si es necesario
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                controller.formattedDate,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            // Ensure controller is registered exactly once
                            if (!Get.isRegistered<StopWatchController>()) {
                              Get.put(StopWatchController());
                            }

                            // Use Wrap so the sheet sizes to content and avoids overflow
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.white,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(16),
                                ),
                              ),
                              builder: (context) => SafeArea(
                                child: Wrap(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Center(child: StopwatchWidget()),
                                    ),
                                  ],
                                ),
                              ),
                            ).whenComplete(() {
                              // Dispose controller when sheet closes if it exists
                              if (Get.isRegistered<StopWatchController>()) {
                                try {
                                  Get.delete<StopWatchController>();
                                } catch (_) {}
                              }
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.timer_outlined,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Today section with task count and Add New button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Today',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Obx(
                              () => Text(
                                '${controller.totalTasksCount} Tasks',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () => Get.to(() => const AddTaskPage()),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'Add New',
                              style: TextStyle(
                                color: AppColors.primaryPurple,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // White content section
            Expanded(
              child: Container(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // Date selector
                      const DateSelector(),

                      const SizedBox(height: 24),

                      // My Tasks header with reload button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'My Tasks',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryText,
                            ),
                          ),
                          Obx(
                            () => GestureDetector(
                              onTap: controller.isLoading
                                  ? null
                                  : () => controller.loadTasksForDate(
                                      controller.selectedDate,
                                    ),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: controller.isLoading
                                      ? AppColors.primaryPurple.withOpacity(0.3)
                                      : AppColors.primaryPurple.withOpacity(
                                          0.1,
                                        ),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: AppColors.primaryPurple.withOpacity(
                                      0.3,
                                    ),
                                    width: 1,
                                  ),
                                ),
                                child: controller.isLoading
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: AppColors.primaryPurple,
                                        ),
                                      )
                                    : const Icon(
                                        Icons.refresh,
                                        color: AppColors.primaryPurple,
                                        size: 16,
                                      ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Manage controls (shown when Manage tab is active)
                      Obx(() {
                        final isManage = controller.selectedFilterRx.value == 3;
                        if (!isManage) return const SizedBox.shrink();

                        final hasSelection = controller.selectedTaskId != null;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            if (controller.selectedTaskId != null)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Text(
                                  'Selected: ${controller.selectedTaskId}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.black54,
                                  ),
                                ),
                              ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  ElevatedButton.icon(
                                    onPressed: () =>
                                        Get.to(() => const AddTaskPage()),
                                    icon: const Icon(Icons.add),
                                    label: const Text('Add'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primaryPurple,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton.icon(
                                    onPressed: hasSelection
                                        ? () {
                                            // Debug: Manage Edit pressed
                                            // ignore: avoid_print
                                            print(
                                              'Manage row: Edit pressed for ${controller.selectedTaskId}',
                                            );
                                            Get.to(
                                              () => AddTaskPage(
                                                taskToEdit:
                                                    controller.selectedTask,
                                              ),
                                            );
                                          }
                                        : null,
                                    icon: const Icon(Icons.edit),
                                    label: const Text('Edit'),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton.icon(
                                    onPressed: hasSelection
                                        ? () async {
                                            // Debug: Manage Delete pressed
                                            // ignore: avoid_print
                                            print(
                                              'Manage row: Delete pressed for ${controller.selectedTaskId}',
                                            );
                                            final confirm = await showDialog<bool>(
                                              context: context,
                                              builder: (ctx) => AlertDialog(
                                                title: const Text(
                                                  'Delete task',
                                                ),
                                                content: const Text(
                                                  'Are you sure you want to delete the selected task?',
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.of(
                                                          ctx,
                                                        ).pop(false),
                                                    child: const Text('Cancel'),
                                                  ),
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.of(
                                                          ctx,
                                                        ).pop(true),
                                                    child: const Text('Delete'),
                                                  ),
                                                ],
                                              ),
                                            );

                                            if (confirm == true) {
                                              // Debug: Manage confirmed delete
                                              // ignore: avoid_print
                                              print(
                                                'Manage row: Confirm delete for ${controller.selectedTaskId}',
                                              );
                                              await controller.deleteTask(
                                                controller.selectedTaskId!,
                                              );
                                              controller.clearSelection();
                                            }
                                          }
                                        : null,
                                    icon: const Icon(Icons.delete),
                                    label: const Text('Delete'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.redAccent,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }),

                      // Tasks list (uses visibleTasks which applies the selected filter)
                      Expanded(
                        child: Obx(() {
                          if (controller.isLoading) {
                            return const Center(
                              child: CircularProgressIndicator(
                                color: AppColors.primaryPurple,
                              ),
                            );
                          }

                          final visible = controller.visibleTasks;

                          if (visible.isEmpty) {
                            return const Center(
                              child: Text(
                                'No tasks for this filter',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: AppColors.secondaryText,
                                ),
                              ),
                            );
                          }

                          return ListView.builder(
                            itemCount: visible.length,
                            itemBuilder: (context, index) {
                              return TaskCard(task: visible[index]);
                            },
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Obx(() {
        final idx = controller.selectedFilterRx.value; // explicit Rx access
        return BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: idx,
          selectedItemColor: AppColors.primaryPurple,
          onTap: (i) => controller.changeFilter(i),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.list), label: 'All'),
            BottomNavigationBarItem(
              icon: Icon(Icons.priority_high),
              label: 'Urgent',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.check_circle_outline),
              label: 'Completed',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.manage_accounts),
              label: 'Manage',
            ),
          ],
        );
      }),
    );
  }
}
