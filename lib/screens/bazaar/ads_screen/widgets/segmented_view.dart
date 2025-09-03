import 'package:flutter/material.dart';
import 'package:oqdo_mobile_app/screens/bazaar/ads_screen/model/advertisement_type_response_model.dart';

class SegmentedView extends StatefulWidget {
  final List<AdvertisementTypeResponse> segments;
  final void Function(AdvertisementTypeResponse)? onSegmentSelected;
  final Color selectedColor;
  final Color unselectedColor;
  final Color backgroundColor;
  final int initialIndex;
  final VoidCallback? onPressed;

  const SegmentedView({
    super.key,
    required this.segments,
    this.onSegmentSelected,
    this.onPressed,
    this.selectedColor = const Color(0xFF006590),
    this.unselectedColor = const Color(0xFFD4EEF9),
    this.backgroundColor = const Color(0xFFE0E0E0),
    this.initialIndex = 0,
  });

  @override
  _SegmentedViewState createState() => _SegmentedViewState();
}

class _SegmentedViewState extends State<SegmentedView> {
  late int selectedIndex;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.initialIndex;
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToSelectedSegment() {
    if (widget.segments.length <= 2) return;

    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final double width = renderBox.size.width;
    final double segmentWidth = width / 2; // Width for 2 segments
    final double offset = segmentWidth * selectedIndex;

    _scrollController.animateTo(
      offset.clamp(0, _scrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: widget.backgroundColor,
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: widget.segments.length <= 2
                  ? Row(
                      children: List.generate(
                        widget.segments.length,
                        (index) => _buildSegment(index),
                      ),
                    )
                  : SingleChildScrollView(
                      controller: _scrollController,
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: List.generate(
                          widget.segments.length,
                          (index) => SizedBox(
                            width: MediaQuery.of(context).size.width / 2,
                            child: _buildSegment(index),
                          ),
                        ),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSegment(int index) {
    final segment = widget.segments[index];
    final bool isSelected = selectedIndex == index;

    return Expanded(
      flex: widget.segments.length <= 2 ? 1 : 0,
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedIndex = index;
          });
          if (widget.segments.length > 2) {
            _scrollToSelectedSegment();
          }
          widget.onSegmentSelected?.call(segment);
          segment.onPressed?.call();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          decoration: BoxDecoration(
            color: isSelected ? widget.selectedColor : widget.unselectedColor,
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                segment.name,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.w700,
                  fontSize: 17.0,
                  fontFamily: 'Montserrat',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
