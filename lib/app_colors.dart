import 'package:flutter/material.dart';

@immutable
class SharedColorTokens {
  const SharedColorTokens({
    required this.cardBackground,
    required this.navBackground,
    required this.transparent,
    required this.white,
    required this.shadowFaint,
    required this.shadowSoft,
    required this.shadowSubtle,
    required this.shadowStrong,
    required this.overlayWhite08,
    required this.overlayWhite12,
    required this.avatarGradientTop,
    required this.avatarGradientBottom,
    required this.fadeGradientStart,
    required this.fadeGradientEnd,
    required this.participantAvatarBlue,
    required this.participantAvatarSand,
    required this.participantAvatarSlate,
    required this.participantAvatarGreen,
    required this.participantAvatarWarm,
    required this.participantAvatarNeutral,
    required this.participantAvatarLilac,
    required this.currentUserAvatar,
  });

  final Color cardBackground;
  final Color navBackground;
  final Color transparent;
  final Color white;
  final Color shadowFaint;
  final Color shadowSoft;
  final Color shadowSubtle;
  final Color shadowStrong;
  final Color overlayWhite08;
  final Color overlayWhite12;
  final Color avatarGradientTop;
  final Color avatarGradientBottom;
  final Color fadeGradientStart;
  final Color fadeGradientEnd;
  final Color participantAvatarBlue;
  final Color participantAvatarSand;
  final Color participantAvatarSlate;
  final Color participantAvatarGreen;
  final Color participantAvatarWarm;
  final Color participantAvatarNeutral;
  final Color participantAvatarLilac;
  final Color currentUserAvatar;
}

@immutable
class SplashColorTokens {
  const SplashColorTokens({
    required this.background,
    required this.title,
    required this.subtitle,
    required this.buttonFill,
    required this.texture,
  });

  final Color background;
  final Color title;
  final Color subtitle;
  final Color buttonFill;
  final Color texture;
}

@immutable
class AuthColorTokens {
  const AuthColorTokens({
    required this.background,
    required this.buttonFill,
    required this.buttonDisabledFill,
    required this.buttonDisabledText,
    required this.cardBorder,
    required this.dividerSoft,
    required this.error,
    required this.fieldBorder,
    required this.fieldFill,
    required this.footerBorder,
    required this.footerFill,
    required this.footerText,
    required this.orangeDark,
    required this.textMuted,
    required this.textPlaceholder,
    required this.textPrimary,
    required this.socialButtonBorder,
    required this.socialButtonText,
  });

  final Color background;
  final Color buttonFill;
  final Color buttonDisabledFill;
  final Color buttonDisabledText;
  final Color cardBorder;
  final Color dividerSoft;
  final Color error;
  final Color fieldBorder;
  final Color fieldFill;
  final Color footerBorder;
  final Color footerFill;
  final Color footerText;
  final Color orangeDark;
  final Color textMuted;
  final Color textPlaceholder;
  final Color textPrimary;
  final Color socialButtonBorder;
  final Color socialButtonText;
}

@immutable
class CalculatorColorTokens {
  const CalculatorColorTokens({
    required this.background,
    required this.displayFill,
    required this.borderSoft,
    required this.separator,
    required this.textPrimary,
    required this.textMuted,
    required this.displayText,
    required this.orange,
    required this.orangeText,
    required this.red,
  });

  final Color background;
  final Color displayFill;
  final Color borderSoft;
  final Color separator;
  final Color textPrimary;
  final Color textMuted;
  final Color displayText;
  final Color orange;
  final Color orangeText;
  final Color red;
}

@immutable
class CreateTripColorTokens {
  const CreateTripColorTokens({
    required this.background,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.textPlaceholder,
    required this.orange,
    required this.orangeText,
    required this.darkButton,
    required this.fieldFill,
    required this.cardBorder,
    required this.separator,
    required this.avatarBlue,
    required this.avatarBlueText,
    required this.avatarGreen,
    required this.avatarGreenText,
    required this.avatarSoft,
  });

  final Color background;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color textPlaceholder;
  final Color orange;
  final Color orangeText;
  final Color darkButton;
  final Color fieldFill;
  final Color cardBorder;
  final Color separator;
  final Color avatarBlue;
  final Color avatarBlueText;
  final Color avatarGreen;
  final Color avatarGreenText;
  final Color avatarSoft;
}

@immutable
class CreateExpenseColorTokens {
  const CreateExpenseColorTokens({
    required this.background,
    required this.summaryFill,
    required this.segmentFill,
    required this.cardBorder,
    required this.inputBorder,
    required this.dashedBorder,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.placeholder,
    required this.orange,
    required this.orangeText,
    required this.saveText,
    required this.green,
  });

  final Color background;
  final Color summaryFill;
  final Color segmentFill;
  final Color cardBorder;
  final Color inputBorder;
  final Color dashedBorder;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color placeholder;
  final Color orange;
  final Color orangeText;
  final Color saveText;
  final Color green;
}

@immutable
class DashboardColorTokens {
  const DashboardColorTokens({
    required this.background,
    required this.participantFill,
    required this.border,
    required this.borderSoft,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.orange,
    required this.orangeText,
    required this.green,
    required this.greenText,
    required this.red,
  });

  final Color background;
  final Color participantFill;
  final Color border;
  final Color borderSoft;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color orange;
  final Color orangeText;
  final Color green;
  final Color greenText;
  final Color red;
}

@immutable
class TripDetailsColorTokens {
  const TripDetailsColorTokens({
    required this.background,
    required this.summaryFill,
    required this.participantFill,
    required this.splitFill,
    required this.border,
    required this.borderSoft,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.orange,
    required this.orangeText,
    required this.green,
    required this.greenText,
    required this.red,
  });

  final Color background;
  final Color summaryFill;
  final Color participantFill;
  final Color splitFill;
  final Color border;
  final Color borderSoft;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color orange;
  final Color orangeText;
  final Color green;
  final Color greenText;
  final Color red;
}

@immutable
class ExpenseDetailsColorTokens {
  const ExpenseDetailsColorTokens({
    required this.background,
    required this.segmentFill,
    required this.portionFill,
    required this.border,
    required this.borderSoft,
    required this.textPrimary,
    required this.textMuted,
    required this.orange,
    required this.orangeText,
    required this.saveText,
    required this.green,
    required this.red,
    required this.currentUserAvatar,
  });

  final Color background;
  final Color segmentFill;
  final Color portionFill;
  final Color border;
  final Color borderSoft;
  final Color textPrimary;
  final Color textMuted;
  final Color orange;
  final Color orangeText;
  final Color saveText;
  final Color green;
  final Color red;
  final Color currentUserAvatar;
}

@immutable
class ProfileColorTokens {
  const ProfileColorTokens({
    required this.background,
    required this.buttonFill,
    required this.tagFill,
    required this.switchTrack,
    required this.cardBorder,
    required this.textPrimary,
    required this.textMuted,
    required this.orange,
    required this.orangeText,
    required this.red,
  });

  final Color background;
  final Color buttonFill;
  final Color tagFill;
  final Color switchTrack;
  final Color cardBorder;
  final Color textPrimary;
  final Color textMuted;
  final Color orange;
  final Color orangeText;
  final Color red;
}

@immutable
class FinalSettleColorTokens {
  const FinalSettleColorTokens({
    required this.background,
    required this.borderSoft,
    required this.borderStrong,
    required this.buttonDisabledFill,
    required this.buttonDisabledText,
    required this.buttonText,
    required this.cardBorder,
    required this.cardDivider,
    required this.clearedFill,
    required this.clearedText,
    required this.creditFill,
    required this.creditText,
    required this.debtFill,
    required this.debtText,
    required this.decorativeStroke,
    required this.decorativeStrokeSoft,
    required this.optimizationFill,
    required this.orange,
    required this.orangeDark,
    required this.orangeText,
    required this.readyFill,
    required this.readyText,
    required this.textMuted,
    required this.textPrimary,
    required this.textSecondary,
    required this.headerBackground,
    required this.textureLine,
    required this.textureDot,
  });

  final Color background;
  final Color borderSoft;
  final Color borderStrong;
  final Color buttonDisabledFill;
  final Color buttonDisabledText;
  final Color buttonText;
  final Color cardBorder;
  final Color cardDivider;
  final Color clearedFill;
  final Color clearedText;
  final Color creditFill;
  final Color creditText;
  final Color debtFill;
  final Color debtText;
  final Color decorativeStroke;
  final Color decorativeStrokeSoft;
  final Color optimizationFill;
  final Color orange;
  final Color orangeDark;
  final Color orangeText;
  final Color readyFill;
  final Color readyText;
  final Color textMuted;
  final Color textPrimary;
  final Color textSecondary;
  final Color headerBackground;
  final Color textureLine;
  final Color textureDot;
}

class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.shared,
    required this.splash,
    required this.auth,
    required this.calculator,
    required this.createTrip,
    required this.createExpense,
    required this.dashboard,
    required this.tripDetails,
    required this.expenseDetails,
    required this.profile,
    required this.finalSettle,
  });

  final SharedColorTokens shared;
  final SplashColorTokens splash;
  final AuthColorTokens auth;
  final CalculatorColorTokens calculator;
  final CreateTripColorTokens createTrip;
  final CreateExpenseColorTokens createExpense;
  final DashboardColorTokens dashboard;
  final TripDetailsColorTokens tripDetails;
  final ExpenseDetailsColorTokens expenseDetails;
  final ProfileColorTokens profile;
  final FinalSettleColorTokens finalSettle;

  static const AppColors light = AppColors(
    shared: SharedColorTokens(
      cardBackground: Color(0xFFFFFFFF),
      navBackground: Color(0xFFFFFFFF),
      transparent: Color(0x00000000),
      white: Color(0xFFFFFFFF),
      shadowFaint: Color(0x08000000),
      shadowSoft: Color(0x0A000000),
      shadowSubtle: Color(0x0C000000),
      shadowStrong: Color(0x19000000),
      overlayWhite08: Color(0x14FFFFFF),
      overlayWhite12: Color(0x1FFFFFFF),
      avatarGradientTop: Color(0xFFF6D4C0),
      avatarGradientBottom: Color(0xFFB77C5C),
      fadeGradientStart: Color(0x66A58C7F),
      fadeGradientEnd: Color(0x00A58C7F),
      participantAvatarBlue: Color(0xFFDCE2F8),
      participantAvatarSand: Color(0xFFE8E4DE),
      participantAvatarSlate: Color(0xFFC9D0E4),
      participantAvatarGreen: Color(0xFFD5E5D4),
      participantAvatarWarm: Color(0xFFFFDBC9),
      participantAvatarNeutral: Color(0xFFE2E3DF),
      participantAvatarLilac: Color(0xFFE3D9F4),
      currentUserAvatar: Color(0xFFFFC9AE),
    ),
    splash: SplashColorTokens(
      background: Color(0xFFFDFCF0),
      title: Color(0xFF131407),
      subtitle: Color(0xCC584235),
      buttonFill: Color(0xFFFF7A00),
      texture: Color(0xFFE5DBC1),
    ),
    auth: AuthColorTokens(
      background: Color(0xFFFDFCF9),
      buttonFill: Color(0xFFFF8A3D),
      buttonDisabledFill: Color(0xFFE7DED8),
      buttonDisabledText: Color(0xFF8A7B72),
      cardBorder: Color(0x7FD8C2B9),
      dividerSoft: Color(0x4CD8C2B9),
      error: Color(0xFFBA1A1A),
      fieldBorder: Color(0x99D8C2B9),
      fieldFill: Color(0xFFF7F3F0),
      footerBorder: Color(0x33D8C2B9),
      footerFill: Color(0xFFF7F3F0),
      footerText: Color(0xFF85736B),
      orangeDark: Color(0xFF9A4600),
      textMuted: Color(0xFF53433C),
      textPlaceholder: Color(0x9953433C),
      textPrimary: Color(0xFF1A1C1A),
      socialButtonBorder: Color(0x66D8C2B9),
      socialButtonText: Color(0xFF1A1C1A),
    ),
    calculator: CalculatorColorTokens(
      background: Color(0xFFFDFAF6),
      displayFill: Color(0xFFFDF1E8),
      borderSoft: Color(0xFFD9C4B8),
      separator: Color(0xFFA58C7F),
      textPrimary: Color(0xFF151B2B),
      textMuted: Color(0xFF564338),
      displayText: Color(0xFF9A4600),
      orange: Color(0xFFFF8A3D),
      orangeText: Color(0xFF682D00),
      red: Color(0xFFBA1A1A),
    ),
    createTrip: CreateTripColorTokens(
      background: Color(0xFFFDFCFB),
      textPrimary: Color(0xFF151B2B),
      textSecondary: Color(0xFF564338),
      textMuted: Color(0xFF404758),
      textPlaceholder: Color(0x7F564338),
      orange: Color(0xFFFF8A3D),
      orangeText: Color(0xFF682D00),
      darkButton: Color(0xFF151B2B),
      fieldFill: Color(0xFFF8F6F2),
      cardBorder: Color(0xFFD8CFC4),
      separator: Color(0xFFA58C7F),
      avatarBlue: Color(0xFFC0C6DB),
      avatarBlueText: Color(0xFF293041),
      avatarGreen: Color(0xFF4DE082),
      avatarGreenText: Color(0xFF003919),
      avatarSoft: Color(0xFFDCE2F8),
    ),
    createExpense: CreateExpenseColorTokens(
      background: Color(0xFFFCF8F5),
      summaryFill: Color(0xFFF8F2EC),
      segmentFill: Color(0xFFF0EBE6),
      cardBorder: Color(0xFFE7E0DB),
      inputBorder: Color(0xFFD5C2B6),
      dashedBorder: Color(0xFFD5C2B6),
      textPrimary: Color(0xFF151B2B),
      textSecondary: Color(0xFF404758),
      textMuted: Color(0xFF53433A),
      placeholder: Color(0xFF6B7280),
      orange: Color(0xFFFF8A3D),
      orangeText: Color(0xFF321200),
      saveText: Color(0xFF9A4600),
      green: Color(0xFF22C268),
    ),
    dashboard: DashboardColorTokens(
      background: Color(0xFFFDFAF6),
      participantFill: Color(0xFFE8E4DE),
      border: Color(0xFF564338),
      borderSoft: Color(0xFFA58C7F),
      textPrimary: Color(0xFF151B2B),
      textSecondary: Color(0xFF404758),
      textMuted: Color(0xFF564338),
      orange: Color(0xFFFF8A3D),
      orangeText: Color(0xFF682D00),
      green: Color(0xFF22C268),
      greenText: Color(0xFF004922),
      red: Color(0xFFBA1A1A),
    ),
    tripDetails: TripDetailsColorTokens(
      background: Color(0xFFFDFAF6),
      summaryFill: Color(0xFFF4F1EC),
      participantFill: Color(0xFFE8E4DE),
      splitFill: Color(0xFFE0E2EC),
      border: Color(0xFF564338),
      borderSoft: Color(0xFFA58C7F),
      textPrimary: Color(0xFF151B2B),
      textSecondary: Color(0xFF404758),
      textMuted: Color(0xFF564338),
      orange: Color(0xFFFF8A3D),
      orangeText: Color(0xFF682D00),
      green: Color(0xFF22C268),
      greenText: Color(0xFF004922),
      red: Color(0xFFBA1A1A),
    ),
    expenseDetails: ExpenseDetailsColorTokens(
      background: Color(0xFFF8F6F1),
      segmentFill: Color(0xFFEEEEEC),
      portionFill: Color(0xFFF0F1ED),
      border: Color(0xFFD5C3B9),
      borderSoft: Color(0xFFA58C7F),
      textPrimary: Color(0xFF151B2B),
      textMuted: Color(0xFF564338),
      orange: Color(0xFFFF8A3D),
      orangeText: Color(0xFF682D00),
      saveText: Color(0xFF9A4600),
      green: Color(0xFF006D36),
      red: Color(0xFFBA1A1A),
      currentUserAvatar: Color(0xFFFFC9AE),
    ),
    profile: ProfileColorTokens(
      background: Color(0xFFFDFAF6),
      buttonFill: Color(0xFF151B2B),
      tagFill: Color(0xFFF1EFE9),
      switchTrack: Color(0xFFE8E1DA),
      cardBorder: Color(0xFFDDC1B3),
      textPrimary: Color(0xFF151B2B),
      textMuted: Color(0xFF564338),
      orange: Color(0xFFFF8A3D),
      orangeText: Color(0xFF532200),
      red: Color(0xFFBA1A1A),
    ),
    finalSettle: FinalSettleColorTokens(
      background: Color(0xFFF9F7F3),
      borderSoft: Color(0xFFA58C7F),
      borderStrong: Color(0xFF564338),
      buttonDisabledFill: Color(0xFFE4DDD7),
      buttonDisabledText: Color(0xFF84766E),
      buttonText: Color(0xFF321200),
      cardBorder: Color(0xFFD8C2B7),
      cardDivider: Color(0xFFD8CFC7),
      clearedFill: Color(0xFFE6F4EA),
      clearedText: Color(0xFF0F5223),
      creditFill: Color(0xFF4DE082),
      creditText: Color(0xFF00210C),
      debtFill: Color(0xFFFFDAD6),
      debtText: Color(0xFFBA1A1A),
      decorativeStroke: Color(0xFFF2EFEB),
      decorativeStrokeSoft: Color(0xFFF5F2EE),
      optimizationFill: Color(0xFFE8E9E6),
      orange: Color(0xFFFF8A3D),
      orangeDark: Color(0xFF9A4600),
      orangeText: Color(0xFF682D00),
      readyFill: Color(0xFF4DE082),
      readyText: Color(0xFF00210C),
      textMuted: Color(0xFF564338),
      textPrimary: Color(0xFF1E201E),
      textSecondary: Color(0xFF404758),
      headerBackground: Color(0xD6FFFFFF),
      textureLine: Color(0xFFD8CFC7),
      textureDot: Color(0xFFA58C7F),
    ),
  );

  static const AppColors dark = AppColors(
    shared: SharedColorTokens(
      cardBackground: Color(0xFF1E201E),
      navBackground: Color(0xFF1E201E),
      transparent: Color(0x00000000),
      white: Color(0xFFFFFFFF),
      shadowFaint: Color(0x14000000),
      shadowSoft: Color(0x1A000000),
      shadowSubtle: Color(0x24000000),
      shadowStrong: Color(0x33000000),
      overlayWhite08: Color(0x14FFFFFF),
      overlayWhite12: Color(0x1FFFFFFF),
      avatarGradientTop: Color(0xFFF6D4C0),
      avatarGradientBottom: Color(0xFFB77C5C),
      fadeGradientStart: Color(0x66564338),
      fadeGradientEnd: Color(0x00564338),
      participantAvatarBlue: Color(0xFF2B3139),
      participantAvatarSand: Color(0xFF2A2623),
      participantAvatarSlate: Color(0xFF30353D),
      participantAvatarGreen: Color(0xFF1D2B22),
      participantAvatarWarm: Color(0xFF3B2C25),
      participantAvatarNeutral: Color(0xFF2A2C2A),
      participantAvatarLilac: Color(0xFF312B38),
      currentUserAvatar: Color(0xFFFFC9AE),
    ),
    splash: SplashColorTokens(
      background: Color(0xFF121412),
      title: Color(0xFFE2E3DF),
      subtitle: Color(0xFFDDC1B3),
      buttonFill: Color(0xFFFF8A3D),
      texture: Color(0xFF564338),
    ),
    auth: AuthColorTokens(
      background: Color(0xFF121412),
      buttonFill: Color(0xFFFF8A3D),
      buttonDisabledFill: Color(0xFF1E201E),
      buttonDisabledText: Color(0xFF6B7280),
      cardBorder: Color(0xFF333533),
      dividerSoft: Color(0xFF564338),
      error: Color(0xFFBA1A1A),
      fieldBorder: Color(0xFF564338),
      fieldFill: Color(0xFF0D0F0D),
      footerBorder: Color(0xFF333533),
      footerFill: Color(0xFF1E201E),
      footerText: Color(0xFFDDC1B3),
      orangeDark: Color(0xFFFFB68D),
      textMuted: Color(0xFFDDC1B3),
      textPlaceholder: Color(0xFF6B7280),
      textPrimary: Color(0xFFE2E3DF),
      socialButtonBorder: Color(0xFF333533),
      socialButtonText: Color(0xFFE2E3DF),
    ),
    calculator: CalculatorColorTokens(
      background: Color(0xFF121412),
      displayFill: Color(0xFF0D0F0D),
      borderSoft: Color(0xFF333533),
      separator: Color(0xFF564338),
      textPrimary: Color(0xFFE2E3DF),
      textMuted: Color(0xFFDDC1B3),
      displayText: Color(0xFFFFB68D),
      orange: Color(0xFFFF8A3D),
      orangeText: Color(0xFF682D00),
      red: Color(0xFFBA1A1A),
    ),
    createTrip: CreateTripColorTokens(
      background: Color(0xFF121412),
      textPrimary: Color(0xFFE2E3DF),
      textSecondary: Color(0xFFDDC1B3),
      textMuted: Color(0xFFDDC1B3),
      textPlaceholder: Color(0xFF6B7280),
      orange: Color(0xFFFF8A3D),
      orangeText: Color(0xFF682D00),
      darkButton: Color(0xFF1E201E),
      fieldFill: Color(0xFF0D0F0D),
      cardBorder: Color(0xFF333533),
      separator: Color(0xFF564338),
      avatarBlue: Color(0xFF2B3139),
      avatarBlueText: Color(0xFFE2E3DF),
      avatarGreen: Color(0xFF4DE082),
      avatarGreenText: Color(0xFF00210C),
      avatarSoft: Color(0xFF2F343D),
    ),
    createExpense: CreateExpenseColorTokens(
      background: Color(0xFF121412),
      summaryFill: Color(0xFF1E201E),
      segmentFill: Color(0xFF1E201E),
      cardBorder: Color(0xFF333533),
      inputBorder: Color(0xFF564338),
      dashedBorder: Color(0xFF564338),
      textPrimary: Color(0xFFE2E3DF),
      textSecondary: Color(0xFFDDC1B3),
      textMuted: Color(0xFFDDC1B3),
      placeholder: Color(0xFF6B7280),
      orange: Color(0xFFFF8A3D),
      orangeText: Color(0xFF682D00),
      saveText: Color(0xFFFFB68D),
      green: Color(0xFF4DE082),
    ),
    dashboard: DashboardColorTokens(
      background: Color(0xFF121412),
      participantFill: Color(0xFF0D0F0D),
      border: Color(0xFF333533),
      borderSoft: Color(0xFF564338),
      textPrimary: Color(0xFFE2E3DF),
      textSecondary: Color(0xFFDDC1B3),
      textMuted: Color(0xFFDDC1B3),
      orange: Color(0xFFFF8A3D),
      orangeText: Color(0xFF682D00),
      green: Color(0xFF4DE082),
      greenText: Color(0xFF00210C),
      red: Color(0xFFBA1A1A),
    ),
    tripDetails: TripDetailsColorTokens(
      background: Color(0xFF121412),
      summaryFill: Color(0xFF1E201E),
      participantFill: Color(0xFF0D0F0D),
      splitFill: Color(0xFF0D0F0D),
      border: Color(0xFF333533),
      borderSoft: Color(0xFF564338),
      textPrimary: Color(0xFFE2E3DF),
      textSecondary: Color(0xFFDDC1B3),
      textMuted: Color(0xFFDDC1B3),
      orange: Color(0xFFFF8A3D),
      orangeText: Color(0xFF682D00),
      green: Color(0xFF4DE082),
      greenText: Color(0xFF00210C),
      red: Color(0xFFBA1A1A),
    ),
    expenseDetails: ExpenseDetailsColorTokens(
      background: Color(0xFF121412),
      segmentFill: Color(0xFF1E201E),
      portionFill: Color(0xFF1E201E),
      border: Color(0xFF333533),
      borderSoft: Color(0xFF564338),
      textPrimary: Color(0xFFE2E3DF),
      textMuted: Color(0xFFDDC1B3),
      orange: Color(0xFFFF8A3D),
      orangeText: Color(0xFF682D00),
      saveText: Color(0xFFFFB68D),
      green: Color(0xFF4DE082),
      red: Color(0xFFBA1A1A),
      currentUserAvatar: Color(0xFFFFC9AE),
    ),
    profile: ProfileColorTokens(
      background: Color(0xFF121412),
      buttonFill: Color(0xFF1E201E),
      tagFill: Color(0xFF0D0F0D),
      switchTrack: Color(0xFF0D0F0D),
      cardBorder: Color(0xFF333533),
      textPrimary: Color(0xFFE2E3DF),
      textMuted: Color(0xFFDDC1B3),
      orange: Color(0xFFFF8A3D),
      orangeText: Color(0xFF682D00),
      red: Color(0xFFBA1A1A),
    ),
    finalSettle: FinalSettleColorTokens(
      background: Color(0xFF121412),
      borderSoft: Color(0xFF564338),
      borderStrong: Color(0xFF564338),
      buttonDisabledFill: Color(0xFF1E201E),
      buttonDisabledText: Color(0xFF6B7280),
      buttonText: Color(0xFF321200),
      cardBorder: Color(0xFF333533),
      cardDivider: Color(0xFF564338),
      clearedFill: Color(0xFF1E201E),
      clearedText: Color(0xFF4DE082),
      creditFill: Color(0xFF4DE082),
      creditText: Color(0xFF00210C),
      debtFill: Color(0xFF3B1F1F),
      debtText: Color(0xFFBA1A1A),
      decorativeStroke: Color(0xFF1E201E),
      decorativeStrokeSoft: Color(0xFF1E201E),
      optimizationFill: Color(0xFF0D0F0D),
      orange: Color(0xFFFF8A3D),
      orangeDark: Color(0xFFFFB68D),
      orangeText: Color(0xFF682D00),
      readyFill: Color(0xFF4DE082),
      readyText: Color(0xFF00210C),
      textMuted: Color(0xFFDDC1B3),
      textPrimary: Color(0xFFE2E3DF),
      textSecondary: Color(0xFFDDC1B3),
      headerBackground: Color(0xD61E201E),
      textureLine: Color(0xFF564338),
      textureDot: Color(0xFF564338),
    ),
  );

  @override
  AppColors copyWith() => this;

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) {
      return this;
    }

    return t < 0.5 ? this : other;
  }
}
