import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:number_puzzles/widgets/coin_icon_wdget.dart';

class CustomAppBar extends StatelessWidget {
  final String title;
  final bool showBackButton;
  const CustomAppBar({
    Key? key,
    required this.title,
    required this.showBackButton,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
          top: 8, bottom: 8, left: showBackButton ? 2 : 8, right: 12),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blueAccent, Colors.redAccent],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back Button
          Row(
            children: [
              if (showBackButton)
                IconButton(
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    // Handle back button press
                    Navigator.of(context).pop();
                  },
                ),
              const SizedBox(
                width: 5,
              ),
              Text(
                title,
                style: GoogleFonts.poppins(),
              ),
            ],
          ),
          const CoinIconWithText(),
        ],
      ),
    );
  }
}
