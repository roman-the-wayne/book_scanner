import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainContainerPage extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainContainerPage({
    super.key,
    required this.navigationShell,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.camera_alt),
            selectedIcon: Icon(Icons.camera),
            label: 'Поиск по фото',
          ),
          NavigationDestination(
            icon: Icon(Icons.auto_stories),
            selectedIcon: Icon(Icons.menu_book),
            label: 'Библиотека',
          ),
        ],
      ),
    );
  }
}
