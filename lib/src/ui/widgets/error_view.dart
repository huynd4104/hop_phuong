import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'package:hop_phuong/src/data/app_repository.dart';
import 'package:hop_phuong/src/models/user_entity.dart';
import 'package:hop_phuong/src/models/pool_entity.dart';
import 'package:hop_phuong/src/models/pool_member_entity.dart';
import 'package:hop_phuong/src/models/round_entity.dart';
import 'package:hop_phuong/src/models/payment_status_entity.dart';
import 'package:hop_phuong/src/models/statement_models.dart';
import 'package:hop_phuong/src/providers/app_providers.dart';
import 'package:hop_phuong/src/services/backup_service.dart';
import 'package:hop_phuong/src/services/financial_calculator.dart';
import 'package:hop_phuong/src/services/lunar_schedule_service.dart';
import 'package:hop_phuong/src/services/statement_export_service.dart';
import 'package:hop_phuong/src/utils/formatters.dart';

// UI Imports (nếu cần)
import 'package:hop_phuong/src/ui/screens/home_shell.dart';
import 'package:hop_phuong/src/ui/screens/members_screen.dart';
import 'package:hop_phuong/src/ui/screens/pools_screen.dart';
import 'package:hop_phuong/src/ui/screens/rounds_screen.dart';
import 'package:hop_phuong/src/ui/screens/statement_screen.dart';
import 'package:hop_phuong/src/ui/screens/backup_screen.dart';
import 'package:hop_phuong/src/ui/widgets/side_nav.dart';
import 'package:hop_phuong/src/ui/widgets/info_card.dart';
import 'package:hop_phuong/src/ui/widgets/feature_card.dart';
import 'package:hop_phuong/src/ui/widgets/mini_chip.dart';
import 'package:hop_phuong/src/ui/widgets/pool_header_card.dart';
import 'package:hop_phuong/src/ui/widgets/empty_state.dart';
import 'package:hop_phuong/src/ui/widgets/error_view.dart';
import 'package:hop_phuong/src/ui/widgets/date_info_card.dart';
import 'package:hop_phuong/src/ui/dialogs/user_dialog.dart';
import 'package:hop_phuong/src/ui/dialogs/pool_dialog.dart';
import 'package:hop_phuong/src/ui/dialogs/round_dialog.dart';
import 'package:hop_phuong/src/models/statement_totals.dart';

class ErrorView extends StatelessWidget {
  const ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 42),
              const SizedBox(height: 10),
              Text('Đã có lỗi xảy ra', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(message, textAlign: TextAlign.center),
              const SizedBox(height: 14),
              FilledButton(onPressed: onRetry, child: const Text('Thử lại')),
            ],
          ),
        ),
      ),
    );
  }
}

