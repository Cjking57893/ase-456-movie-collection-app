import 'package:flutter/material.dart';
import 'movie_list_page.dart';

/// Root home page that displays the movie collection
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const MovieListPage();
  }
}
