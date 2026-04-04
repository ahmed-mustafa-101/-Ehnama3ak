import 'package:flutter/material.dart';

import 'package:ehnama3ak/core/storage/secure_token_storage.dart';
import 'package:ehnama3ak/features/auth/data/models/auth_model.dart';

/// عرض **اسم الدكتور المسجّل**، **التخصص**، و**سنوات الخبرة** من:
/// - بيانات الجلسة الحالية ([AuthModel] من [AuthCubit])
/// - ثم [SecureTokenStorage] إذا كانت لقطة الـ Cubit ناقصة (بعد إعادة فتح التطبيق، إلخ)
class RegisteredDoctorProfileTexts extends StatefulWidget {
  const RegisteredDoctorProfileTexts({
    super.key,
    required this.user,
    required this.nameStyle,
    required this.specializationStyle,
    required this.yearsStyle,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.textAlign = TextAlign.start,
    this.nameMaxLines = 2,
    this.specializationMaxLines = 2,
  });

  final AuthModel? user;
  final TextStyle nameStyle;
  final TextStyle specializationStyle;
  final TextStyle yearsStyle;
  final CrossAxisAlignment crossAxisAlignment;
  final TextAlign textAlign;
  final int nameMaxLines;
  final int specializationMaxLines;

  @override
  State<RegisteredDoctorProfileTexts> createState() =>
      _RegisteredDoctorProfileTextsState();
}

class _RegisteredDoctorProfileTextsState
    extends State<RegisteredDoctorProfileTexts> {
  final SecureTokenStorage _storage = SecureTokenStorage();

  String? _nameFromStorage;
  String? _emailFromStorage;
  String? _specializationFromStorage;
  int? _yearsFromStorage;

  @override
  void initState() {
    super.initState();
    _syncFromStorage();
  }

  @override
  void didUpdateWidget(covariant RegisteredDoctorProfileTexts oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.user?.id != widget.user?.id ||
        oldWidget.user?.name != widget.user?.name ||
        oldWidget.user?.email != widget.user?.email ||
        oldWidget.user?.specialization != widget.user?.specialization ||
        oldWidget.user?.yearsOfExperience != widget.user?.yearsOfExperience) {
      _syncFromStorage();
    }
  }

  Future<void> _syncFromStorage() async {
    if (widget.user == null) {
      if (mounted) {
        setState(() {
          _nameFromStorage = null;
          _emailFromStorage = null;
          _specializationFromStorage = null;
          _yearsFromStorage = null;
        });
      }
      return;
    }

    final name = await _storage.getUserName();
    final email = await _storage.getUserEmail();
    final spec = await _storage.getUserSpecialization();
    final years = await _storage.getUserYearsExperience();
    if (!mounted) return;
    setState(() {
      _nameFromStorage = name;
      _emailFromStorage = email;
      _specializationFromStorage = spec;
      _yearsFromStorage = years;
    });
  }

  String _resolveDisplayName(AuthModel? u) {
    final fromUser = u?.name.trim();
    if (fromUser != null && fromUser.isNotEmpty) return fromUser;

    final fromStore = _nameFromStorage?.trim();
    if (fromStore != null && fromStore.isNotEmpty) return fromStore;

    final emailUser = u?.email.trim();
    if (emailUser != null && emailUser.isNotEmpty) return emailUser;

    final emailStore = _emailFromStorage?.trim();
    if (emailStore != null && emailStore.isNotEmpty) return emailStore;

    return 'Doctor';
  }

  @override
  Widget build(BuildContext context) {
    final u = widget.user;

    final displayName = _resolveDisplayName(u);

    final String specializationText;
    final fromUserSpec = u?.specializationLine;
    if (fromUserSpec != null && fromUserSpec.trim() != '—') {
      specializationText = fromUserSpec;
    } else {
      final fromStore = _specializationFromStorage?.trim();
      specializationText =
          (fromStore != null && fromStore.isNotEmpty) ? fromStore : '—';
    }

    final yearsText;
    final fromUserYears = u?.yearsExperienceLine;
    if (fromUserYears != null && fromUserYears.trim() != '—') {
      yearsText = fromUserYears;
    } else {
      final y = _yearsFromStorage;
      yearsText = y != null ? '$y Years Exp' : '—';
    }

    return Column(
      crossAxisAlignment: widget.crossAxisAlignment,
      children: [
        Text(
          displayName,
          maxLines: widget.nameMaxLines,
          overflow: TextOverflow.ellipsis,
          textAlign: widget.textAlign,
          style: widget.nameStyle,
        ),
        Text(
          specializationText,
          maxLines: widget.specializationMaxLines,
          overflow: TextOverflow.ellipsis,
          textAlign: widget.textAlign,
          style: widget.specializationStyle,
        ),
        Text(
          yearsText,
          textAlign: widget.textAlign,
          style: widget.yearsStyle,
        ),
      ],
    );
  }
}
