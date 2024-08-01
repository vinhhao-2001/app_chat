import 'package:flutter/material.dart';

class AvatarWidget extends StatelessWidget {
  final Image? image;
  final bool isOnline;
  final double size;
  const AvatarWidget(
      {super.key,
      required this.image,
      required this.size,
      required this.isOnline});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: size,
      backgroundImage: image?.image,
      child: Stack(
        children: [
          Positioned(
              bottom: 0,
              right: 5,
              child: Container(
                width: size / 2,
                height: size / 2,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isOnline ? Colors.green : Colors.red,
                ),
              ))
        ],
      ),
    );
  }
}
