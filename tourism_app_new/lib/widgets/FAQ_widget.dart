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
  bool _showAllFAQs = false;

  // Store user reactions fetched from backend
  Map<int, UserReaction?> userReactions = {}; // faqId -> UserReaction object
  bool _isLoadingReactions = false;

  @override
  void initState() {
    super.initState();
    _loadFAQs();
  }

  void _loadFAQs() {
    setState(() {
      _faqsFuture = FAQService.getFAQsForHotel(widget.hotelId);
    });
    // Load reactions after FAQs are fetched
    _faqsFuture.then((response) => _loadUserReactions(response.faqs));
  }

  Future<void> _loadUserReactions(List<FAQ> faqs) async {
    setState(() {
      _isLoadingReactions = true;
    });

    // Fetch user reaction for each FAQ
    for (var faq in faqs) {
      try {
        final reaction = await FAQService.getUserReaction(faq.id);
        setState(() {
          userReactions[faq.id] = reaction;
        });
      } catch (e) {
        print('Error loading reaction for FAQ ${faq.id}: $e');
        // Set to null if error - means no reaction
        setState(() {
          userReactions[faq.id] = null;
        });
      }
    }

    setState(() {
      _isLoadingReactions = false;
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
      // Check if user already reacted the same way
      final currentReaction = userReactions[faqId];
      if (currentReaction != null &&
          currentReaction.reacted &&
          currentReaction.isLike == isLike) {
        // User clicked the same reaction again - do nothing or show message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('You already reacted to this FAQ'),
            duration: Duration(seconds: 1),
          ),
        );
        return;
      }

      // Add the reaction
      if (isLike) {
        await FAQService.likeFAQ(faqId);
      } else {
        await FAQService.dislikeFAQ(faqId);
      }

      // Fetch updated reaction from backend
      final updatedReaction = await FAQService.getUserReaction(faqId);
      setState(() {
        userReactions[faqId] = updatedReaction;
      });

      // Refresh FAQ list to get updated counts
      _loadFAQs();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Reaction recorded!'),
          duration: Duration(seconds: 1),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to record reaction: $e'),
          backgroundColor: Colors.red,
        ),
      );
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
    final List<FAQ> faqsToShow =
        _showAllFAQs ? allFAQs : allFAQs.take(3).toList();
    final bool hasMoreFAQs = allFAQs.length > 3;

    return Scrollbar(
      thumbVisibility: true, // Always show the scrollbar
      trackVisibility: true, // Show track as well
      thickness: 6.0, // Custom thickness
      radius: Radius.circular(3), // Rounded edges
      child: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: faqsToShow.length + (hasMoreFAQs && !_showAllFAQs ? 2 : 1),
        itemBuilder: (context, index) {
          if (index < faqsToShow.length) {
            final faq = faqsToShow[index];
            final reaction = userReactions[faq.id];

            // Determine user reaction state
            String? userReactionState;
            if (reaction != null && reaction.reacted) {
              userReactionState = reaction.isLike ? 'like' : 'dislike';
            }

            return _FAQItem(
              faq: faq,
              userReaction: userReactionState,
              onLike: () => _handleReaction(faq.id, true),
              onDislike: () => _handleReaction(faq.id, false),
              isLoadingReaction: _isLoadingReactions,
            );
          }

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
                      color: AppColors.mainGreen,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      //decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
            );
          }

          return Column(
            children: [SizedBox(height: 16), _buildQuestionInput()],
          );
        },
      ),
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

          if (_showQuestionInput) ...[
            SizedBox(height: 16),
            TextField(
              controller: _questionController,
              decoration: InputDecoration(
                hintText: 'Type your question here...',
                hintStyle: TextStyle(color: Colors.grey[600], fontSize: 13),
                isDense: true,
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey[400]!, width: 1.0),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: AppColors.mainGreen,
                    width: 2.0,
                  ),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 0,
                  vertical: 6,
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

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }
}

class _FAQItem extends StatelessWidget {
  final FAQ faq;
  final String? userReaction;
  final VoidCallback onLike;
  final VoidCallback onDislike;
  final bool isLoadingReaction;

  const _FAQItem({
    Key? key,
    required this.faq,
    this.userReaction,
    required this.onLike,
    required this.onDislike,
    this.isLoadingReaction = false,
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
          Text(
            faq.question,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 8),

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

          Row(
            children: [
              GestureDetector(
                onTap: isLoadingReaction ? null : onLike,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      hasLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                      size: 16,
                      color: hasLiked ? AppColors.mainGreen : Colors.grey[600],
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Helpful (${faq.likeCount})',
                      style: TextStyle(
                        fontSize: 12,
                        color:
                            hasLiked ? AppColors.mainGreen : Colors.grey[600],
                        fontWeight:
                            hasLiked ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(width: 24),

              GestureDetector(
                onTap: isLoadingReaction ? null : onDislike,
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
