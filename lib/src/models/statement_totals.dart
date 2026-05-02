import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../data/app_repository.dart';
import './user_entity.dart';
import './pool_entity.dart';
import './pool_member_entity.dart';
import './round_entity.dart';
import './payment_status_entity.dart';
import './statement_models.dart';
import '../providers/app_providers.dart';
import '../services/backup_service.dart';
import '../services/financial_calculator.dart';
import '../services/lunar_schedule_service.dart';
import '../services/statement_export_service.dart';
import '../utils/formatters.dart';

// UI Imports are generally discouraged in Model files, but keeping them for now if needed by other logic
import '../ui/screens/home_shell.dart';
import '../ui/screens/members_screen.dart';
import '../ui/screens/pools_screen.dart';
import '../ui/screens/rounds_screen.dart';
import '../ui/screens/statement_screen.dart';
import '../ui/screens/backup_screen.dart';
import '../ui/widgets/side_nav.dart';
import '../ui/widgets/info_card.dart';
import '../ui/widgets/feature_card.dart';
import '../ui/widgets/mini_chip.dart';
import '../ui/widgets/pool_header_card.dart';
import '../ui/widgets/empty_state.dart';
import '../ui/widgets/error_view.dart';
import '../ui/widgets/date_info_card.dart';
import '../ui/dialogs/user_dialog.dart';
import '../ui/dialogs/pool_dialog.dart';
import '../ui/dialogs/round_dialog.dart';

class StatementTotals {
  const StatementTotals({required this.totalPay, required this.totalReceive});

  final int totalPay;
  final int totalReceive;

  int get netBalance => totalReceive - totalPay;

}
