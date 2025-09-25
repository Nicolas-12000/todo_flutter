import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/task_entity.dart';
import '../../core/constants/app_colors.dart';
import '../controllers/task_controller.dart';
import '../pages/add_task_page.dart';

class TaskCard extends StatelessWidget {
  final TaskEntity task;

  const TaskCard({Key? key, required this.task}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TaskController>();

    return Obx(() {
      final selectedId = controller.selectedTaskId;
      final isSelected = selectedId == task.id;

      return GestureDetector(
        onTap: () {
          // Debug: log card tap
          // ignore: avoid_print
          print('TaskCard tapped: ${task.id}');
          controller.toggleSelectTask(task.id);
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primaryPurple.withOpacity(0.08)
                : (task.isCompleted
                      ? AppColors.lightPurple
                      : AppColors.cardBackground),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? AppColors.primaryPurple
                  : (task.isCompleted
                        ? AppColors.primaryPurple
                        : AppColors.pendingTask),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              // Time section
              Container(
                width: 80,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormat('HH:mm').format(task.startTime),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: task.isCompleted
                            ? AppColors.primaryPurple
                            : AppColors.primaryText,
                      ),
                    ),
                    Text(
                      '- ${DateFormat('HH:mm').format(task.endTime)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: task.isCompleted
                            ? AppColors.primaryPurple
                            : AppColors.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),

              // Task content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Priority chip
                    Row(
                      children: [
                        if (task.priority == TaskPriority.high)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'High',
                              style: TextStyle(color: Colors.red, fontSize: 12),
                            ),
                          )
                        else if (task.priority == TaskPriority.low)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'Low',
                              style: TextStyle(
                                color: Colors.green,
                                fontSize: 12,
                              ),
                            ),
                          )
                        else
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'Normal',
                              style: TextStyle(
                                color: Colors.orange,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        const SizedBox(width: 8),
                      ],
                    ),
                    Text(
                      task.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: task.isCompleted
                            ? AppColors.primaryPurple
                            : AppColors.primaryText,
                        decoration: task.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      task.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: task.isCompleted
                            ? AppColors.primaryPurple
                            : AppColors.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),

              // Checkbox
              GestureDetector(
                onTap: () => controller.toggleTaskCompletion(task.id),
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: task.isCompleted
                        ? AppColors.primaryPurple
                        : Colors.transparent,
                    border: Border.all(
                      color: task.isCompleted
                          ? AppColors.primaryPurple
                          : AppColors.pendingTask,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: task.isCompleted
                      ? const Icon(Icons.check, size: 16, color: Colors.white)
                      : null,
                ),
              ),

              // Popup menu for edit/delete
              const SizedBox(width: 8),
              PopupMenuButton<String>(
                onSelected: (value) async {
                  if (value == 'edit') {
                    // Debug: log per-item edit
                    // ignore: avoid_print
                    print('Popup Edit selected for: ${task.id}');
                    Get.to(() => AddTaskPage(taskToEdit: task));
                  } else if (value == 'delete') {
                    // Debug: log per-item delete
                    // ignore: avoid_print
                    print('Popup Delete selected for: ${task.id}');
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Delete task'),
                        content: const Text(
                          'Are you sure you want to delete this task?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(true),
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true) {
                      // Debug: confirm delete
                      // ignore: avoid_print
                      print('Confirm delete: ${task.id}');
                      controller.deleteTask(task.id);
                    }
                  }
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'edit', child: Text('Edit')),
                  PopupMenuItem(value: 'delete', child: Text('Delete')),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }
}
