import 'dart:async';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const TruckJobsApp());
}

PageRouteBuilder<T> premiumPageRoute<T>(Widget page) {
  return PageRouteBuilder<T>(
    transitionDuration: const Duration(milliseconds: 360),
    reverseTransitionDuration: const Duration(milliseconds: 260),
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curvedAnimation = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );

      return FadeTransition(
        opacity: curvedAnimation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.05, 0.04),
            end: Offset.zero,
          ).animate(curvedAnimation),
          child: ScaleTransition(
            scale: Tween<double>(
              begin: 0.97,
              end: 1,
            ).animate(curvedAnimation),
            child: child,
          ),
        ),
      );
    },
  );
}

Future<T?> showPremiumDialog<T>({
  required BuildContext context,
  required Widget child,
  bool barrierDismissible = true,
}) {
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierLabel: 'Close',
    barrierColor: Colors.black.withValues(alpha: 0.45),
    transitionDuration: const Duration(milliseconds: 260),
    pageBuilder: (context, animation, secondaryAnimation) {
      return Center(child: child);
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final curvedAnimation = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutBack,
        reverseCurve: Curves.easeInCubic,
      );

      return FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: Tween<double>(
            begin: 0.92,
            end: 1,
          ).animate(curvedAnimation),
          child: child,
        ),
      );
    },
  );
}

class PremiumTap extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final BorderRadius borderRadius;

  const PremiumTap({
    super.key,
    required this.child,
    required this.onTap,
    this.borderRadius = const BorderRadius.all(Radius.circular(18)),
  });

  @override
  State<PremiumTap> createState() => _PremiumTapState();
}

class _PremiumTapState extends State<PremiumTap> {
  bool isPressed = false;
  bool isHovered = false;

  void setPressed(bool value) {
    if (widget.onTap == null) {
      return;
    }

    setState(() {
      isPressed = value;
    });
  }

  void setHovered(bool value) {
    if (widget.onTap == null) {
      return;
    }

    setState(() {
      isHovered = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final double scale = isPressed
        ? 0.965
        : isHovered
            ? 1.012
            : 1;

    return MouseRegion(
      cursor: widget.onTap == null
          ? SystemMouseCursors.basic
          : SystemMouseCursors.click,
      onEnter: (_) => setHovered(true),
      onExit: (_) {
        setHovered(false);
        setPressed(false);
      },
      child: Listener(
        onPointerDown: (_) => setPressed(true),
        onPointerUp: (_) => setPressed(false),
        onPointerCancel: (_) => setPressed(false),
        child: AnimatedScale(
          scale: scale,
          duration: const Duration(milliseconds: 140),
          curve: Curves.easeOutCubic,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              borderRadius: widget.borderRadius,
              boxShadow: isPressed
                  ? const []
                  : [
                      BoxShadow(
                        color: isHovered
                            ? const Color(0x33000000)
                            : const Color(0x1F000000),
                        blurRadius: isHovered ? 18 : 10,
                        offset: Offset(0, isHovered ? 9 : 5),
                      ),
                    ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: widget.borderRadius,
                splashColor: const Color(0xFFFF7A00).withValues(alpha: 0.10),
                highlightColor: const Color(0xFFFF7A00).withValues(alpha: 0.06),
                onTap: widget.onTap,
                child: widget.child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class TruckJobsApp extends StatelessWidget {
  const TruckJobsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TruckJobs AU',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFF7A00),
          primary: const Color(0xFFFF7A00),
          secondary: const Color(0xFF111827),
          surface: Colors.white,
        ),
        scaffoldBackgroundColor: const Color(0xFFF3F4F6),
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF111827),
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 0,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF111827),
          contentTextStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
          actionTextColor: const Color(0xFFFFA726),
          elevation: 10,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          insetPadding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
        ),
        dialogTheme: DialogThemeData(
          backgroundColor: Colors.white,
          elevation: 18,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 2,
          shadowColor: Colors.black26,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            minimumSize: WidgetStateProperty.all(
              const Size(44, 46),
            ),
            backgroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.disabled)) {
                return const Color(0xFFFFB86B);
              }

              if (states.contains(WidgetState.pressed)) {
                return const Color(0xFFE86F00);
              }

              if (states.contains(WidgetState.hovered)) {
                return const Color(0xFFFF8A1F);
              }

              return const Color(0xFFFF7A00);
            }),
            foregroundColor: WidgetStateProperty.all(Colors.white),
            elevation: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.pressed)) {
                return 1;
              }

              if (states.contains(WidgetState.disabled)) {
                return 0;
              }

              if (states.contains(WidgetState.hovered)) {
                return 10;
              }

              return 6;
            }),
            shadowColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.hovered)) {
                return const Color(0x88FF7A00);
              }

              return const Color(0x55FF7A00);
            }),
            overlayColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.pressed)) {
                return Colors.black.withValues(alpha: 0.10);
              }

              if (states.contains(WidgetState.hovered)) {
                return Colors.white.withValues(alpha: 0.16);
              }

              return Colors.white.withValues(alpha: 0.10);
            }),
            animationDuration: const Duration(milliseconds: 180),
            padding: WidgetStateProperty.all(
              const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            ),
            shape: WidgetStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            textStyle: WidgetStateProperty.all(
              const TextStyle(
                fontWeight: FontWeight.w900,
                letterSpacing: 0.1,
              ),
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: ButtonStyle(
            minimumSize: WidgetStateProperty.all(
              const Size(44, 46),
            ),
            foregroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.pressed) ||
                  states.contains(WidgetState.hovered)) {
                return const Color(0xFFFF7A00);
              }

              return const Color(0xFF111827);
            }),
            side: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.pressed) ||
                  states.contains(WidgetState.hovered)) {
                return const BorderSide(
                  color: Color(0xFFFF7A00),
                  width: 1.6,
                );
              }

              return const BorderSide(
                color: Color(0xFF111827),
                width: 1.2,
              );
            }),
            backgroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.pressed)) {
                return const Color(0xFFFFF7ED);
              }

              if (states.contains(WidgetState.hovered)) {
                return const Color(0xFFFFFBF7);
              }

              return Colors.transparent;
            }),
            overlayColor: WidgetStateProperty.all(
              const Color(0xFFFF7A00).withValues(alpha: 0.08),
            ),
            animationDuration: const Duration(milliseconds: 180),
            padding: WidgetStateProperty.all(
              const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            ),
            shape: WidgetStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            textStyle: WidgetStateProperty.all(
              const TextStyle(
                fontWeight: FontWeight.w900,
                letterSpacing: 0.1,
              ),
            ),
          ),
        ),
        pageTransitionsTheme: PageTransitionsTheme(
          builders: {
            TargetPlatform.android: ZoomPageTransitionsBuilder(),
            TargetPlatform.iOS: ZoomPageTransitionsBuilder(),
            TargetPlatform.windows: ZoomPageTransitionsBuilder(),
            TargetPlatform.macOS: ZoomPageTransitionsBuilder(),
            TargetPlatform.linux: ZoomPageTransitionsBuilder(),
          },
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: Color(0xFFFF7A00),
              width: 2,
            ),
          ),
        ),
      ),
      home: const MainScreen(),
    );
  }
}


class AnimatedEntrance extends StatelessWidget {
  final Widget child;
  final int index;

  const AnimatedEntrance({
    super.key,
    required this.child,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final delay = Duration(milliseconds: (index.clamp(0, 5)) * 30);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 360 + delay.inMilliseconds),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        final safeValue = value.clamp(0.0, 1.0);

        return Opacity(
          opacity: safeValue,
          child: Transform.translate(
            offset: Offset(0, 18 * (1 - safeValue)),
            child: Transform.scale(
              scale: 0.985 + (0.015 * safeValue),
              child: child,
            ),
          ),
        );
      },
      child: child,
    );
  }
}

void showPremiumMessage(
  BuildContext context,
  String message, {
  IconData icon = Icons.check_circle,
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          Icon(
            icon,
            color: const Color(0xFFFFA726),
            size: 22,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(message),
          ),
        ],
      ),
    ),
  );
}

class Job {
  final String id;
  final String status;
  final String title;
  final String company;
  final String location;
  final String licence;
  final String pay;
  final String type;
  final String contact;
  final String description;
  final String paymentTerms;
  final bool isUrgent;
  final int views;
  final int callClicks;
  final int whatsappClicks;
  final DateTime? createdAt;
  final DateTime? filledAt;
  final DateTime? expiresAt;

  const Job({
    this.id = '',
    this.status = 'pending',
    required this.title,
    required this.company,
    required this.location,
    required this.licence,
    required this.pay,
    required this.type,
    required this.contact,
    required this.description,
    required this.paymentTerms,
    required this.isUrgent,
    this.views = 0,
    this.callClicks = 0,
    this.whatsappClicks = 0,
    this.createdAt,
    this.filledAt,
    this.expiresAt,
  });

  factory Job.fromFirestore(String id, Map<String, dynamic> data) {
    DateTime? createdAtDate;

    final createdAtValue = data['createdAt'];
    if (createdAtValue is Timestamp) {
      createdAtDate = createdAtValue.toDate();
    }

    DateTime? filledAtDate;

    final filledAtValue = data['filledAt'];
    if (filledAtValue is Timestamp) {
      filledAtDate = filledAtValue.toDate();
    }

    DateTime? expiresAtDate;

    final expiresAtValue = data['expiresAt'];
    if (expiresAtValue is Timestamp) {
      expiresAtDate = expiresAtValue.toDate();
    }

    return Job(
      id: id,
      title: data['title'] ?? '',
      company: data['company'] ?? '',
      location: data['location'] ?? '',
      licence: data['licence'] ?? '',
      pay: data['pay'] ?? 'Pay not listed',
      type: data['type'] ?? '',
      contact: data['contact'] ?? '',
      description: data['description'] ?? 'No description added.',
      paymentTerms: data['paymentTerms'] ?? 'Payment terms not listed.',
      isUrgent: data['isUrgent'] ?? false,
      views: data['views'] ?? 0,
      callClicks: data['callClicks'] ?? 0,
      whatsappClicks: data['whatsappClicks'] ?? 0,
      status: data['status'] ?? 'pending',
      createdAt: createdAtDate,
      filledAt: filledAtDate,
      expiresAt: expiresAtDate,
    );
  }
}

String formatPostedDate(DateTime? date) {
  if (date == null) {
    return 'Posted recently';
  }

  final months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  return 'Posted: ${date.day} ${months[date.month - 1]} ${date.year}';
}

String formatFilledDate(DateTime? date) {
  if (date == null) {
    return 'Filled recently';
  }

  final months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  return 'Filled on: ${date.day} ${months[date.month - 1]} ${date.year}';
}

String formatExpiryDate(DateTime? date) {
  if (date == null) {
    return 'Expires: not set';
  }

  final months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  return 'Expires: ${date.day} ${months[date.month - 1]} ${date.year}';
}

String formatExpiredDate(DateTime? date) {
  if (date == null) {
    return 'Expired';
  }

  final months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  return 'Expired on: ${date.day} ${months[date.month - 1]} ${date.year}';
}

DateTime expiryFromNow() {
  return DateTime.now().add(const Duration(days: 15));
}

bool isJobExpired(Job job) {
  final expiryDate = job.expiresAt;

  if (expiryDate == null) {
    return false;
  }

  return expiryDate.isBefore(DateTime.now());
}

int jobDaysLeft(Job job) {
  final expiryDate = job.expiresAt;

  if (expiryDate == null) {
    return 15;
  }

  final daysLeft = expiryDate.difference(DateTime.now()).inDays + 1;

  if (daysLeft < 0) {
    return 0;
  }

  return daysLeft;
}

String formatDaysLeft(Job job) {
  final daysLeft = jobDaysLeft(job);

  if (daysLeft <= 0) {
    return 'Expires today';
  }

  if (daysLeft == 1) {
    return '1 day left';
  }

  return '$daysLeft days left';
}

String normaliseForDuplicateCheck(String value) {
  return value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
}

String onlyDigits(String value) {
  return value.replaceAll(RegExp(r'[^0-9]'), '');
}

InputDecoration premiumInputDecoration(String label, IconData icon) {
  return InputDecoration(
    labelText: label,
    prefixIcon: Icon(icon, color: const Color(0xFFFF7A00)),
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: Color(0xFFFF7A00), width: 2),
    ),
    labelStyle: const TextStyle(
      color: Color(0xFF64748B),
      fontWeight: FontWeight.w500,
    ),
  );
}

Future<void> trackJobClick(String jobId, String fieldName) async {
  if (jobId.isEmpty) {
    return;
  }

  await FirebaseFirestore.instance.collection('jobs').doc(jobId).update({
    fieldName: FieldValue.increment(1),
  });
}

Future<String?> chooseReportReason(BuildContext context) async {
  final reasons = [
    {
      'title': 'Underpaid job',
      'subtitle': 'Pay rate looks too low or unfair',
      'icon': Icons.payments,
    },
    {
      'title': 'Fake or scam job',
      'subtitle': 'Job looks suspicious or not genuine',
      'icon': Icons.warning_amber,
    },
    {
      'title': 'Employer asked for bank details / OTP',
      'subtitle': 'Unsafe request for private information',
      'icon': Icons.lock,
    },
    {
      'title': 'Company does not pay drivers on time',
      'subtitle': 'Late payment or unpaid driver complaint',
      'icon': Icons.schedule,
    },
    {
      'title': 'Misleading job details',
      'subtitle': 'Job information does not match reality',
      'icon': Icons.description,
    },
    {
      'title': 'Wrong contact details',
      'subtitle': 'Phone number or contact information is wrong',
      'icon': Icons.phone_disabled,
    },
    {
      'title': 'Unsafe work request',
      'subtitle': 'Work looks unsafe, illegal or risky',
      'icon': Icons.health_and_safety,
    },
    {
      'title': 'Other issue',
      'subtitle': 'Something else needs admin review',
      'icon': Icons.more_horiz,
    },
  ];

  return showPremiumDialog<String>(
    context: context,
    child: Dialog(
        insetPadding: const EdgeInsets.all(18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(26),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Color(0xFF111827),
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(26),
                  ),
                ),
                child: const Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Color(0xFFFFE8D6),
                      child: Icon(
                        Icons.report,
                        color: Colors.red,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Report Job',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Help keep TruckJobs AU safe for drivers.',
                            style: TextStyle(
                              color: Color(0xFFE5E7EB),
                              height: 1.35,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        margin: const EdgeInsets.only(bottom: 14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF7ED),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: const Color(0xFFFFD7A8),
                          ),
                        ),
                        child: const Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.privacy_tip,
                              color: Color(0xFFFF7A00),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Choose the closest reason. Admin will review this job and remove unsafe or misleading posts.',
                                style: TextStyle(
                                  color: Color(0xFF92400E),
                                  height: 1.35,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      for (final reason in reasons)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(18),
                            onTap: () {
                              Navigator.pop(
                                context,
                                reason['title'] as String,
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: const Color(0xFFE5E7EB),
                                ),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 6,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    height: 44,
                                    width: 44,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFF1F2),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Icon(
                                      reason['icon'] as IconData,
                                      color: Colors.red,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          reason['title'] as String,
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w900,
                                            color: Color(0xFF111827),
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          reason['subtitle'] as String,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF64748B),
                                            fontWeight: FontWeight.w600,
                                            height: 1.3,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(
                                    Icons.chevron_right,
                                    color: Color(0xFF94A3B8),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.close),
                    label: const Text('Cancel'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
  );
}


class _HeroBadge extends StatelessWidget {
  final IconData icon;
  final String label;

  const _HeroBadge({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.24),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: const Color(0xFFFFA726),
            size: 15,
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}


class FrontHeroCarousel extends StatefulWidget {
  const FrontHeroCarousel({super.key});

  @override
  State<FrontHeroCarousel> createState() => _FrontHeroCarouselState();
}

class _FrontHeroCarouselState extends State<FrontHeroCarousel> {
  int currentHeroIndex = 0;
  Timer? heroTimer;

  final List<String> heroImages = const [
    'assets/images/truckbanner.jpg',
    'assets/images/truckbanner2.jpg',
  ];

  @override
  void initState() {
    super.initState();

    heroTimer = Timer.periodic(const Duration(seconds: 6), (timer) {
      if (!mounted || heroImages.length < 2) {
        return;
      }

      setState(() {
        currentHeroIndex = (currentHeroIndex + 1) % heroImages.length;
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    for (final imagePath in heroImages) {
      precacheImage(AssetImage(imagePath), context);
    }
  }

  @override
  void dispose() {
    heroTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        height: 260,
        margin: const EdgeInsets.only(bottom: 18),
        decoration: BoxDecoration(
          color: const Color(0xFF111827),
          borderRadius: BorderRadius.circular(28),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 18,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Stack(
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 700),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                child: Image.asset(
                  heroImages[currentHeroIndex],
                  key: ValueKey<String>(heroImages[currentHeroIndex]),
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  cacheWidth: 1400,
                  filterQuality: FilterQuality.medium,
                  gaplessPlayback: true,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      key: ValueKey<String>('error_$currentHeroIndex'),
                      color: const Color(0xFF111827),
                      alignment: Alignment.center,
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'IMAGE NOT FOUND: ${heroImages[currentHeroIndex]}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    );
                  },
                ),
              ),

              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withValues(alpha: 0.78),
                      Colors.black.withValues(alpha: 0.48),
                      Colors.black.withValues(alpha: 0.18),
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
              ),

              Positioned(
                left: 18,
                right: 18,
                top: 18,
                bottom: 18,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: const [
                        _HeroBadge(
                          icon: Icons.verified,
                          label: 'Admin Reviewed Jobs',
                        ),
                        _HeroBadge(
                          icon: Icons.local_shipping,
                          label: 'Australia Wide',
                        ),
                      ],
                    ),

                    const Spacer(),

                    const Text(
                      'Find Trucking Jobs Across Australia',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        height: 1.05,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      'MR, HR, HC, MC and owner driver jobs with clear pay and safer job reporting.',
                      style: TextStyle(
                        color: Color(0xFFE5E7EB),
                        fontSize: 14,
                        height: 1.35,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 14),

                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 9,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF7A00),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x55FF7A00),
                                blurRadius: 12,
                                offset: Offset(0, 5),
                              ),
                            ],
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.search,
                                color: Colors.white,
                                size: 18,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Browse Live Jobs',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const Spacer(),

                        Row(
                          children: [
                            for (int index = 0; index < heroImages.length; index++)
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                margin: const EdgeInsets.only(left: 5),
                                height: 8,
                                width: currentHeroIndex == index ? 22 : 8,
                                decoration: BoxDecoration(
                                  color: currentHeroIndex == index
                                      ? const Color(0xFFFF7A00)
                                      : Colors.white.withValues(alpha: 0.65),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int selectedIndex = 0;

  final List<Job> jobs = [];

  void addJob(Job job) {
    setState(() {
      selectedIndex = 0;
    });
  }

  Future<bool> saveJob(Job job) async {
    final savedJobId = job.id.isNotEmpty
        ? job.id
        : '${job.title}_${job.company}_${job.contact}'.replaceAll(' ', '_');

    final savedJobRef =
        FirebaseFirestore.instance.collection('savedJobs').doc(savedJobId);

    final existingSavedJob = await savedJobRef.get();

    if (existingSavedJob.exists) {
      return false;
    }

    await savedJobRef.set({
      'jobId': job.id,
      'title': job.title,
      'company': job.company,
      'location': job.location,
      'licence': job.licence,
      'pay': job.pay,
      'type': job.type,
      'contact': job.contact,
      'contactDigits': onlyDigits(job.contact),
      'description': job.description,
      'paymentTerms': job.paymentTerms,
      'isUrgent': job.isUrgent,
      'views': job.views,
      'callClicks': job.callClicks,
      'whatsappClicks': job.whatsappClicks,
      'status': job.status,
      if (job.filledAt != null) 'filledAt': Timestamp.fromDate(job.filledAt!),
      if (job.expiresAt != null) 'expiresAt': Timestamp.fromDate(job.expiresAt!),
      'createdAt': job.createdAt == null
          ? FieldValue.serverTimestamp()
          : Timestamp.fromDate(job.createdAt!),
      'savedAt': FieldValue.serverTimestamp(),
    });

    return true;
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      JobsPage(jobs: jobs, onSaveJob: saveJob),
      PostJobPage(onJobSubmit: addJob),
      const SavedJobsPage(),
      const AdminPinPage(),
      const ProfilePage(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('TruckJobs AU'),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 280),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.03, 0.02),
                end: Offset.zero,
              ).animate(animation),
              child: ScaleTransition(
                scale: Tween<double>(
                  begin: 0.985,
                  end: 1,
                ).animate(animation),
                child: child,
              ),
            ),
          );
        },
        child: KeyedSubtree(
          key: ValueKey<int>(selectedIndex),
          child: pages[selectedIndex],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 18,
              offset: Offset(0, -6),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: selectedIndex,
          selectedItemColor: const Color(0xFFFF7A00),
          unselectedItemColor: Colors.grey,
          backgroundColor: Colors.white,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w900,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w700,
          ),
          onTap: (index) {
            if (index == selectedIndex) {
              return;
            }

            setState(() {
              selectedIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.work), label: 'Jobs'),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_circle),
              label: 'Post Job',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.bookmark), label: 'Saved'),
            BottomNavigationBarItem(
              icon: Icon(Icons.admin_panel_settings),
              label: 'Admin',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}

class JobsPage extends StatefulWidget {
  final List<Job> jobs;
  final Future<bool> Function(Job) onSaveJob;

  const JobsPage({
    super.key,
    required this.jobs,
    required this.onSaveJob,
  });

  @override
  State<JobsPage> createState() => _JobsPageState();
}

class _JobsPageState extends State<JobsPage> {
  String searchText = '';
  String selectedLicence = 'All';
  String selectedLocation = 'All';

  Future<void> callEmployer(String phoneNumber) async {
    final Uri phoneUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );

    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }

  Future<void> whatsappEmployer(Job job) async {
    final cleanNumber = job.contact.replaceAll(' ', '');

    final ausNumber = cleanNumber.startsWith('0')
        ? '61${cleanNumber.substring(1)}'
        : cleanNumber;

    final message =
        'Hi, I am interested in the job: ${job.title} at ${job.company}. Is this job still available?';

    final Uri whatsappUri = Uri.parse(
      'https://wa.me/$ausNumber?text=${Uri.encodeComponent(message)}',
    );

    if (await canLaunchUrl(whatsappUri)) {
      await launchUrl(
        whatsappUri,
        mode: LaunchMode.externalApplication,
      );
    }
  }

  Future<void> reportJob(
    Job job,
    BuildContext context, {
    required String reason,
  }) async {
    await FirebaseFirestore.instance.collection('reports').add({
      'jobId': job.id,
      'jobTitle': job.title,
      'company': job.company,
      'contact': job.contact,
      'reason': reason,
      'createdAt': FieldValue.serverTimestamp(),
    });

    if (!mounted) {
      return;
    }

    showPremiumMessage(
      context,
      'Job reported. Thank you.',
      icon: Icons.report,
    );
  }

  Widget heroBanner() {
    return const FrontHeroCarousel();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('jobs')
          .where('status', isEqualTo: 'approved')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(
            child: Text('Something went wrong loading jobs'),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final firebaseJobs = snapshot.data!.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return Job.fromFirestore(doc.id, data);
        }).toList();

        firebaseJobs.sort((a, b) {
          if (a.isUrgent != b.isUrgent) {
            return a.isUrgent ? -1 : 1;
          }

          final aDate = a.createdAt ?? DateTime(2000);
          final bDate = b.createdAt ?? DateTime(2000);
          return bDate.compareTo(aDate);
        });

        final activeJobs = firebaseJobs.where((job) {
          return !isJobExpired(job);
        }).toList();

        final featuredJobs = activeJobs.where((job) {
          return job.isUrgent;
        }).take(6).toList();

        final filteredJobs = activeJobs.where((job) {
          final searchLower = searchText.toLowerCase();

          final matchesSearch = job.title.toLowerCase().contains(searchLower) ||
              job.company.toLowerCase().contains(searchLower) ||
              job.location.toLowerCase().contains(searchLower) ||
              job.licence.toLowerCase().contains(searchLower);

          final matchesLicence =
              selectedLicence == 'All' || job.licence.contains(selectedLicence);

          final matchesLocation = selectedLocation == 'All' ||
              job.location.toLowerCase().contains(
                    selectedLocation.toLowerCase(),
                  );

          return matchesSearch && matchesLicence && matchesLocation;
        }).toList();

        return ListView(
          padding: const EdgeInsets.all(16),
          addAutomaticKeepAlives: true,
          addRepaintBoundaries: true,
          children: [
            heroBanner(),

            if (featuredJobs.isNotEmpty) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Featured Jobs',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF111827),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF1F2),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: const Color(0xFFFECACA),
                      ),
                    ),
                    child: Text(
                      '${featuredJobs.length} live',
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (int index = 0;
                        index < featuredJobs.length;
                        index++) ...[
                      featuredJobCard(
                        context,
                        featuredJobs[index],
                      ),
                      if (index != featuredJobs.length - 1)
                        const SizedBox(width: 12),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 22),
            ],

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Browse by Licence',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF111827),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      selectedLicence = 'All';
                      selectedLocation = 'All';
                    });
                  },
                  child: const Text(
                    'View all',
                    style: TextStyle(
                      color: Color(0xFFFF7A00),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                licenceQuickCard(
                  licence: 'MR',
                  count: licenceJobCount(activeJobs, 'MR'),
                  icon: Icons.local_shipping_outlined,
                ),
                const SizedBox(width: 8),
                licenceQuickCard(
                  licence: 'HR',
                  count: licenceJobCount(activeJobs, 'HR'),
                  icon: Icons.fire_truck_outlined,
                ),
                const SizedBox(width: 8),
                licenceQuickCard(
                  licence: 'HC',
                  count: licenceJobCount(activeJobs, 'HC'),
                  icon: Icons.airport_shuttle_outlined,
                ),
                const SizedBox(width: 8),
                licenceQuickCard(
                  licence: 'MC',
                  count: licenceJobCount(activeJobs, 'MC'),
                  icon: Icons.route_outlined,
                ),
              ],
            ),

            const SizedBox(height: 22),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Popular Locations',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF111827),
                  ),
                ),
                if (selectedLocation != 'All')
                  TextButton(
                    onPressed: () {
                      setState(() {
                        selectedLocation = 'All';
                      });
                    },
                    child: const Text(
                      'Clear',
                      style: TextStyle(
                        color: Color(0xFFFF7A00),
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 10),

            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  locationQuickCard(
                    city: 'Melbourne',
                    count: locationJobCount(activeJobs, 'Melbourne'),
                    icon: Icons.location_city,
                  ),
                  const SizedBox(width: 10),
                  locationQuickCard(
                    city: 'Sydney',
                    count: locationJobCount(activeJobs, 'Sydney'),
                    icon: Icons.apartment,
                  ),
                  const SizedBox(width: 10),
                  locationQuickCard(
                    city: 'Brisbane',
                    count: locationJobCount(activeJobs, 'Brisbane'),
                    icon: Icons.sunny,
                  ),
                  const SizedBox(width: 10),
                  locationQuickCard(
                    city: 'Perth',
                    count: locationJobCount(activeJobs, 'Perth'),
                    icon: Icons.explore,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            TextField(
              onChanged: (value) {
                setState(() {
                  searchText = value;
                });
              },
              decoration: premiumInputDecoration(
                'Search by city, licence or job title',
                Icons.search,
              ),
            ),

            const SizedBox(height: 16),

            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  filterChip('All'),
                  filterChip('MR'),
                  filterChip('HR'),
                  filterChip('HC'),
                  filterChip('MC'),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Latest Jobs',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text('${filteredJobs.length} found'),
              ],
            ),

            const SizedBox(height: 10),

            if (filteredJobs.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 40),
                child: Center(
                  child: Text(
                    'No jobs found',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ),
              ),

            for (int index = 0; index < filteredJobs.length; index++)
              RepaintBoundary(
                child: AnimatedEntrance(
                  index: index,
                  child: jobCard(context, filteredJobs[index]),
                ),
              ),
          ],
        );
      },
    );
  }


  int licenceJobCount(List<Job> jobs, String licence) {
    return jobs.where((job) => job.licence.contains(licence)).length;
  }

  Widget licenceQuickCard({
    required String licence,
    required int count,
    required IconData icon,
  }) {
    final bool isSelected = selectedLicence == licence;

    return Expanded(
      child: PremiumTap(
        onTap: () {
          setState(() {
            selectedLicence = licence;
          });
        },
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 14,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFFFF7A00)
                : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFFFF7A00)
                  : const Color(0xFFE5E7EB),
            ),
            boxShadow: [
              BoxShadow(
                color: isSelected
                    ? const Color(0x44FF7A00)
                    : Colors.black.withValues(alpha: 0.06),
                blurRadius: isSelected ? 14 : 8,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                height: 42,
                width: 42,
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.18)
                      : const Color(0xFFFFF7ED),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  color: isSelected
                      ? Colors.white
                      : const Color(0xFFFF7A00),
                  size: 23,
                ),
              ),
              const SizedBox(height: 9),
              Text(
                licence,
                style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : const Color(0xFF111827),
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                '$count jobs',
                style: TextStyle(
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.88)
                      : const Color(0xFF64748B),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  int locationJobCount(List<Job> jobs, String city) {
    return jobs.where((job) {
      return job.location.toLowerCase().contains(city.toLowerCase());
    }).length;
  }

  Widget locationQuickCard({
    required String city,
    required int count,
    required IconData icon,
  }) {
    final bool isSelected = selectedLocation == city;

    return SizedBox(
      width: 150,
      child: PremiumTap(
        onTap: () {
          setState(() {
            selectedLocation = isSelected ? 'All' : city;
          });
        },
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF111827)
                : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF111827)
                  : const Color(0xFFE5E7EB),
            ),
            boxShadow: [
              BoxShadow(
                color: isSelected
                    ? const Color(0x33111827)
                    : Colors.black.withValues(alpha: 0.06),
                blurRadius: isSelected ? 14 : 8,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                height: 42,
                width: 42,
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFFFF7A00)
                      : const Color(0xFFFFF7ED),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  color: isSelected
                      ? Colors.white
                      : const Color(0xFFFF7A00),
                  size: 22,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      city,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFF111827),
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '$count jobs',
                      style: TextStyle(
                        color: isSelected
                            ? const Color(0xFFCBD5E1)
                            : const Color(0xFF64748B),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget featuredJobCard(BuildContext context, Job job) {
    Future<void> openFeaturedJob() async {
      await trackJobClick(job.id, 'views');

      if (!mounted) {
        return;
      }

      Navigator.push(
        context,
        premiumPageRoute(
          JobDetailsPage(
            job: job,
            onSaveJob: () async {
              final wasSaved = await widget.onSaveJob(job);

              if (!mounted) {
                return;
              }

              showPremiumMessage(
                context,
                wasSaved ? 'Job saved' : 'Already saved',
                icon: wasSaved ? Icons.bookmark_added : Icons.bookmark,
              );
            },
            onCallEmployer: () async {
              await trackJobClick(job.id, 'callClicks');
              await callEmployer(job.contact);
            },
            onWhatsappEmployer: () async {
              await trackJobClick(job.id, 'whatsappClicks');
              await whatsappEmployer(job);
            },
            onReportJob: () async {
              final reason = await chooseReportReason(context);

              if (reason != null) {
                await reportJob(
                  job,
                  context,
                  reason: reason,
                );
              }
            },
          ),
        ),
      );
    }

    return SizedBox(
      width: 290,
      child: PremiumTap(
        onTap: openFeaturedJob,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF111827),
                Color(0xFF1F2937),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: const Color(0x33FF7A00),
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x22111827),
                blurRadius: 14,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF7A00),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.flash_on,
                          size: 14,
                          color: Colors.white,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'FEATURED',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Text(
                    formatDaysLeft(job),
                    style: const TextStyle(
                      color: Color(0xFFCBD5E1),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                job.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  height: 1.15,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                job.company,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFFE5E7EB),
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  const Icon(
                    Icons.location_on,
                    color: Color(0xFFFFA726),
                    size: 17,
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      job.location,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFFCBD5E1),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        job.licence,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF7A00),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        job.pay,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget filterChip(String text) {
    final bool isSelected = selectedLicence == text;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(text),
        selected: isSelected,
        selectedColor: const Color(0xFFFF7A00),
        backgroundColor: Colors.white,
        side: BorderSide(
          color: isSelected ? const Color(0xFFFF7A00) : Colors.grey.shade300,
        ),
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : const Color(0xFF111827),
          fontWeight: FontWeight.bold,
        ),
        onSelected: (selected) {
          setState(() {
            selectedLicence = text;
          });
        },
      ),
    );
  }

  Widget jobCard(BuildContext context, Job job) {
    Future<void> openDetails() async {
      await trackJobClick(job.id, 'views');

      Navigator.push(
        context,
        premiumPageRoute(
          JobDetailsPage(
            job: job,
            onSaveJob: () async {
              final wasSaved = await widget.onSaveJob(job);

              showPremiumMessage(
                context,
                wasSaved ? 'Job saved' : 'Already saved',
                icon: wasSaved ? Icons.bookmark_added : Icons.bookmark,
              );
            },
            onCallEmployer: () async {
              await trackJobClick(job.id, 'callClicks');
              await callEmployer(job.contact);
            },
            onWhatsappEmployer: () async {
              await trackJobClick(job.id, 'whatsappClicks');
              await whatsappEmployer(job);
            },
            onReportJob: () async {
              final reason = await chooseReportReason(context);

              if (reason != null) {
                await reportJob(
                  job,
                  context,
                  reason: reason,
                );
              }
            },
          ),
        ),
      );
    }

    return PremiumTap(
      onTap: openDetails,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: job.isUrgent
            ? Border.all(
                color: Colors.red,
                width: 1.4,
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: job.isUrgent
                ? Colors.red.withValues(alpha: 0.18)
                : Colors.black.withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 54,
                  width: 54,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFFF7A00),
                        Color(0xFFFFA726),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.local_shipping,
                    color: Colors.white,
                    size: 30,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        job.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        job.company,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Row(
                        children: [
                          Icon(
                            Icons.verified,
                            size: 15,
                            color: Color(0xFFFF7A00),
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Verified Employer',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFFFF7A00),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        formatPostedDate(job.createdAt),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF7ED),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFFFFD7A8),
                          ),
                        ),
                        child: Text(
                          formatDaysLeft(job),
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFFFF7A00),
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                if (job.isUrgent)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.flash_on,
                          size: 14,
                          color: Colors.red,
                        ),
                        SizedBox(width: 3),
                        Text(
                          'FEATURED',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 14),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 18,
                        color: Color(0xFFFF7A00),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          job.location,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  Row(
                    children: [
                      Expanded(
                        child: infoPill(
                          Icons.badge,
                          job.licence,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: infoPill(
                          Icons.work,
                          job.type,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  Row(
                    children: [
                      Expanded(
                        child: infoPill(
                          Icons.payments,
                          job.pay,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: infoPill(
                          Icons.phone_locked,
                          'Contact in details',
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  infoPill(
                    Icons.event_note,
                    job.paymentTerms,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final wasSaved = await widget.onSaveJob(job);

                      showPremiumMessage(
                        context,
                        wasSaved ? 'Job saved' : 'Already saved',
                        icon: wasSaved ? Icons.bookmark_added : Icons.bookmark,
                      );
                    },
                    icon: const Icon(Icons.bookmark_border),
                    label: const Text('Save'),
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: openDetails,
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text('View Details'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      ),
    );
  }

  Widget infoPill(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 9,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: const Color(0xFFFF7A00),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF111827),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void showJobDetails(BuildContext context, Job job) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: ListView(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      job.title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (job.isUrgent)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'URGENT',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 10),

              Text(job.company),

              const SizedBox(height: 8),

              Text(
                formatPostedDate(job.createdAt),
                style: const TextStyle(color: Colors.grey),
              ),

              const SizedBox(height: 16),

              detailRow(Icons.location_on, 'Location', job.location),
              detailRow(Icons.badge, 'Licence', job.licence),
              detailRow(Icons.payments, 'Pay', job.pay),
              detailRow(Icons.work, 'Job Type', job.type),
              detailRow(Icons.phone, 'Contact', job.contact),

              const SizedBox(height: 16),

              const Text(
                'Job Description',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 6),

              Text(job.description),

              const SizedBox(height: 20),

              ElevatedButton.icon(
                onPressed: () {
                  callEmployer(job.contact);
                },
                icon: const Icon(Icons.phone),
                label: const Text('Call Employer'),
              ),

              const SizedBox(height: 10),

              ElevatedButton.icon(
                onPressed: () {
                  whatsappEmployer(job);
                },
                icon: const Icon(Icons.chat),
                label: const Text('Apply on WhatsApp'),
              ),

              const SizedBox(height: 10),

              OutlinedButton.icon(
                onPressed: () {
                  widget.onSaveJob(job);
                  Navigator.pop(context);

                  showPremiumMessage(
  context,
  'Job saved',
  icon: Icons.bookmark_added,
);
                },
                icon: const Icon(Icons.bookmark),
                label: const Text('Save Job'),
              ),

              const SizedBox(height: 10),

              OutlinedButton.icon(
                onPressed: () {
                  
                  reportJob(
                    job,
                    context,
                    reason: 'Other issue',
                  );
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.report),
                label: const Text('Report Job'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFFF7A00)),
          const SizedBox(width: 10),
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

class JobDetailsPage extends StatelessWidget {
  final Job job;
  final Future<void> Function() onSaveJob;
  final Future<void> Function() onCallEmployer;
  final Future<void> Function() onWhatsappEmployer;
  final Future<void> Function() onReportJob;

  const JobDetailsPage({
    super.key,
    required this.job,
    required this.onSaveJob,
    required this.onCallEmployer,
    required this.onWhatsappEmployer,
    required this.onReportJob,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Job Details'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFF111827),
              borderRadius: BorderRadius.circular(24),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 12,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (job.isUrgent)
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'URGENT HIRING',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),

                Text(
                  job.title,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  job.company,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFFE5E7EB),
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  formatPostedDate(job.createdAt),
                  style: const TextStyle(
                    color: Color(0xFFCBD5E1),
                  ),
                ),

                const SizedBox(height: 10),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF7A00),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    formatDaysLeft(job),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7ED),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: const Color(0xFFFFD7A8),
              ),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 46,
                  width: 46,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFE8D6),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Icon(
                    Icons.verified_user,
                    color: Color(0xFFFF7A00),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Verified Employer',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        'This job has been reviewed by TruckJobs AU admin before appearing live.',
                        style: TextStyle(
                          color: Color(0xFF92400E),
                          height: 1.35,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        formatPostedDate(job.createdAt),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: const Color(0xFFBBF7D0),
              ),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.price_check,
                  color: Colors.green,
                  size: 28,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Check the pay before accepting. Avoid underpaid work and always confirm rate, hours, overtime, fuel/tolls and payment terms before starting.',
                    style: TextStyle(
                      color: Color(0xFF166534),
                      height: 1.4,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF1F2),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: const Color(0xFFFECACA),
              ),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.security,
                  color: Colors.red,
                  size: 28,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Driver Safety Reminder',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF991B1B),
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Do not accept underpaid work. Never pay money to get a job. Do not share bank details, OTP, passwords, licence photos or personal documents unless you are fully confident the employer is genuine.',
                        style: TextStyle(
                          color: Color(0xFF7F1D1D),
                          height: 1.4,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          detailsTile(Icons.location_on, 'Location', job.location),
          detailsTile(Icons.event_available, 'Job Expiry', formatDaysLeft(job)),
          detailsTile(Icons.badge, 'Licence Needed', job.licence),
          detailsTile(Icons.payments, 'Pay / Rate', job.pay),
          detailsTile(Icons.event_note, 'Payment Terms', job.paymentTerms),
          detailsTile(Icons.work, 'Job Type', job.type),
          detailsTile(Icons.phone, 'Contact', job.contact),

          const SizedBox(height: 10),

          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Job Description',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  job.description,
                  style: const TextStyle(
                    height: 1.45,
                    color: Color(0xFF475569),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          SizedBox(
            height: 54,
            child: ElevatedButton.icon(
              onPressed: () async {
                await onCallEmployer();
              },
              icon: const Icon(Icons.phone),
              label: const Text('Call Employer'),
            ),
          ),

          const SizedBox(height: 10),

          SizedBox(
            height: 54,
            child: ElevatedButton.icon(
              onPressed: () async {
                await onWhatsappEmployer();
              },
              icon: const Icon(Icons.chat),
              label: const Text('Apply on WhatsApp'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
            ),
          ),

          const SizedBox(height: 10),

          SizedBox(
            height: 54,
            child: OutlinedButton.icon(
              onPressed: () async {
                await onSaveJob();
              },
              icon: const Icon(Icons.bookmark),
              label: const Text('Save Job'),
            ),
          ),

          const SizedBox(height: 10),

          SizedBox(
            height: 54,
            child: OutlinedButton.icon(
              onPressed: () async {
                await onReportJob();
              },
              icon: const Icon(Icons.report),
              label: const Text('Report Job'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget detailsTile(IconData icon, String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 9,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFFFE8D6),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: const Color(0xFFFF7A00),
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF111827),
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
class PostJobPage extends StatefulWidget {
  final Function(Job) onJobSubmit;

  const PostJobPage({super.key, required this.onJobSubmit});

  @override
  State<PostJobPage> createState() => _PostJobPageState();
}

class _PostJobPageState extends State<PostJobPage> {
  final titleController = TextEditingController();
  final companyController = TextEditingController();
  final cityController = TextEditingController();
  final payController = TextEditingController();
  final contactController = TextEditingController();
  final descriptionController = TextEditingController();
  final paymentTermsController = TextEditingController();

  String selectedLicence = 'MR';
  String selectedState = 'VIC';
  String selectedJobType = 'Full Time';
  bool isUrgent = false;
  bool isSubmitting = false;
  bool agreedToSafetyRules = false;

  final List<String> licences = ['MR', 'HR', 'HC', 'MC'];

  final List<String> states = [
    'VIC',
    'NSW',
    'QLD',
    'SA',
    'WA',
    'TAS',
    'NT',
    'ACT',
  ];

  final List<String> jobTypes = [
    'Full Time',
    'Part Time',
    'Casual',
    'ABN',
    'Owner Driver',
  ];

  @override
  void dispose() {
    titleController.dispose();
    companyController.dispose();
    cityController.dispose();
    payController.dispose();
    contactController.dispose();
    descriptionController.dispose();
    paymentTermsController.dispose();
    super.dispose();
  }

  Future<void> submitJob() async {
    if (isSubmitting) {
      return;
    }

    final title = titleController.text.trim();
    final company = companyController.text.trim();
    final city = cityController.text.trim();
    final contact = contactController.text.trim();
    final pay = payController.text.trim();
    final description = descriptionController.text.trim();
    final paymentTerms = paymentTermsController.text.trim();
    final phoneDigits = onlyDigits(contact);

    if (title.length < 4) {
      showPremiumMessage(
  context,
  'Job title is too short',
  icon: Icons.edit,
);
      return;
    }

    if (company.length < 2) {
      showPremiumMessage(
  context,
  'Please enter a valid company name',
  icon: Icons.business,
);
      return;
    }

    if (city.length < 2) {
      showPremiumMessage(
  context,
  'Please enter a valid city',
  icon: Icons.location_city,
);
      return;
    }

    if (phoneDigits.length < 8) {
      showPremiumMessage(
  context,
  'Please enter a valid phone number',
  icon: Icons.phone,
);
      return;
    }

    if (pay.length < 2) {
      showPremiumMessage(
        context,
        'Please enter a clear pay rate',
        icon: Icons.payments,
      );
      return;
    }

    final lowerPay = pay.toLowerCase();
    final hasPayRedFlag =
        lowerPay.contains('commission only') ||
            lowerPay.contains('free trial') ||
            lowerPay.contains('experience only') ||
            lowerPay.contains('unpaid') ||
            lowerPay.contains('no pay');

    if (hasPayRedFlag) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This pay wording is not allowed. Please add a fair clear rate.'),
        ),
      );
      return;
    }

    if (description.isNotEmpty && description.length < 15) {
      showPremiumMessage(
  context,
  'Job description is too short. Add duties and payment terms.',
  icon: Icons.description,
);
      return;
    }

    if (paymentTerms.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add clear payment terms e.g. paid weekly'),
        ),
      );
      return;
    }

    if (!agreedToSafetyRules) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please agree to the safety and fair pay rules first'),
        ),
      );
      return;
    }

    setState(() {
      isSubmitting = true;
    });

    try {
      final duplicateSnapshot = await FirebaseFirestore.instance
          .collection('jobs')
          .where('contactDigits', isEqualTo: phoneDigits)
          .limit(20)
          .get();

    final normalisedTitle = normaliseForDuplicateCheck(title);
    final normalisedCompany = normaliseForDuplicateCheck(company);
    final normalisedLocation = normaliseForDuplicateCheck('$city, $selectedState');

    final duplicateExists = duplicateSnapshot.docs.any((doc) {
      final data = doc.data();

      final existingStatus = (data['status'] ?? '').toString();

      if (existingStatus == 'rejected' || existingStatus == 'filled') {
        return false;
      }

      final existingTitle = normaliseForDuplicateCheck(
        (data['title'] ?? '').toString(),
      );
      final existingCompany = normaliseForDuplicateCheck(
        (data['company'] ?? '').toString(),
      );
      final existingLocation = normaliseForDuplicateCheck(
        (data['location'] ?? '').toString(),
      );

      return existingTitle == normalisedTitle &&
          existingCompany == normalisedCompany &&
          existingLocation == normalisedLocation;
    });

      if (duplicateExists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('This job already exists. Please edit the existing job or contact admin.'),
          ),
        );
        return;
      }

      final newJob = Job(
      title: title,
      company: company,
      location: '$city, $selectedState',
      licence: selectedLicence,
      pay: pay,
      type: selectedJobType,
      contact: contact,
      description: description.isEmpty
          ? 'No description added.'
          : description,
      paymentTerms: paymentTerms,
      isUrgent: isUrgent,
    );

    await FirebaseFirestore.instance.collection('jobs').add({
      'title': newJob.title,
      'company': newJob.company,
      'location': newJob.location,
      'licence': newJob.licence,
      'pay': newJob.pay,
      'type': newJob.type,
      'contact': newJob.contact,
      'contactDigits': phoneDigits,
      'description': newJob.description,
      'paymentTerms': newJob.paymentTerms,
      'isUrgent': newJob.isUrgent,
      'views': 0,
      'callClicks': 0,
      'whatsappClicks': 0,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });

    widget.onJobSubmit(newJob);

    titleController.clear();
    companyController.clear();
    cityController.clear();
    payController.clear();
    contactController.clear();
    descriptionController.clear();
    paymentTermsController.clear();

    setState(() {
      selectedLicence = 'MR';
      selectedState = 'VIC';
      selectedJobType = 'Full Time';
      isUrgent = false;
      agreedToSafetyRules = false;
    });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Job submitted. Waiting for admin approval.'),
        ),
      );
    } catch (error) {
      showPremiumMessage(
        context,
        'Something went wrong: $error',
        icon: Icons.error,
      );
    } finally {
      if (mounted) {
        setState(() {
          isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFF111827),
            borderRadius: BorderRadius.circular(22),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 12,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.add_business,
                color: Color(0xFFFFA726),
                size: 34,
              ),
              SizedBox(height: 12),
              Text(
                'Post a Trucking Job',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 6),
              Text(
                'Add job details below. Admin approval is required before the job appears live.',
                style: TextStyle(
                  color: Color(0xFFE5E7EB),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        inputField('Job title *', Icons.work, titleController),
        inputField('Company name *', Icons.business, companyController),
        inputField(
          'City e.g. Melbourne *',
          Icons.location_city,
          cityController,
        ),

        dropdownField(
          label: 'State',
          icon: Icons.map,
          value: selectedState,
          items: states,
          onChanged: (value) {
            setState(() {
              selectedState = value!;
            });
          },
        ),

        dropdownField(
          label: 'Licence needed',
          icon: Icons.badge,
          value: selectedLicence,
          items: licences,
          onChanged: (value) {
            setState(() {
              selectedLicence = value!;
            });
          },
        ),

        inputField(
          'Pay rate * e.g. \$45/hr or \$550/day',
          Icons.payments,
          payController,
        ),

        Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF0FDF4),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: const Color(0xFFBBF7D0),
            ),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.payments,
                color: Colors.green,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Fair pay matters. Pay rate is required. Underpaid jobs may be rejected by TruckJobs AU admin. Please list a clear hourly, daily, weekly or contract rate.',
                  style: TextStyle(
                    color: Color(0xFF166534),
                    height: 1.4,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),

        Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: const Color(0xFFBFDBFE),
            ),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.event_note,
                color: Color(0xFF2563EB),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Add clear payment terms below, for example: paid weekly, paid fortnightly, 7-day invoice terms, overtime, fuel, tolls and deductions.',
                  style: TextStyle(
                    color: Color(0xFF1E3A8A),
                    height: 1.4,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),

        inputField(
          'Payment terms * e.g. paid weekly / 7-day invoice',
          Icons.event_note,
          paymentTermsController,
        ),

        dropdownField(
          label: 'Job type',
          icon: Icons.schedule,
          value: selectedJobType,
          items: jobTypes,
          onChanged: (value) {
            setState(() {
              selectedJobType = value!;
            });
          },
        ),

        inputField('Contact phone number *', Icons.phone, contactController),

        Container(
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: SwitchListTile(
            title: const Text(
              'Mark as urgent job',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            subtitle: const Text('Urgent jobs will show a red badge'),
            value: isUrgent,
            activeThumbColor: const Color(0xFFFF7A00),
            onChanged: (value) {
              setState(() {
                isUrgent = value;
              });
            },
          ),
        ),

        Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: TextField(
            controller: descriptionController,
            maxLines: 5,
            decoration: premiumInputDecoration(
              'Job description',
              Icons.description,
            ),
          ),
        ),

        Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF7ED),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: const Color(0xFFFFD7A8),
            ),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.security,
                color: Color(0xFFFF7A00),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'All jobs are reviewed by TruckJobs AU admin before going live. Underpaid jobs, duplicate posts, fake jobs, spam, commission-based scams or misleading jobs may be removed.',
                  style: TextStyle(
                    color: Color(0xFF92400E),
                    height: 1.4,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),

        Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: agreedToSafetyRules
                  ? const Color(0xFF22C55E)
                  : const Color(0xFFE5E7EB),
            ),
          ),
          child: CheckboxListTile(
            value: agreedToSafetyRules,
            activeColor: const Color(0xFF22C55E),
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            onChanged: (value) {
              setState(() {
                agreedToSafetyRules = value ?? false;
              });
            },
            title: const Text(
              'I agree to TruckJobs AU safety and fair pay rules',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                color: Color(0xFF111827),
              ),
            ),
            subtitle: const Padding(
              padding: EdgeInsets.only(top: 6),
              child: Text(
                'No underpaid work, fake jobs, scams, misleading details, commission-only tricks, or requests for bank passwords/OTP.',
                style: TextStyle(
                  color: Color(0xFF64748B),
                  height: 1.35,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 8),

        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            onPressed: isSubmitting ? null : submitJob,
            icon: isSubmitting
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.send),
            label: Text(
              isSubmitting ? 'Submitting...' : 'Submit Job',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF7A00),
              foregroundColor: Colors.white,
              disabledBackgroundColor: const Color(0xFFFFB86B),
              disabledForegroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget inputField(
    String label,
    IconData icon,
    TextEditingController controller,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        decoration: premiumInputDecoration(label, icon),
      ),
    );
  }

  Widget dropdownField({
    required String label,
    required IconData icon,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: DropdownButtonFormField<String>(
        initialValue: value,
        items: items.map((item) {
          return DropdownMenuItem(
            value: item,
            child: Text(item),
          );
        }).toList(),
        onChanged: onChanged,
        decoration: premiumInputDecoration(label, icon),
      ),
    );
  }
}


class SavedJobsPage extends StatelessWidget {
  const SavedJobsPage({super.key});

  Future<void> removeSavedJob(String savedJobId, BuildContext context) async {
    await FirebaseFirestore.instance.collection('savedJobs').doc(savedJobId).delete();

    showPremiumMessage(
      context,
      'Saved job removed',
      icon: Icons.delete,
    );
  }

  Future<void> callEmployer(String phoneNumber) async {
    final Uri phoneUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );

    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }

  Future<void> whatsappEmployer(Job job) async {
    final cleanNumber = job.contact.replaceAll(' ', '');

    final ausNumber = cleanNumber.startsWith('0')
        ? '61${cleanNumber.substring(1)}'
        : cleanNumber;

    final message =
        'Hi, I am interested in the job: ${job.title} at ${job.company}. Is this job still available?';

    final Uri whatsappUri = Uri.parse(
      'https://wa.me/$ausNumber?text=${Uri.encodeComponent(message)}',
    );

    if (await canLaunchUrl(whatsappUri)) {
      await launchUrl(
        whatsappUri,
        mode: LaunchMode.externalApplication,
      );
    }
  }

  Future<void> reportJob(
    Job job,
    BuildContext context, {
    required String reason,
  }) async {
    await FirebaseFirestore.instance.collection('reports').add({
      'jobId': job.id,
      'jobTitle': job.title,
      'company': job.company,
      'contact': job.contact,
      'reason': reason,
      'createdAt': FieldValue.serverTimestamp(),
    });

    showPremiumMessage(
  context,
  'Job reported. Thank you.',
  icon: Icons.report,
);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('savedJobs')
          .orderBy('savedAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(
            child: Text('Something went wrong loading saved jobs'),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final savedDocs = snapshot.data!.docs;

        if (savedDocs.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Container(
                padding: const EdgeInsets.all(26),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 12,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.bookmark_border,
                      size: 64,
                      color: Color(0xFFFF7A00),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No Saved Jobs Yet',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Jobs you save will appear here so you can apply later.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF64748B),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final savedJobs = savedDocs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return Job.fromFirestore(doc.id, data);
        }).toList();

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFF111827),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Row(
                children: [
                  Container(
                    height: 48,
                    width: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF7A00),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.bookmark,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Saved Jobs',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${savedJobs.length} saved job${savedJobs.length == 1 ? '' : 's'}',
                          style: const TextStyle(
                            color: Color(0xFFE5E7EB),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            for (int index = 0; index < savedJobs.length; index++)
              AnimatedEntrance(
                index: index,
                child: Builder(
                  builder: (context) {
                    final job = savedJobs[index];
                    final savedJobId = savedDocs[index].id;

                  Future<void> openDetails() async {
                    final originalJobId =
                        job.id.isNotEmpty ? job.id : savedJobId;

                    await trackJobClick(originalJobId, 'views');

                    Navigator.push(
                      context,
                      premiumPageRoute(
                        JobDetailsPage(
                          job: job,
                          onSaveJob: () async {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Already saved'),
                              ),
                            );
                          },
                          onCallEmployer: () async {
                            final originalJobId =
                                job.id.isNotEmpty ? job.id : savedJobId;

                            await trackJobClick(
                              originalJobId,
                              'callClicks',
                            );
                            await callEmployer(job.contact);
                          },
                          onWhatsappEmployer: () async {
                            final originalJobId =
                                job.id.isNotEmpty ? job.id : savedJobId;

                            await trackJobClick(
                              originalJobId,
                              'whatsappClicks',
                            );
                            await whatsappEmployer(job);
                          },
                          onReportJob: () async {
                            final reason = await chooseReportReason(context);

                            if (reason != null) {
                              await reportJob(
                                job,
                                context,
                                reason: reason,
                              );
                            }
                          },
                        ),
                      ),
                    );
                  }

                  return PremiumTap(
                    onTap: openDetails,
                    borderRadius: BorderRadius.circular(22),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 52,
                              width: 52,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFFF7A00),
                                    Color(0xFFFFA726),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(
                                Icons.local_shipping,
                                color: Colors.white,
                              ),
                            ),

                            const SizedBox(width: 14),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    job.title,
                                    style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w900,
                                      color: Color(0xFF111827),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    job.company,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF64748B),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    job.location,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF94A3B8),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    formatPostedDate(job.createdAt),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF94A3B8),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    formatDaysLeft(job),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFFFF7A00),
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            IconButton(
                              tooltip: 'Remove saved job',
                              onPressed: () {
                                removeSavedJob(savedJobId, context);
                              },
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 14),

                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF9FAFB),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: savedInfoPill(Icons.badge, job.licence),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: savedInfoPill(Icons.payments, job.pay),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              savedInfoPill(
                                Icons.event_note,
                                job.paymentTerms,
                              ),
                              const SizedBox(height: 8),
                              savedInfoPill(
                                Icons.phone_locked,
                                'Contact available in details',
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 14),

                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  removeSavedJob(savedJobId, context);
                                },
                                icon: const Icon(Icons.close),
                                label: const Text('Remove'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.red,
                                  side: const BorderSide(color: Colors.red),
                                ),
                              ),
                            ),

                            const SizedBox(width: 10),

                            Expanded(
                              flex: 2,
                              child: ElevatedButton.icon(
                                onPressed: openDetails,
                                icon: const Icon(Icons.arrow_forward),
                                label: const Text('View Details'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    ),
                  );
                  },
                ),
              ),
          ],
        );
      },
    );
  }

  Widget savedInfoPill(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 9,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: const Color(0xFFFF7A00),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: Color(0xFF111827),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
class AdminPinPage extends StatefulWidget {
  const AdminPinPage({super.key});

  @override
  State<AdminPinPage> createState() => _AdminPinPageState();
}

class _AdminPinPageState extends State<AdminPinPage> {
  final pinController = TextEditingController();
  bool isUnlocked = false;

  @override
  void dispose() {
    pinController.dispose();
    super.dispose();
  }

  void checkPin() {
    if (pinController.text.trim() == '2329') {
      setState(() {
        isUnlocked = true;
      });
    } else {
      showPremiumMessage(
  context,
  'Wrong admin PIN',
  icon: Icons.lock,
);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isUnlocked) {
      return const AdminPage();
    }

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 88,
            width: 88,
            decoration: BoxDecoration(
              color: const Color(0xFFFFE8D6),
              borderRadius: BorderRadius.circular(28),
            ),
            child: const Icon(
              Icons.admin_panel_settings,
              size: 52,
              color: Color(0xFFFF7A00),
            ),
          ),

          const SizedBox(height: 20),

          const Text(
            'Admin Access',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 10),

          const Text(
            'Enter admin PIN to approve, reject, or delete jobs.',
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 20),

          TextField(
            controller: pinController,
            obscureText: true,
            keyboardType: TextInputType.number,
            decoration: premiumInputDecoration('Admin PIN', Icons.lock),
          ),

          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton.icon(
              onPressed: checkPin,
              icon: const Icon(Icons.lock_open),
              label: const Text('Unlock Admin'),
            ),
          ),
        ],
      ),
    );
  }
}

class AdminPage extends StatelessWidget {
  const AdminPage({super.key});

  Future<bool> confirmAction(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmText,
    bool isDanger = false,
  }) async {
    final result = await showPremiumDialog<bool>(
      context: context,
      child: Dialog(
        insetPadding: const EdgeInsets.all(18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(26),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: isDanger
                      ? const Color(0xFFFFF1F2)
                      : const Color(0xFFFFF7ED),
                  child: Icon(
                    isDanger ? Icons.warning_amber : Icons.help_outline,
                    color: isDanger ? Colors.red : const Color(0xFFFF7A00),
                    size: 32,
                  ),
                ),

                const SizedBox(height: 14),

                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF111827),
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    height: 1.4,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context, false);
                        },
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context, true);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              isDanger ? Colors.red : const Color(0xFFFF7A00),
                          foregroundColor: Colors.white,
                        ),
                        child: Text(confirmText),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    return result ?? false;
  }

  Future<void> approveJob(String jobId, BuildContext context) async {
    final confirmed = await showPremiumDialog<bool>(
      context: context,
      child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: const Row(
            children: [
              Icon(
                Icons.verified_user,
                color: Color(0xFF22C55E),
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text('Approve this job?'),
              ),
            ],
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Before approving, quickly check:',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF111827),
                ),
              ),
              SizedBox(height: 12),
              Text('✅ Pay rate is clear and fair'),
              SizedBox(height: 6),
              Text('✅ Payment terms are listed'),
              SizedBox(height: 6),
              Text('✅ Contact number looks genuine'),
              SizedBox(height: 6),
              Text('✅ No bank password / OTP / upfront payment request'),
              SizedBox(height: 6),
              Text('✅ Job details are not fake or misleading'),
              SizedBox(height: 14),
              Text(
                'Approved jobs go live for 15 days.',
                style: TextStyle(
                  color: Color(0xFFFF7A00),
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context, true);
              },
              icon: const Icon(Icons.check_circle),
              label: const Text('Approve Live'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF22C55E),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
    );

    if (confirmed != true) {
      return;
    }

    await FirebaseFirestore.instance.collection('jobs').doc(jobId).update({
      'status': 'approved',
      'expiresAt': Timestamp.fromDate(expiryFromNow()),
    });

    showPremiumMessage(
      context,
      'Job approved for 15 days',
      icon: Icons.verified_user,
    );
  }

  Future<void> rejectJob(String jobId, BuildContext context) async {
    await FirebaseFirestore.instance.collection('jobs').doc(jobId).update({
      'status': 'rejected',
    });

    showPremiumMessage(
      context,
      'Job rejected',
      icon: Icons.cancel,
    );
  }

  Future<void> deleteJob(String jobId, BuildContext context) async {
    await FirebaseFirestore.instance.collection('jobs').doc(jobId).delete();

    showPremiumMessage(
      context,
      'Job deleted',
      icon: Icons.delete,
    );
  }

  Future<void> markJobFilled(String jobId, BuildContext context) async {
    await FirebaseFirestore.instance.collection('jobs').doc(jobId).update({
      'status': 'filled',
      'filledAt': FieldValue.serverTimestamp(),
    });

    showPremiumMessage(
      context,
      'Job marked as filled',
      icon: Icons.check_circle,
    );
  }

  Future<void> restoreJobLive(String jobId, BuildContext context) async {
    await FirebaseFirestore.instance.collection('jobs').doc(jobId).update({
      'status': 'approved',
      'filledAt': FieldValue.delete(),
      'expiresAt': Timestamp.fromDate(expiryFromNow()),
    });

    showPremiumMessage(
  context,
  'Job restored to live for 15 days',
  icon: Icons.restore,
);
  }

  Future<void> extendExpiredJob(String jobId, BuildContext context) async {
    await FirebaseFirestore.instance.collection('jobs').doc(jobId).update({
      'status': 'approved',
      'expiresAt': Timestamp.fromDate(expiryFromNow()),
    });

    showPremiumMessage(
  context,
  'Job restored for another 15 days',
  icon: Icons.restore,
);
  }

  Future<void> deleteReport(String reportId, BuildContext context) async {
    await FirebaseFirestore.instance.collection('reports').doc(reportId).delete();

    showPremiumMessage(
      context,
      'Report removed',
      icon: Icons.check_circle,
    );
  }

  Future<void> deleteReportedJob(
    String jobId,
    String reportId,
    BuildContext context,
  ) async {
    if (jobId.isEmpty) {
      showPremiumMessage(
  context,
  'Job ID missing. Cannot delete job.',
  icon: Icons.error,
);
      return;
    }

    await FirebaseFirestore.instance.collection('jobs').doc(jobId).delete();
    await FirebaseFirestore.instance.collection('reports').doc(reportId).delete();

    showPremiumMessage(
  context,
  'Reported job deleted',
  icon: Icons.delete_forever,
);
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFF111827),
            borderRadius: BorderRadius.circular(22),
          ),
          child: const Row(
            children: [
              Icon(
                Icons.admin_panel_settings,
                color: Color(0xFFFFA726),
                size: 34,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Admin Dashboard',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 22),

        adminStatsCards(),

        const SizedBox(height: 24),

        sectionTitle('Pending Jobs'),

        const SizedBox(height: 10),

        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('jobs')
              .where('status', isEqualTo: 'pending')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Text('Error loading pending jobs');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final pendingJobs = snapshot.data!.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return Job.fromFirestore(doc.id, data);
            }).toList();

            pendingJobs.sort((a, b) {
              final aDate = a.createdAt ?? DateTime(2000);
              final bDate = b.createdAt ?? DateTime(2000);
              return bDate.compareTo(aDate);
            });

            if (pendingJobs.isEmpty) {
              return emptyAdminCard('No pending jobs');
            }

            return Column(
              children: [
                for (int index = 0; index < pendingJobs.length; index++)
                  AnimatedEntrance(
                    index: index,
                    child: adminJobCard(
                    context: context,
                    job: pendingJobs[index],
                    onApprove: () => approveJob(pendingJobs[index].id, context),
                    onReject: () async {
                      final confirmed = await confirmAction(
                        context,
                        title: 'Reject job?',
                        message: 'Are you sure you want to reject this job?',
                        confirmText: 'Reject',
                        isDanger: true,
                      );

                      if (confirmed) {
                        rejectJob(pendingJobs[index].id, context);
                      }
                    },
                    onDelete: () async {
                      final confirmed = await confirmAction(
                        context,
                        title: 'Delete job?',
                        message: 'This will permanently delete this job from Firestore.',
                        confirmText: 'Delete',
                        isDanger: true,
                      );

                      if (confirmed) {
                        deleteJob(pendingJobs[index].id, context);
                      }
                    },
                    ),
                  ),
              ],
            );
          },
        ),

        const SizedBox(height: 30),

        sectionTitle('Approved Jobs Performance'),

        const SizedBox(height: 10),

        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('jobs')
              .where('status', isEqualTo: 'approved')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Text('Error loading approved jobs');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final approvedJobs = snapshot.data!.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return Job.fromFirestore(doc.id, data);
            }).where((job) {
              return !isJobExpired(job);
            }).toList();

            approvedJobs.sort((a, b) {
              final aClicks = a.views + a.callClicks + a.whatsappClicks;
              final bClicks = b.views + b.callClicks + b.whatsappClicks;

              if (aClicks != bClicks) {
                return bClicks.compareTo(aClicks);
              }

              final aDate = a.createdAt ?? DateTime(2000);
              final bDate = b.createdAt ?? DateTime(2000);
              return bDate.compareTo(aDate);
            });

            if (approvedJobs.isEmpty) {
              return emptyAdminCard('No approved jobs yet');
            }

            return Column(
              children: [
                for (int index = 0; index < approvedJobs.length; index++)
                  AnimatedEntrance(
                    index: index,
                    child: adminApprovedJobCard(
                    context: context,
                    job: approvedJobs[index],
                    onMarkFilled: () async {
                      final confirmed = await confirmAction(
                        context,
                        title: 'Mark job as filled?',
                        message:
                            'This will hide the job from the public Jobs page but keep its performance data in Admin.',
                        confirmText: 'Mark Filled',
                      );

                      if (confirmed) {
                        markJobFilled(approvedJobs[index].id, context);
                      }
                    },
                    onDelete: () async {
                      final confirmed = await confirmAction(
                        context,
                        title: 'Delete live job?',
                        message:
                            'This approved job is currently visible to users. Deleting it will permanently remove it from Firestore.',
                        confirmText: 'Delete',
                        isDanger: true,
                      );

                      if (confirmed) {
                        deleteJob(approvedJobs[index].id, context);
                      }
                    },
                    ),
                  ),
              ],
            );
          },
        ),

        const SizedBox(height: 30),

        sectionTitle('Expired Jobs'),

        const SizedBox(height: 10),

        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('jobs')
              .where('status', isEqualTo: 'approved')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Text('Error loading expired jobs');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final expiredJobs = snapshot.data!.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return Job.fromFirestore(doc.id, data);
            }).where((job) {
              return isJobExpired(job);
            }).toList();

            expiredJobs.sort((a, b) {
              final aDate = a.expiresAt ?? DateTime(2000);
              final bDate = b.expiresAt ?? DateTime(2000);
              return bDate.compareTo(aDate);
            });

            if (expiredJobs.isEmpty) {
              return emptyAdminCard('No expired jobs yet');
            }

            return Column(
              children: [
                for (int index = 0; index < expiredJobs.length; index++)
                  AnimatedEntrance(
                    index: index,
                    child: adminExpiredJobCard(
                    context: context,
                    job: expiredJobs[index],
                    onRestore: () async {
                      final confirmed = await confirmAction(
                        context,
                        title: 'Restore expired job?',
                        message:
                            'This will make the job live again for another 15 days.',
                        confirmText: 'Restore',
                      );

                      if (confirmed) {
                        extendExpiredJob(expiredJobs[index].id, context);
                      }
                    },
                    onMarkFilled: () async {
                      final confirmed = await confirmAction(
                        context,
                        title: 'Mark expired job as filled?',
                        message:
                            'This will move the expired job into Filled Jobs and keep its performance history.',
                        confirmText: 'Mark Filled',
                      );

                      if (confirmed) {
                        markJobFilled(expiredJobs[index].id, context);
                      }
                    },
                    onDelete: () async {
                      final confirmed = await confirmAction(
                        context,
                        title: 'Delete expired job?',
                        message:
                            'This will permanently delete this expired job and its performance history.',
                        confirmText: 'Delete',
                        isDanger: true,
                      );

                      if (confirmed) {
                        deleteJob(expiredJobs[index].id, context);
                      }
                    },
                    ),
                  ),
              ],
            );
          },
        ),

        const SizedBox(height: 30),

        sectionTitle('Filled Jobs'),

        const SizedBox(height: 10),

        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('jobs')
              .where('status', isEqualTo: 'filled')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Text('Error loading filled jobs');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final filledJobs = snapshot.data!.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return Job.fromFirestore(doc.id, data);
            }).toList();

            filledJobs.sort((a, b) {
              final aDate = a.createdAt ?? DateTime(2000);
              final bDate = b.createdAt ?? DateTime(2000);
              return bDate.compareTo(aDate);
            });

            if (filledJobs.isEmpty) {
              return emptyAdminCard('No filled jobs yet');
            }

            return Column(
              children: [
                for (int index = 0; index < filledJobs.length; index++)
                  AnimatedEntrance(
                    index: index,
                    child: adminFilledJobCard(
                    context: context,
                    job: filledJobs[index],
                    onRestore: () async {
                      final confirmed = await confirmAction(
                        context,
                        title: 'Restore job to live?',
                        message:
                            'This will move the job back to Approved Jobs and make it visible on the public Jobs page again.',
                        confirmText: 'Restore',
                      );

                      if (confirmed) {
                        restoreJobLive(filledJobs[index].id, context);
                      }
                    },
                    onDelete: () async {
                      final confirmed = await confirmAction(
                        context,
                        title: 'Delete filled job?',
                        message:
                            'This will permanently delete this filled job and its performance history.',
                        confirmText: 'Delete',
                        isDanger: true,
                      );

                      if (confirmed) {
                        deleteJob(filledJobs[index].id, context);
                      }
                    },
                    ),
                  ),
              ],
            );
          },
        ),

        const SizedBox(height: 30),

        sectionTitle('Reported Jobs'),

        const SizedBox(height: 10),

        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('reports').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Text('Error loading reports');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final reports = snapshot.data!.docs;

            if (reports.isEmpty) {
              return emptyAdminCard('No reported jobs');
            }

            return Column(
              children: [
                for (int index = 0; index < reports.length; index++)
                  AnimatedEntrance(
                    index: index,
                    child: Builder(
                      builder: (context) {
                        final report = reports[index];
                        final data = report.data() as Map<String, dynamic>;

                      return reportedJobCard(
                        context: context,
                        data: data,
                        onDeleteJob: () async {
                          final confirmed = await confirmAction(
                            context,
                            title: 'Delete reported job?',
                            message: 'This will delete the job and remove the report.',
                            confirmText: 'Delete',
                            isDanger: true,
                          );

                          if (confirmed) {
                            final jobId = (data['jobId'] ?? '').toString();
                            deleteReportedJob(jobId, report.id, context);
                          }
                        },
                        onRemoveReport: () async {
                          final confirmed = await confirmAction(
                            context,
                            title: 'Remove report?',
                            message: 'This will remove the report but keep the job.',
                            confirmText: 'Remove',
                          );

                          if (confirmed) {
                            deleteReport(report.id, context);
                          }
                        },
                      );
                      },
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget adminStatsCards() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('jobs').snapshots(),
      builder: (context, jobsSnapshot) {
        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('reports').snapshots(),
          builder: (context, reportsSnapshot) {
            final jobsDocs = jobsSnapshot.data?.docs ?? [];
            final reportsDocs = reportsSnapshot.data?.docs ?? [];

            final pendingCount = jobsDocs.where((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return data['status'] == 'pending';
            }).length;

            final approvedCount = jobsDocs.where((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final job = Job.fromFirestore(doc.id, data);
              return job.status == 'approved' && !isJobExpired(job);
            }).length;

            final expiredCount = jobsDocs.where((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final job = Job.fromFirestore(doc.id, data);
              return job.status == 'approved' && isJobExpired(job);
            }).length;

            final filledCount = jobsDocs.where((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return data['status'] == 'filled';
            }).length;

            final reportsCount = reportsDocs.length;

            return Row(
              children: [
                Expanded(
                  child: adminStatCard(
                    icon: Icons.pending_actions,
                    title: 'Pending',
                    value: pendingCount.toString(),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: adminStatCard(
                    icon: Icons.verified,
                    title: 'Approved',
                    value: approvedCount.toString(),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: adminStatCard(
                    icon: Icons.timer_off,
                    title: 'Expired',
                    value: expiredCount.toString(),
                    isDanger: expiredCount > 0,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: adminStatCard(
                    icon: Icons.task_alt,
                    title: 'Filled',
                    value: filledCount.toString(),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: adminStatCard(
                    icon: Icons.report,
                    title: 'Reports',
                    value: reportsCount.toString(),
                    isDanger: reportsCount > 0,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget adminStatCard({
    required IconData icon,
    required String title,
    required String value,
    bool isDanger = false,
  }) {
    final Color mainColor = isDanger ? Colors.red : const Color(0xFFFF7A00);
    final Color bgColor =
        isDanger ? Colors.red.shade50 : const Color(0xFFFFF7ED);

    return PremiumTap(
      onTap: () {},
      borderRadius: BorderRadius.circular(22),
      child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDanger ? Colors.red.shade100 : const Color(0xFFFFD7A8),
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: mainColor,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: mainColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
      ),
    );
  }

  Widget sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w900,
        color: Color(0xFF111827),
      ),
    );
  }

  Widget emptyAdminCard(String text) {
    return PremiumTap(
      onTap: () {},
      borderRadius: BorderRadius.circular(22),
      child: Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: Color(0xFF64748B),
        ),
      ),
      ),
    );
  }

  Widget adminJobCard({
    required BuildContext context,
    required Job job,
    required VoidCallback onApprove,
    required VoidCallback onReject,
    required VoidCallback onDelete,
  }) {
    return PremiumTap(
      onTap: () {},
      borderRadius: BorderRadius.circular(22),
      child: Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.pending_actions, color: Color(0xFFFF7A00)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  job.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Text(
            job.company,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),

          const SizedBox(height: 6),

          Text(
            formatPostedDate(job.createdAt),
            style: const TextStyle(color: Colors.grey, fontSize: 13),
          ),

          const SizedBox(height: 4),

          Text(
            formatFilledDate(job.filledAt),
            style: const TextStyle(
              color: Colors.green,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 12),

          adminInfoRow(Icons.location_on, 'Location', job.location),
          adminInfoRow(Icons.event_available, 'Expiry', formatExpiryDate(job.expiresAt)),
          adminInfoRow(Icons.badge, 'Licence', job.licence),
          adminInfoRow(Icons.payments, 'Pay', job.pay),
          adminInfoRow(Icons.event_note, 'Payment Terms', job.paymentTerms),
          adminInfoRow(Icons.work, 'Type', job.type),
          adminInfoRow(Icons.phone, 'Contact', job.contact),
          adminInfoRow(Icons.visibility, 'Views', job.views.toString()),
          adminInfoRow(
            Icons.call,
            'Call clicks',
            job.callClicks.toString(),
          ),
          adminInfoRow(
            Icons.chat,
            'WhatsApp clicks',
            job.whatsappClicks.toString(),
          ),

          const SizedBox(height: 10),

          Text(
            job.description,
            style: const TextStyle(height: 1.35),
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onApprove,
                  icon: const Icon(Icons.check),
                  label: const Text('Approve'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onReject,
                  icon: const Icon(Icons.close),
                  label: const Text('Reject'),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onDelete,
              icon: const Icon(Icons.delete),
              label: const Text('Delete Job'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }

  Widget adminApprovedJobCard({
    required BuildContext context,
    required Job job,
    required VoidCallback onMarkFilled,
    required VoidCallback onDelete,
  }) {
    final totalClicks = job.views + job.callClicks + job.whatsappClicks;

    return PremiumTap(
      onTap: () {},
      borderRadius: BorderRadius.circular(22),
      child: Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFFFD7A8)),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.trending_up, color: Color(0xFFFF7A00)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  job.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7ED),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFFFD7A8)),
                ),
                child: Text(
                  '$totalClicks interest',
                  style: const TextStyle(
                    color: Color(0xFFFF7A00),
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Text(
            job.company,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),

          const SizedBox(height: 6),

          Text(
            formatPostedDate(job.createdAt),
            style: const TextStyle(color: Colors.grey, fontSize: 13),
          ),

          const SizedBox(height: 12),

          adminInfoRow(Icons.location_on, 'Location', job.location),
          adminInfoRow(Icons.badge, 'Licence', job.licence),
          adminInfoRow(Icons.payments, 'Pay', job.pay),
          adminInfoRow(Icons.event_note, 'Payment Terms', job.paymentTerms),
          adminInfoRow(Icons.work, 'Type', job.type),
          adminInfoRow(Icons.visibility, 'Views', job.views.toString()),
          adminInfoRow(Icons.call, 'Call clicks', job.callClicks.toString()),
          adminInfoRow(
            Icons.chat,
            'WhatsApp clicks',
            job.whatsappClicks.toString(),
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onMarkFilled,
                  icon: const Icon(Icons.task_alt),
                  label: const Text('Mark Filled'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_forever),
                  label: const Text('Delete'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      ),
    );
  }

  Widget adminExpiredJobCard({
    required BuildContext context,
    required Job job,
    required VoidCallback onRestore,
    required VoidCallback onMarkFilled,
    required VoidCallback onDelete,
  }) {
    final totalInterest = job.views + job.callClicks + job.whatsappClicks;

    return PremiumTap(
      onTap: () {},
      borderRadius: BorderRadius.circular(22),
      child: Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.red.shade100),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.timer_off, color: Colors.red),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  job.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.red.shade100),
                ),
                child: const Text(
                  'EXPIRED',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Text(
            job.company,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),

          const SizedBox(height: 6),

          Text(
            formatExpiredDate(job.expiresAt),
            style: const TextStyle(
              color: Colors.red,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 12),

          adminInfoRow(Icons.location_on, 'Location', job.location),
          adminInfoRow(Icons.badge, 'Licence', job.licence),
          adminInfoRow(Icons.payments, 'Pay', job.pay),
          adminInfoRow(Icons.event_note, 'Payment Terms', job.paymentTerms),
          adminInfoRow(Icons.visibility, 'Views', job.views.toString()),
          adminInfoRow(Icons.call, 'Call clicks', job.callClicks.toString()),
          adminInfoRow(
            Icons.chat,
            'WhatsApp clicks',
            job.whatsappClicks.toString(),
          ),
          adminInfoRow(
            Icons.insights,
            'Total interest',
            totalInterest.toString(),
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onRestore,
                  icon: const Icon(Icons.restore),
                  label: const Text('Restore 15 Days'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onMarkFilled,
                  icon: const Icon(Icons.task_alt),
                  label: const Text('Filled'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.green,
                    side: const BorderSide(color: Colors.green),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onDelete,
              icon: const Icon(Icons.delete_forever),
              label: const Text('Delete Expired Job'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }

  Widget adminFilledJobCard({
    required BuildContext context,
    required Job job,
    required VoidCallback onRestore,
    required VoidCallback onDelete,
  }) {
    final totalInterest = job.views + job.callClicks + job.whatsappClicks;

    return PremiumTap(
      onTap: () {},
      borderRadius: BorderRadius.circular(22),
      child: Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.green.shade100),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.task_alt, color: Colors.green),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  job.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.green.shade100),
                ),
                child: const Text(
                  'FILLED',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Text(
            job.company,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),

          const SizedBox(height: 6),

          Text(
            formatPostedDate(job.createdAt),
            style: const TextStyle(color: Colors.grey, fontSize: 13),
          ),

          const SizedBox(height: 12),

          adminInfoRow(Icons.location_on, 'Location', job.location),
          adminInfoRow(Icons.badge, 'Licence', job.licence),
          adminInfoRow(Icons.payments, 'Pay', job.pay),
          adminInfoRow(Icons.event_note, 'Payment Terms', job.paymentTerms),
          adminInfoRow(Icons.visibility, 'Views', job.views.toString()),
          adminInfoRow(Icons.call, 'Call clicks', job.callClicks.toString()),
          adminInfoRow(
            Icons.chat,
            'WhatsApp clicks',
            job.whatsappClicks.toString(),
          ),
          adminInfoRow(
            Icons.insights,
            'Total interest',
            totalInterest.toString(),
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onRestore,
                  icon: const Icon(Icons.restore),
                  label: const Text('Restore Live'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF7A00),
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_forever),
                  label: const Text('Delete'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      ),
    );
  }

  Widget reportedJobCard({
    required BuildContext context,
    required Map<String, dynamic> data,
    required VoidCallback onDeleteJob,
    required VoidCallback onRemoveReport,
  }) {
    final reason = (data['reason'] ?? 'Reported by user').toString();
    final jobTitle = (data['jobTitle'] ?? 'Unknown job').toString();
    final company = (data['company'] ?? 'Unknown company').toString();
    final contact = (data['contact'] ?? 'No contact').toString();

    final bool highPriority =
        reason.toLowerCase().contains('scam') ||
            reason.toLowerCase().contains('bank') ||
            reason.toLowerCase().contains('otp') ||
            reason.toLowerCase().contains('unsafe') ||
            reason.toLowerCase().contains('pay drivers on time') ||
            reason.toLowerCase().contains('underpaid');

    return PremiumTap(
      onTap: () {},
      borderRadius: BorderRadius.circular(22),
      child: Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: highPriority ? Colors.red.shade200 : const Color(0xFFE5E7EB),
          width: highPriority ? 1.4 : 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  color: highPriority
                      ? Colors.red.shade50
                      : const Color(0xFFFFF7ED),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  highPriority ? Icons.priority_high : Icons.report,
                  color: highPriority ? Colors.red : const Color(0xFFFF7A00),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  jobTitle,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF111827),
                  ),
                ),
              ),
              if (highPriority)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.red.shade100),
                  ),
                  child: const Text(
                    'URGENT',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 12),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: highPriority
                  ? const Color(0xFFFFF1F2)
                  : const Color(0xFFFFF7ED),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: highPriority
                    ? const Color(0xFFFECACA)
                    : const Color(0xFFFFD7A8),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.report_problem,
                  color: highPriority ? Colors.red : const Color(0xFFFF7A00),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    reason,
                    style: TextStyle(
                      color: highPriority
                          ? const Color(0xFF991B1B)
                          : const Color(0xFF92400E),
                      fontWeight: FontWeight.w900,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          adminInfoRow(Icons.business, 'Company', company),
          adminInfoRow(Icons.phone, 'Contact', contact),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onRemoveReport,
                  icon: const Icon(Icons.check_circle),
                  label: const Text('Keep Job'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF111827),
                    side: const BorderSide(color: Color(0xFF111827)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onDeleteJob,
                  icon: const Icon(Icons.delete_forever),
                  label: const Text('Delete Job'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      ),
    );
  }

  Widget adminInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 17, color: const Color(0xFFFF7A00)),
          const SizedBox(width: 7),
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: const Color(0xFF111827),
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 12,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: const Column(
            children: [
              CircleAvatar(
                radius: 46,
                backgroundColor: Color(0xFFFF7A00),
                child: Icon(
                  Icons.person,
                  size: 52,
                  color: Colors.white,
                ),
              ),

              SizedBox(height: 16),

              Text(
                'Driver / Employer Profile',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),

              SizedBox(height: 8),

              Text(
                'Manage your trucking profile, licence details and job preferences.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFFE5E7EB),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        profileTile(
          icon: Icons.person,
          title: 'Name',
          subtitle: 'Add your name later',
        ),

        profileTile(
          icon: Icons.badge,
          title: 'Licence',
          subtitle: 'MR / HR / HC / MC',
        ),

        profileTile(
          icon: Icons.location_on,
          title: 'Location',
          subtitle: 'Australia',
        ),

        profileTile(
          icon: Icons.local_shipping,
          title: 'Role',
          subtitle: 'Driver / Employer',
        ),

        profileTile(
          icon: Icons.verified_user,
          title: 'Verification',
          subtitle: 'Coming soon',
        ),

        const SizedBox(height: 14),

        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF7ED),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: const Color(0xFFFFD7A8),
            ),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.info,
                color: Color(0xFFFF7A00),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Profile editing, driver verification and employer accounts will be added in the next version.',
                  style: TextStyle(
                    color: Color(0xFF92400E),
                    height: 1.4,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static Widget profileTile({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFFFE8D6),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              color: const Color(0xFFFF7A00),
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: Color(0xFFCBD5E1),
          ),
        ],
      ),
    );
  }
}