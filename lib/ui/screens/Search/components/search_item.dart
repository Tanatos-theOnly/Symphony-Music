import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/ui/screens/Search/search_screen_controller.dart';
import '../../../widgets/liquid_glass.dart';
import '../../../navigator.dart';

class SearchItem extends StatelessWidget {
  final String queryString;
  final bool isHistoryString;
  const SearchItem(
      {super.key, required this.queryString, required this.isHistoryString});

  @override
  Widget build(BuildContext context) {
    final searchScreenController = Get.find<SearchScreenController>();
    return LiquidGlassCard(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      onTap: () {
        Get.toNamed(ScreenNavigationSetup.searchResultScreen,
            id: ScreenNavigationSetup.id, arguments: queryString);
        searchScreenController.addToHistryQueryList(queryString);
        // for Desktop searchbar
        if (GetPlatform.isDesktop) {
          searchScreenController.focusNode.unfocus();
        }
      },
      child: Row(
        children: [
          Icon(
            isHistoryString ? Icons.history : Icons.search,
            size: 20,
            color: Colors.white70,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              queryString,
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
          if (isHistoryString)
            IconButton(
              iconSize: 18,
              splashRadius: 18,
              visualDensity: const VisualDensity(horizontal: -2),
              onPressed: () {
                searchScreenController.removeQueryFromHistory(queryString);
              },
              icon: Icon(
                Icons.clear,
                color: Theme.of(context).textTheme.titleMedium!.color,
              ),
            ),
          IconButton(
            iconSize: 20,
            splashRadius: 18,
            visualDensity: const VisualDensity(horizontal: -2),
            onPressed: () {
              searchScreenController.suggestionInput(queryString);
            },
            icon: Icon(
              Icons.north_west,
              color: Theme.of(context).textTheme.titleMedium!.color,
            ),
          ),
        ],
      ),
    );
  }
}