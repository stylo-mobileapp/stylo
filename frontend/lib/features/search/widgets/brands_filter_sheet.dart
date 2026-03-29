import 'package:flutter/cupertino.dart';
import 'package:frontend/core/constants/constants.dart';
import 'package:frontend/core/text_sizes/text_sizes.dart';
import 'package:frontend/core/theme/palette.dart';

void showBrandsFilterSheet({
  required BuildContext context,
  required List<String> allOptions,
  required List<String> initiallySelected,
  required Function(List<String>) onApply,
}) {
  showCupertinoModalPopup(
    context: context,
    builder: (context) => _BrandsFilterSheet(
      allOptions: allOptions,
      initiallySelected: initiallySelected,
      onApply: onApply,
    ),
  );
}

class _BrandsFilterSheet extends StatefulWidget {
  final List<String> allOptions;
  final List<String> initiallySelected;
  final Function(List<String>) onApply;

  const _BrandsFilterSheet({
    required this.allOptions,
    required this.initiallySelected,
    required this.onApply,
  });

  @override
  State<_BrandsFilterSheet> createState() => _BrandsFilterSheetState();
}

class _BrandsFilterSheetState extends State<_BrandsFilterSheet> {
  late Set<String> _selected;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _selected = Set.from(widget.initiallySelected);
  }

  void _toggleOption(String option) {
    setState(() {
      if (_selected.contains(option)) {
        _selected.remove(option);
      } else {
        _selected.add(option);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double height = Constants.height(context);
    double width = Constants.width(context);

    final filteredBrands = widget.allOptions
        .where(
          (brand) => brand.toLowerCase().contains(_searchQuery.toLowerCase()),
        )
        .toList();

    return Container(
      width: width,
      height: height * 0.9,
      decoration: BoxDecoration(
        color: Palette.backgroundColor,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(Constants.borderRadius(context) * 2),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.symmetric(vertical: height * 0.01),
              width: width * 0.1,
              height: height * 0.005,
              decoration: BoxDecoration(
                color: Palette.borderColor,
                borderRadius: BorderRadius.circular(
                  Constants.borderRadius(context),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: Constants.horizontalSpacing(context),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_selected.isNotEmpty)
                    Container(
                      width: Constants.iconSize(context) * 1.2,
                      height: Constants.iconSize(context) * 1.2,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Palette.goldColor,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        _selected.length.toString(),
                        style: TextStyle(
                          fontSize: TextSizes.small(context),
                          fontWeight: FontWeight.bold,
                          color: Palette.whiteColor,
                        ),
                      ),
                    )
                  else
                    SizedBox(width: Constants.iconSize(context) * 1.2),
                  Text(
                    "BRANDS",
                    style: TextStyle(
                      fontSize: TextSizes.medium(context),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => Navigator.pop(context),
                    child: Icon(
                      CupertinoIcons.clear,
                      size: Constants.iconSize(context),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: height * 0.01),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: Constants.horizontalSpacing(context),
              ),
              child: CupertinoSearchTextField(
                placeholder: "Search",
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
            ),
            SizedBox(height: height * 0.02),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(
                  horizontal: Constants.horizontalSpacing(context),
                ),
                itemCount: filteredBrands.length,
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                itemBuilder: (context, index) {
                  final brand = filteredBrands[index];
                  final isSelected = _selected.contains(brand);

                  return GestureDetector(
                    onTap: () => _toggleOption(brand),
                    child: Container(
                      margin: EdgeInsets.only(bottom: height * 0.015),
                      padding: EdgeInsets.symmetric(
                        horizontal: width * 0.04,
                        vertical: height * 0.02,
                      ),
                      decoration: BoxDecoration(
                        color: Palette.whiteColor,
                        borderRadius: BorderRadius.circular(
                          Constants.borderRadius(context),
                        ),
                        border: Border.all(
                          color: isSelected
                              ? Palette.goldColor
                              : Palette.borderColor,
                          width: isSelected ? 1.5 : 1.0,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            brand,
                            style: TextStyle(
                              fontSize: TextSizes.medium(context),
                              color: isSelected
                                  ? Palette.goldColor
                                  : Palette.blackColor,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                          if (isSelected)
                            Icon(
                              CupertinoIcons.check_mark,
                              color: Palette.goldColor,
                              size: Constants.iconSize(context),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: Constants.horizontalSpacing(context),
                vertical: height * 0.02,
              ),
              decoration: BoxDecoration(
                color: Palette.backgroundColor,
                border: Border(top: BorderSide(color: Palette.borderColor)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        setState(() {
                          _selected.clear();
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Palette.whiteColor,
                          border: Border.all(color: Palette.blackColor),
                          borderRadius: BorderRadius.circular(
                            Constants.borderRadius(context),
                          ),
                        ),
                        alignment: Alignment.center,
                        padding: EdgeInsets.symmetric(vertical: height * 0.015),
                        child: Text(
                          "Clear All",
                          style: TextStyle(
                            fontSize: TextSizes.medium(context),
                            color: Palette.blackColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: width * 0.04),
                  Expanded(
                    child: CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        widget.onApply(_selected.toList());
                        Navigator.pop(context);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Palette.blackColor,
                          border: Border.all(color: Palette.blackColor),
                          borderRadius: BorderRadius.circular(
                            Constants.borderRadius(context),
                          ),
                        ),
                        alignment: Alignment.center,
                        padding: EdgeInsets.symmetric(vertical: height * 0.015),
                        child: Text(
                          "Apply",
                          style: TextStyle(
                            fontSize: TextSizes.medium(context),
                            color: Palette.whiteColor,
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
      ),
    );
  }
}
