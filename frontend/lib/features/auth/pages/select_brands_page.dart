import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/constants/constants.dart';
import 'package:frontend/core/providers/providers.dart';
import 'package:frontend/core/text_sizes/text_sizes.dart';
import 'package:frontend/core/theme/palette.dart';
import 'package:frontend/core/widgets/loading.dart';
import 'package:frontend/features/auth/pages/auth_page.dart';

class SelectBrandsPage extends ConsumerStatefulWidget {
  const SelectBrandsPage({super.key});

  @override
  ConsumerState<SelectBrandsPage> createState() => _SelectBrandsPageState();
}

class _SelectBrandsPageState extends ConsumerState<SelectBrandsPage> {
  String _searchQuery = '';
  late FocusNode _searchFocusNode;

  @override
  void initState() {
    super.initState();
    _searchFocusNode = FocusNode();
    _searchFocusNode.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double height = Constants.height(context);
    double width = Constants.width(context);
    List<String> brands = ref.watch(authBrandsProvider);

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: Constants.horizontalSpacing(context),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () =>
                            ref.read(authPageIndexProvider.notifier).state = 0,
                        child: Icon(
                          CupertinoIcons.arrow_left,
                          size: Constants.iconSize(context),
                        ),
                      ),
                      Spacer(),
                      Text(
                        "Personalise your feed",
                        style: TextStyle(fontSize: TextSizes.medium(context)),
                      ),
                      Spacer(),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () {},
                        child: Icon(null, size: Constants.iconSize(context)),
                      ),
                    ],
                  ),
                  SizedBox(height: height * 0.04),
                  Text(
                    brands.isEmpty
                        ? "Select some of your favourites brands"
                        : brands.length < 3
                        ? "Great! How about a few more?"
                        : "Nice! Are there any more brands you like?",
                    style: TextStyle(
                      fontSize: TextSizes.large(context),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: height * 0.02),
                  CupertinoSearchTextField(
                    focusNode: _searchFocusNode,
                    placeholder: "Search for 'Nike'",
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                  Expanded(
                    child: ref
                        .watch(fetchAllBrandsProvider)
                        .when(
                          data: (data) {
                            final filteredData = data
                                .where(
                                  (brand) => brand.toLowerCase().contains(
                                    _searchQuery.toLowerCase(),
                                  ),
                                )
                                .toList();

                            return ListView.builder(
                              itemCount: filteredData.length,
                              keyboardDismissBehavior:
                                  ScrollViewKeyboardDismissBehavior.onDrag,
                              itemBuilder: (context, index) {
                                String brand = filteredData[index];

                                return Container(
                                  margin: EdgeInsets.only(top: height * 0.02),
                                  child: Row(
                                    children: [
                                      Text(
                                        brand,
                                        style: TextStyle(
                                          fontSize: TextSizes.medium(context),
                                        ),
                                      ),
                                      Spacer(),
                                      CupertinoButton(
                                        padding: EdgeInsets.zero,
                                        onPressed: () {
                                          ref
                                              .read(authBrandsProvider.notifier)
                                              .update((state) {
                                                if (state.contains(brand)) {
                                                  return state
                                                      .where((b) => b != brand)
                                                      .toList();
                                                } else {
                                                  return [...state, brand];
                                                }
                                              });
                                        },
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                            vertical: height * 0.005,
                                            horizontal: width * 0.025,
                                          ),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              Constants.borderRadius(context),
                                            ),
                                            color: brands.contains(brand)
                                                ? Palette.whiteColor
                                                : Palette.blackColor,
                                            border: Border.all(
                                              color: Palette.blackColor,
                                            ),
                                          ),
                                          child: Text(
                                            brands.contains(brand)
                                                ? "Following"
                                                : "Follow",
                                            style: TextStyle(
                                              fontSize: TextSizes.medium(
                                                context,
                                              ),
                                              color: brands.contains(brand)
                                                  ? Palette.blackColor
                                                  : Palette.whiteColor,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                          error: (error, stackTrace) => SizedBox(
                            width: double.infinity,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(height: height * 0.02),
                                Text(
                                  "Sorry, we couldn't find anything like that.",
                                  style: TextStyle(
                                    fontSize: TextSizes.medium(context),
                                    color: Palette.mediumGreyColor,
                                  ),
                                ),
                                CupertinoButton(
                                  padding: EdgeInsets.zero,
                                  onPressed: () =>
                                      ref.refresh(fetchAllBrandsProvider),
                                  child: Text(
                                    "Try again",
                                    style: TextStyle(
                                      fontSize: TextSizes.medium(context),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          loading: () => const Loading(),
                        ),
                  ),
                ],
              ),
            ),
          ),
          if (!_searchFocusNode.hasFocus)
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: Constants.horizontalSpacing(context),
                vertical: height * 0.02,
              ),
              decoration: BoxDecoration(
                border: Border.symmetric(
                  horizontal: BorderSide(color: Palette.borderColor),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    "This helps build a fully personalised fashion shopping experience, just for you.",
                    style: TextStyle(
                      fontSize: TextSizes.medium(context),
                      color: Palette.mediumGreyColor,
                    ),
                  ),
                  SizedBox(height: height * 0.015),
                  brands.isNotEmpty
                      ? CupertinoButton(
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            ref.read(authPageIndexProvider.notifier).state = 2;
                          },
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(
                              vertical: height * 0.015,
                            ),
                            decoration: BoxDecoration(
                              color: Palette.blackColor,
                              border: Border.all(color: Palette.blackColor),
                              borderRadius: BorderRadius.circular(
                                Constants.borderRadius(context),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                "Done",
                                style: TextStyle(
                                  fontSize: TextSizes.medium(context),
                                  color: Palette.whiteColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        )
                      : Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                            vertical: height * 0.015,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: Palette.blackColor),
                            color: Palette.softGreyColor,
                            borderRadius: BorderRadius.circular(
                              Constants.borderRadius(context),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              "Done",
                              style: TextStyle(
                                fontSize: TextSizes.medium(context),
                                color: Palette.mediumGreyColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                  SizedBox(height: height * 0.01),
                  Divider(color: Palette.borderColor),
                  SizedBox(height: height * 0.01),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      ref.read(authPageIndexProvider.notifier).state = 2;
                    },
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: height * 0.015),
                      decoration: BoxDecoration(
                        border: Border.all(color: Palette.blackColor),
                        borderRadius: BorderRadius.circular(
                          Constants.borderRadius(context),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          "Skip this step",
                          style: TextStyle(
                            fontSize: TextSizes.medium(context),
                            color: Palette.blackColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
