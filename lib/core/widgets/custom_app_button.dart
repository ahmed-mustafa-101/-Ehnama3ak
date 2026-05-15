// import 'package:flutter/material.dart';

// class CustomSmallButton extends StatelessWidget {
//   final String label;
//   final VoidCallback onPressed;
//   final IconData? icon;
//   final double width;
//   final double height;
//   final double radius;
//   final double fontSize;
//   final dynamic backgroundColor;

//   const CustomSmallButton({
//     super.key,
//     required this.label,
//     required this.onPressed,
//     this.icon,
//     this.width = 80,
//     this.height = 35,
//     this.radius = 10,
//     this.fontSize = 10,
//     this.backgroundColor = const Color(0xFF0DA5FE),
//   });

//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       width: width,
//       height: height,
//       child: ElevatedButton(
//         onPressed: onPressed,
//         style: ElevatedButton.styleFrom(
//           backgroundColor: backgroundColor,
//           padding: EdgeInsets.zero,
//           minimumSize: Size.zero,
//           tapTargetSize: MaterialTapTargetSize.shrinkWrap,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(radius),
//           ),
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             if (icon != null) ...[
//               Icon(icon, size: 14, color: Colors.white),
//               const SizedBox(width: 4),
//             ],
//             Text(
//               label,
//               style: TextStyle(
//                 fontSize: fontSize,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.white,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';

class CustomSmallButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final IconData? icon;
  final double? width;
  final double? height;
  final double radius;
  final double fontSize;
  final Color backgroundColor;

  const CustomSmallButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.width,
    this.height,
    this.radius = 10,
    this.fontSize = 12,
    this.backgroundColor = const Color(0xFF0DA5FE),
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return SizedBox(
      width: width ?? screenWidth * 0.18,
      height: height ?? screenWidth * 0.1,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
        ),
        child: FittedBox(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: screenWidth * 0.04, color: Colors.white),
                const SizedBox(width: 4),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
