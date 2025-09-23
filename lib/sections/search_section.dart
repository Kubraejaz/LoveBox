import 'package:flutter/material.dart';
import '../constants/color.dart';
import '../constants/strings.dart';

class SearchSection extends StatelessWidget {
  final ValueChanged<String> onSearchChanged; // ✅ callback

  const SearchSection({super.key, required this.onSearchChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: AppColors.inputFill,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade400, width: 1),
      ),
      child: TextField(
        onChanged: onSearchChanged, // ✅ send query upwards
        decoration: const InputDecoration(
          hintText: AppStrings.searchHint,
          hintStyle: TextStyle(color: Colors.grey),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          prefixIcon: Icon(Icons.search, color: Colors.grey),
        ),
      ),
    );
  }
}
