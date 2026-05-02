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

class HomeShell extends ConsumerWidget {
  const HomeShell({super.key});

  static const _titles = <String>[
    'Thành viên',
    'Phường',
    'Kỳ Phường',
    'Bảng kê',
    'Sao lưu',
  ];

  static const _icons = <IconData>[
    Icons.people_alt_outlined,
    Icons.account_balance_outlined,
    Icons.event_note_outlined,
    Icons.receipt_long_outlined,
    Icons.backup_outlined,
  ];

  static const _selectedIcons = <IconData>[
    Icons.people_alt,
    Icons.account_balance,
    Icons.event_note,
    Icons.receipt_long,
    Icons.backup,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTab = ref.watch(selectedTabProvider);
    final size = MediaQuery.sizeOf(context);
    final isTablet = size.width >= 600;
    final isDesktop = size.width >= 1100;
    final cs = Theme.of(context).colorScheme;

    final shellBody = IndexedStack(
      index: selectedTab,
      children: const [
        MembersScreen(),
        PoolsScreen(),
        RoundsScreen(),
        StatementScreen(),
        BackupScreen(),
      ],
    );

    return Scaffold(
      appBar: isDesktop
          ? null
          : AppBar(
              title: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [cs.primary, cs.tertiary],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.hub, color: Colors.white, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Text(_titles[selectedTab]),
                ],
              ),
            ),
      body: SafeArea(
        child: isDesktop
            ? Row(
                children: [
                  SideNav(
                    selectedIndex: selectedTab,
                    extended: size.width >= 1360,
                    onDestinationSelected: (v) => ref.read(selectedTabProvider.notifier).state = v,
                    titles: _titles,
                    icons: _icons,
                    selectedIcons: _selectedIcons,
                  ),
                  Expanded(child: shellBody),
                ],
              )
            : shellBody,
      ),
      bottomNavigationBar: isDesktop
          ? null
          : Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Colors.grey.shade200)),
              ),
              child: NavigationBar(
                selectedIndex: selectedTab,
                onDestinationSelected: (v) => ref.read(selectedTabProvider.notifier).state = v,
                labelBehavior: isTablet
                    ? NavigationDestinationLabelBehavior.alwaysShow
                    : NavigationDestinationLabelBehavior.alwaysShow,
                destinations: [
                  for (var i = 0; i < _titles.length; i++)
                    NavigationDestination(
                      icon: Icon(_icons[i]),
                      selectedIcon: Icon(_selectedIcons[i]),
                      label: _titles[i],
                    ),
                ],
              ),
            ),
    );
  }
}

