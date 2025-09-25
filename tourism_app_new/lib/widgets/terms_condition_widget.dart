import 'package:flutter/material.dart';
import 'package:tourism_app_new/constants/colors.dart';

class TermsConditionsWidget {
  /// Shows a modal bottom sheet with terms and conditions
  static void showTermsAndConditions({
    required BuildContext context,
    required List<String> terms,
    String title = 'Terms & Conditions',
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TermsBottomSheet(terms: terms, title: title),
    );
  }

  /// Returns a clickable text widget that opens terms modal
  static Widget buildTermsButton({
    required BuildContext context,
    required List<String> terms,
    String text = 'Terms & Conditions Apply',
    TextStyle? textStyle,
    String title = 'Terms & Conditions',
  }) {
    return GestureDetector(
      onTap:
          () => showTermsAndConditions(
            context: context,
            terms: terms,
            title: title,
          ),
      child: Text(
        text,
        style:
            textStyle ??
            TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              decoration: TextDecoration.underline,
            ),
      ),
    );
  }

  /// Returns a clickable button widget that opens terms modal
  static Widget buildTermsButtonWidget({
    required BuildContext context,
    required List<String> terms,
    String text = 'View Terms & Conditions',
    String title = 'Terms & Conditions',
    Color? color,
    IconData? icon,
  }) {
    return TextButton.icon(
      onPressed:
          () => showTermsAndConditions(
            context: context,
            terms: terms,
            title: title,
          ),
      icon: Icon(
        icon ?? Icons.description_outlined,
        size: 16,
        color: color ?? Colors.blue,
      ),
      label: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: color ?? Colors.blue,
          decoration: TextDecoration.underline,
        ),
      ),
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}

class TermsBottomSheet extends StatelessWidget {
  final List<String> terms;
  final String title;

  const TermsBottomSheet({Key? key, required this.terms, required this.title})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 10),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(Icons.description, color: AppColors.mainGreen, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.grey[100],
                    padding: const EdgeInsets.all(8),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Terms list
          Expanded(
            child:
                terms.isEmpty
                    ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.description_outlined,
                            size: 64,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No terms available',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                    : ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: terms.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: const EdgeInsets.only(top: 8),
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: AppColors.mainGreen,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  terms[index],
                                  style: const TextStyle(
                                    fontSize: 14,
                                    height: 1.5,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
          ),
          // Footer with close button
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              border: Border(top: BorderSide(color: Colors.grey[200]!)),
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.mainGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'I Understand',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
