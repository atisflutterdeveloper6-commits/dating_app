import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class FavoriteView extends StatelessWidget {
  FavoriteView({super.key});

  final List<Map<String, String>> users = [
    {
      "image": "assets/images/profile1.jpg",
      "name": "James",
      "age": "23",
      "job": "programming",
    },
    {
      "image": "assets/images/profile2.jpg",
      "name": "James",
      "age": "23",
      "job": "programming",
    },
    {
      "image": "assets/images/profile3.jpg",
      "name": "James",
      "age": "23",
      "job": "programming",
    },
    {
      "image": "assets/images/profile4.jpg",
      "name": "James",
      "age": "23",
      "job": "programming",
    },
    {
      "image": "assets/images/profile5.jpg",
      "name": "James",
      "age": "23",
      "job": "programming",
    },
    {
      "image": "assets/images/profile6.jpg",
      "name": "James",
      "age": "23",
      "job": "programming",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF7F7F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        surfaceTintColor: Colors.white,
        leading: Padding(
          padding: const EdgeInsets.only(left: 14),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => Get.back(),
            child: Container(
              height: 32,
              width: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xffE5E5E5)),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                size: 14,
                color: Colors.black,
              ),
            ),
          ),
        ),
        title: Text(
          "Favourite",
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          itemCount: users.length,
          gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 14,
            mainAxisSpacing: 18,
            childAspectRatio: 0.72,
          ),
          itemBuilder: (context, index) {
            final user = users[index];

            return ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Image.asset(
                      user["image"]!,
                      fit: BoxFit.cover,
                    ),
                  ),

                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(.75),
                          ],
                          stops: const [0.55, 1],
                        ),
                      ),
                    ),
                  ),

                  /// Orange Bookmark
                  const Positioned(
                    top: 0,
                    right: 10,
                    child: Icon(
                      Icons.bookmark,
                      color: Color(0xffFF6B00),
                      size: 28,
                    ),
                  ),

                  Positioned(
                    left: 10,
                    right: 10,
                    bottom: 10,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${user["name"]}, ${user["age"]}",
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          user["job"]!,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}