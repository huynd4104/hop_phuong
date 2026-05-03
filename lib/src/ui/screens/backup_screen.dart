import 'package:hop_phuong/src/utils/ui_helpers.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import 'package:share_plus/share_plus.dart';

import 'package:flutter/foundation.dart';
import 'package:hop_phuong/src/models/backup_snapshot.dart';
import 'package:hop_phuong/src/data/app_repository.dart';
import 'package:hop_phuong/src/providers/app_providers.dart';
import 'package:hop_phuong/src/services/backup_service.dart';
import 'package:hop_phuong/src/services/statement_export_service.dart';
import 'package:hop_phuong/src/services/sample_data_service.dart';

// UI Imports
import 'package:hop_phuong/src/ui/widgets/feature_card.dart';
import 'package:hop_phuong/src/ui/widgets/error_view.dart';

class BackupScreen extends ConsumerStatefulWidget {
  const BackupScreen({super.key});

  @override
  ConsumerState<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends ConsumerState<BackupScreen> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: EdgeInsets.fromLTRB(
        MediaQuery.sizeOf(context).width < 600 ? 16 : 24,
        8,
        MediaQuery.sizeOf(context).width < 600 ? 16 : 24,
        24,
      ),
      child: ref
          .watch(appRepositoryProvider)
          .when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => ErrorView(
              message: error.toString(),
              onRetry: () => ref.invalidate(appRepositoryProvider),
            ),
            data: (repository) => SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FeatureCard(
                    icon: Icons.upload_file_outlined,
                    title: 'Sao lưu dữ liệu (JSON)',
                    subtitle:
                        'Xuất toàn bộ cơ sở dữ liệu để sao lưu ngoại tuyến hoặc khôi phục từ ảnh chụp trước đó.',
                    trailing: FilledButton.icon(
                      onPressed: () async {
                        try {
                          final file = await BackupService(
                            repository,
                          ).exportBackup();
                          
                          if (context.mounted) {
                            final box = context.findRenderObject() as RenderBox?;
                            final rect = box != null ? box.localToGlobal(Offset.zero) & box.size : null;

                            // Show share sheet
                            await Share.shareXFiles(
                              [XFile(file.path)],
                              sharePositionOrigin: rect,
                            );

                            if (context.mounted) {
                              showSnackBar(
                                context,
                                'Đã xuất sao lưu thành công!',
                              );
                            }
                          }
                        } catch (error) {
                          if (context.mounted) {
                            showSnackBar(
                              context,
                              error.toString(),
                              isError: true,
                            );
                          }
                        }
                      },
                      icon: const Icon(Icons.upload_rounded, size: 18),
                      label: const Text('Xuất JSON'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  FeatureCard(
                    icon: Icons.download_outlined,
                    title: 'Khôi phục từ JSON',
                    subtitle:
                        'Chọn một tệp sao lưu và thay thế cơ sở dữ liệu cục bộ bằng nội dung của tệp đó.',
                    trailing: OutlinedButton.icon(
                      onPressed: () async {
                        try {
                          final result = await FilePicker.platform.pickFiles(
                            type: FileType.custom,
                            allowedExtensions: ['json'],
                          );
                          if (result == null) return;

                          if (!context.mounted) return;
                          final confirm = await showConfirmDialog(
                            context,
                            'Xác nhận khôi phục',
                            'Toàn bộ dữ liệu hiện tại sẽ bị xóa và thay thế bằng dữ liệu từ tệp sao lưu. Bạn có chắc chắn muốn tiếp tục?',
                            isDestructive: true,
                          );
                          if (!confirm) return;

                          if (kIsWeb) {
                            final bytes = result.files.single.bytes;
                            if (bytes == null) return;
                            final raw = utf8.decode(bytes);
                            final json = jsonDecode(raw);
                            if (json is! Map<String, dynamic>) {
                              throw StateError('Tệp sao lưu không hợp lệ.');
                            }
                            await repository.importSnapshot(
                              BackupSnapshot.fromJson(json),
                            );
                          } else {
                            final path = result.files.single.path;
                            if (path == null) return;
                            await BackupService(
                              repository,
                            ).importBackupFromFile(File(path));
                          }

                          refreshAll(ref);
                          if (context.mounted) {
                            showSnackBar(
                              context,
                              'Đã khôi phục dữ liệu thành công',
                            );
                          }
                        } catch (error) {
                          if (context.mounted) {
                            showSnackBar(
                              context,
                              error.toString(),
                              isError: true,
                            );
                          }
                        }
                      },
                      icon: const Icon(Icons.download_rounded, size: 18),
                      label: const Text('Nhập JSON'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  FeatureCard(
                    icon: Icons.table_view_outlined,
                    title: 'Xuất toàn bộ dữ liệu ra Excel',
                    subtitle:
                        'Tạo tệp .xlsx chứa báo cáo tất cả các tháng (mỗi tháng 1 sheet).',
                    trailing: FilledButton.tonalIcon(
                      onPressed: () async {
                        try {
                          showSnackBar(context, 'Đang chuẩn bị dữ liệu toàn hệ thống...');
                          
                          final monthlyData = await repository.getAllStatementsGroupedByMonth();

                          if (monthlyData.isEmpty) {
                            throw StateError('Không có dữ liệu kỳ hụi nào trong hệ thống.');
                          }

                          final file = await StatementExportService().exportAllStatementsToExcel(
                            monthlyData: monthlyData,
                          );
                          
                          if (context.mounted) {
                            final box = context.findRenderObject() as RenderBox?;
                            final rect = box != null ? box.localToGlobal(Offset.zero) & box.size : null;

                            // Show share sheet
                            await Share.shareXFiles(
                              [XFile(file.path)],
                              sharePositionOrigin: rect,
                            );

                            if (context.mounted) {
                              showSnackBar(
                                context,
                                'Đã xuất toàn bộ dữ liệu Excel thành công!',
                              );
                            }
                          }
                        } catch (error) {
                          if (context.mounted) {
                            final message = error.toString()
                                .replaceFirst('Bad state: ', '')
                                .replaceFirst('Exception: ', '')
                                .replaceFirst('StateError: ', '');
                                
                            showSnackBar(
                              context,
                              message,
                              isError: true,
                            );
                          }
                        }
                      },
                      icon: const Icon(Icons.table_view_rounded, size: 18),
                      label: const Text('Xuất Excel'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  FeatureCard(
                    icon: Icons.refresh_rounded,
                    title: 'Đặt lại dữ liệu mẫu',
                    subtitle:
                        'Xóa cơ sở dữ liệu cục bộ và nạp lại dữ liệu thử nghiệm để kiểm tra.',
                    trailing: FilledButton(
                      onPressed: () async {
                        final confirm = await showConfirmDialog(
                          context,
                          'Xác nhận đặt lại',
                          'Toàn bộ dữ liệu hiện tại sẽ bị xóa và thay thế bằng dữ liệu mẫu. Bạn có chắc chắn muốn tiếp tục?',
                          isDestructive: true,
                        );
                        if (!confirm || !context.mounted) return;

                        try {
                          await repository.clearAll();
                          await SampleDataService().seedIfEmpty(repository);
                          refreshAll(ref);
                          if (context.mounted) {
                            showSnackBar(context, 'Đã khôi phục dữ liệu mẫu');
                          }
                        } catch (error) {
                          if (context.mounted) {
                            showSnackBar(
                              context,
                              error.toString(),
                              isError: true,
                            );
                          }
                        }
                      },
                      child: const Text('Nạp lại'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  FeatureCard(
                    icon: Icons.delete_forever_outlined,
                    title: 'Xóa sạch dữ liệu',
                    subtitle: 'Xóa vĩnh viễn toàn bộ thành viên, dây hụi và lịch sử giao dịch.',
                    trailing: OutlinedButton(
                      onPressed: () async {
                        final confirm = await showConfirmDialog(
                          context,
                          'Xóa vĩnh viễn',
                          'Hành động này sẽ xóa toàn bộ dữ liệu trong máy và KHÔNG THỂ hoàn tác. Bạn có chắc chắn muốn xóa sạch không?',
                          isDestructive: true,
                          confirmLabel: 'Xóa vĩnh viễn',
                        );
                        if (!confirm || !context.mounted) return;

                        try {
                          await repository.clearAll();
                          refreshAll(ref);
                          if (context.mounted) {
                            showSnackBar(context, 'Đã xóa sạch dữ liệu thành công');
                          }
                        } catch (error) {
                          if (context.mounted) {
                            showSnackBar(
                              context,
                              error.toString(),
                              isError: true,
                            );
                          }
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.error,
                        side: BorderSide(color: Theme.of(context).colorScheme.error),
                      ),
                      child: const Text('Xóa sạch'),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }
}
