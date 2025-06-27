import 'package:flutter/material.dart';
import 'package:tourism_app_new/constants/colors.dart';

class CommonButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isLoading;
  final double height;
  final double fontSize;
  final Color backgroundColor;
  final double borderRadius;

  const CommonButton({
    Key? key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.height = 50,
    this.fontSize = 16,
    this.backgroundColor = AppColors.buttonColor,
    this.borderRadius = 30,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return SizedBox(
      width: double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        child:
            isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : Text(
                  label,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: fontSize != 0 ? fontSize : screenHeight * 0.02,
                  ),
                ),
      ),
    );
  }
}
