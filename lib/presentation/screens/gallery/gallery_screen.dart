import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/empty_state_widget.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  bool _isLoading = false;
  List<GalleryItem> _galleryItems = [];

  @override
  void initState() {
    super.initState();
    _loadGalleryItems();
  }

  Future<void> _loadGalleryItems() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate loading
    await Future.delayed(const Duration(seconds: 1));

    // Mock data
    setState(() {
      _galleryItems = _getMockGalleryItems();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Gallery',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: _isLoading
          ? const LoadingWidget(message: 'Loading gallery...')
          : _galleryItems.isEmpty
              ? EmptyStateWidget(
                  icon: Icons.photo_library,
                  title: 'No Photos Yet',
                  subtitle: 'Photos from events will appear here',
                  actionText: 'Refresh',
                  onActionTap: _loadGalleryItems,
                )
              : _buildGalleryGrid(),
    );
  }

  Widget _buildGalleryGrid() {
    return RefreshIndicator(
      onRefresh: _loadGalleryItems,
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1,
        ),
        itemCount: _galleryItems.length,
        itemBuilder: (context, index) {
          final item = _galleryItems[index];
          return _buildGalleryItem(item);
        },
      ),
    );
  }

  Widget _buildGalleryItem(GalleryItem item) {
    return GestureDetector(
      onTap: () => _showImageDialog(item),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              offset: const Offset(0, 2),
              blurRadius: 8,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Placeholder for image
              Container(
                color: Colors.grey.shade200,
                child: Icon(
                  Icons.image,
                  size: 50,
                  color: Colors.grey.shade400,
                ),
              ),
              // Event info overlay
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        item.eventName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        item.date,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Category badge
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getCategoryColor(item.category).withOpacity(0.9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    item.category,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showImageDialog(GalleryItem item) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          children: [
            Center(
              child: Container(
                margin: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey.shade200,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Image placeholder
                    Container(
                      height: 300,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                        color: Colors.grey.shade300,
                      ),
                      child: Icon(
                        Icons.image,
                        size: 100,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    // Image info
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.eventName,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.date,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            item.description,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Close button
            Positioned(
              top: 10,
              right: 10,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.black.withOpacity(0.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Gallery'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('All Events'),
              leading: Radio<String>(
                value: 'all',
                groupValue: 'all',
                onChanged: (value) {},
              ),
            ),
            ListTile(
              title: const Text('Technical Events'),
              leading: Radio<String>(
                value: 'technical',
                groupValue: 'all',
                onChanged: (value) {},
              ),
            ),
            ListTile(
              title: const Text('Cultural Events'),
              leading: Radio<String>(
                value: 'cultural',
                groupValue: 'all',
                onChanged: (value) {},
              ),
            ),
            ListTile(
              title: const Text('Sports Events'),
              leading: Radio<String>(
                value: 'sports',
                groupValue: 'all',
                onChanged: (value) {},
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'technical':
        return Colors.blue;
      case 'cultural':
        return Colors.purple;
      case 'sports':
        return Colors.green;
      case 'academic':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  List<GalleryItem> _getMockGalleryItems() {
    return [
      GalleryItem(
        id: '1',
        eventName: 'Tech Fest 2024',
        category: 'Technical',
        date: 'Dec 15, 2024',
        description: 'Annual technical festival showcasing innovation and creativity.',
      ),
      GalleryItem(
        id: '2',
        eventName: 'Cultural Night',
        category: 'Cultural',
        date: 'Dec 10, 2024',
        description: 'An evening filled with cultural performances and traditions.',
      ),
      GalleryItem(
        id: '3',
        eventName: 'Sports Day',
        category: 'Sports',
        date: 'Dec 5, 2024',
        description: 'Annual sports competition with various athletic events.',
      ),
      GalleryItem(
        id: '4',
        eventName: 'Hackathon 2024',
        category: 'Technical',
        date: 'Nov 28, 2024',
        description: '48-hour coding marathon for innovative solutions.',
      ),
      GalleryItem(
        id: '5',
        eventName: 'Dance Competition',
        category: 'Cultural',
        date: 'Nov 20, 2024',
        description: 'Inter-college dance competition with multiple categories.',
      ),
      GalleryItem(
        id: '6',
        eventName: 'Cricket Tournament',
        category: 'Sports',
        date: 'Nov 15, 2024',
        description: 'Annual cricket tournament with multiple teams.',
      ),
    ];
  }
}

class GalleryItem {
  final String id;
  final String eventName;
  final String category;
  final String date;
  final String description;

  GalleryItem({
    required this.id,
    required this.eventName,
    required this.category,
    required this.date,
    required this.description,
  });
}