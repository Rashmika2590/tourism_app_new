import 'package:flutter/material.dart';
import 'package:tourism_app_new/Services/Api%20Services/FAQ_api_service.dart';
import 'package:tourism_app_new/models/faq_model.dart';

class FAQWidget extends StatefulWidget {
  final int hotelId;

  const FAQWidget({Key? key, required this.hotelId}) : super(key: key);

  @override
  State<FAQWidget> createState() => _FAQWidgetState();
}

class _FAQWidgetState extends State<FAQWidget> {
  late Future<FAQResponse> _faqsFuture;
  final TextEditingController _questionController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadFAQs();
  }

  void _loadFAQs() {
    setState(() {
      _faqsFuture = FAQService.getFAQsForHotel(widget.hotelId);
    });
  }

  Future<void> _submitQuestion() async {
    if (_questionController.text.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await FAQService.createFAQForHotel(
        hotelId: widget.hotelId,
        question: _questionController.text.trim(),
      );

      _questionController.clear();
      _loadFAQs(); // Refresh the list
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Question submitted successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to submit question: $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _handleReaction(int faqId, bool isLike) async {
    try {
      if (isLike) {
        await FAQService.likeFAQ(faqId);
      } else {
        await FAQService.dislikeFAQ(faqId);
      }

      _loadFAQs(); // Refresh to get updated counts
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Reaction recorded!')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to record reaction: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // FAQ List
        Expanded(
          child: FutureBuilder<FAQResponse>(
            future: _faqsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Failed to load FAQs'),
                      ElevatedButton(
                        onPressed: _loadFAQs,
                        child: Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              if (!snapshot.hasData || snapshot.data!.faqs.isEmpty) {
                return Center(
                  child: Text(
                    'No questions yet. Be the first to ask!',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                );
              }

              final faqs = snapshot.data!.faqs;

              return ListView.builder(
                itemCount: faqs.length,
                itemBuilder: (context, index) {
                  final faq = faqs[index];
                  return _FAQItem(
                    faq: faq,
                    onLike: () => _handleReaction(faq.id, true),
                    onDislike: () => _handleReaction(faq.id, false),
                  );
                },
              );
            },
          ),
        ),

        // Add Question Section - Moved to bottom
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          margin: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Have a question? Drop here',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                'The owner will answer at their earliest',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _questionController,
                      decoration: InputDecoration(
                        hintText: 'Ask a question about this hotel...',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      maxLines: 2,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _isLoading
                      ? CircularProgressIndicator()
                      : IconButton(
                        icon: Icon(Icons.send, color: Colors.blue),
                        onPressed: _submitQuestion,
                      ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FAQItem extends StatelessWidget {
  final FAQ faq;
  final VoidCallback onLike;
  final VoidCallback onDislike;

  const _FAQItem({
    Key? key,
    required this.faq,
    required this.onLike,
    required this.onDislike,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Determine if current user has reacted (you'll need to get this from your state management)
    final bool hasLiked = faq.likeCount == 'like'; // Adjust based on your model
    final bool hasDisliked =
        faq.dislikeCount == 'dislike'; // Adjust based on your model

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question
          Text(
            faq.question,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          // Answer
          if (faq.answer != null)
            Text(
              faq.answer!,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
            )
          else
            Text(
              'Pending answer from hotel...',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontStyle: FontStyle.italic,
                color: Colors.grey[500],
              ),
            ),

          const SizedBox(height: 12),

          // Reactions
          Row(
            children: [
              // Helpful button
              GestureDetector(
                onTap: onLike,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: hasLiked ? Colors.green : Colors.grey[300]!,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    color: hasLiked ? Colors.green.withOpacity(0.1) : null,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.thumb_up,
                        size: 16,
                        color: hasLiked ? Colors.green : Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Helpful (${faq.likeCount})',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: hasLiked ? Colors.green : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Unhelpful button
              GestureDetector(
                onTap: onDislike,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: hasDisliked ? Colors.red : Colors.grey[300]!,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    color: hasDisliked ? Colors.red.withOpacity(0.1) : null,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.thumb_down,
                        size: 16,
                        color: hasDisliked ? Colors.red : Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Unhelpful (${faq.dislikeCount})',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: hasDisliked ? Colors.red : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Spacer(),

              // "See more" text for the last item
              if (faq == _getLastFAQ()) // You'll need to implement this method
                Text(
                  'See more',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
            ],
          ),

          const SizedBox(height: 16),
          Divider(color: Colors.grey[300]),
        ],
      ),
    );
  }

  // Helper method to get the last FAQ (you'll need to pass the list or index)
  FAQ _getLastFAQ() {
    // This is a placeholder - you'll need to implement this properly
    // by passing the list of FAQs or the index to each _FAQItem
    return faq;
  }
}
