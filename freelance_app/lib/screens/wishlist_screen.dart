import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:freelance_app/models/wishlist_model.dart';
import 'package:freelance_app/services/wishlist_service.dart';

class WishlistScreen extends StatefulWidget {
  final int userId; // Pass userId from FreelancerHomeScreen
  const WishlistScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  List<Wishlist> wishlist = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchWishlist();
  }

  Future<void> _fetchWishlist() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await WishlistService().getWishlistByUser(widget.userId);
      setState(() {
        wishlist = result;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load wishlist. Please try again later.';
        _isLoading = false;
      });
    }
  }

  Future<void> _confirmRemove(int wishlistId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove from Wishlist'),
        content: const Text('Are you sure you want to remove this job from your wishlist?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _removeFromWishlist(wishlistId);
    }
  }

  Future<void> _removeFromWishlist(int wishlistId) async {
    try {
      await WishlistService().deleteWishlist(wishlistId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Removed from wishlist'), backgroundColor: Colors.green),
        );
        _fetchWishlist();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to remove from wishlist'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('My Wishlist'),
        backgroundColor: Color.fromARGB(255, 228, 175, 115),
        foregroundColor: Colors.black,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Text(
                    _error!,
                    style: TextStyle(color: Colors.red.shade700, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                )
              : wishlist.isEmpty
                  ? const Center(
                      child: Text(
                        'No jobs in your wishlist.',
                        style: TextStyle(fontSize: 18, color: Colors.black54),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _fetchWishlist,
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                        itemCount: wishlist.length,
                        itemBuilder: (context, index) {
                          final item = wishlist[index];
                          final job = item.job;

                          return Card(
                            elevation: 3,
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                              title: Text(
                                job.title,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 6),
                                  Text(
                                    job.description,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Budget: \$${job.budget.toStringAsFixed(2)}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: Colors.green.shade700,
                                        ),
                                      ),
                                      Text(
                                        'Deadline: ${job.deadline}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: Colors.red.shade700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete, color: Colors.redAccent),
                                tooltip: 'Remove from wishlist',
                                onPressed: () => _confirmRemove(item.id!),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}
