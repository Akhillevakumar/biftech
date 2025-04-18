import 'package:biftech/provider/reels_provider.dart';
import 'package:flutter/material.dart';
import 'package:whitecodel_reels/whitecodel_reels.dart';
import 'package:video_player/video_player.dart';
import 'package:provider/provider.dart';

import 'flowchart.dart';

class HomeScreen extends StatelessWidget {
  final List<String> _videoUrls = [
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4',
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4',
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4',
  ];

    HomeScreen({super.key});

  void _showComments(BuildContext ctx, int idx) {
    final commentCtrl = TextEditingController();

    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return Consumer<ReelsProvider>(
          builder: (context, model, _) {
            final comments = model.commentsCache[idx] ?? [];
            return Padding(
              padding: MediaQuery.of(ctx).viewInsets,
              child: SizedBox(
                height: 400,
                child: Column(
                  children: [
                    SizedBox(height: 12),
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    SizedBox(height: 12),
                    Expanded(
                      child: ListView.builder(
                        itemCount: comments.length,
                        itemBuilder: (_, i) {
                          final item = comments[i];
                          return ListTile(
                            leading: CircleAvatar(child: Icon(Icons.person)),
                            title: Text(item['text']),
                            subtitle: Text(
                              DateTime.parse(
                                item['timestamp'],
                              ).toLocal().toString().split('.')[0],
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Divider(height: 1),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: commentCtrl,
                              decoration: InputDecoration(
                                hintText: 'Add a comment…',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(24),
                                  borderSide: BorderSide.none,
                                ),
                                fillColor: Colors.grey[200],
                                filled: true,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.send),
                            onPressed: () {
                              final txt = commentCtrl.text.trim();
                              if (txt.isEmpty) return;
                              Provider.of<ReelsProvider>(
                                context,
                                listen: false,
                              ).addComment(idx, txt);
                              commentCtrl.clear();
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: WhiteCodelReels(
        context: context,
        loader: const Center(child: CircularProgressIndicator()),
        videoList: _videoUrls,
        isCaching: true,
        builder: (context, idx, child, videoPlayerController, pageController) {
          return Stack(
            fit: StackFit.expand,
            children: [
              GestureDetector(
                onDoubleTap:
                    () => context.read<ReelsProvider>().toggleLike(idx),
                child: VideoPlayer(videoPlayerController),
              ),
              Positioned(
                right: 16,
                bottom: 48,
                child: Consumer<ReelsProvider>(
                  builder: (context, provider, child) {
                    provider.init(_videoUrls.length);

                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Like button
                        IconButton(
                          icon: Icon(
                            provider.liked[idx]
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color:
                                provider.liked[idx] ? Colors.red : Colors.white,
                            size: 32,
                          ),
                          onPressed: () => provider.toggleLike(idx),
                        ),

                        SizedBox(height: 16),

                        // Comment button
                        IconButton(
                          icon: Icon(
                            Icons.comment,
                            size: 32,
                            color: Colors.white,
                          ),
                          onPressed: () async {
                            await provider.loadComments(idx);
                            _showComments(context, idx);
                          },
                        ),
                        SizedBox(height: 16),

                        // “+” button
                        IconButton(
                          icon: Icon(
                            Icons.add_circle_outline,
                            size: 32,
                            color: Colors.white,
                          ),
                          onPressed: () async {
                            await videoPlayerController.pause();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => FlowChartScreen(videoId: idx),
                              ),
                            );
                          },
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
