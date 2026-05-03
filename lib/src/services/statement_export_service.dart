import 'dart:io';

import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';

import '../models/statement_models.dart';

class StatementExportService {
  const StatementExportService();

  /// Xuất toàn bộ dữ liệu hệ thống, mỗi tháng một Sheet
  Future<File> exportAllStatementsToExcel({
    required Map<String, List<UserMonthlyStatement>> monthlyData,
  }) async {
    final excel = Excel.createExcel();
    
    // Xóa sheet mặc định (Sheet1)
    final defaultSheet = excel.getDefaultSheet();
    if (defaultSheet != null) {
      excel.delete(defaultSheet);
    }
    
    final currencyFormat = NumberFormat('#,###', 'vi_VN');
    final dateFormat = DateFormat('dd/MM/yyyy');
    final styles = _ExcelStyles();

    // Duyệt qua từng tháng để tạo Sheet
    final sortedMonths = monthlyData.keys.toList()..sort((a, b) {
      // Sắp xếp theo thời gian (MM/yyyy)
      final partsA = a.split('/');
      final partsB = b.split('/');
      final yearA = int.parse(partsA[1]);
      final yearB = int.parse(partsB[1]);
      if (yearA != yearB) return yearA.compareTo(yearB);
      return int.parse(partsA[0]).compareTo(int.parse(partsB[0]));
    });

    for (final monthKey in sortedMonths) {
      final statements = monthlyData[monthKey]!;
      final sheetName = 'Tháng ${monthKey.replaceAll('/', '-')}';
      final sheet = excel[sheetName];

      // --- PHẦN 1: TIÊU ĐỀ ---
      sheet.appendRow([TextCellValue('BÁO CÁO CÔNG NỢ THÁNG $monthKey')]);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0)).cellStyle = styles.titleStyle;
      
      sheet.appendRow([TextCellValue('Ngày xuất: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}')]);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 1)).cellStyle = styles.metadataStyle;
      sheet.appendRow([TextCellValue('')]); // Spacer

      // --- PHẦN 2: BẢNG TỔNG HỢP ---
      sheet.appendRow([TextCellValue('I. TỔNG HỢP CÔNG NỢ')]);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 3)).cellStyle = styles.sectionHeaderStyle;

      final summaryHeaders = ['STT', 'Thành viên', 'Số điện thoại', 'Tổng đóng', 'Tổng nhận', 'Cân đối', 'Đã thanh toán', 'Còn lại (Nợ)'];
      sheet.appendRow(summaryHeaders.map((e) => TextCellValue(e)).toList());
      for (var i = 0; i < summaryHeaders.length; i++) {
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 4)).cellStyle = styles.headerStyle;
      }

      int totalPay = 0;
      int totalReceive = 0;
      int totalActual = 0;

      for (var i = 0; i < statements.length; i++) {
        final s = statements[i];
        totalPay += s.totalPay;
        totalReceive += s.totalReceive;
        totalActual += s.totalActualAmount;

        final rowIndex = 5 + i;
        sheet.appendRow([
          IntCellValue(i + 1),
          TextCellValue(s.userName),
          TextCellValue(s.phone),
          TextCellValue(currencyFormat.format(s.totalPay)),
          TextCellValue(currencyFormat.format(s.totalReceive)),
          TextCellValue(currencyFormat.format(s.netBalance)),
          TextCellValue(currencyFormat.format(s.totalActualAmount)),
          TextCellValue(currencyFormat.format(s.remainingBalance)),
        ]);

        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex)).cellStyle = styles.centerStyle;
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: rowIndex)).cellStyle = styles.moneyStyle;
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: rowIndex)).cellStyle = styles.moneyStyle;
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: rowIndex)).cellStyle = s.netBalance >= 0 ? styles.positiveMoneyStyle : styles.negativeMoneyStyle;
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: rowIndex)).cellStyle = styles.moneyStyle;
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: rowIndex)).cellStyle = s.remainingBalance < 0 ? styles.negativeMoneyStyle : (s.remainingBalance > 0 ? styles.positiveMoneyStyle : styles.moneyStyle);
      }

      // Dòng tổng cộng cho bảng tổng hợp
      final summaryTotalIndex = 5 + statements.length;
      sheet.appendRow([
        TextCellValue('TỔNG CỘNG'),
        TextCellValue(''),
        TextCellValue(''),
        TextCellValue(currencyFormat.format(totalPay)),
        TextCellValue(currencyFormat.format(totalReceive)),
        TextCellValue(currencyFormat.format(totalReceive - totalPay)),
        TextCellValue(currencyFormat.format(totalActual)),
        TextCellValue(currencyFormat.format((totalReceive - totalPay) - totalActual)),
      ]);
      for (var i = 0; i < summaryHeaders.length; i++) {
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: summaryTotalIndex)).cellStyle = styles.headerStyle;
      }

      sheet.appendRow([TextCellValue('')]); // Spacer
      sheet.appendRow([TextCellValue('')]); // Spacer

      // --- PHẦN 3: BẢNG CHI TIẾT ---
      final breakdownStartRow = summaryTotalIndex + 3;
      sheet.appendRow([TextCellValue('II. CHI TIẾT DÂY HỤI')]);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: breakdownStartRow)).cellStyle = styles.sectionHeaderStyle;

      final breakdownHeaders = ['Thành viên', 'Tên dây hụi', 'Kỳ', 'Ngày kỳ', 'Phải đóng', 'Được lĩnh', 'Thực tế', 'Ghi chú'];
      sheet.appendRow(breakdownHeaders.map((e) => TextCellValue(e)).toList());
      for (var i = 0; i < breakdownHeaders.length; i++) {
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: breakdownStartRow + 1)).cellStyle = styles.headerStyle;
      }

      int bRow = breakdownStartRow + 2;
      for (final s in statements) {
        for (final b in s.breakdowns) {
          sheet.appendRow([
            TextCellValue(s.userName),
            TextCellValue(b.poolName),
            TextCellValue(b.roundNumbers.join(', ')),
            TextCellValue(b.roundDates.map((d) => dateFormat.format(d)).join('\n')),
            TextCellValue(currencyFormat.format(b.payAmount)),
            TextCellValue(currencyFormat.format(b.receiveAmount)),
            TextCellValue(currencyFormat.format(b.actualAmount)),
            TextCellValue(b.notes.join('; ')),
          ]);
          
          sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: bRow)).cellStyle = styles.moneyStyle;
          sheet.cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: bRow)).cellStyle = styles.moneyStyle;
          sheet.cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: bRow)).cellStyle = styles.moneyStyle;
          bRow++;
        }
      }
      
      // Auto-fit columns cho sheet này
      for (var i = 0; i < breakdownHeaders.length; i++) {
        sheet.setColumnWidth(i, 20.0);
      }
    }

    // --- TRANG CUỐI: NHẬT KÝ TỔNG HỢP ---
    final logSheet = excel['Nhật ký giao dịch'];
    final logHeaders = ['Tháng/Năm', 'Thành viên', 'Dây hụi', 'Số tiền', 'Ngày giao dịch', 'Ghi chú'];
    logSheet.appendRow(logHeaders.map((e) => TextCellValue(e)).toList());
    for (var i = 0; i < logHeaders.length; i++) {
      logSheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0)).cellStyle = styles.headerStyle;
    }

    int lRow = 1;
    for (final monthKey in sortedMonths) {
      for (final s in monthlyData[monthKey]!) {
        for (final b in s.breakdowns) {
          for (final history in b.history) {
            logSheet.appendRow([
              TextCellValue(monthKey),
              TextCellValue(s.userName),
              TextCellValue(b.poolName),
              TextCellValue(currencyFormat.format(history.amount)),
              TextCellValue(dateFormat.format(history.date)),
              TextCellValue(history.note ?? ''),
            ]);
            
            logSheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: lRow)).cellStyle = history.amount >= 0 ? styles.positiveMoneyStyle : styles.negativeMoneyStyle;
            lRow++;
          }
        }
      }
    }
    for (var i = 0; i < logHeaders.length; i++) {
      logSheet.setColumnWidth(i, 20.0);
    }

    // --- LƯU FILE ---
    final bytes = excel.encode();
    if (bytes == null) throw StateError('Không thể tạo tệp Excel.');

    final directory = await getTemporaryDirectory();
    final exportDirectory = Directory('${directory.path}/hop_phuong_exports');
    if (!await exportDirectory.exists()) await exportDirectory.create(recursive: true);

    final timestamp = DateFormat('yyyyMMdd_HHmm').format(DateTime.now());
    final fileName = 'Bao_cao_tong_hop_$timestamp.xlsx';
    final file = File('${exportDirectory.path}/$fileName');
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }

  // Phương thức cũ để tương thích ngược nếu cần (Optional)
  Future<File> exportMonthlyStatementToExcel({
    required int month,
    required int year,
    required List<UserMonthlyStatement> statements,
  }) async {
    return exportAllStatementsToExcel(monthlyData: {'$month/$year': statements});
  }
}

class _ExcelStyles {
  late CellStyle headerStyle;
  late CellStyle titleStyle;
  late CellStyle sectionHeaderStyle;
  late CellStyle metadataStyle;
  late CellStyle moneyStyle;
  late CellStyle negativeMoneyStyle;
  late CellStyle positiveMoneyStyle;
  late CellStyle centerStyle;

  _ExcelStyles() {
    headerStyle = CellStyle(
      bold: true,
      fontSize: 11,
      fontColorHex: ExcelColor.white,
      backgroundColorHex: ExcelColor.blue800,
      horizontalAlign: HorizontalAlign.Center,
      verticalAlign: VerticalAlign.Center,
      leftBorder: Border(borderStyle: BorderStyle.Thin),
      rightBorder: Border(borderStyle: BorderStyle.Thin),
      topBorder: Border(borderStyle: BorderStyle.Thin),
      bottomBorder: Border(borderStyle: BorderStyle.Thin),
    );

    titleStyle = CellStyle(
      bold: true,
      fontSize: 16,
      fontColorHex: ExcelColor.blue800,
    );

    sectionHeaderStyle = CellStyle(
      bold: true,
      fontSize: 13,
      fontColorHex: ExcelColor.blueGrey800,
    );

    metadataStyle = CellStyle(
      italic: true,
      fontSize: 10,
      fontColorHex: ExcelColor.grey,
    );

    moneyStyle = CellStyle(horizontalAlign: HorizontalAlign.Right);
    negativeMoneyStyle = CellStyle(horizontalAlign: HorizontalAlign.Right, fontColorHex: ExcelColor.red600);
    positiveMoneyStyle = CellStyle(horizontalAlign: HorizontalAlign.Right, fontColorHex: ExcelColor.green600);
    centerStyle = CellStyle(horizontalAlign: HorizontalAlign.Center);
  }
}
