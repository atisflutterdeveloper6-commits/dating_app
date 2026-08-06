import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';

class PhotoBox extends StatelessWidget {

  final File? image;
  final VoidCallback onTap;
  final double height;

  const PhotoBox({
    super.key,
    required this.image,
    required this.onTap,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {

    return GestureDetector(

      onTap: onTap,

      child: 
     DottedBorder(
  options: RoundedRectDottedBorderOptions(
    radius: const Radius.circular(15),
    color: const Color(0xffFF6B00),
    strokeWidth: 1.5,
    dashPattern: const [6, 3],
  ),
  child: Container(
    height: height,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(15),
    ),
    child: image == null
        ? const Center(
            child: Icon(
              Icons.add,
              color: Color(0xffFF6B00),
              size: 30,
            ),
          )
        : ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image.file(
              image!,
              fit: BoxFit.cover,
            ),
          ),
  ),
)
   
    );
  }
}