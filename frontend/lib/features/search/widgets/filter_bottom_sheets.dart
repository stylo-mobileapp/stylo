import 'package:flutter/cupertino.dart';
import 'package:frontend/core/constants/constants.dart';
import 'package:frontend/core/text_sizes/text_sizes.dart';
import 'package:frontend/core/theme/palette.dart';

void showMultiSelectFilterSheet({
  required BuildContext context,
  required String title,
  required List<String> allOptions,
  required List<String> initiallySelected,
  required Function(List<String>) onApply,
}) {
  showCupertinoModalPopup(
    context: context,
    builder: (context) => _MultiSelectSheet(
      title: title,
      allOptions: allOptions,
      initiallySelected: initiallySelected,
      onApply: onApply,
    ),
  );
}

class _MultiSelectSheet extends StatefulWidget {
  final String title;
  final List<String> allOptions;
  final List<String> initiallySelected;
  final Function(List<String>) onApply;

  const _MultiSelectSheet({
    required this.title,
    required this.allOptions,
    required this.initiallySelected,
    required this.onApply,
  });

  @override
  State<_MultiSelectSheet> createState() => _MultiSelectSheetState();
}

class _MultiSelectSheetState extends State<_MultiSelectSheet> {
  late Set<String> _selected;

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

    double sheetHeight = widget.allOptions.length > 5
        ? height * 0.9
        : height * 0.7;

    return Container(
      width: width,
      height: sheetHeight,
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
                    widget.title,
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
                      color: Palette.blackColor,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: height * 0.02),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(
                  horizontal: Constants.horizontalSpacing(context),
                ),
                itemCount: widget.allOptions.length,
                itemBuilder: (context, index) {
                  final option = widget.allOptions[index];
                  final isSelected = _selected.contains(option);

                  return GestureDetector(
                    onTap: () => _toggleOption(option),
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
                            option,
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

// -----------------------------------------------------------------------------
// PRICE FILTER (SLIDER)
// -----------------------------------------------------------------------------

void showPriceFilterSheet({
  required BuildContext context,
  required double? minPrice,
  required double? maxPrice,
  required Function(double?, double?) onApply,
}) {
  showCupertinoModalPopup(
    context: context,
    builder: (context) => _PriceFilterSheet(
      minPrice: minPrice,
      maxPrice: maxPrice,
      onApply: onApply,
    ),
  );
}

class PriceRangeOption {
  final String label;
  final double? min;
  final double? max;

  const PriceRangeOption(this.label, this.min, this.max);

  bool matches(double? currentMin, double? currentMax) {
    return min == currentMin && max == currentMax;
  }
}

const List<PriceRangeOption> _priceRanges = [
  PriceRangeOption("Under €50", 0, 50),
  PriceRangeOption("€50 - €100", 50, 100),
  PriceRangeOption("€100 - €200", 100, 200),
  PriceRangeOption("€200 - €500", 200, 500),
  PriceRangeOption("Over €500", 500, null),
];

class _PriceFilterSheet extends StatefulWidget {
  final double? minPrice;
  final double? maxPrice;
  final Function(double?, double?) onApply;

  const _PriceFilterSheet({
    required this.minPrice,
    required this.maxPrice,
    required this.onApply,
  });

  @override
  State<_PriceFilterSheet> createState() => _PriceFilterSheetState();
}

class _PriceFilterSheetState extends State<_PriceFilterSheet> {
  double? _currentMin;
  double? _currentMax;

  @override
  void initState() {
    super.initState();
    _currentMin = widget.minPrice;
    _currentMax = widget.maxPrice;
  }

  void _selectRange(PriceRangeOption option) {
    setState(() {
      if (_currentMin == option.min && _currentMax == option.max) {
        _currentMin = null;
        _currentMax = null;
      } else {
        _currentMin = option.min;
        _currentMax = option.max;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double height = Constants.height(context);
    double width = Constants.width(context);

    return Container(
      width: width,
      height: height * 0.7,
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
                  SizedBox(width: Constants.iconSize(context) * 1.2),
                  Text(
                    "PRICE",
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
                      color: Palette.blackColor,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: height * 0.02),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(
                  horizontal: Constants.horizontalSpacing(context),
                ),
                itemCount: _priceRanges.length,
                itemBuilder: (context, index) {
                  final option = _priceRanges[index];
                  final isSelected = option.matches(_currentMin, _currentMax);

                  return GestureDetector(
                    onTap: () => _selectRange(option),
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
                            option.label,
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
                          _currentMin = null;
                          _currentMax = null;
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
                        widget.onApply(_currentMin, _currentMax);
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
