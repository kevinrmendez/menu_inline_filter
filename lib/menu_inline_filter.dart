library menu_inline_filter;

import 'package:flutter/material.dart';

class MenuInlineFilter extends StatefulWidget {
  final Function updateCategory;
  final Function updateSubCategory;

  final List<List<String>> subcategories;
  final List<String> categories;
  final double height;
  final double horizontalPadding;
  final Color backgroundColor;

  const MenuInlineFilter({
    Key key,
    this.updateCategory,
    @required this.subcategories,
    @required this.categories,
    this.updateSubCategory,
    this.height = 50,
    this.horizontalPadding = 15,
    this.backgroundColor = Colors.white,
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
  double _horizontalOffset;
  //current MenuItemCategory
  String _selectecCategory;
  // animation controller
  AnimationController _controller;
  // animation
  Animation<double> _animation;
  //menu items global keys
  List<GlobalKey> globalkeys;
  //MenuInlineFilter global keu
  GlobalKey menuFilterKey = GlobalKey();
  //size of MenuInlineFilter widget
  double filterSizeWidth;
  //size of individual menu item
  double menuItemSize;
  // check if any item from menu filter is selected
  bool _isCurrentItemSelected;
  // scroll controller
  final ScrollController _scrollController = ScrollController();
  // animation duration
  static const int _animationDuration = 800;
  //current category index
  int _selectedCategoryIndex;
  //current subcategory index
  int _selectedSubCategoryIndex;

  @override
  void initState() {
    super.initState();
    _isCurrentItemSelected = false;
    _horizontalOffset = 0;
    _selectedCategoryIndex = 0;
    _selectecCategory = widget.categories[0];
    globalkeys = widget.categories
        .map((value) => GlobalKey(debugLabel: value.toString()))
        .toList();
    filterSizeWidth = 0;
    menuItemSize = 0;
    WidgetsBinding.instance.addPostFrameCallback(_getMenuFilterSize);
    _controller = AnimationController(
      duration: const Duration(milliseconds: _animationDuration),
      vsync: this,
    );
    _animation =
        Tween(begin: 1.0, end: 1 / _horizontalOffset).animate(_controller);
  }

  void _changeSelectedCategory(String value) {
    setState(() {
      _selectecCategory = value;
    });
  }

  void _changeSelectedSubCategory(String value) {
    setState(() {
      _selectecCategory = value;
    });
  }

  void _changeSelectedCategoryIndex(int value) {
    setState(() {
      _selectedCategoryIndex = value;
    });
  }

  void _changeSelectedSubCategoryIndex(int value) {
    setState(() {
      _selectedSubCategoryIndex = value;
    });
  }

//get total width of expandable menu filter
  void _getMenuFilterSize(Duration duration) {
    RenderBox box =
        menuFilterKey.currentContext.findRenderObject() as RenderBox;
    setState(() {
      filterSizeWidth = box.size.width;
    });
  }

  void _changeHorizontalOffset() {
    //difference between offset and menuitembar width size(70)
    // some padding 12
    //change offset based on enum index MenuItemCategory
    final RenderBox box = globalkeys[_selectedCategoryIndex]
        .currentContext
        .findRenderObject() as RenderBox;
    var position = box.localToGlobal(Offset.zero);

    print("POS: $position");
    setState(() {
      // _horizontalOffset = -80 * _selectecCategory.index.toDouble();
      _horizontalOffset = -position.dx +
          widget.horizontalPadding -
          _scrollController.position.pixels;
    });

    //scroll menu filter to beginning of scroll
    _scrollController.animateTo(0.0,
        duration: const Duration(milliseconds: 800), curve: Curves.linear);

    _controller.forward().then((value) => {
          //show static current menu item
          setState(() {
            _isCurrentItemSelected = true;
          })
        });
  }

//get size of individual menu Item
  void _getItemSize(String category) {
    final RenderBox box = globalkeys[_selectedCategoryIndex]
        .currentContext
        .findRenderObject() as RenderBox;

    setState(() {
      menuItemSize = box.size.width;
      _animation = Tween(begin: 1.0, end: menuItemSize / filterSizeWidth)
          .animate(_controller);
    });
  }

  //reset menu filter to original position
  void _resetOffset() {
    //make current item invisible
    setState(() {
      _isCurrentItemSelected = false;
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

  @override
  Widget build(BuildContext context) {
    return Container(
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
                          duration:
                              const Duration(milliseconds: _animationDuration),
                          left: _horizontalOffset,
                          child: Row(
                            key: menuFilterKey,
                            children: [
                              Row(
                                  children: widget.categories
                                      .map(
                                        (category) => MenuCategoryAppBarItem(
                                          height: widget.height,
                                          index: widget.categories
                                              .indexOf(category),
                                          changeSelectedCategoryIndex:
                                              _changeSelectedCategoryIndex,
                                          key: globalkeys[widget.categories
                                              .indexOf(category)],
                                          getItemSize: _getItemSize,
                                          selectedCategory: _selectecCategory,
                                          changeSelectedCategory:
                                              _changeSelectedCategory,
                                          resetHorizontalOffset: _resetOffset,
                                          changeMenuFilterOffset:
                                              _changeHorizontalOffset,
                                          title: category,
                                          // title: getMenuCategoryName(category),
                                          updateCategory: widget.updateCategory,
                                          textColor: widget.categories
                                                      .indexOf(category) ==
                                                  _selectedCategoryIndex
                                              ? Colors.red
                                              : Colors.grey,
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
                    children: widget.subcategories[_selectedCategoryIndex]
                        .map(
                          (subcategory) => MenuSubCategoryAppBarItem(
                              height: widget.height,
                              index: widget
                                  .subcategories[_selectedCategoryIndex]
                                  .indexOf(subcategory),
                              title: subcategory,
                              textColor: widget
                                          .subcategories[_selectedCategoryIndex]
                                          .indexOf(subcategory) ==
                                      _selectedSubCategoryIndex
                                  // _getSubCategoryFromString(subcategory)
                                  ? Colors.black
                                  : Colors.grey,
                              updateSubCategory: widget.updateSubCategory,
                              selectedSubCategory: subcategory,
                              changeSelectedSubCategoryIndex:
                                  _changeSelectedSubCategoryIndex
                              // _getSubCategoryFromString(subcategory),
                              ),
                        )
                        .toList(),
                  )
                ],
              )),
          // CURRENT SELECTED MENU ITEM
          Positioned(
            left: 0,
            child: IgnorePointer(
              child: Opacity(
                opacity: _isCurrentItemSelected ? 1 : 0,
                child: Container(
                  color: Colors.white,
                  child: Row(
                    children: [
                      MenuAppBarItem(
                        height: widget.height,
                        title: _selectecCategory,
                        textColor: Colors.red,
                      ),
                      const VerticalDivider(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class VerticalDivider extends StatelessWidget {
  const VerticalDivider({
    Key key,
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

class MenuCategoryAppBarItem extends StatefulWidget {
  final String title;
  final double height;
  final int index;
  final String menuItemCategory;
  final Function updateCategory;
  final Function changeSelectedCategoryIndex;
  final Function resetHorizontalOffset;
  final Function getItemSize;
  final Function changeMenuFilterOffset;
  final Color textColor;
  final String selectedCategory;
  final Function changeSelectedCategory;
  const MenuCategoryAppBarItem({
    Key key,
    @required this.title,
    this.menuItemCategory,
    this.updateCategory,
    this.textColor,
    this.changeMenuFilterOffset,
    this.resetHorizontalOffset,
    this.selectedCategory,
    this.changeSelectedCategory,
    this.getItemSize,
    @required this.index,
    this.changeSelectedCategoryIndex,
    this.height,
  }) : super(key: key);

  @override
  _MenuCategoryAppBarItemState createState() => _MenuCategoryAppBarItemState();
}

class _MenuCategoryAppBarItemState extends State<MenuCategoryAppBarItem> {
  // detect if menu item state is open or close
  bool _isOpen;
  @override
  void initState() {
    _isOpen = false;
    super.initState();
  }

  void _moveMenuFilter(BuildContext context) {
    if (widget.selectedCategory == widget.menuItemCategory && !_isOpen) {
      widget.resetHorizontalOffset();
    } else {
      widget.changeMenuFilterOffset();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MenuAppBarItem(
      onTapDown: (details) {
        setState(() {
          _isOpen = !_isOpen;
        });
        widget.changeSelectedCategory(widget.menuItemCategory);
        //update category for filtering menut list
        if (widget.updateCategory != null) {
          widget.updateCategory(widget.menuItemCategory);
        }
        //change selected category index
        widget.changeSelectedCategoryIndex(widget.index);
        //move menu filter based on menu item selection
        _moveMenuFilter(context);
        //get size of individual menu item (used for closed transition animation)
        widget.getItemSize(widget.menuItemCategory);
      },
      height: widget.height,
      title: widget.title,
      textColor: widget.textColor,
    );
  }
}

class MenuSubCategoryAppBarItem extends StatelessWidget {
  final int index;
  final String title;
  final String selectedSubCategory;
  final Function updateSubCategory;
  final Function changeSelectedSubCategoryIndex;
  final Color textColor;
  final double height;

  const MenuSubCategoryAppBarItem({
    Key key,
    @required this.title,
    this.selectedSubCategory,
    this.updateSubCategory,
    this.textColor,
    this.index,
    this.changeSelectedSubCategoryIndex,
    this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MenuAppBarItem(
      onTapDown: (details) {
        if (updateSubCategory != null) {
          updateSubCategory(selectedSubCategory);
        }
        changeSelectedSubCategoryIndex(index);
      },
      height: height,
      title: title,
      textColor: textColor,
    );
  }
}

class MenuAppBarItem extends StatelessWidget {
  const MenuAppBarItem({
    Key key,
    @required this.title,
    this.textColor = Colors.grey,
    this.height,
    this.onTapDown,
  }) : super(key: key);

  final String title;
  final Color textColor;
  final double height;
  final void Function(TapDownDetails) onTapDown;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: onTapDown,
      child: Container(
        height: height,
        margin: const EdgeInsets.symmetric(horizontal: 5),
        child: Center(
          child: Text(title.toUpperCase(),
              overflow: TextOverflow.fade,
              // style: AppTextStyles.inlineFilter.copyWith(color: textColor)),
              style: TextStyle(color: textColor, fontSize: 16)),
        ),
      ),
    );
  }
}
