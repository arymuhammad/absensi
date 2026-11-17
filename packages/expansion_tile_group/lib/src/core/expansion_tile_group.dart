import 'package:expansion_tile_group/expansion_tile_group.dart';
import 'package:flutter/material.dart';

class ExpansionTileGroup extends StatefulWidget {
  const ExpansionTileGroup(
      {Key? key,
      required this.children,
      this.toggleType = ToggleType.none,
      this.onExpansionItemChanged,
      this.spaceBetweenItem = 0.0})
      : assert(spaceBetweenItem >= 0.0,
            '[Error] ExpansionTileGroup: The spaceBetweenItem must be >= 0'),
        super(key: key);
  final List<ExpansionTileItem> children;
  final ToggleType toggleType;
  final Function(int, bool)? onExpansionItemChanged;
  final double spaceBetweenItem;

  @override
  State<ExpansionTileGroup> createState() => _ExpansionTileGroupState();
}

class _ExpansionTileGroupState extends State<ExpansionTileGroup> {
  late final List<GlobalKey<ExpansionTileCoreState>> expansionTileKeys;
  late final List<ExpansionTileItem> expansionChildren;

  bool _isGroupTransforming = false;

  @override
  void initState() {
    expansionTileKeys = List.generate(widget.children.length,
        (index) => widget.children[index].expansionKey ?? GlobalKey());
    expansionChildren = List.generate(
        widget.children.length,
        (index) => widget.children[index].copyWith(
            expansionKey: expansionTileKeys[index],
            onExpansionChanged: (isExpanded) {
              if (!_isGroupTransforming) {
                _updateExpandedForAccordions(index, isExpanded, false);
                widget.onExpansionItemChanged?.call(index, isExpanded);
              }
            }));
    super.initState();
  }

  
@override
void didUpdateWidget(ExpansionTileGroup oldWidget) {
  super.didUpdateWidget(oldWidget);

  // Simpan GlobalKey lama berdasarkan identitas item.
  final Map<Key, GlobalKey<ExpansionTileCoreState>> oldKeysByItemKey = {};

  for (int i = 0; i < oldWidget.children.length; i++) {
    if (i >= expansionTileKeys.length) break;

    final itemKey = oldWidget.children[i].key;

    if (itemKey != null) {
      oldKeysByItemKey[itemKey] = expansionTileKeys[i];
    }
  }

  // Pertahankan GlobalKey untuk item yang masih sama.
  final newKeys = List.generate(
    widget.children.length,
    (index) {
      final item = widget.children[index];

      // Prioritaskan GlobalKey yang diberikan dari luar.
      if (item.expansionKey != null) {
        return item.expansionKey!;
      }

      // Item memiliki Key: cari GlobalKey berdasarkan identitasnya.
      if (item.key != null) {
        return oldKeysByItemKey[item.key] ??
            GlobalKey<ExpansionTileCoreState>();
      }

      // Item tanpa Key: pertahankan berdasarkan posisi jika memungkinkan.
      if (index < oldWidget.children.length &&
          index < expansionTileKeys.length &&
          oldWidget.children[index].key == null &&
          oldWidget.children[index].expansionKey == null) {
        return expansionTileKeys[index];
      }

      return GlobalKey<ExpansionTileCoreState>();
    },
  );

  expansionTileKeys
    ..clear()
    ..addAll(newKeys);

  // Perbarui daftar item dan callback.
  expansionChildren
    ..clear()
    ..addAll(
      List.generate(
        widget.children.length,
        (index) => widget.children[index].copyWith(
          expansionKey: expansionTileKeys[index],
          onExpansionChanged: (isExpanded) {
            if (!_isGroupTransforming) {
              _updateExpandedForAccordions(index, isExpanded, false);
              widget.onExpansionItemChanged?.call(index, isExpanded);
            }
          },
        ),
      ),
    );
}


  @override
  Widget build(BuildContext context) {
    return Column(
      children: [...getChildrenToShown()],
    );
  }

  List<Widget> getChildrenToShown() {
    var result = <Widget>[];
    for (var item in expansionChildren) {
      result.add(item);
      if (expansionChildren.last != item) {
        result.add(SizedBox(
          height: widget.spaceBetweenItem,
        ));
      }
    }
    return result;
  }

  void _updateExpandedForAccordions(
      int index, bool isExpanded, bool defaultState) {
    switch (widget.toggleType) {
      case ToggleType.expandOnlyCurrent:
        _onExpandOne(index, isExpanded, defaultState);
        break;
      case ToggleType.expandAlwaysCurrent:
        _onExpandAlwaysCurrent(index, isExpanded, defaultState);
        break;
      case ToggleType.collapseAll:
        _onCollapseAll(index, isExpanded, defaultState);
        break;
      case ToggleType.expandAll:
        _onExpandAll(index, isExpanded, defaultState);
        break;
      case ToggleType.expandAllOrCollapseAll:
        _onExpandAllAndCollapseALl(index, isExpanded, defaultState);
        break;
      case ToggleType.none:
        break;
    }
  }

  //todo create abstract class to handle action
  void _onExpandOne(int index, bool isExpanded, bool defaultState) {
    _isGroupTransforming = true;
    if (isExpanded) {
      expansionTileKeys[index].currentState?.expand();
    } else {
      expansionTileKeys[index].currentState?.collapse();
    }
    for (int i = 0; i < expansionTileKeys.length; i++) {
      if (i != index) {
        if (defaultState) {
          expansionTileKeys[i].currentState?.expand();
        } else {
          expansionTileKeys[i].currentState?.collapse();
        }
      }
    }
    _isGroupTransforming = false;
  }

  void _onExpandAlwaysCurrent(int index, bool isExpanded, bool defaultState) {
    _isGroupTransforming = true;
    expansionTileKeys[index].currentState?.expand();

    for (int i = 0; i < expansionTileKeys.length; i++) {
      if (i != index) {
        if (defaultState) {
          expansionTileKeys[i].currentState?.expand();
        } else {
          expansionTileKeys[i].currentState?.collapse();
        }
      }
    }
    _isGroupTransforming = false;
  }

  //todo create abstract class to handle action
  void _onCollapseAll(int index, bool isExpanded, bool defaultState) {
    _isGroupTransforming = true;
    if (!isExpanded) {
      for (int i = 0; i < expansionTileKeys.length; i++) {
        expansionTileKeys[i].currentState?.collapse();
      }
    }
    _isGroupTransforming = false;
  }

  //todo create abstract class to handle action
  void _onExpandAll(int index, bool isExpanded, bool defaultState) {
    _isGroupTransforming = true;
    if (isExpanded) {
      for (int i = 0; i < expansionTileKeys.length; i++) {
        expansionTileKeys[i].currentState?.expand();
      }
    }
    _isGroupTransforming = false;
  }

  //todo create abstract class to handle action
  void _onExpandAllAndCollapseALl(
      int index, bool isExpanded, bool defaultState) {
    _isGroupTransforming = true;
    if (isExpanded) {
      for (int i = 0; i < expansionTileKeys.length; i++) {
        expansionTileKeys[i].currentState?.expand();
      }
    } else {
      for (int i = 0; i < expansionTileKeys.length; i++) {
        expansionTileKeys[i].currentState?.collapse();
      }
    }
    _isGroupTransforming = false;
  }
}
