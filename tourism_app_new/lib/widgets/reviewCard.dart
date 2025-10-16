import 'package:flutter/material.dart';
import 'package:tourism_app_new/Services/Api%20Services/review_api_service.dart';
import 'package:tourism_app_new/models/review_model.dart';

class ReviewCarousel extends StatefulWidget {
  final int hotelId;

  const ReviewCarousel({super.key, required this.hotelId});

  @override
  State<ReviewCarousel> createState() => _ReviewCarouselState();
}

class _ReviewCarouselState extends State<ReviewCarousel> {
  late Future<List<Review>> _reviewsFuture;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _reviewsFuture = _loadReviews();
  }

  Future<List<Review>> _loadReviews() async {
    try {
      return await ReviewService.getReviewsForHotel(widget.hotelId);
    } catch (e) {
      print("Error loading reviews: $e");
      return [];
    }
  }

  void _refreshReviews() {
    setState(() {
      _reviewsFuture = _loadReviews();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Review>>(
      future: _reviewsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox(
            height: MediaQuery.of(context).size.height * 0.4,
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return SizedBox(
            height: MediaQuery.of(context).size.height * 0.4,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error loading reviews: ${snapshot.error}'),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _refreshReviews,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        final reviews = snapshot.data ?? [];

        if (reviews.isEmpty) {
          return SizedBox(
            height: MediaQuery.of(context).size.height * 0.4,
            child: const Center(
              child: Text(
                'No reviews yet',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
          );
        }

        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.4,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: reviews.length,
            itemBuilder: (context, index) {
              final review = reviews[index];
              return ReviewCard(review: review);
            },
          ),
        );
      },
    );
  }
}

class ReviewCard extends StatefulWidget {
  final Review review;

  const ReviewCard({super.key, required this.review});

  @override
  State<ReviewCard> createState() => _ReviewCardState();
}

class _ReviewCardState extends State<ReviewCard> {
  bool isExpanded = false;
  bool showSeeMore = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkTextOverflow();
    });
  }

  void _checkTextOverflow() {
    final textPainter = TextPainter(
      text: TextSpan(
        text: '"${widget.review.comment}"',
        style: const TextStyle(fontSize: 14),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 4, // Allow 4 lines before showing "See more"
    );
    textPainter.layout(maxWidth: 156); // Card width minus padding

    if (textPainter.didExceedMaxLines) {
      setState(() {
        showSeeMore = true;
      });
    }
  }

  String _getInitials(String userId) {
    if (userId.length >= 2) {
      return userId.substring(0, 2).toUpperCase();
    }
    return 'U'; // Default if user ID is too short
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final defaultHeight = screenHeight * 0.4 - 70; // Default fixed height
    final maxExpandedHeight =
        screenHeight * 0.8; // Maximum height when expanded

    return Container(
      width: 180,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          // Main Green Container
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            margin: const EdgeInsets.only(top: 30),
            padding: const EdgeInsets.fromLTRB(12, 40, 12, 12),
            constraints:
                isExpanded
                    ? BoxConstraints(
                      minHeight: defaultHeight,
                      maxHeight: maxExpandedHeight,
                    ) // Limited expansion with max height
                    : BoxConstraints(
                      maxHeight: defaultHeight,
                    ), // Force fixed height when collapsed
            decoration: BoxDecoration(
              color: Colors.teal.shade200,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Stars
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return Icon(
                      index < widget.review.rating
                          ? Icons.star
                          : Icons.star_border,
                      color: Colors.orange,
                      size: 16,
                    );
                  }),
                ),
                const SizedBox(height: 8),

                // Review Text with See More/Less
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              Text(
                                '"${widget.review.comment}"',
                                textAlign: TextAlign.center,
                                maxLines:
                                    isExpanded
                                        ? null
                                        : (showSeeMore ? 4 : null),
                                overflow:
                                    isExpanded
                                        ? null
                                        : (showSeeMore
                                            ? TextOverflow.ellipsis
                                            : null),
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (showSeeMore) ...[
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              isExpanded = !isExpanded;
                            });
                          },
                          child: Text(
                            isExpanded ? 'See less' : 'See more',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white70,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Reviewer Name (using user ID initials)
                Text(
                  '-User ${_getInitials(widget.review.userId)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 12),

                // Review Images - Always at bottom of container
                if (widget.review.images.isNotEmpty)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (
                        int i = 0;
                        i <
                            (widget.review.images.length > 2
                                ? 2
                                : widget.review.images.length);
                        i++
                      )
                        Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              widget.review.images[i],
                              height: 32,
                              width: 32,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  height: 32,
                                  width: 32,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade300,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.image_not_supported,
                                    size: 16,
                                    color: Colors.grey,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      if (widget.review.images.length > 2)
                        Container(
                          height: 32,
                          width: 32,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.black45,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '+${widget.review.images.length - 2}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
              ],
            ),
          ),
          // Circle Avatar - Outside the container
          Positioned(
            top: 0,
            child: CircleAvatar(
              backgroundColor: Colors.teal.shade400,
              radius: 30,
              child: Text(
                _getInitials(widget.review.userId),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
