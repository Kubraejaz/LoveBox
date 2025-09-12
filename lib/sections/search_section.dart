import 'package:flutter/material.dart';
import '../constants/color.dart';
import '../constants/strings.dart';

class SearchSection extends StatelessWidget {
  const SearchSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: AppColors.inputFill,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200, width: 1),
      ),
      child: const TextField(
        decoration: InputDecoration(
          hintText: AppStrings.searchHint,
          hintStyle: TextStyle(color: Colors.grey),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          prefixIcon: Icon(Icons.search, color: Colors.grey),
        ),
      ),
    );
  }
}
