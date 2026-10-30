import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'components/search_item.dart';
import '/ui/screens/Settings/settings_screen_controller.dart';
import '../../widgets/modified_text_field.dart';
import '../../widgets/liquid_glass.dart';
import '/ui/navigator.dart';
import 'search_screen_controller.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final searchScreenController = Get.put(SearchScreenController());
    final settingsScreenController = Get.find<SettingsScreenController>();
    final topPadding = context.isLandscape ? 50.0 : 70.0;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Obx(
        () {
          final isBottomNav = settingsScreenController.isBottomNavBarEnabled.isTrue;
          return Row(
            children: [
              if (!isBottomNav)
                Container(
                  width: 60,
                  color: Theme.of(context).navigationRailTheme.backgroundColor,
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: topPadding),
                        child: FlowyButton(
                          onTap: () {
                            Get.nestedKey(ScreenNavigationSetup.id)!
                                .currentState!
                                .pop();
                          },
                          child: LiquidGlassPebble(
                            width: 42,
                            height: 42,
                            isCircle: true,
                            borderRadius: BorderRadius.circular(21),
                            chromaticColor: const Color(0xFF4FA5FF),
                            highlightIntensity: 1.0,
                            hasDropShadow: false,
                            padding: EdgeInsets.zero,
                            child: const Icon(
                              Icons.arrow_back_ios_new,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    top: topPadding,
                    left: isBottomNav ? 16.0 : 8.0,
                    right: 16.0,
                  ),
                  child: Column(
                    children: [
                      // Header Row with Back Button in Bottom Nav Mode
                      Row(
                        children: [
                          if (isBottomNav) ...[
                            FlowyButton(
                              onTap: () {
                                Get.nestedKey(ScreenNavigationSetup.id)!
                                    .currentState!
                                    .pop();
                              },
                              child: LiquidGlassPebble(
                                width: 38,
                                height: 38,
                                isCircle: true,
                                borderRadius: BorderRadius.circular(19),
                                chromaticColor: const Color(0xFF4FA5FF),
                                highlightIntensity: 1.0,
                                hasDropShadow: false,
                                padding: EdgeInsets.zero,
                                child: const Icon(
                                  Icons.arrow_back_ios_new,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                          ],
                          Text(
                            "search".tr,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Perfectly Centered & Aligned Liquid Glass Search Input Bar
                      LiquidGlassContainer(
                        borderRadius: BorderRadius.circular(16),
                        blurSigma: 16,
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                        child: ModifiedTextField(
                          textCapitalization: TextCapitalization.sentences,
                          controller: searchScreenController.textInputController,
                          textInputAction: TextInputAction.search,
                          textAlignVertical: TextAlignVertical.center,
                          onChanged: searchScreenController.onChanged,
                          onSubmitted: (val) {
                            if (val.contains("https://")) {
                              searchScreenController.filterLinks(Uri.parse(val));
                              searchScreenController.reset();
                              return;
                            }
                            Get.toNamed(ScreenNavigationSetup.searchResultScreen,
                                id: ScreenNavigationSetup.id, arguments: val);
                            searchScreenController.addToHistryQueryList(val);
                          },
                          autofocus: settingsScreenController
                              .isBottomNavBarEnabled.isFalse,
                          cursorColor: Theme.of(context).textTheme.bodySmall!.color,
                          decoration: InputDecoration(
                            isDense: true,
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            prefixIcon: const Icon(
                              Icons.search,
                              size: 20,
                              color: Colors.white70,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 12,
                            ),
                            focusColor: Colors.white,
                            hintText: "searchDes".tr,
                            suffix: IconButton(
                              onPressed: searchScreenController.reset,
                              icon: const Icon(Icons.close),
                              splashRadius: 16,
                              iconSize: 19,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // History / Suggestions List
                      Expanded(
                        child: Obx(() {
                          final isEmpty = searchScreenController
                                  .suggestionList.isEmpty ||
                              searchScreenController.textInputController.text ==
                                  "";
                          final list = isEmpty
                              ? searchScreenController.historyQuerylist.toList()
                              : searchScreenController.suggestionList.toList();
                          return ListView(
                            padding: const EdgeInsets.only(top: 4, bottom: 400),
                            physics: const BouncingScrollPhysics(
                                parent: AlwaysScrollableScrollPhysics()),
                            children: searchScreenController.urlPasted.isTrue
                                ? [
                                    InkWell(
                                      onTap: () {
                                        searchScreenController.filterLinks(
                                            Uri.parse(searchScreenController
                                                .textInputController.text));
                                        searchScreenController.reset();
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 10.0),
                                        child: SizedBox(
                                          width: double.maxFinite,
                                          height: 60,
                                          child: Center(
                                            child: Text(
                                              "urlSearchDes".tr,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleMedium,
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                  ]
                                : list
                                    .map((item) => SearchItem(
                                        queryString: item,
                                        isHistoryString: isEmpty))
                                    .toList(),
                          );
                        }),
                      )
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
