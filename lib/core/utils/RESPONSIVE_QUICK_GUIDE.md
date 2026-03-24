# Responsive Utils - Quick Reference Guide

## Import
```dart
import 'package:ehnama3ak/core/utils/responsive.dart';
```

## Common Usage Patterns

### Spacing
```dart
// Vertical spacing
SizedBox(height: Responsive.spacing(context, 20))

// Horizontal spacing
SizedBox(width: Responsive.spacing(context, 16))
```

### Padding
```dart
// Symmetric padding
Padding(
  padding: EdgeInsets.symmetric(
    horizontal: Responsive.padding(context, 20),
    vertical: Responsive.padding(context, 16),
  ),
)

// All sides
Padding(
  padding: EdgeInsets.all(Responsive.padding(context, 16)),
)
```

### Text Sizes
```dart
Text(
  'Hello',
  style: TextStyle(
    fontSize: Responsive.fontSize(context, 16),
  ),
)
```

### Dimensions
```dart
// Width
Container(
  width: Responsive.width(context, 0.8), // 80% of screen width
)

// Height
Container(
  height: Responsive.height(context, 0.3), // 30% of screen height
)

// With min/max constraints
Container(
  height: Responsive.height(context, 0.07).clamp(50, 70),
)
```

### Icons
```dart
Icon(
  Icons.home,
  size: Responsive.iconSize(context, 24),
)
```

### Border Radius
```dart
Container(
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(
      Responsive.borderRadius(context, 12),
    ),
  ),
)
```

### Device-Specific Values
```dart
// Different values for different devices
Padding(
  padding: EdgeInsets.symmetric(
    horizontal: Responsive.valueByDevice(
      context: context,
      mobile: 20,
      tablet: 60,
      desktop: 100,
    ),
  ),
)
```

### Max Content Width (for large screens)
```dart
Center(
  child: ConstrainedBox(
    constraints: BoxConstraints(
      maxWidth: Responsive.getMaxContentWidth(context),
    ),
    child: yourContent,
  ),
)
```

### Device Type Checks
```dart
if (Responsive.isMobile(context)) {
  // Mobile-specific code
} else if (Responsive.isTablet(context)) {
  // Tablet-specific code
} else {
  // Desktop-specific code
}
```

## Complete Screen Template

```dart
import 'package:flutter/material.dart';
import '../../core/utils/responsive.dart';

class MyResponsiveScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final maxContentWidth = Responsive.getMaxContentWidth(context);
    
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxContentWidth),
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: Responsive.valueByDevice(
                    context: context,
                    mobile: 20,
                    tablet: 60,
                    desktop: 100,
                  ),
                ),
                child: Column(
                  children: [
                    SizedBox(height: Responsive.spacing(context, 20)),
                    
                    Text(
                      'Title',
                      style: TextStyle(
                        fontSize: Responsive.fontSize(context, 24),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    
                    SizedBox(height: Responsive.spacing(context, 16)),
                    
                    Container(
                      width: double.infinity,
                      height: Responsive.height(context, 0.3),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          Responsive.borderRadius(context, 12),
                        ),
                      ),
                    ),
                    
                    SizedBox(height: Responsive.spacing(context, 20)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
```

## Breakpoints Reference

| Device Type | Width Range | Multiplier |
|------------|-------------|------------|
| Mobile     | < 600px     | 1.0x       |
| Tablet     | 600-1024px  | 1.1-1.2x   |
| Desktop    | > 1024px    | 1.2-1.5x   |

## Tips

1. **Always use responsive utils** instead of fixed values
2. **Test on multiple screen sizes** during development
3. **Use SingleChildScrollView** to prevent overflow
4. **Constrain content width** on large screens
5. **Use Wrap** for text that might overflow
6. **Clamp values** when you need min/max constraints

## Common Mistakes to Avoid

❌ **Don't:**
```dart
Container(width: 300, height: 200)
Text('Hello', style: TextStyle(fontSize: 16))
SizedBox(height: 20)
```

✅ **Do:**
```dart
Container(
  width: Responsive.width(context, 0.8),
  height: Responsive.height(context, 0.25),
)
Text(
  'Hello',
  style: TextStyle(fontSize: Responsive.fontSize(context, 16)),
)
SizedBox(height: Responsive.spacing(context, 20))
```
