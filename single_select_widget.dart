part of '../flutter_easy_select.dart';

/// A widget that displays a modal bottom sheet for selecting a single item
/// from a list of items.
///
/// This widget supports searching through the items and optionally allows
/// users to input free text that is not present in the list.
class SingleSelectWidget<T> extends StatefulWidget {
  /// Creates a [SingleSelectWidget].
  ///
  /// The [items] parameter is a list of items of type [T] that can be selected.
  ///
  /// The [itemBuilder] parameter is a function that defines how to render each item.
  ///
  /// The [searchProperty] parameter is a function that extracts a searchable
  /// property from each item.
  ///
  /// The [title] parameter specifies the title displayed at the top of the modal.
  ///
  /// The [enableFreeText] parameter, if set to true, allows users to input
  /// custom text not in the list of items (default is false).
  ///
  /// The [isSearchEnable] parameter, if set to true, enables the search functionality
  /// (default is true).
  ///
  /// The [freeTextSelected] callback is invoked when free text is selected.
  ///
  /// The [initialSelectedItem] parameter allows for an item to be pre-selected.
  ///
  /// The [fieldDecoration] parameter provides optional decoration for the input field.
  const SingleSelectWidget({
    super.key,
    required this.items,
    required this.itemBuilder,
    required this.searchProperty,
    required this.title,
    this.enableFreeText = false,
    this.isSearchEnable = true,
    this.freeTextSelected,
    this.initialSelectedItem,
    this.fieldDecoration,
  });

  final List<T> items; // The list of items to select from.
  final Widget Function(T item) itemBuilder; // Function to render each item.
  final String Function(T item)
      searchProperty; // Function to extract searchable property.
  final bool enableFreeText; // Whether to allow free text input.
  final bool isSearchEnable; // Whether to enable search functionality.
  final String title; // The title displayed at the top of the modal.
  final void Function(String)?
      freeTextSelected; // Callback for free text selection.
  final T? initialSelectedItem; // Pre-selected item, if any.
  final InputDecoration? fieldDecoration; // Decoration for the input field.

  @override
  State<SingleSelectWidget<T>> createState() => _SingleSelectWidgetState<T>();
}

class _SingleSelectWidgetState<T> extends State<SingleSelectWidget<T>> {
  T? _selectedItem; // The currently selected item.
  String _searchQuery = ''; // The current search query.
  late List<T> _filteredItems; // The list of items filtered by search.
  bool _freeTextSelected = false; // Whether free text is selected.
  late bool isSearchEnable; // Whether search is enabled.
  late String title; // The title of the modal.
  final TextEditingController _textController =
      TextEditingController(); // Controller for the text field.
  late final FocusNode _focusNode; // Focus node for the text field.

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode(); // Initialize the focus node.
    _selectedItem =
        widget.initialSelectedItem; // Set the initially selected item.
    isSearchEnable = widget.isSearchEnable; // Set whether search is enabled.
    title = widget.title; // Set the modal title.
    _filteredItems = _getOrderedItems(); // Initialize the filtered items.
  }

  /// Returns a list of items, ensuring the selected item is at the top.
  List<T> _getOrderedItems() {
    if (_selectedItem != null) {
      final itemIndex = widget.items.indexWhere((item) =>
          widget.searchProperty(item) ==
          widget.searchProperty(_selectedItem as T));
      if (itemIndex != -1) {
        final orderedList = List<T>.from(widget.items);
        orderedList.removeAt(
            itemIndex); // Remove the selected item from its original position.
        return [_selectedItem as T, ...orderedList]; // Place it at the top.
      }
    }
    return List<T>.from(
        widget.items); // Return the original list if no item is selected.
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadiusTopLeft24, // Custom border radius.
      child: Scaffold(
        body: Column(
          children: [
            BaseBottomSheetHeader(title: title), // Header with the title.
            if (isSearchEnable)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TextField(
                  controller: _textController,
                  focusNode: _focusNode,
                  decoration: widget.fieldDecoration ??
                      const InputDecoration(
                          border: OutlineInputBorder(), labelText: 'Search'),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value; // Update the search query.
                      _filterItems(); // Filter items based on the search query.
                    });
                  },
                ),
              ),
            // Display the free text option if enabled and search query is not empty.
            if (widget.enableFreeText && _searchQuery.isNotEmpty) ...[
              RadioListTile<bool>(
                  value: true,
                  groupValue: _freeTextSelected,
                  onChanged: (_) {
                    setState(() {
                      _selectedItem = null; // Reset selected item.
                      _freeTextSelected = true; // Mark free text as selected.
                      widget.freeTextSelected
                          ?.call(_searchQuery); // Invoke callback.
                    });
                  },
                  title: Text(_searchQuery)),
            ],
            (_filteredItems.isEmpty)
                ? const Flexible(
                    child: Center(
                    child: Text('No record(s) found.'),
                  ))
                : Expanded(
                    child: ListView.builder(
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      itemCount: _filteredItems.length,
                      itemBuilder: (context, index) {
                        final item = _filteredItems[index];
                        return RadioListTile<T>(
                          value: item,
                          groupValue: _selectedItem,
                          title: widget.itemBuilder(
                              item), // Render item using the builder.
                          onChanged: (value) {
                            setState(() {
                              _selectedItem = value; // Update selected item.
                              _freeTextSelected = false; // Deselect free text.
                            });
                            _onApply(); // Apply the selection.
                          },
                        );
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  /// Handles the action when an item is selected or free text is confirmed.
  void _onApply() {
    if (_freeTextSelected) {
      Navigator.pop(context, _searchQuery); // Return the free text input.
    } else if (_selectedItem != null) {
      Navigator.pop(context, _selectedItem); // Return the selected item.
    }
  }

  /// Filters the list of items based on the current search query.
  void _filterItems() {
    _filteredItems = _getOrderedItems().where((item) {
      final String searchText = widget.searchProperty(item).toLowerCase();
      return searchText.contains(
          _searchQuery.toLowerCase()); // Check if item matches search query.
    }).toList();
  }
}
