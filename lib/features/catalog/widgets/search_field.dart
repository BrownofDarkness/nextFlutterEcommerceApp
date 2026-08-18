import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/filter_provider.dart';

/// Search input bound to `filterProvider.searchQuery`.
///
/// Owns a local [TextEditingController] (via [ConsumerStatefulWidget]) —
/// the controller is a mutable widget-lifecycle resource that shouldn't
/// live inside a provider. On every keystroke, [onChanged] pushes the new
/// value into the notifier, which re-triggers `filteredProductsProvider`.
///
/// The clear-button ("×") reads the local controller state via a listener,
/// avoiding a full rebuild of the search field on every character.
class SearchField extends ConsumerStatefulWidget {
  const SearchField({super.key});

  @override
  ConsumerState<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends ConsumerState<SearchField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: ref.read(filterProvider).searchQuery,
    );
    _controller.addListener(_handleTextChange);
  }

  void _handleTextChange() {
    // setState only to refresh the clear-icon visibility.
    setState(() {});
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_handleTextChange)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      onChanged: (value) =>
          ref.read(filterProvider.notifier).setSearch(value),
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: 'Rechercher un produit…',
        prefixIcon: const Icon(Icons.search, size: 20),
        suffixIcon: _controller.text.isEmpty
            ? null
            : IconButton(
                icon: const Icon(Icons.close, size: 18),
                onPressed: () {
                  _controller.clear();
                  ref.read(filterProvider.notifier).setSearch('');
                },
              ),
      ),
    );
  }
}
