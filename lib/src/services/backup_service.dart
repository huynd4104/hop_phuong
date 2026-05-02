import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import '../data/app_repository.dart';
import '../models/backup_snapshot.dart';

class BackupService {
  const BackupService(this.repository);

  final AppRepository repository;

  Future<File> exportBackup() async {
    if (kIsWeb) {
      throw UnsupportedError('Sao lưu file trực tiếp không được hỗ trợ trên Web.');
    }
    final snapshot = await repository.exportSnapshot();
    return repository.exportSnapshotToFile(snapshot);
  }

  Future<void> importBackupFromFile(File file) async {
    if (kIsWeb) {
      throw UnsupportedError('Nhập file trực tiếp từ đối tượng File không được hỗ trợ trên Web.');
    }
    final raw = await file.readAsString();
    final json = jsonDecode(raw);
    if (json is! Map<String, dynamic>) {
      throw StateError('Tệp sao lưu không hợp lệ.');
    }
    await repository.importSnapshot(BackupSnapshot.fromJson(json));
  }
}
