import 'package:flutter/material.dart';
import 'package:shiny_counter/core/theme/tokens.dart';
import 'package:shiny_counter/features/pokemon/domain/entities/pokemon.dart';
import 'package:shiny_counter/features/pokemon/presentation/widgets/list/collapsible_section.dart';
import 'package:shiny_counter/features/pokemon/presentation/widgets/list/pokemon_card.dart';

class PokemonSection extends StatefulWidget {
  const PokemonSection({
    super.key,
    required this.title,
    required this.expanded,
    required this.onToggle,
    required this.pokemons,
    required this.isCaught,
    required this.onTap,
    this.onEdit,
    this.onDelete,
    this.canManage,
  });

  final String title;
  final bool expanded;
  final VoidCallback onToggle;
  final List<Pokemon> pokemons;
  final bool Function(Pokemon) isCaught;
  final Future<void> Function(Pokemon) onTap;
  final ValueChanged<Pokemon>? onEdit;
  final ValueChanged<Pokemon>? onDelete;
  final bool Function(Pokemon)? canManage;

  @override
  State<PokemonSection> createState() => _PokemonSectionState();
}

class _PokemonSectionState extends State<PokemonSection> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  late List<Pokemon> _items;

  @override
  void initState() {
    super.initState();
    _items = List.of(widget.pokemons);
  }

  @override
  void didUpdateWidget(PokemonSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncItems(widget.pokemons);
  }

  void _syncItems(List<Pokemon> next) {
    final nextIds = next.map((p) => p.id).toSet();

    for (var i = _items.length - 1; i >= 0; i--) {
      final item = _items[i];
      if (!nextIds.contains(item.id)) {
        _items.removeAt(i);
        _listKey.currentState?.removeItem(
          i,
          (context, animation) => _buildAnimatedItem(item, animation),
          duration: AppAnim.normal,
        );
      }
    }

    for (var i = 0; i < next.length; i++) {
      final item = next[i];
      if (i >= _items.length || _items[i].id != item.id) {
        final existingIndex = _items.indexWhere(
          (current) => current.id == item.id,
        );
        if (existingIndex == -1) {
          _items.insert(i, item);
          _listKey.currentState?.insertItem(i, duration: AppAnim.normal);
        }
      }
    }

    if (_items.length == next.length) {
      setState(() {
        _items = List.of(next);
      });
    }
  }

  Widget _buildAnimatedItem(Pokemon pokemon, Animation<double> animation) {
    final canManage = widget.canManage?.call(pokemon) ?? false;
    final curve = CurvedAnimation(
      parent: animation,
      curve: AppAnim.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    return SizeTransition(
      sizeFactor: curve,
      axisAlignment: -1,
      child: FadeTransition(
        opacity: curve,
        child: ScaleTransition(
          scale: Tween<double>(
            begin: AppAnim.listItemPopStartScale,
            end: 1.0,
          ).animate(curve),
          child: PokemonCard(
            key: ValueKey(pokemon.id),
            pokemon: pokemon,
            isCaught: widget.isCaught(pokemon),
            onTap: () => widget.onTap(pokemon),
            onEdit: canManage && widget.onEdit != null
                ? () => widget.onEdit!(pokemon)
                : null,
            onDelete: canManage && widget.onDelete != null
                ? () => widget.onDelete!(pokemon)
                : null,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CollapsibleSection(
      title: widget.title,
      expanded: widget.expanded,
      onToggle: widget.onToggle,
      child: AnimatedList(
        key: _listKey,
        initialItemCount: _items.length,
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        primary: false,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index, animation) {
          final item = _items[index];
          return _buildAnimatedItem(item, animation);
        },
      ),
    );
  }
}
