import 'package:flutter/material.dart';
import '../../constants/color.dart';

class RefreshSection extends StatefulWidget {
  final Future<void> Function() onRefresh;
  final Future<void> Function()? onLoadMore;
  final Widget child;

  const RefreshSection({
    super.key,
    required this.onRefresh,
    this.onLoadMore,
    required this.child,
  });

  @override
  State<RefreshSection> createState() => _RefreshSectionState();
}

class _RefreshSectionState extends State<RefreshSection> {
  final ScrollController _scrollController = ScrollController();
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() async {
    if (widget.onLoadMore == null) return;
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 50 &&
        !_isRefreshing) {
      await _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (_isRefreshing || widget.onLoadMore == null) return;

    setState(() => _isRefreshing = true);
    try {
      await widget.onLoadMore!();
    } finally {
      setState(() => _isRefreshing = false);
    }
  }

  Future<void> _handleRefresh() async {
    if (_isRefreshing) return;

    setState(() => _isRefreshing = true);
    try {
      await widget.onRefresh();
    } finally {
      setState(() => _isRefreshing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Wrap child with SingleChildScrollView if it's not scrollable
    return RefreshIndicator(
      onRefresh: _handleRefresh,
      color: AppColors.primary,
      backgroundColor: Colors.white,
      child: NotificationListener<ScrollNotification>(
        onNotification: (_) {
          _scrollListener();
          return false;
        },
        child: widget.child,
      ),
    );
  }
}
