import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/config/supabase_config.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/repositories/task_repository.dart';
import '../models/task_model.dart';

class TaskRepositoryImpl implements TaskRepository {
  final SupabaseClient _client = SupabaseConfig.client;
  static const String _tableName = 'tasks';

  @override
  Future<List<TaskEntity>> getAllTasks() async {
    try {
      final response = await _client
          .from(_tableName)
          .select()
          .order('start_time', ascending: true);

      return response
          .map<TaskEntity>((json) => TaskModel.fromJson(json).toEntity())
          .toList();
    } catch (e) {
      throw Exception('Error al obtener las tareas: $e');
    }
  }

  @override
  Future<TaskEntity> getTaskById(String id) async {
    try {
      final response = await _client
          .from(_tableName)
          .select()
          .eq('id', id)
          .single();

      return TaskModel.fromJson(response).toEntity();
    } catch (e) {
      throw Exception('Error al obtener la tarea por ID: $e');
    }
  }

  @override
  Future<void> addTask(TaskEntity task) async {
    try {
      final taskModel = TaskModel.fromEntity(task);
      final payload = taskModel.toJsonForInsert();

      try {
        // Debug: log payload
        // ignore: avoid_print
        print('Supabase INSERT payload: $payload');
        final res = await _client.from(_tableName).insert(payload).select();
        // If Supabase returns an empty result, try fallback
        if (res == null || (res is List && res.isEmpty)) {
          if (payload.containsKey('priority')) {
            final fallback = Map<String, dynamic>.from(payload)
              ..remove('priority');
            // ignore: avoid_print
            print('Supabase INSERT fallback payload: $fallback');
            final r2 = await _client.from(_tableName).insert(fallback).select();
            if (r2 == null || (r2 is List && r2.isEmpty)) {
              throw Exception('Insert returned empty result');
            }
          } else {
            throw Exception('Insert returned empty result');
          }
        }
      } catch (e) {
        // If insert fails (for example missing 'priority' column), retry without priority
        if (payload.containsKey('priority')) {
          try {
            final fallback = Map<String, dynamic>.from(payload)
              ..remove('priority');
            // ignore: avoid_print
            print('Supabase INSERT fallback try payload: $fallback');
            final r = await _client.from(_tableName).insert(fallback).select();
            if (r == null || (r is List && r.isEmpty)) {
              throw Exception('Insert fallback returned empty result: $r');
            }
            return;
          } catch (e2) {
            throw Exception('Insert failed (original: $e, fallback: $e2)');
          }
        }
        throw Exception('Insert failed: $e');
      }
    } catch (e) {
      throw Exception('Error al crear la tarea: $e');
    }
  }

  @override
  Future<void> updateTask(TaskEntity task) async {
    try {
      final taskModel = TaskModel.fromEntity(task);
      final payload = taskModel.toJson();

      try {
        // Debug: log payload
        // ignore: avoid_print
        print('Supabase UPDATE payload for id ${task.id}: $payload');
        final res = await _client
            .from(_tableName)
            .update(payload)
            .eq('id', task.id)
            .select();
        if (res == null || (res is List && res.isEmpty)) {
          if (payload.containsKey('priority')) {
            final fallback = Map<String, dynamic>.from(payload)
              ..remove('priority');
            // ignore: avoid_print
            print(
              'Supabase UPDATE fallback payload for id ${task.id}: $fallback',
            );
            final r2 = await _client
                .from(_tableName)
                .update(fallback)
                .eq('id', task.id)
                .select();
            if (r2 == null || (r2 is List && r2.isEmpty)) {
              throw Exception('Update returned empty result');
            }
          } else {
            throw Exception('Update returned empty result');
          }
        }
      } catch (e) {
        if (payload.containsKey('priority')) {
          try {
            final fallback = Map<String, dynamic>.from(payload)
              ..remove('priority');
            // ignore: avoid_print
            print(
              'Supabase UPDATE fallback try payload for id ${task.id}: $fallback',
            );
            final r = await _client
                .from(_tableName)
                .update(fallback)
                .eq('id', task.id)
                .select();
            if (r == null || (r is List && r.isEmpty)) {
              throw Exception('Update fallback returned empty result: $r');
            }
            return;
          } catch (e2) {
            throw Exception('Update failed (original: $e, fallback: $e2)');
          }
        }
        throw Exception('Update failed: $e');
      }
    } catch (e) {
      throw Exception('Error al actualizar la tarea: $e');
    }
  }

  @override
  Future<void> deleteTask(String id) async {
    try {
      await _client.from(_tableName).delete().eq('id', id);
    } catch (e) {
      throw Exception('Error al eliminar la tarea: $e');
    }
  }

  @override
  Future<List<TaskEntity>> getTasksByDate(DateTime date) async {
    try {
      // Query by start_time range to match tasks occurring on the given date
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

      final response = await _client
          .from(_tableName)
          .select()
          .gte('start_time', startOfDay.toIso8601String())
          .lte('start_time', endOfDay.toIso8601String())
          .order('start_time', ascending: true);

      return response
          .map<TaskEntity>((json) => TaskModel.fromJson(json).toEntity())
          .toList();
    } catch (e) {
      throw Exception('Error al obtener las tareas por fecha: $e');
    }
  }
}
