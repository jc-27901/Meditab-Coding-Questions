part of '../flutter_easy_select.dart';

/// A widget that serves as a header for a bottom sheet.
///
/// This widget displays a title and a close button, providing a consistent
/// look for bottom sheet headers.
class BaseBottomSheetHeader extends StatelessWidget {
  /// Creates a [BaseBottomSheetHeader].
  ///
  /// The [title] parameter specifies the text to display in the header.
  const BaseBottomSheetHeader({super.key, required this.title});

  final String title; // The title displayed in the header.

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(
          height: 16.0, // Spacer for visual separation from the top.
        ),
        Container(
          height: 4, // Height of the indicator line.
          width: 36, // Width of the indicator line.
          decoration: BoxDecoration(
            borderRadius: borderAll8, // Rounded corners for the indicator.
            color: Theme.of(context)
                .colorScheme
                .primary
                .withOpacity(0.7), // Indicator color.
          ),
        ),
        const SizedBox(
          height: 4.0, // Spacer between the indicator and title.
        ),
        Padding(
          padding: left16Top10, // Padding around the title and button.
          child: Row(
            mainAxisAlignment: MainAxisAlignment
                .spaceBetween, // Align title and button to opposite ends.
            children: [
              Text(title), // Display the header title.
              TextButton(
                child:
                    const CloseButton(), // Close button to dismiss the bottom sheet.
                onPressed: () {
                  Navigator.pop(
                      context); // Pop the current route off the navigator stack.
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// A constant [BorderRadius] used for rounding the top corners of the bottom sheet.
const BorderRadius borderRadiusTopLeft24 = BorderRadius.only(
  topLeft: Radius.circular(24.0), // Radius for the top left corner.
  topRight: Radius.circular(24.0), // Radius for the top right corner.
);

/// A constant [EdgeInsets] for uniform padding of 12 pixels on all sides.
const EdgeInsets all12 = EdgeInsets.all(12);

/// A constant [BorderRadius] used for rounded corners on various widgets.
const BorderRadius borderAll8 =
    BorderRadius.all(Radius.circular(8)); // Uniform radius of 8 pixels.

/// A constant [EdgeInsets] for specific padding of 16 pixels on the left and 10 pixels on the top.
const EdgeInsets left16Top10 = EdgeInsets.only(left: 16, right: 10);
