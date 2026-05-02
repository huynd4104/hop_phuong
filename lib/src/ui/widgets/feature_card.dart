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

class FeatureCard extends StatelessWidget {
  const FeatureCard({required this.title, required this.subtitle, required this.icon, this.trailing});

  final String title;
  final String subtitle;
  final IconData icon;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isMobile = MediaQuery.sizeOf(context).width < 500;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: isMobile
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 38, height: 38,
                        decoration: BoxDecoration(color: cs.primaryContainer, borderRadius: BorderRadius.circular(10)),
                        child: Icon(icon, size: 20, color: cs.onPrimaryContainer),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15))),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(subtitle, style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant, height: 1.4)),
                  if (trailing != null) ...[const SizedBox(height: 12), trailing!],
                ],
              )
            : Row(
                children: [
                  Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(color: cs.primaryContainer, borderRadius: BorderRadius.circular(12)),
                    child: Icon(icon, size: 22, color: cs.onPrimaryContainer),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                        const SizedBox(height: 4),
                        Text(subtitle, style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant)),
                      ],
                    ),
                  ),
                  if (trailing != null) ...[const SizedBox(width: 16), trailing!],
                ],
              ),
      ),
    );
  }
}

