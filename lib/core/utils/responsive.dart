import 'package:flutter/material.dart';

/// Screen breakpoints for different device types
class ScreenBreakpoints {
  static const double mobile = 600;
  static const double tablet = 1024;
  static const double desktop = 1440;
}

/// Device type enum
enum DeviceType {
  mobile,
  tablet,
  desktop,
}

/// Responsive utility class for adaptive layouts
class Responsive {
  /// Get device type based on screen width
  static DeviceType getDeviceType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < ScreenBreakpoints.mobile) {
      return DeviceType.mobile;
    } else if (width < ScreenBreakpoints.tablet) {
      return DeviceType.tablet;
    } else {
      return DeviceType.desktop;
    }
  }

  /// Check if device is mobile
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < ScreenBreakpoints.mobile;
  }

  /// Check if device is tablet
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= ScreenBreakpoints.mobile &&
        width < ScreenBreakpoints.tablet;
  }

  /// Check if device is desktop
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= ScreenBreakpoints.tablet;
  }

  /// Get responsive width based on percentage
  static double width(BuildContext context, double percentage) {
    return MediaQuery.of(context).size.width * percentage;
  }

  /// Get responsive height based on percentage
  static double height(BuildContext context, double percentage) {
    return MediaQuery.of(context).size.height * percentage;
  }

  /// Get responsive font size
  static double fontSize(BuildContext context, double baseSize) {
    final width = MediaQuery.of(context).size.width;
    if (width < ScreenBreakpoints.mobile) {
      return baseSize;
    } else if (width < ScreenBreakpoints.tablet) {
      return baseSize * 1.1;
    } else {
      return baseSize * 1.2;
    }
  }

  /// Get responsive padding
  static double padding(BuildContext context, double basePadding) {
    final width = MediaQuery.of(context).size.width;
    if (width < ScreenBreakpoints.mobile) {
      return basePadding;
    } else if (width < ScreenBreakpoints.tablet) {
      return basePadding * 1.2;
    } else {
      return basePadding * 1.5;
    }
  }

  /// Get responsive spacing
  static double spacing(BuildContext context, double baseSpacing) {
    final width = MediaQuery.of(context).size.width;
    if (width < ScreenBreakpoints.mobile) {
      return baseSpacing;
    } else if (width < ScreenBreakpoints.tablet) {
      return baseSpacing * 1.2;
    } else {
      return baseSpacing * 1.5;
    }
  }

  /// Get responsive icon size
  static double iconSize(BuildContext context, double baseSize) {
    final width = MediaQuery.of(context).size.width;
    if (width < ScreenBreakpoints.mobile) {
      return baseSize;
    } else if (width < ScreenBreakpoints.tablet) {
      return baseSize * 1.15;
    } else {
      return baseSize * 1.3;
    }
  }

  /// Get responsive border radius
  static double borderRadius(BuildContext context, double baseRadius) {
    final width = MediaQuery.of(context).size.width;
    if (width < ScreenBreakpoints.mobile) {
      return baseRadius;
    } else if (width < ScreenBreakpoints.tablet) {
      return baseRadius * 1.1;
    } else {
      return baseRadius * 1.2;
    }
  }

  /// Get max content width for centered layouts on large screens
  static double getMaxContentWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < ScreenBreakpoints.mobile) {
      return width;
    } else if (width < ScreenBreakpoints.tablet) {
      return ScreenBreakpoints.mobile;
    } else {
      return ScreenBreakpoints.tablet;
    }
  }

  /// Get responsive value based on device type
  static T valueByDevice<T>({
    required BuildContext context,
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    final deviceType = getDeviceType(context);
    switch (deviceType) {
      case DeviceType.mobile:
        return mobile;
      case DeviceType.tablet:
        return tablet ?? mobile;
      case DeviceType.desktop:
        return desktop ?? tablet ?? mobile;
    }
  }
}
