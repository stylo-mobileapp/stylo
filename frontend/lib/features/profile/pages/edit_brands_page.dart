import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/constants/constants.dart';
import 'package:frontend/core/providers/providers.dart';
import 'package:frontend/core/text_sizes/text_sizes.dart';
import 'package:frontend/core/theme/palette.dart';
import 'package:frontend/core/widgets/loading.dart';
import 'package:frontend/features/profile/controller/profile_controller.dart';

class EditBrandsPage extends ConsumerStatefulWidget {
  const EditBrandsPage({super.key});

  @override
  ConsumerState<EditBrandsPage> createState() => _EditBrandsPageState();
}

class _EditBrandsPageState extends ConsumerState<EditBrandsPage> {
  String _searchQuery = '';
  late List<String> _selectedBrands;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double height = Constants.height(context);
    double width = Constants.width(context);

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        padding: EdgeInsetsDirectional.symmetric(
          horizontal: Constants.horizontalSpacing(context),
        ),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          minimumSize: Size.zero,
          onPressed: () {
            Navigator.pop(context);
          },
          child: Icon(
            CupertinoIcons.arrow_left,
            size: Constants.iconSize(context),
          ),
        ),
        middle: Text(
          'Favorite brands',
          style: TextStyle(
            fontSize: TextSizes.medium(context),
            fontWeight: FontWeight.bold,
          ),
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          minimumSize: Size.zero,
          onPressed: () {
            if (!_initialized) return;
            ref
                .read(profileControllerProvider.notifier)
                .updateBrands(context: context, brands: _selectedBrands);
            Navigator.pop(context);
          },
          child: Text(
            'Save',
            style: TextStyle(
              fontSize: TextSizes.medium(context),
              color: Palette.blackColor,
            ),
          ),
        ),
      ),
      child: SafeArea(
        child: ref
            .watch(userProfileProvider)
            .when(
              data: (userProfile) {
                if (userProfile == null) {
                  return const Center(child: Text("Profile not found"));
                }

                if (!_initialized) {
                  _selectedBrands = List.from(userProfile.brands);
                  _initialized = true;
                }

                return Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: Constants.horizontalSpacing(context),
                  ),
                  child: Column(
                    children: [
                      SizedBox(height: height * 0.02),
                      CupertinoSearchTextField(
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
                                  itemBuilder: (context, index) {
                                    String brand = filteredData[index];
                                    bool isSelected = _selectedBrands.contains(
                                      brand,
                                    );

                                    return Container(
                                      margin: EdgeInsets.only(
                                        top: height * 0.02,
                                      ),
                                      child: Row(
                                        children: [
                                          Text(
                                            brand,
                                            style: TextStyle(
                                              fontSize: TextSizes.medium(
                                                context,
                                              ),
                                            ),
                                          ),
                                          Spacer(),
                                          CupertinoButton(
                                            padding: EdgeInsets.zero,
                                            onPressed: () {
                                              setState(() {
                                                if (isSelected) {
                                                  _selectedBrands.remove(brand);
                                                } else {
                                                  _selectedBrands.add(brand);
                                                }
                                              });
                                            },
                                            child: Container(
                                              padding: EdgeInsets.symmetric(
                                                vertical: height * 0.005,
                                                horizontal: width * 0.025,
                                              ),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                      Constants.borderRadius(
                                                        context,
                                                      ),
                                                    ),
                                                color: isSelected
                                                    ? Palette.whiteColor
                                                    : Palette.blackColor,
                                                border: Border.all(
                                                  color: Palette.blackColor,
                                                ),
                                              ),
                                              child: Text(
                                                isSelected
                                                    ? "Following"
                                                    : "Follow",
                                                style: TextStyle(
                                                  fontSize: TextSizes.medium(
                                                    context,
                                                  ),
                                                  color: isSelected
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
                      onPressed: () => ref.refresh(userProfileProvider),
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
    );
  }
}
