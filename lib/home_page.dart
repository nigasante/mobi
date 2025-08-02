import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'models/article.dart';
import 'theme_provider.dart';
import 'category.dart';
import 'admin_manager.dart';
import 'pages/favorites_page.dart';
import 'widgets/article_list_item.dart';

class HomePage extends StatefulWidget {
  final int currentUserId;
  final int currentUserRoleId;
  final VoidCallback? onLoginTap;
  final VoidCallback? onLogout;

  const HomePage({
    super.key,
    required this.currentUserId,
    required this.currentUserRoleId,
    this.onLoginTap,
    this.onLogout,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Article> articles = [];
  List<Category> categories = [];
  bool isLoading = true;
  int? selectedCategoryId;
  Map<int, bool> favoriteStatus = {};
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    fetchArticles();
    fetchCategories();
    _refreshFavorites();
  }

  @override
  void didUpdateWidget(HomePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentUserId != oldWidget.currentUserId) {
      _refreshFavorites();
    }
  }

  void _refreshFavorites() {
    if (widget.currentUserId != 0) {
      _initializeFavorites();
    } else {
      setState(() {
        favoriteStatus.clear();
      });
    }
  }

  Future<void> _initializeFavorites() async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:5264/api/FavoriteArticles/user/${widget.currentUserId}'),
      );
      if (response.statusCode == 200) {
        final List<dynamic> favorites = json.decode(response.body);
        final Map<int, bool> newFavoriteStatus = {};
        for (var favorite in favorites) {
          newFavoriteStatus[favorite['articleID']] = true;
        }
        setState(() {
          favoriteStatus = newFavoriteStatus;
        });
      }
    } catch (e) {
      print('Error initializing favorites: $e');
    }
  }

  Future<void> _toggleFavorite(Article article) async {
    if (widget.currentUserId == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to add favorites')),
      );
      widget.onLoginTap?.call();
      return;
    }

    final bool currentFavorite = favoriteStatus[article.articleID] ?? false;
    final bool newStatus = !currentFavorite;
    
    setState(() {
      favoriteStatus[article.articleID] = newStatus;
    });

    int retryCount = 0;
    const maxRetries = 3;

    while (retryCount < maxRetries) {
      try {
        final apiEndpoint = currentFavorite
            ? 'http://10.0.2.2:5264/api/FavoriteArticles/${widget.currentUserId}/${article.articleID}'
            : 'http://10.0.2.2:5264/api/FavoriteArticles';

        final response = currentFavorite
            ? await http.delete(
                Uri.parse(apiEndpoint),
                headers: {'Content-Type': 'application/json'},
              )
            : await http.post(
                Uri.parse(apiEndpoint),
                headers: {'Content-Type': 'application/json'},
                body: json.encode({
                  'userID': widget.currentUserId,
                  'articleID': article.articleID,
                }),
              );

        if (response.statusCode == 200 || response.statusCode == 201 || response.statusCode == 204) {
          if (mounted) {
            ScaffoldMessenger.of(context).removeCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  currentFavorite ? 'Removed from favorites' : 'Added to favorites',
                  style: const TextStyle(color: Colors.white),
                ),
                backgroundColor: Colors.green,
              ),
            );
          }
          return;
        } else if (response.statusCode == 409) {
          return;
        } else {
          throw Exception('Server returned ${response.statusCode}');
        }
      } catch (e) {
        print('Error toggling favorite (attempt ${retryCount + 1}): $e');
        retryCount++;
        
        if (retryCount == maxRetries || !mounted) {
          if (mounted) {
            setState(() {
              favoriteStatus[article.articleID] = currentFavorite;
            });
            ScaffoldMessenger.of(context).removeCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text(
                  'Failed to update favorite status',
                  style: TextStyle(color: Colors.white),
                ),
                backgroundColor: Colors.red,
                action: SnackBarAction(
                  label: 'RETRY',
                  textColor: Colors.white,
                  onPressed: () => _toggleFavorite(article),
                ),
              ),
            );
          }
          return;
        }
        await Future.delayed(Duration(milliseconds: 500 * retryCount));
      }
    }
  }

  void _navigateToFavorites() {
    if (widget.currentUserId == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to view favorites')),
      );
      widget.onLoginTap?.call();
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FavoritesPage(userId: widget.currentUserId),
      ),
    ).then((_) => _initializeFavorites());
  }

  Future<void> fetchArticles({int? categoryId}) async {
    setState(() => isLoading = true);
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final uri = categoryId != null 
          ? Uri.parse('http://10.0.2.2:5264/api/articles?categoryId=$categoryId&t=$timestamp&nocache=true')
          : Uri.parse('http://10.0.2.2:5264/api/articles?t=$timestamp&nocache=true');
          
      final response = await http.get(
        uri,
        headers: {
          'Cache-Control': 'no-cache',
          'Pragma': 'no-cache',
        },
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final parsedArticles = data
            .where((json) => json['isDeleted'] == false)
            .map((json) => Article.fromJson(json))
            .toList();
        setState(() {
          articles = parsedArticles;
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  Future<void> fetchCategories() async {
    final response = await http.get(
      Uri.parse('http://10.0.2.2:5264/api/categories'),
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        categories = data.map((json) => Category.fromJson(json)).toList();
      });
    }
  }

  void _onCategorySelected(int? categoryId) {
    setState(() {
      selectedCategoryId = categoryId;
      searchQuery = ''; // Reset search when changing category
    });
    fetchArticles(categoryId: categoryId);
    Navigator.pop(context);
  }

  void _onSearchSubmitted(String query) {
    setState(() {
      searchQuery = query;
    });
  }

  String get appBarTitle {
    if (selectedCategoryId == null) return "News";
    final selected = categories.firstWhere(
      (cat) => cat.categoryID == selectedCategoryId,
      orElse: () => Category(categoryID: 0, name: "News"),
    );
    return selected.name;
  }

  bool _isAdmin() => widget.currentUserRoleId == 1;

  List<Article> get filteredArticles {
    if (searchQuery.isEmpty) {
      return articles.where((article) {
        if (selectedCategoryId != null) {
          final catField = article.categoryID;
          if (catField == null || !catField.contains(selectedCategoryId)) {
            return false;
          }
        }
        if (widget.currentUserRoleId == 1 || widget.currentUserRoleId == 2) {
          return true;
        }
        return article.status == 'Published';
      }).toList();
    } else {
      return articles.where((article) {
        final matchesCategory = selectedCategoryId == null ||
            (article.categoryID?.contains(selectedCategoryId) ?? false);
        final matchesRole = widget.currentUserRoleId == 1 || widget.currentUserRoleId == 2 ||
            article.status == 'Published';
        final matchesSearch = article.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
            article.content.toLowerCase().contains(searchQuery.toLowerCase());
        return matchesCategory && matchesRole && matchesSearch;
      }).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("News"),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: 'Search articles...',
                  border: InputBorder.none,
                ),
                onSubmitted: _onSearchSubmitted,
                onChanged: (value) {
                  if (value.isEmpty) {
                    setState(() {
                      searchQuery = '';
                    });
                  }
                },
              ),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        actions: [
          if (widget.currentUserId != 0)
            IconButton(
              icon: const Icon(Icons.favorite, color: Colors.white),
              onPressed: _navigateToFavorites,
            ),
          Container(
            margin: const EdgeInsets.only(right: 10),
            child: IconButton(
              icon: Icon(
                context.watch<ThemeProvider>().isDarkMode
                    ? Icons.light_mode
                    : Icons.dark_mode,
                color: Colors.white,
                size: 26,
              ),
              onPressed: () {
                context.read<ThemeProvider>().toggleTheme();
              },
            ),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 22, 175, 152),
              ),
              child: Text(
                'Categories',
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
            ),
            ListTile(
              title: const Text('All'),
              selected: selectedCategoryId == null,
              onTap: () => _onCategorySelected(null),
            ),
            ...categories.map(
              (cat) => ListTile(
                title: Text(cat.name),
                selected: selectedCategoryId == cat.categoryID,
                onTap: () => _onCategorySelected(cat.categoryID),
              ),
            ),
            const Divider(),
            if (widget.currentUserId != 0) ...[
              ListTile(
                leading: const Icon(Icons.favorite, color: Colors.red),
                title: const Text('Favorites'),
                onTap: _navigateToFavorites,
              ),
            ],
            const Divider(),
            if (widget.currentUserId == 0)
              ListTile(
                leading: const Icon(Icons.login, color: Colors.blue),
                title: const Text('Login'),
                onTap: () {
                  Navigator.pop(context);
                  widget.onLoginTap?.call();
                },
              )
            else ...[
              if (_isAdmin())
                ListTile(
                  leading: const Icon(
                    Icons.admin_panel_settings,
                    color: Colors.orange,
                  ),
                  title: const Text('Manage Articles'),
                  onTap: () async {
                    Navigator.pop(context);
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AdminArticleManager(
                          adminUserId: widget.currentUserId,
                        ),
                      ),
                    );
                    if (result == true) {
                      fetchArticles(categoryId: selectedCategoryId);
                    }
                  },
                ),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text('Logout'),
                onTap: () {
                  Navigator.pop(context);
                  widget.onLogout?.call();
                },
              ),
            ],
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => fetchArticles(categoryId: selectedCategoryId),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : filteredArticles.isEmpty
            ? ListView(
                children: const [
                  Center(
                    child: Text(
                      "No articles found.",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              )
            : ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: filteredArticles.length,
                itemBuilder: (context, index) {
                  final article = filteredArticles[index];
                  return ArticleListItem(
                    article: article,
                    onToggleFavorite: _toggleFavorite,
                    isFavorite: favoriteStatus[article.articleID] ?? false,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ArticleDetailPage(article: article),
                        ),
                      ).then((_) => _refreshFavorites());
                    },
                  );
                },
              ),
      ),
    );
  }
}

class ArticleDetailPage extends StatelessWidget {
  final Article article;

  const ArticleDetailPage({super.key, required this.article});

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final paragraphs = article.content
        .split(RegExp(r'(\r\n|\r|\n){2,}'))
        .where((p) => p.trim().isNotEmpty)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(article.title),
        backgroundColor: const Color.fromARGB(255, 22, 175, 152),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (article.imageUrl != null && article.imageUrl!.isNotEmpty)
              SizedBox(
                width: double.infinity,
                height: 200,
                child: Image.network(
                  article.imageUrl! + "?t=${DateTime.now().millisecondsSinceEpoch}",
                  fit: BoxFit.cover,
                  cacheWidth: null,
                  cacheHeight: null,
                  headers: {
                    'Cache-Control': 'no-cache',
                    'Pragma': 'no-cache',
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[200],
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(
                            Icons.broken_image,
                            size: 48,
                            color: Colors.grey,
                          ),
                          Text('Image not available'),
                        ],
                      ),
                    );
                  },
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Created: ${_formatDate(article.createdAt)}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...paragraphs.map(
                    (paragraph) => Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Text(
                        paragraph,
                        style: const TextStyle(fontSize: 16, height: 1.6),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}