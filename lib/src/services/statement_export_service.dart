import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';

import '../models/statement_models.dart';

class StatementExportService {
  const StatementExportService();

  Future<File> exportMonthlyStatementToExcel({
    required int month,
    required int year,
    required List<UserMonthlyStatement> statements,
  }) async {
    final excel = Excel.createExcel();
    final summarySheet = excel['Tổng hợp'];
    final breakdownSheet = excel['Chi tiết'];

    summarySheet.appendRow(<CellValue?>[
      TextCellValue('Người dùng'),
      TextCellValue('Điện thoại'),
      TextCellValue('Tổng đóng'),
      TextCellValue('Tổng giao'),
      TextCellValue('Cân đối'),
    ]);
    breakdownSheet.appendRow(<CellValue?>[
      TextCellValue('Người dùng'),
      TextCellValue('Phường'),
      TextCellValue('Đóng vào'),
      TextCellValue('Thực giao'),
      TextCellValue('Cân đối'),
    ]);

    for (final statement in statements) {
      summarySheet.appendRow(<CellValue?>[
        TextCellValue(statement.userName),
        TextCellValue(statement.phone),
        IntCellValue(statement.totalPay),
        IntCellValue(statement.totalReceive),
        IntCellValue(statement.netBalance),
      ]);

      for (final breakdown in statement.breakdowns) {
        breakdownSheet.appendRow(<CellValue?>[
          TextCellValue(statement.userName),
          TextCellValue(breakdown.poolName),
          IntCellValue(breakdown.payAmount),
          IntCellValue(breakdown.receiveAmount),
          IntCellValue(breakdown.netBalance),
        ]);
      }
    }

    final bytes = excel.encode();
    if (bytes == null) {
      throw StateError('Không thể tạo tệp Excel.');
    }

    if (kIsWeb) {
      // Trên Web, chúng ta sẽ trả về một lỗi rõ ràng cho đến khi tích hợp công cụ tải xuống
      throw UnsupportedError(
        'Xuất file Excel trực tiếp không được hỗ trợ trên Web.',
      );
    }

    final directory = await getApplicationDocumentsDirectory();
    final exportDirectory = Directory('${directory.path}/hop_phuong_exports');
    if (!await exportDirectory.exists()) {
      await exportDirectory.create(recursive: true);
    }

    final fileName =
        'monthly_statement_${year.toString().padLeft(4, '0')}_${month.toString().padLeft(2, '0')}.xlsx';
    final file = File('${exportDirectory.path}/$fileName');
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }
}
