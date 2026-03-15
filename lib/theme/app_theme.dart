import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AETheme {
  // ── Color Palette (from CSS :root) ──────────────────────────
  static const Color bg       = Color(0xFFF7F5EF);
  static const Color bg2      = Color(0xFFEFECE3);
  static const Color bg3      = Color(0xFFE6E2D5);
  static const Color white    = Color(0xFFFFFFFF);
  static const Color ink      = Color(0xFF07091F);
  static const Color ink2     = Color(0xFF10163A);
  static const Color ink3     = Color(0xFF1C2348);
  static const Color slate    = Color(0xFF3A4165);
  static const Color muted    = Color(0xFF7880A0);
  static const Color faint    = Color(0xFFB8BECE);

  static const Color indigo   = Color(0xFF3730A3);
  static const Color indigo2  = Color(0xFF4F46E5);
  static const Color indigo3  = Color(0xFF818CF8);
  static const Color violet   = Color(0xFF6D28D9);
  static const Color violet2  = Color(0xFF8B5CF6);
  static const Color red      = Color(0xFFDC2626);
  static const Color red2     = Color(0xFFEF4444);
  static const Color green    = Color(0xFF047857);
  static const Color green2   = Color(0xFF10B981);
  static const Color amber    = Color(0xFFB45309);
  static const Color amber2   = Color(0xFFF59E0B);
  static const Color sky      = Color(0xFF0369A1);
  static const Color sky2     = Color(0xFF38BDF8);
  static const Color pink     = Color(0xFFBE185D);

  // Asset colors
  static const Color cryptoColor      = Color(0xFFF0A500);
  static const Color equitiesColor    = Color(0xFF818CF8);
  static const Color forexColor       = Color(0xFF22C55E);
  static const Color commoditiesColor = Color(0xFF38BDF8);
  static const Color otherColor       = Color(0xFFF472B6);

  // ── Gradients ──────────────────────────────────────────────
  static const LinearGradient indigoGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [indigo2, violet],
  );

  static const LinearGradient darkGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [ink, ink2],
  );

  static const LinearGradient greenGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [green, green2],
  );

  static const LinearGradient amberGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [amber, amber2],
  );

  // ── Typography ─────────────────────────────────────────────
  static TextStyle fraunces({
    double size = 16,
    FontWeight weight = FontWeight.w900,
    Color color = ink,
    double? letterSpacing,
    double? height,
    bool italic = false,
  }) =>
      GoogleFonts.playfairDisplay(
        fontSize: size,
        fontWeight: weight,
        color: color,
        letterSpacing: letterSpacing,
        height: height,
        fontStyle: italic ? FontStyle.italic : FontStyle.normal,
      );

  static TextStyle syne({
    double size = 14,
    FontWeight weight = FontWeight.w700,
    Color color = ink,
    double? letterSpacing,
  }) =>
      GoogleFonts.syne(
        fontSize: size,
        fontWeight: weight,
        color: color,
        letterSpacing: letterSpacing,
      );

  // ── Theme Data ─────────────────────────────────────────────
  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: bg,
        colorScheme: const ColorScheme.light(
          primary: indigo2,
          secondary: violet,
          surface: white,
          error: red,
        ),
        textTheme: GoogleFonts.syneTextTheme(),
        appBarTheme: AppBarTheme(
          backgroundColor: white,
          foregroundColor: ink,
          elevation: 0,
          titleTextStyle: GoogleFonts.playfairDisplay(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: ink,
          ),
        ),
      );
}

// ── Shared Decoration Helpers ──────────────────────────────
class AECard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final VoidCallback? onTap;
  final Color? color;
  final double radius;

  const AECard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.color,
    this.radius = 14,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color ?? AETheme.white,
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(color: const Color(0x12070921), width: 1),
          boxShadow: const [
            BoxShadow(
              color: Color(0x08070921),
              blurRadius: 4,
              offset: Offset(0, 1),
            ),
            BoxShadow(
              color: Color(0x07070921),
              blurRadius: 16,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: padding != null
              ? Padding(padding: padding!, child: child)
              : child,
        ),
      ),
    );
  }
}

class AEBadge extends StatelessWidget {
  final String text;
  final Color color;
  final Color bg;

  const AEBadge({
    super.key,
    required this.text,
    required this.color,
    required this.bg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        text,
        style: AETheme.syne(size: 9, weight: FontWeight.w800, color: color),
      ),
    );
  }
}
