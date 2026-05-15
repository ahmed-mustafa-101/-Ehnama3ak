String? validateEgyptianNationalId(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'National ID is required';
  }

  final trimmedValue = value.trim();

  if (!RegExp(r'^\d+$').hasMatch(trimmedValue)) {
    return 'Numbers only';
  }

  if (trimmedValue.length != 14) {
    return 'National ID must be 14 digits';
  }

  // Validate first digit (2 for 1900-1999, 3 for 2000-2099)
  final firstDigit = trimmedValue[0];
  if (firstDigit != '2' && firstDigit != '3') {
    return 'Invalid National ID';
  }

  // Validate birth date (YYMMDD) in positions 2-7
  final yearPart = trimmedValue.substring(1, 3);
  final monthPart = trimmedValue.substring(3, 5);
  final dayPart = trimmedValue.substring(5, 7);

  final century = firstDigit == '2' ? '19' : '20';
  final fullYear = int.tryParse('$century$yearPart');
  final month = int.tryParse(monthPart);
  final day = int.tryParse(dayPart);

  if (fullYear == null || month == null || day == null) {
    return 'Invalid National ID';
  }

  if (month < 1 || month > 12) {
    return 'Invalid National ID';
  }

  final daysInMonth = [
    31,
    (_isLeapYear(fullYear) ? 29 : 28),
    31,
    30,
    31,
    30,
    31,
    31,
    30,
    31,
    30,
    31
  ];

  if (day < 1 || day > daysInMonth[month - 1]) {
    return 'Invalid National ID';
  }

  return null;
}

bool _isLeapYear(int year) {
  if (year % 4 == 0) {
    if (year % 100 == 0) {
      if (year % 400 == 0) return true;
      return false;
    }
    return true;
  }
  return false;
}
