import 'package:flutter/material.dart';
import 'package:shiny_counter/core/theme/tokens.dart';

class SearchGenFilterRow extends StatelessWidget {
  const SearchGenFilterRow({
    super.key,
    required this.searchController,
    required this.hintText,
    required this.query,
    required this.onQueryChanged,
    required this.onClearQuery,
    required this.allGensLabel,
    required this.selectedGen,
    required this.onGenChanged,
    this.cancelTooltip,
    this.genCount = 9,
  });

  static const Key searchFieldKey = ValueKey('searchGenFilter.searchField');
  static const Key clearButtonKey = ValueKey('searchGenFilter.clearButton');
  static const Key genDropdownKey = ValueKey('searchGenFilter.genDropdown');
  static Key genItemKey(int? gen) =>
      ValueKey('searchGenFilter.genItem.${gen ?? 'all'}');

  final TextEditingController searchController;
  final String hintText;
  final String query;
  final ValueChanged<String> onQueryChanged;
  final VoidCallback onClearQuery;

  final String allGensLabel;
  final int? selectedGen;
  final ValueChanged<int?> onGenChanged;
  final String? cancelTooltip;
  final int genCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            key: searchFieldKey,
            controller: searchController,
            onChanged: onQueryChanged,
            decoration: InputDecoration(
              hintText: hintText,
              prefixIcon: const Icon(Icons.search),
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(AppRadii.sm)),
              ),
              isDense: true,
              suffixIcon: query.isEmpty
                  ? null
                  : IconButton(
                      key: clearButtonKey,
                      icon: const Icon(Icons.close),
                      tooltip: cancelTooltip,
                      onPressed: onClearQuery,
                    ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        SizedBox(
          width: AppSizes.dropdownWidth,
          child: DropdownButtonFormField<int?>(
            key: genDropdownKey,
            initialValue: selectedGen,
            isDense: true,
            isExpanded: true,
            alignment: Alignment.centerLeft,
            decoration: const InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(AppRadii.sm)),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.sm,
              ),
            ),
            onChanged: onGenChanged,
            items: [
              DropdownMenuItem<int?>(
                key: genItemKey(null),
                value: null,
                child: Text(allGensLabel, overflow: TextOverflow.ellipsis),
              ),
              for (final gen in List.generate(genCount, (i) => i + 1))
                DropdownMenuItem<int?>(
                  key: genItemKey(gen),
                  value: gen,
                  child: Text('Gen $gen', overflow: TextOverflow.ellipsis),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
