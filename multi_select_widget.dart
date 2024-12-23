part of '../flutter_easy_select.dart';

/// A widget that displays a modal bottom sheet for selecting multiple items
/// from a list of items.
///
/// This widget supports searching through the items and optionally allows
/// users to input free text that is not present in the list. Selected items
/// can be managed via checkboxes.
class MultiSelectWidget<T> extends StatefulWidget {
  /// Creates a [MultiSelectWidget].
  ///
  /// The [items] parameter is a list of items of type [T] that can be selected.
  ///
  /// The [itemBuilder] parameter is a function that defines how to render each item.
  ///
  /// The [searchProperty] parameter is a function that extracts a searchable
  /// property from each item.
  ///
  /// The [itemIdentifier] parameter is a function that provides a unique
  /// identifier for each item, used to manage selections.
  ///
  /// The [title] parameter specifies the title displayed at the top of the modal.
  ///
  /// The [enableFreeText] parameter, if set to true, allows users to input
  /// custom text not present in the list of items (default is false).
  ///
  /// The [isSearchEnable] parameter, if set to true, enables the search functionality
  /// (default is true).
  ///
  /// The [freeTextSelected] callback is invoked when free text is selected.
  ///
  /// The [initialSelectedItems] parameter allows for items to be pre-selected.
  ///
  /// The [fieldDecoration] parameter provides optional decoration for the input field.
  const MultiSelectWidget({
    super.key,
    required this.items,
    required this.itemBuilder,
    required this.searchProperty,
    required this.title,
    required this.itemIdentifier,
    this.enableFreeText = false,
    this.isSearchEnable = true,
    this.freeTextSelected,
    this.initialSelectedItems,
    this.fieldDecoration,
  });

  final List<T> items; // The list of items to select from.
  final Widget Function(T item) itemBuilder; // Function to render each item.
  final String Function(T item)
      searchProperty; // Function to extract searchable property.
  final String Function(T item)
      itemIdentifier; // Function to get unique identifier for each item.
  final bool enableFreeText; // Whether to allow free text input.
  final bool isSearchEnable; // Whether to enable search functionality.
  final String title; // The title displayed at the top of the modal.
  final void Function(String)?
      freeTextSelected; // Callback for free text selection.
  final List<T>? initialSelectedItems; // Pre-selected items, if any.
  final InputDecoration? fieldDecoration; // Decoration for the input field.

  @override
  State<MultiSelectWidget<T>> createState() => _MultiSelectWidgetState<T>();
}

class _MultiSelectWidgetState<T> extends State<MultiSelectWidget<T>> {
  late Set<String> _selectedItemIds; // Set of selected item identifiers.
  late List<T>
      _sortedItems; // List of items sorted with selected items at the top.
  String _searchQuery = ''; // The current search query.
  late List<T> _filteredItems; // List of items filtered by search.
  bool _freeTextSelected = false; // Whether free text is selected.
  late bool isSearchEnable; // Whether search is enabled.
  late String title; // The title of the modal.
  final TextEditingController _textController =
      TextEditingController(); // Controller for the text field.
  final FocusNode _focusNode = FocusNode(); // Focus node for the text field.

  @override
  void initState() {
    super.initState();
    _selectedItemIds = Set<String>.from(widget.initialSelectedItems
            ?.map((item) => widget.itemIdentifier(item)) ??
        []);
    isSearchEnable = widget.isSearchEnable; // Set whether search is enabled.
    title = widget.title; // Set the modal title.
    _sortedItems = _getSortedItems(); // Initialize the sorted items.
    _filteredItems =
        List<T>.from(_sortedItems); // Initialize the filtered items.
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
              _buildSearchBar(), // Build search bar if enabled.
            if (widget.enableFreeText && _searchQuery.isNotEmpty)
              _buildFreeTextOption(), // Build free text option if applicable.
            Expanded(
              child: _filteredItems.isEmpty
                  ? _buildEmptyState() // Show empty state if no items match.
                  : _buildCheckboxList(), // Show the list of checkboxes.
            ),
          ],
        ),
        bottomNavigationBar: _buildApplyButton(), // Button to apply selections.
      ),
    );
  }

  /// Builds the search bar widget.
  Widget _buildSearchBar() {
    return Padding(
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
    );
  }

  /// Builds the free text option checkbox.
  Widget _buildFreeTextOption() {
    return CheckboxListTile(
      value: _freeTextSelected,
      onChanged: (value) {
        setState(() {
          _freeTextSelected =
              value ?? false; // Update free text selection state.
          if (_freeTextSelected) {
            widget.freeTextSelected?.call(_searchQuery); // Invoke callback.
          }
        });
      },
      title: Text(_searchQuery), // Display the free text input.
    );
  }

  /// Builds the widget displayed when no items match the search query.
  Widget _buildEmptyState() {
    return Center(
      child: Text(
        'No record(s) found',
        style:
            TextStyle(color: Theme.of(context).hintColor), // Style hint color.
      ),
    );
  }

  /// Builds the list of checkboxes for item selection.
  Widget _buildCheckboxList() {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0),
      child: ListView.builder(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        itemCount: _filteredItems.length,
        itemBuilder: (context, index) {
          final item = _filteredItems[index];
          final itemId = widget.itemIdentifier(item); // Get item identifier.
          return CheckboxListTile(
            controlAffinity: ListTileControlAffinity.leading,
            value:
                _selectedItemIds.contains(itemId), // Check if item is selected.
            onChanged: (bool? value) {
              setState(() {
                if (value == true) {
                  _selectedItemIds.add(itemId); // Add item to selected items.
                } else {
                  _selectedItemIds
                      .remove(itemId); // Remove item from selected items.
                }
              });
            },
            title: widget.itemBuilder(item), // Render item using the builder.
          );
        },
      ),
    );
  }

  /// Returns a sorted list of items, with initially selected items at the top.
  List<T> _getSortedItems() {
    final initialSelectedItems = widget.initialSelectedItems ?? [];
    final initialSelectedIds =
        initialSelectedItems.map(widget.itemIdentifier).toSet();

    return [
      ...initialSelectedItems, // Start with initially selected items.
      ...widget.items.where(
          (item) => !initialSelectedIds.contains(widget.itemIdentifier(item)))
    ]; // Append non-selected items.
  }

  /// Handles the action when the "Apply" button is pressed.
  void _onApply() {
    if (_freeTextSelected) {
      Navigator.pop(context, _searchQuery); // Return the free text input.
    } else {
      final selectedItems = widget.items
          .where(
              (item) => _selectedItemIds.contains(widget.itemIdentifier(item)))
          .toList(); // Get selected items.
      Navigator.pop(context, selectedItems); // Return selected items.
    }
  }

  /// Filters the list of items based on the current search query.
  void _filterItems() {
    _filteredItems = _sortedItems.where((item) {
      final String searchText = widget.searchProperty(item).toLowerCase();
      return searchText.contains(
          _searchQuery.toLowerCase()); // Check if item matches search query.
    }).toList();
  }

  /// Builds the "Apply" button at the bottom of the modal.
  Widget _buildApplyButton() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.maxFinite, 36.0),
            backgroundColor:
                Theme.of(context).colorScheme.primary), // Button styling.
        onPressed: _onApply, // Handle button press.
        child: Text(
          'Apply',
          style: TextStyle(
              color: Theme.of(context)
                  .colorScheme
                  .onPrimary), // Button text color.
        ),
      ),
    );
  }
}
