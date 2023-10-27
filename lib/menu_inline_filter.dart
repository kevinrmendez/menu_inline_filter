library menu_inline_filter;

import 'package:flutter/material.dart';

class MenuInlineFilter extends StatefulWidget {
  //callback used when category selected
  final Function? updateCategory;
  //callback used when category subcategory selected
  final Function? updateSubCategory;
//list of list of subcategories
  final List<List<String>> subcategories;
  //list of categories
  final List<String> categories;
  //height of menu filter
  final double height;
  //horizontal padding of menu filter
  final double horizontalPadding;
  //background color of menu filter
  final Color backgroundColor;
  //selectedCategory color
  final Color selectedCategoryColor;
  //text color
  final Color textColor;
  //selected subcategory color
  final Color selectedSubCategoryColor;
  //unselected category color
  final Color unselectedCategoryColor;
  //unselected subcategory color
  final Color unselectedSubCategoryColor;
//font size
  final double fontSize;
  //font family
  final String fontFamily;

  final int animationDuration;

  const MenuInlineFilter({
    Key? key,
    this.updateCategory,
    required this.subcategories,
    required this.categories,
    this.updateSubCategory,
    this.height = 50,
    this.horizontalPadding = 15,
    this.backgroundColor = Colors.white,
    this.fontSize = 13,
    this.selectedCategoryColor = Colors.red,
    this.textColor = Colors.grey,
    this.selectedSubCategoryColor = Colors.black,
    this.unselectedCategoryColor = Colors.grey,
    this.unselectedSubCategoryColor = Colors.grey,
    this.fontFamily = 'roboto',
    this.animationDuration = 800,
  })  : assert(subcategories != null),
        assert(categories != null),
        assert(subcategories is List<List<String>>),
        assert(categories.length == subcategories.length),
        super(key: key);

  @override
  _MenuInlineFilterState createState() => _MenuInlineFilterState();
}

class _MenuInlineFilterState extends State<MenuInlineFilter>
    with TickerProviderStateMixin {
// horizontal offset of menu filter
  double? _horizontalOffset;
  // animation controller
  late AnimationController _controller;
  // animation
  late Animation<double> _animation;
  //menu items global keys
  late List<GlobalKey> globalkeys;
  //MenuCategoryAppBarItemExpandable global keu
  GlobalKey menuFilterKey = GlobalKey();
  //size of MenuCategoryAppBarItemExpandable widget
  double? filterSizeWidth;
  //size of individual menu item
  late double menuItemSize;
  // check if any item from menu filter is selected
  late bool _isCurrentItemShown;
  // scroll controller
  final ScrollController _scrollController = ScrollController();
  //current category index
  int? _selectedCategoryIndex;
  //current subcategory index
  int? _selectedSubCategoryIndex;
  //current selected subcategory
  String? _selectedSubcategory;

  @override
  void initState() {
    super.initState();
    _isCurrentItemShown = false;
    _horizontalOffset = 0;
    _selectedCategoryIndex = 0;
    _selectedSubcategory = "";
    globalkeys = widget.categories
        .map((value) => GlobalKey(debugLabel: value.toString()))
        .toList();
    filterSizeWidth = 0;
    menuItemSize = 0;
    WidgetsBinding.instance.addPostFrameCallback(_getMenuFilterSize);
    _controller = AnimationController(
      duration: Duration(milliseconds: widget.animationDuration),
      vsync: this,
    );
    _animation =
        Tween(begin: 1.0, end: 1 / _horizontalOffset!).animate(_controller);
  }

//change category index
  void _changeSelectedCategoryIndex(int value) {
    setState(() {
      _selectedCategoryIndex = value;
    });
  }

//change subcategory index
  void _changeSelectedSubCategoryIndex(int value) {
    setState(() {
      _selectedSubCategoryIndex = value;
    });
  }

  //change subcategory index
  void _changeSelectedSubCategory(String value) {
    setState(() {
      _selectedSubcategory = value;
    });
  }

//get total width of expandable menu filter
  void _getMenuFilterSize(Duration duration) {
    RenderBox? box =
        menuFilterKey.currentContext!.findRenderObject() as RenderBox?;
    setState(() {
      filterSizeWidth = box!.size.width;
    });
  }

//change menu filter horizontal offset
  void _changeHorizontalOffset() {
    final RenderBox box = globalkeys[_selectedCategoryIndex!]
        .currentContext!
        .findRenderObject() as RenderBox;
    var position = box.localToGlobal(Offset.zero);

    setState(() {
      _horizontalOffset = -position.dx +
          widget.horizontalPadding -
          _scrollController.position.pixels;
    });

    //scroll menu filter to beginning of scroll
    _scrollController.animateTo(0.0,
        duration: Duration(milliseconds: widget.animationDuration),
        curve: Curves.linear);

    _controller.forward().then((value) => {
          //show static current menu item
          setState(() {
            _isCurrentItemShown = true;
          })
        });
  }

//get size of individual menu Item
  void _getItemSize(String category) {
    final RenderBox? box = globalkeys[_selectedCategoryIndex!]
        .currentContext!
        .findRenderObject() as RenderBox?;

    setState(() {
      menuItemSize = box!.size.width;
      _animation = Tween(begin: 1.0, end: menuItemSize / filterSizeWidth!)
          .animate(_controller);
    });
  }

  //reset menu filter to original position
  void _resetOffset() {
    //make current item invisible
    setState(() {
      _isCurrentItemShown = false;
    });

    setState(() {
      _horizontalOffset = 0;
    });

    _controller.reverse();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
    _scrollController.dispose();
  }

//get subcategory test color based on menu filter state
  Color _getSubCategoryTextColor(String subcategory) {
    return _selectedSubcategory == ''
        ? widget.unselectedCategoryColor
        : widget.subcategories[_selectedCategoryIndex!].indexOf(subcategory) ==
                _selectedSubCategoryIndex
            ? widget.selectedSubCategoryColor
            : widget.unselectedSubCategoryColor;
  }

//get category test color based on menu filter state
  Color _getCategoryTextColor(String category) {
    return widget.categories.indexOf(category) == _selectedCategoryIndex
        ? widget.selectedCategoryColor
        : widget.unselectedCategoryColor;
  }

  @override
  Widget build(BuildContext context) {
    return MenuInlineFilterProvider(
      fontFamily: widget.fontFamily,
      fontSize: widget.fontSize,
      height: widget.height,
      child: Container(
        height: widget.height,
        padding: EdgeInsets.symmetric(horizontal: widget.horizontalPadding),
        color: widget.backgroundColor,
        margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
        child: Stack(
          children: [
            SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    SizeTransition(
                      axis: Axis.horizontal,
                      sizeFactor: _animation,
                      axisAlignment: -1,
                      child: Stack(
                        children: [
                          Container(
                            width: filterSizeWidth,
                          ),
                          AnimatedPositioned(
                            duration: Duration(
                                milliseconds: widget.animationDuration),
                            left: _horizontalOffset,
                            child: Row(
                              key: menuFilterKey,
                              children: [
                                Row(
                                    children: widget.categories
                                        .map(
                                          (category) => MenuCategoryAppBarItem(
                                            index: widget.categories
                                                .indexOf(category),
                                            changeSelectedCategoryIndex:
                                                _changeSelectedCategoryIndex,
                                            key: globalkeys[widget.categories
                                                .indexOf(category)],
                                            getItemSize: _getItemSize,
                                            selectedCategory: widget.categories[
                                                _selectedCategoryIndex!],
                                            resetHorizontalOffset: _resetOffset,
                                            changeMenuFilterOffset:
                                                _changeHorizontalOffset,
                                            title: category,
                                            updateCategory:
                                                widget.updateCategory,
                                            textColor:
                                                _getCategoryTextColor(category),
                                            menuItemCategory: category,
                                          ),
                                        )
                                        .toList()),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const VerticalDivider(),
                    //SUBCATEGORIES
                    Row(
                      children: widget.subcategories[_selectedCategoryIndex!]
                          .map(
                            (subcategory) => MenuSubCategoryAppBarItem(
                                index: widget
                                    .subcategories[_selectedCategoryIndex!]
                                    .indexOf(subcategory),
                                title: subcategory,
                                textColor:
                                    _getSubCategoryTextColor(subcategory),
                                updateSubCategory: widget.updateSubCategory,
                                selectedSubCategory: subcategory,
                                changeSelectedSubCategoryIndex:
                                    _changeSelectedSubCategoryIndex,
                                changeSelectedSubCategory:
                                    _changeSelectedSubCategory),
                          )
                          .toList(),
                    )
                  ],
                )),
            // CURRENT SELECTED MENU ITEM
            Positioned(
                left: 0,
                child: _isCurrentItemShown
                    ? Container(
                        color: Colors.white,
                        child: Row(
                          children: [
                            MenuAppBarItem(
                              onTapDown: (details) {
                                _scrollController
                                    .animateTo(0.0,
                                        duration: Duration(
                                            milliseconds:
                                                widget.animationDuration),
                                        curve: Curves.linear)
                                    .then((value) => _resetOffset());
                                //remove selection from subcategory when menu filter closed
                                setState(() {
                                  _selectedSubcategory = '';
                                });
                              },
                              title: widget.categories[_selectedCategoryIndex!],
                              textColor: widget.selectedCategoryColor,
                            ),
                            const VerticalDivider(),
                          ],
                        ),
                      )
                    : const SizedBox()),
          ],
        ),
      ),
    );
  }
}

class VerticalDivider extends StatelessWidget {
  const VerticalDivider({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 9),
      height: 17,
      decoration: const BoxDecoration(
          border: Border(right: BorderSide(width: 2.0, color: Colors.grey))),
    );
  }
}

class MenuInlineFilterProvider extends InheritedWidget {
  const MenuInlineFilterProvider({
    Key? key,
    required this.height,
    required this.fontSize,
    required this.fontFamily,
    required Widget child,
  })  : assert(child != null),
        super(key: key, child: child);

  final double height;
  final double fontSize;
  final String fontFamily;

  static MenuInlineFilterProvider? of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<MenuInlineFilterProvider>();
  }

  @override
  bool updateShouldNotify(MenuInlineFilterProvider old) {
    return true;
  }
}

class MenuCategoryAppBarItem extends StatefulWidget {
  final String title;

  final int index;
  final String? menuItemCategory;
  final Function? updateCategory;
  final Function? changeSelectedCategoryIndex;
  final Function? resetHorizontalOffset;
  final Function? getItemSize;
  final Function? changeMenuFilterOffset;
  final Color? textColor;
  final String? selectedCategory;

  const MenuCategoryAppBarItem({
    Key? key,
    required this.title,
    this.menuItemCategory,
    this.updateCategory,
    this.textColor,
    this.changeMenuFilterOffset,
    this.resetHorizontalOffset,
    this.selectedCategory,
    this.getItemSize,
    required this.index,
    this.changeSelectedCategoryIndex,
  }) : super(key: key);

  @override
  _MenuCategoryAppBarItemState createState() => _MenuCategoryAppBarItemState();
}

class _MenuCategoryAppBarItemState extends State<MenuCategoryAppBarItem> {
  // detect if menu item state is open or close
  late bool _isOpen;
  @override
  void initState() {
    _isOpen = false;
    super.initState();
  }

  void _moveMenuFilter(BuildContext context) {
    if (widget.selectedCategory == widget.menuItemCategory && !_isOpen) {
      widget.resetHorizontalOffset!();
    } else {
      widget.changeMenuFilterOffset!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MenuAppBarItem(
      onTapDown: (details) {
        setState(() {
          _isOpen = !_isOpen;
        });
        //update category for filtering menut list
        if (widget.updateCategory != null) {
          widget.updateCategory!(widget.menuItemCategory);
        }

        //change selected category index
        widget.changeSelectedCategoryIndex!(widget.index);
        //move menu filter based on menu item selection
        _moveMenuFilter(context);
        //get size of individual menu item (used for closed transition animation)
        widget.getItemSize!(widget.menuItemCategory);
      },
      title: widget.title,
      textColor: widget.textColor,
    );
  }
}

class MenuSubCategoryAppBarItem extends StatelessWidget {
  final int? index;
  final String title;
  final String? selectedSubCategory;
  final Function? updateSubCategory;
  final Function? changeSelectedSubCategoryIndex;
  final Function? changeSelectedSubCategory;
  final Color? textColor;

  const MenuSubCategoryAppBarItem({
    Key? key,
    required this.title,
    this.selectedSubCategory,
    this.updateSubCategory,
    this.textColor,
    this.index,
    this.changeSelectedSubCategoryIndex,
    this.changeSelectedSubCategory,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MenuAppBarItem(
      onTapDown: (details) {
        if (updateSubCategory != null) {
          updateSubCategory!(selectedSubCategory);
        }
        changeSelectedSubCategoryIndex!(index);
        changeSelectedSubCategory!(selectedSubCategory);
      },
      title: title,
      textColor: textColor,
    );
  }
}

class MenuAppBarItem extends StatelessWidget {
  const MenuAppBarItem({
    Key? key,
    required this.title,
    this.textColor = Colors.grey,
    this.onTapDown,
  }) : super(key: key);

  final String title;
  final Color? textColor;

  final void Function(TapDownDetails)? onTapDown;

  @override
  Widget build(BuildContext context) {
    MenuInlineFilterProvider _menuInlineFilterProvider =
        MenuInlineFilterProvider.of(context)!;

    return GestureDetector(
      onTapDown: onTapDown,
      child: Container(
        height: _menuInlineFilterProvider.height,
        margin: const EdgeInsets.symmetric(horizontal: 5),
        child: Center(
          child: Text(title.toUpperCase(),
              overflow: TextOverflow.fade,
              style: TextStyle(
                  color: textColor,
                  fontSize: _menuInlineFilterProvider.fontSize,
                  fontFamily: _menuInlineFilterProvider.fontFamily)),
        ),
      ),
    );
  }
}
