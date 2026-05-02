import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/app_repository.dart';
import 'models/backup_snapshot.dart';
import 'models/pool_entity.dart';
import 'models/round_entity.dart';
import 'models/statement_models.dart';
import 'models/user_entity.dart';
import 'providers/app_providers.dart';

import 'ui/screens/home_shell.dart';
import 'ui/screens/members_screen.dart';
import 'ui/screens/pools_screen.dart';
import 'ui/screens/rounds_screen.dart';
import 'ui/screens/statement_screen.dart';
import 'ui/screens/backup_screen.dart';

import 'services/backup_service.dart';
import 'services/sample_data_service.dart';
import 'services/statement_export_service.dart';
import 'services/lunar_schedule_service.dart';
import 'utils/formatters.dart';
import 'package:lunar_calendar/lunar_calendar.dart';

class HopPhuongApp extends StatelessWidget {
  const HopPhuongApp({super.key});

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xFF0D7A6F);
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: Brightness.light,
      surface: const Color(0xFFF5F7F6),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Họp Phường',
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('vi')],
      locale: const Locale('vi'),
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: colorScheme,
        scaffoldBackgroundColor: const Color(0xFFF5F7F6),
        appBarTheme: AppBarTheme(
          centerTitle: false,
          backgroundColor: const Color(0xFFF5F7F6),
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          titleTextStyle: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
            letterSpacing: -0.3,
          ),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.grey.shade200),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: Colors.white,
          indicatorColor: colorScheme.primaryContainer,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          height: 64,
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            final selected = states.contains(WidgetState.selected);
            return TextStyle(
              fontSize: 11,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            );
          }),
        ),
        navigationRailTheme: NavigationRailThemeData(
          backgroundColor: Colors.white,
          indicatorColor: colorScheme.primaryContainer,
          selectedLabelTextStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: colorScheme.primary),
          unselectedLabelTextStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: const Color(0xFFF0F4F3),
          side: BorderSide.none,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        ),
        dividerTheme: DividerThemeData(color: Colors.grey.shade100, thickness: 1),
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      home: const HomeShell(),
    );
  }
}

