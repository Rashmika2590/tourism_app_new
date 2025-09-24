import 'package:flutter/material.dart';
import 'package:tourism_app_new/Services/Api%20Services/FAQ_api_service.dart';
import 'package:tourism_app_new/constants/colors.dart';
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
  bool _showQuestionInput = false;
  bool _showAllFAQs = false; // 🆕 Added to control showing all FAQs

  // Track user reactions locally (fallback if backend doesn't provide userReaction)
  Map<int, String?> localUserReactions = {}; // faqId -> 'like'/'dislike'/null

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
      setState(() {
        _showQuestionInput = false;
      });
      _loadFAQs(); // Refresh the list
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Question submitted successfully!'),
          backgroundColor: AppColors.mainGreen,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to submit question: $e'),
          backgroundColor: Colors.red,
        ),
      );
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
        setState(() {
          localUserReactions[faqId] = 'like';
        });
      } else {
        await FAQService.dislikeFAQ(faqId);
        setState(() {
          localUserReactions[faqId] = 'dislike';
        });
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
    return Container(
      color: Colors.grey[100],
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
                  ElevatedButton(onPressed: _loadFAQs, child: Text('Retry')),
                ],
              ),
            );
          }

          final faqs = snapshot.hasData ? snapshot.data!.faqs : <FAQ>[];
          final bool hasFAQs = faqs.isNotEmpty;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // FAQ List or Empty State
              if (hasFAQs)
                Expanded(child: _buildFAQsList(faqs))
              else
                // Empty state with question input
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'No questions yet. Be the first to ask!',
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(color: Colors.grey[600]),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 24),
                        _buildQuestionInput(),
                        Spacer(),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFAQsList(List<FAQ> allFAQs) {
    // Show only first 3 FAQs initially, or all if _showAllFAQs is true
    final List<FAQ> faqsToShow =
        _showAllFAQs ? allFAQs : allFAQs.take(3).toList();
    final bool hasMoreFAQs = allFAQs.length > 3;

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount:
          faqsToShow.length +
          (hasMoreFAQs && !_showAllFAQs
              ? 2
              : 1), // +1 for question input, +1 for "See more" if needed
      itemBuilder: (context, index) {
        // Show FAQ items
        if (index < faqsToShow.length) {
          final faq = faqsToShow[index];
          // Use model's userReaction if available, otherwise use local state
          final userReaction = faq.userReaction ?? localUserReactions[faq.id];
          return _FAQItem(
            faq: faq,
            userReaction: userReaction,
            onLike: () => _handleReaction(faq.id, true),
            onDislike: () => _handleReaction(faq.id, false),
          );
        }

        // Show "See more" button if there are more FAQs and not showing all
        if (hasMoreFAQs && !_showAllFAQs && index == faqsToShow.length) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Center(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _showAllFAQs = true;
                  });
                },
                child: Text(
                  'See more',
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
          );
        }

        // Show question input section (always last item)
        return Column(children: [SizedBox(height: 16), _buildQuestionInput()]);
      },
    );
  }

  Widget _buildQuestionInput() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 0),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                _showQuestionInput = !_showQuestionInput;
              });
            },
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.mainGreen,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.chat_bubble_outline,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Have a question? Drop here',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'The owner will answer at their earliest',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Expandable question input field
          if (_showQuestionInput) ...[
            SizedBox(height: 16),
            TextField(
              controller: _questionController,
              decoration: InputDecoration(
                hintText: 'Type your question here...',
                hintStyle: TextStyle(color: Colors.grey[600], fontSize: 13),
                isDense: true, // makes the field more compact
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.grey[400]!, // normal underline color
                    width: 1.0, // underline thickness
                  ),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: AppColors.mainGreen, // focused underline color
                    width: 2.0, // thicker when focused
                  ),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 0,
                  vertical: 6, // reduces height
                ),
              ),
              maxLines: 3,
              minLines: 2,
            ),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      _showQuestionInput = false;
                      _questionController.clear();
                    });
                  },
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _isLoading ? null : _submitQuestion,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.mainGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child:
                      _isLoading
                          ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                          : Text('Submit'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _FAQItem extends StatelessWidget {
  final FAQ faq;
  final String? userReaction; // 'like', 'dislike', or null
  final VoidCallback onLike;
  final VoidCallback onDislike;

  const _FAQItem({
    Key? key,
    required this.faq,
    this.userReaction,
    required this.onLike,
    required this.onDislike,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool hasLiked = userReaction == 'like';
    final bool hasDisliked = userReaction == 'dislike';

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question
          Text(
            faq.question,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 8),

          // Answer
          if (faq.answer != null)
            Text(
              faq.answer!,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[700],
                height: 1.4,
              ),
            )
          else
            Text(
              'Pending answer from hotel...',
              style: TextStyle(
                fontSize: 13,
                fontStyle: FontStyle.italic,
                color: Colors.grey[500],
              ),
            ),

          SizedBox(height: 16),

          // Reaction buttons
          Row(
            children: [
              // Helpful button
              GestureDetector(
                onTap: onLike,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      hasLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                      size: 16,
                      color: hasLiked ? Colors.green : Colors.grey[600],
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Helpful (${faq.likeCount})',
                      style: TextStyle(
                        fontSize: 12,
                        color: hasLiked ? Colors.green : Colors.grey[600],
                        fontWeight:
                            hasLiked ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(width: 24),

              // Unhelpful button
              GestureDetector(
                onTap: onDislike,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      hasDisliked
                          ? Icons.thumb_down
                          : Icons.thumb_down_outlined,
                      size: 16,
                      color: hasDisliked ? Colors.red : Colors.grey[600],
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Unhelpful (${faq.dislikeCount})',
                      style: TextStyle(
                        fontSize: 12,
                        color: hasDisliked ? Colors.red : Colors.grey[600],
                        fontWeight:
                            hasDisliked ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
