import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/constants/constants.dart';
import 'package:frontend/core/text_sizes/text_sizes.dart';
import 'package:frontend/core/theme/palette.dart';
import 'package:frontend/navigation_page.dart';
import 'package:frontend/features/search/controller/search_controller.dart';
import 'package:frontend/features/search/pages/search_results_page.dart';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  void _onSearch(String query) {
    if (query.trim().isEmpty) return;

    // update provider
    ref.read(searchQueryProvider.notifier).state = query.trim();
    // add to history
    ref.read(recentSearchesProvider.notifier).add(query.trim());

    // clear input for next time
    _textController.clear();

    // navigate
    Navigator.of(
      context,
    ).push(CupertinoPageRoute(builder: (context) => const SearchResultsPage()));
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Listen for tab changes to refocus the search field
    ref.listen<int>(navigationPageIndexProvider, (previous, next) {
      if (next == 1 && (ModalRoute.of(context)?.isCurrent ?? false)) {
        _focusNode.requestFocus();
      }
    });

    double height = Constants.height(context);
    double width = Constants.width(context);
    final recentSearches = ref.watch(recentSearchesProvider);

    return CupertinoPageScaffold(
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: Constants.horizontalSpacing(context),
              ),
              child: CupertinoSearchTextField(
                controller: _textController,
                focusNode: _focusNode,
                placeholder: "Search (e.g 'Asics Novablast 4')",
                autofocus: true,
                onSubmitted: _onSearch,
              ),
            ),
            if (recentSearches.isNotEmpty) ...[
              SizedBox(height: height * 0.025),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: Constants.horizontalSpacing(context),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recent Searches',
                      style: TextStyle(
                        fontSize: TextSizes.medium(context),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: recentSearches.length,
                  itemBuilder: (context, index) {
                    final searchStr = recentSearches[index];
                    return CupertinoButton(
                      padding: EdgeInsets.symmetric(
                        horizontal: Constants.horizontalSpacing(context),
                        vertical: height * 0.015,
                      ),
                      onPressed: () => _onSearch(searchStr),
                      child: Row(
                        children: [
                          Icon(
                            CupertinoIcons.time,
                            size: Constants.iconSize(context),
                            color: Palette.mediumGreyColor,
                          ),
                          SizedBox(width: width * 0.025),
                          Expanded(
                            child: Text(
                              searchStr,
                              style: TextStyle(
                                fontSize: TextSizes.medium(context),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              ref
                                  .read(recentSearchesProvider.notifier)
                                  .remove(searchStr);
                            },
                            child: Icon(
                              CupertinoIcons.clear_circled,
                              size: Constants.iconSize(context),
                              color: Palette.mediumGreyColor,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
