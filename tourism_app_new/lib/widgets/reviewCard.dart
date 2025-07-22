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
            "he place was spotless, check-in was smooth, and the Wi-Fi was fast enough for video calls.",
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
            "he place was spotless, check-in was smooth, hgjhgjufgfgfyfdfdydyfdfydfdgddyddand the Wi-Fi was fast enough for video calls.",
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
      height: 400,
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

class ReviewCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          // Card content
          Container(
            margin: const EdgeInsets.only(top: 30),
            padding: const EdgeInsets.fromLTRB(12, 40, 12, 12),
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
                      index < starRating ? Icons.star : Icons.star_border,
                      color: Colors.orange,
                      size: 16,
                    );
                  }),
                ),
                const SizedBox(height: 8),
                // Review Text
                Text(
                  '"$reviewText"',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14, color: Colors.white),
                ),
                const SizedBox(height: 8),
                // Reviewer Name
                Text(
                  '-$reviewerName',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                // Review Images
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (
                      int i = 0;
                      i < (reviewImages.length > 2 ? 2 : reviewImages.length);
                      i++
                    )
                      Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            reviewImages[i],
                            height: 32,
                            width: 32,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    if (reviewImages.length > 2)
                      Container(
                        height: 32,
                        width: 32,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.black45,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '+${reviewImages.length - 2}',
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
          // Circle Avatar
          Positioned(
            top: 0,
            child: CircleAvatar(
              backgroundImage: NetworkImage(profileImageUrl),
              radius: 30,
            ),
          ),
        ],
      ),
    );
  }
}
