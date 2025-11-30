import 'package:flutter/material.dart';
import '../core/service_locator.dart';
import '../models/wishlist.dart';

class WishlistPage extends StatefulWidget {
  const WishlistPage({super.key});

  @override
  State<WishlistPage> createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  final _wishlistService = ServiceLocator().wishlistService;
  final _authService = ServiceLocator().authService;
  
  List<WishlistItem> _items = [];
  bool _isLoading = true;
  String? _errorMessage;
  WishlistPriority? _filterPriority;

  @override
  void initState() {
    super.initState();
    _loadWishlist();
  }

  Future<void> _loadWishlist() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final userId = _authService.currentUser?.uid;
      if (userId != null) {
        final wishlist = await _wishlistService.getUserWishlist(userId);
        if (mounted) {
          setState(() {
            _items = wishlist?.items ?? [];
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _errorMessage = 'User not authenticated';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Could not load wishlist';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteItem(String itemId) async {
    try {
      final userId = _authService.currentUser?.uid;
      if (userId != null) {
        await _wishlistService.deleteWishlistItem(userId, itemId);
        await _loadWishlist();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Item removed from wishlist')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not delete item'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  List<WishlistItem> get _filteredItems {
    if (_filterPriority == null) return _items;
    return _items.where((item) => item.priority == _filterPriority).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Wishlist'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          PopupMenuButton<WishlistPriority?>(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filter by Priority',
            onSelected: (priority) {
              setState(() => _filterPriority = priority);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: null,
                child: Text('All Priorities'),
              ),
              const PopupMenuItem(
                value: WishlistPriority.high,
                child: Row(
                  children: [
                    Icon(Icons.priority_high, color: Colors.red, size: 20),
                    SizedBox(width: 8),
                    Text('High Priority'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: WishlistPriority.medium,
                child: Row(
                  children: [
                    Icon(Icons.remove, color: Colors.orange, size: 20),
                    SizedBox(width: 8),
                    Text('Medium Priority'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: WishlistPriority.low,
                child: Row(
                  children: [
                    Icon(Icons.arrow_downward, color: Colors.green, size: 20),
                    SizedBox(width: 8),
                    Text('Low Priority'),
                  ],
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadWishlist,
            tooltip: 'Refresh Wishlist',
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await _showAddEditDialog();
          if (result == true) {
            _loadWishlist();
          }
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(_errorMessage!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadWishlist,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final displayItems = _filteredItems;

    if (displayItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.playlist_add,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              _filterPriority == null
                  ? 'No wishlist items yet'
                  : 'No ${_filterPriority!.name} priority items',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tap the + button to add movies you want',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadWishlist,
      child: ListView.builder(
        itemCount: displayItems.length,
        itemBuilder: (context, index) {
          final item = displayItems[index];
          return _WishlistItemTile(
            item: item,
            onEdit: () async {
              final result = await _showAddEditDialog(item: item);
              if (result == true) {
                _loadWishlist();
              }
            },
            onDelete: () => _showDeleteDialog(item),
          );
        },
      ),
    );
  }

  Future<void> _showDeleteDialog(WishlistItem item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Item'),
        content: Text(
          'Are you sure you want to remove "${item.movieTitle}" from your wishlist?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _deleteItem(item.id);
    }
  }

  Future<bool?> _showAddEditDialog({WishlistItem? item}) async {
    final titleController = TextEditingController(text: item?.movieTitle ?? '');
    final notesController = TextEditingController(text: item?.notes ?? '');
    final priceController = TextEditingController(
      text: item?.expectedPrice?.toString() ?? '',
    );
    final whereToFindController = TextEditingController(
      text: item?.whereToFind ?? '',
    );
    
    WishlistPriority selectedPriority = item?.priority ?? WishlistPriority.medium;
    final formKey = GlobalKey<FormState>();

    return showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(item == null ? 'Add to Wishlist' : 'Edit Wishlist Item'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Movie Title *',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a movie title';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<WishlistPriority>(
                    value: selectedPriority,
                    decoration: const InputDecoration(
                      labelText: 'Priority',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      const DropdownMenuItem(
                        value: WishlistPriority.high,
                        child: Row(
                          children: [
                            Icon(Icons.priority_high, color: Colors.red, size: 20),
                            SizedBox(width: 8),
                            Text('High'),
                          ],
                        ),
                      ),
                      const DropdownMenuItem(
                        value: WishlistPriority.medium,
                        child: Row(
                          children: [
                            Icon(Icons.remove, color: Colors.orange, size: 20),
                            SizedBox(width: 8),
                            Text('Medium'),
                          ],
                        ),
                      ),
                      const DropdownMenuItem(
                        value: WishlistPriority.low,
                        child: Row(
                          children: [
                            Icon(Icons.arrow_downward, color: Colors.green, size: 20),
                            SizedBox(width: 8),
                            Text('Low'),
                          ],
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      setDialogState(() => selectedPriority = value!);
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: priceController,
                    decoration: const InputDecoration(
                      labelText: 'Expected Price',
                      border: OutlineInputBorder(),
                      prefixText: '\$',
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: whereToFindController,
                    decoration: const InputDecoration(
                      labelText: 'Where to Find',
                      border: OutlineInputBorder(),
                      hintText: 'e.g., Amazon, eBay, Local store',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: notesController,
                    decoration: const InputDecoration(
                      labelText: 'Notes',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;

                try {
                  final userId = _authService.currentUser?.uid;
                  if (userId == null) {
                    throw Exception('User not authenticated');
                  }

                  final price = priceController.text.trim().isEmpty
                      ? null
                      : double.tryParse(priceController.text.trim());

                  if (item == null) {
                    // Add new item
                    await _wishlistService.addWishlistItem(
                      userId: userId,
                      movieTitle: titleController.text.trim(),
                      priority: selectedPriority,
                      notes: notesController.text.trim().isEmpty
                          ? null
                          : notesController.text.trim(),
                      expectedPrice: price,
                      whereToFind: whereToFindController.text.trim().isEmpty
                          ? null
                          : whereToFindController.text.trim(),
                    );
                  } else {
                    // Update existing item
                    await _wishlistService.updateWishlistItem(
                      userId: userId,
                      itemId: item.id,
                      movieTitle: titleController.text.trim(),
                      priority: selectedPriority,
                      notes: notesController.text.trim().isEmpty
                          ? null
                          : notesController.text.trim(),
                      expectedPrice: price,
                      whereToFind: whereToFindController.text.trim().isEmpty
                          ? null
                          : whereToFindController.text.trim(),
                    );
                  }

                  if (context.mounted) {
                    Navigator.of(context).pop(true);
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: ${e.toString()}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: Text(item == null ? 'Add' : 'Save'),
            ),
          ],
        ),
      ),
    );
  }
}

class _WishlistItemTile extends StatelessWidget {
  final WishlistItem item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _WishlistItemTile({
    required this.item,
    required this.onEdit,
    required this.onDelete,
  });

  Color _getPriorityColor() {
    switch (item.priority) {
      case WishlistPriority.high:
        return Colors.red;
      case WishlistPriority.medium:
        return Colors.orange;
      case WishlistPriority.low:
        return Colors.green;
    }
  }

  IconData _getPriorityIcon() {
    switch (item.priority) {
      case WishlistPriority.high:
        return Icons.priority_high;
      case WishlistPriority.medium:
        return Icons.remove;
      case WishlistPriority.low:
        return Icons.arrow_downward;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getPriorityColor(),
          child: Icon(_getPriorityIcon(), color: Colors.white),
        ),
        title: Text(
          item.movieTitle,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Priority: ${item.priority.name.toUpperCase()}',
              style: TextStyle(color: _getPriorityColor()),
            ),
            if (item.expectedPrice != null)
              Text('Expected Price: \$${item.expectedPrice!.toStringAsFixed(2)}'),
            if (item.whereToFind != null)
              Text('Where: ${item.whereToFind}'),
            if (item.notes != null && item.notes!.isNotEmpty)
              Text(
                item.notes!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontStyle: FontStyle.italic),
              ),
            Text(
              'Added: ${_formatDate(item.dateAdded)}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'edit') {
              onEdit();
            } else if (value == 'delete') {
              onDelete();
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 20),
                  SizedBox(width: 8),
                  Text('Edit'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 20, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Remove', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }
}
