import 'package:flutter/material.dart';

class ReviewCarousel extends StatelessWidget {
  const ReviewCarousel({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> reviewList = [
      {
        "name": "Dinesh R",
        "text":
            "Stayed here for two nights while attending a conference nearby. The place was spotless, check-in was smooth, and the Wi-Fi was fast enough for video calls.",
        "profileImage": "https://randomuser.me/api/portraits/men/1.jpg",
        "images": [
          "https://picsum.photos/id/1011/200",
          "https://picsum.photos/id/1012/200",
          "https://picsum.photos/id/1014/200",
        ],
        "rating": 3,
      },
      {
        "name": "Claire",
        "text":
            "Nice property overall, clean and well-maintained. Only downside was the road noise in the morning. Great value for the price though.",
        "profileImage": "https://randomuser.me/api/portraits/women/2.jpg",
        "images": [
          "https://picsum.photos/id/1015/200",
          "https://picsum.photos/id/1016/200",
          "https://picsum.photos/id/1017/200",
        ],
        "rating": 3,
      },
      {
        "name": "Dinesh R",
        "text":
            "The place was spotless, check-in was smooth, and the Wi-Fi was fast enough for video calls.",
        "profileImage": "https://randomuser.me/api/portraits/men/1.jpg",
        "images": [
          "https://picsum.photos/id/1011/200",
          "https://picsum.photos/id/1012/200",
          "https://picsum.photos/id/1014/200",
        ],
        "rating": 3,
      },
      {
        "name": "Dinesh R",
        "text":
            "The place was spotless, check-in was smooth, and the Wi-Fi was fast enough for video calls and many more things that I want to write here to test the expandable functionality of this review card component.",
        "profileImage": "https://randomuser.me/api/portraits/men/1.jpg",
        "images": [
          "https://picsum.photos/id/1011/200",
          "https://picsum.photos/id/1012/200",
          "https://picsum.photos/id/1014/200",
        ],
        "rating": 3,
      },
    ];

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.4,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: reviewList.length,
        itemBuilder: (context, index) {
          final review = reviewList[index];
          return ReviewCard(
            reviewerName: review["name"],
            reviewText: review["text"],
            profileImageUrl: review["profileImage"],
            reviewImages: List<String>.from(review["images"]),
            starRating: review["rating"],
          );
        },
      ),
    );
  }
}

class ReviewCard extends StatefulWidget {
  final String reviewerName;
  final String reviewText;
  final String profileImageUrl;
  final List<String> reviewImages;
  final int starRating;

  const ReviewCard({
    super.key,
    required this.reviewerName,
    required this.reviewText,
    required this.profileImageUrl,
    required this.reviewImages,
    required this.starRating,
  });

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
        text: '"${widget.reviewText}"',
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
                      index < widget.starRating
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
                                '"${widget.reviewText}"',
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

                // Reviewer Name
                Text(
                  '-${widget.reviewerName}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 12),

                // Review Images - Always at bottom of container
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (
                      int i = 0;
                      i <
                          (widget.reviewImages.length > 2
                              ? 2
                              : widget.reviewImages.length);
                      i++
                    )
                      Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            widget.reviewImages[i],
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
                    if (widget.reviewImages.length > 2)
                      Container(
                        height: 32,
                        width: 32,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.black45,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '+${widget.reviewImages.length - 2}',
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
              backgroundImage: NetworkImage(widget.profileImageUrl),
              radius: 30,
              onBackgroundImageError: (exception, stackTrace) {
                // Handle image loading error
              },
              child:
                  widget.profileImageUrl.isEmpty
                      ? const Icon(Icons.person, size: 30)
                      : null,
            ),
          ),
        ],
      ),
    );
  }
}
