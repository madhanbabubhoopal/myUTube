import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';
import '../providers/video_provider.dart';
import '../widgets/video_card.dart';
import 'player_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<VideoProvider>();
    final isDark = provider.isDarkMode;
    final results = provider.searchResults;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F0F0F) : Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF0000),
        title: TextField(
          controller: _ctrl,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          cursorColor: Colors.white,
          decoration: const InputDecoration(
            hintText: 'Search videos...',
            hintStyle: TextStyle(color: Colors.white60),
            border: InputBorder.none,
          ),
          onChanged: (q) => context.read<VideoProvider>().search(q),
        ),
        actions: [
          if (_ctrl.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear, color: Colors.white),
              onPressed: () {
                _ctrl.clear();
                context.read<VideoProvider>().search('');
              },
            ),
        ],
      ),
      body: _ctrl.text.isEmpty
          ? const Center(
              child: Text(
                'Search your video library.',
                style: TextStyle(color: Colors.grey),
              ),
            )
          : results.isEmpty
              ? const Center(
                  child: Text(
                    'No results found.',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : AnimationLimiter(
                  child: ListView.builder(
                    padding: const EdgeInsets.only(top: 8, bottom: 16),
                    itemCount: results.length,
                    itemBuilder: (context, index) =>
                        AnimationConfiguration.staggeredList(
                      position: index,
                      duration: const Duration(milliseconds: 300),
                      child: SlideAnimation(
                        verticalOffset: 30,
                        child: FadeInAnimation(
                          child: VideoCard(
                            video: results[index],
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PlayerScreen(
                                  video: results[index],
                                  queue: results,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
    );
  }
}
