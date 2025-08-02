import 'package:flutter/material.dart';
import '../category.dart';

class AppDrawer extends StatelessWidget {
  final List<Category> categories;
  final int? selectedCategoryId;
  final Function(int?) onCategorySelected;
  final int currentUserId;
  final int currentUserRoleId;
  final VoidCallback onManageArticles;
  final VoidCallback onLogout;

  const AppDrawer({
    super.key,
    required this.categories,
    required this.selectedCategoryId,
    required this.onCategorySelected,
    required this.currentUserId,
    required this.currentUserRoleId,
    required this.onManageArticles,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
            child: const Center(
              child: Text(
                'Danh mục',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                ListTile(
                  leading: const Icon(Icons.article),
                  title: const Text('Tất cả'),
                  selected: selectedCategoryId == null,
                  onTap: () {
                    onCategorySelected(null);
                    Navigator.pop(context);
                  },
                ),
                if (currentUserId > 0) // Only show Favorites if logged in
                  ListTile(
                    leading: const Icon(Icons.favorite),
                    title: const Text('Favorites'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/favorites');
                    },
                  ),
                const Divider(),
                ...categories.map(
                  (category) => ListTile(
                    leading: const Icon(Icons.category),
                    title: Text(category.name),
                    selected: selectedCategoryId == category.categoryID,
                    onTap: () {
                      onCategorySelected(category.categoryID);
                      Navigator.pop(context);
                    },
                  ),
                ),
                if (currentUserRoleId == 1) ...[
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.admin_panel_settings),
                    title: const Text('Quản lý bài viết'),
                    onTap: () {
                      Navigator.pop(context);
                      onManageArticles();
                    },
                  ),
                ],
                const Divider(),
                if (currentUserId > 0)
                  ListTile(
                    leading: const Icon(Icons.logout),
                    title: const Text('Đăng xuất'),
                    onTap: () {
                      Navigator.pop(context);
                      onLogout();
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
