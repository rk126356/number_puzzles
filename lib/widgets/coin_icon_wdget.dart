import 'package:flutter/material.dart';
import 'package:number_puzzles/pages/shop/shop_page.dart';
import 'package:number_puzzles/providers/coin_provider.dart';
import 'package:provider/provider.dart';

class CoinIconWithText extends StatelessWidget {
  final bool? isPlus;
  const CoinIconWithText({super.key, this.isPlus});

  @override
  Widget build(BuildContext context) {
    final coinProvider = Provider.of<CoinProvider>(context);
    return InkWell(
      onTap: () {
        if (isPlus == null) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const ShopPageScreen(),
            ),
          );
        }
      },
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Image.asset(
                  'assets/images/coin_icon.png', // Replace with the path to your coin icon image
                  height: 30,
                  width: 30,
                ),
                const SizedBox(width: 8),
                Text(
                  coinProvider.coins.toString(),
                  style: const TextStyle(fontSize: 18, color: Colors.white),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.add,
                  color: Colors.white,
                ),
              ],
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                    color: Colors.white60,
                    width: 2), // Set your border color and width
                borderRadius: BorderRadius.circular(12),
                color: Colors
                    .transparent, // Set the background color of the border
              ),
            ),
          ),
        ],
      ),
    );
  }
}
