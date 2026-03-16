import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AETheme {
  // ── Colors ────────────────────────────────────────────────
  static const Color bg       = Color(0xFFF7F5EF);
  static const Color bg2      = Color(0xFFEFECE3);
  static const Color bg3      = Color(0xFFE6E2D5);
  static const Color white    = Color(0xFFFFFFFF);
  static const Color ink      = Color(0xFF07091F);
  static const Color ink2     = Color(0xFF10163A);
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

  // ── Gradients ─────────────────────────────────────────────
  static const LinearGradient indigoGradient = LinearGradient(
    begin: Alignment.topLeft, end: Alignment.bottomRight,
    colors: [indigo2, violet],
  );
  static const LinearGradient darkGradient = LinearGradient(
    begin: Alignment.topLeft, end: Alignment.bottomRight,
    colors: [ink, ink2],
  );
  static const LinearGradient greenGradient = LinearGradient(
    begin: Alignment.topLeft, end: Alignment.bottomRight,
    colors: [green, green2],
  );
  static const LinearGradient amberGradient = LinearGradient(
    begin: Alignment.topLeft, end: Alignment.bottomRight,
    colors: [amber, amber2],
  );
  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft, end: Alignment.bottomRight,
    colors: [ink, ink2, Color(0xFF1E1B4B), indigo],
  );

  // ── Typography ────────────────────────────────────────────
  static TextStyle fraunces({
    double size = 16, FontWeight weight = FontWeight.w900,
    Color color = ink, double? letterSpacing, double? height, bool italic = false,
  }) => GoogleFonts.playfairDisplay(
    fontSize: size, fontWeight: weight, color: color,
    letterSpacing: letterSpacing, height: height,
    fontStyle: italic ? FontStyle.italic : FontStyle.normal,
  );

  static TextStyle syne({
    double size = 14, FontWeight weight = FontWeight.w700,
    Color color = ink, double? letterSpacing,
  }) => GoogleFonts.syne(
    fontSize: size, fontWeight: weight, color: color, letterSpacing: letterSpacing,
  );

  // ── Theme ─────────────────────────────────────────────────
  static ThemeData get theme => ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: bg,
    colorScheme: const ColorScheme.light(
      primary: indigo2, secondary: violet, surface: white, error: red,
    ),
    textTheme: GoogleFonts.syneTextTheme(),
    appBarTheme: AppBarTheme(
      backgroundColor: white, foregroundColor: ink, elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
    ),
    cardTheme: const CardThemeData(elevation: 0, color: white),
  );
}

// ── Shared Card Widget ────────────────────────────────────
class AECard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final VoidCallback? onTap;
  final Color? color;
  final double radius;

  const AECard({
    super.key, required this.child, this.padding,
    this.onTap, this.color, this.radius = 16,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color ?? AETheme.white,
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(color: const Color(0x0F070921)),
          boxShadow: const [
            BoxShadow(color: Color(0x06070921), blurRadius: 8, offset: Offset(0, 2)),
            BoxShadow(color: Color(0x05070921), blurRadius: 20, offset: Offset(0, 6)),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: padding != null ? Padding(padding: padding!, child: child) : child,
        ),
      ),
    );
  }
}

// ── Stat Card ─────────────────────────────────────────────
class StatCard extends StatelessWidget {
  final String label, value, sub, icon;
  final Color valueColor, subColor, subBg, accentColor;

  const StatCard({
    super.key, required this.label, required this.value,
    required this.valueColor, required this.sub,
    required this.subColor, required this.subBg,
    required this.icon, required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AETheme.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x0F070921)),
        boxShadow: const [
          BoxShadow(color: Color(0x07070921), blurRadius: 12, offset: Offset(0, 3)),
        ],
      ),
      child: Stack(children: [
        // Accent top bar
        Positioned(top: 0, left: 0, right: 0,
          child: Container(
            height: 3,
            decoration: BoxDecoration(
              color: accentColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(label.toUpperCase(),
                  style: AETheme.syne(size: 8, color: AETheme.muted,
                      weight: FontWeight.w800, letterSpacing: 1.5)),
                Text(icon, style: const TextStyle(fontSize: 16,
                    color: Color(0x20070921))),
              ]),
              const SizedBox(height: 8),
              Text(value,
                style: AETheme.fraunces(size: 22, color: valueColor, letterSpacing: -0.5),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: subBg, borderRadius: BorderRadius.circular(6)),
                child: Text(sub,
                  style: AETheme.syne(size: 9, color: subColor, weight: FontWeight.w700),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ]),
    );
  }
}

// ── Gradient Button ───────────────────────────────────────
class GradBtn extends StatelessWidget {
  final String label;
  final LinearGradient gradient;
  final VoidCallback? onTap;
  final bool loading;
  final double height;

  const GradBtn({
    super.key, required this.label, required this.gradient,
    this.onTap, this.loading = false, this.height = 52,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: onTap != null ? gradient : null,
        color: onTap == null ? AETheme.faint : null,
        borderRadius: BorderRadius.circular(14),
        boxShadow: onTap != null ? [
          BoxShadow(color: gradient.colors.first.withValues(alpha: 0.4),
              blurRadius: 16, offset: const Offset(0, 6)),
        ] : [],
      ),
      child: Center(
        child: loading
            ? const SizedBox(width: 20, height: 20,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : Text(label,
                style: AETheme.syne(size: 15, color: Colors.white, weight: FontWeight.w800)),
      ),
    ),
  );
}
