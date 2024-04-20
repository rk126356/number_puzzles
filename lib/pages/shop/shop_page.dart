import 'dart:async';
import 'dart:io' show Platform;

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:number_puzzles/providers/coin_provider.dart';
import 'package:number_puzzles/providers/purchase_value_provider.dart';
import 'package:number_puzzles/providers/sound_provider.dart';
import 'package:number_puzzles/widgets/coin_icon_wdget.dart';
import 'package:number_puzzles/widgets/hint_popup_widget.dart';
import 'package:provider/provider.dart';

class ShopPageScreen extends StatefulWidget {
  const ShopPageScreen({Key? key}) : super(key: key);

  @override
  State<ShopPageScreen> createState() => _ShopPageScreenState();
}

class _ShopPageScreenState extends State<ShopPageScreen> {
  late RewardedAd _rewardedAd;
  bool _isRewardedAdLoaded = false;
  bool hasInternet = false;

  final String _adUnitId = Platform.isAndroid
      ? 'ca-app-pub-3442981380712673/2742424851'
      : 'ca-app-pub-3442981380712673/2742424851';

  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;
  List<ProductDetails> _products = <ProductDetails>[];

  final _productIdList = [
    '100_coins_number_puzzles',
    '500_coins_number_puzzles',
    '1000_coins_number_puzzles',
    '2000_coins_number_puzzles',
    '5000_coins_number_puzzles',
  ];

  String? _queryProductError = "";
  bool _isAvailable = false;
  List<String> _notFoundIds = <String>[];
  bool _loading = true;
  bool _purchasePending = false;
  List currentValue = ["null", 0];

  @override
  void initState() {
    super.initState();
    final Stream<List<PurchaseDetails>> purchaseUpdated =
        _inAppPurchase.purchaseStream;
    _subscription = purchaseUpdated.listen((purchaseDetailsList) {
      _listenToPurchaseUpdated(purchaseDetailsList);
    }, onDone: () {
      _subscription.cancel();
    }, onError: (Object e) {
      debugPrint("error :${e.toString()}");
    });

    initStoreInfo();

    checkInternetConnection();
    loadAd();
  }

  Future<void> checkInternetConnection() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    setState(() {
      hasInternet = connectivityResult == ConnectivityResult.mobile ||
          connectivityResult == ConnectivityResult.wifi;
    });
  }

  Future<void> initStoreInfo() async {
    final bool isAvailable = await _inAppPurchase.isAvailable();
    if (kDebugMode) {
      print(isAvailable);
    }
    if (!isAvailable) {
      setState(() {
        _isAvailable = isAvailable;
        _products = <ProductDetails>[];
        _notFoundIds = <String>[];
        _loading = false;
      });
      return;
    }

    final ProductDetailsResponse productDetailResponse =
        await _inAppPurchase.queryProductDetails(_productIdList.toSet());
    if (productDetailResponse.error != null) {
      setState(() {
        _queryProductError = productDetailResponse.error!.message;
        _isAvailable = isAvailable;
        _products = productDetailResponse.productDetails;
        _notFoundIds = productDetailResponse.notFoundIDs;
        if (kDebugMode) {
          print('_notFoundIds :: ${_notFoundIds.toList()}');
        }
        _loading = false;
      });
      return;
    }

    print(productDetailResponse.productDetails);

    if (productDetailResponse.productDetails.isEmpty) {
      setState(() {
        _queryProductError = null;
        _isAvailable = isAvailable;
        _products = productDetailResponse.productDetails;
        _notFoundIds = productDetailResponse.notFoundIDs;
        if (kDebugMode) {
          print("Products details empty");
        }
        if (kDebugMode) {
          print('_notFoundIds : ${_notFoundIds.toList()}');
        }
        if (kDebugMode) {
          print(
              'productDetailResponse error :: ${productDetailResponse.error}');
        }
        _loading = false;
      });
      return;
    }

    setState(() {
      _products = productDetailResponse.productDetails;
      _notFoundIds = productDetailResponse.notFoundIDs;
      _isAvailable = isAvailable;
      if (kDebugMode) {
        print('_notFoundIds error : ${_notFoundIds.toList()}');
      }
      _loading = false;
    });
  }

  void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    if (kDebugMode) {
      print("Listening....");
    }
    if (kDebugMode) {
      print(purchaseDetailsList[0].productID);
    }

    purchaseDetailsList.forEach((purchaseDetails) async {
      final value = Provider.of<PurchaseValueProvider>(context, listen: false);
      final coins = Provider.of<CoinProvider>(context, listen: false);
      if (purchaseDetails.status == PurchaseStatus.pending) {
        value.setPurchasePending(true);
        setState(() {
          _purchasePending = true;
        });
      } else {
        setState(() {
          _purchasePending = false;
        });
        if (purchaseDetails.status == PurchaseStatus.error) {
          value.setPurchasePending(false);
          showSnackBar('Purchase Error');
        } else if (purchaseDetails.status == PurchaseStatus.purchased) {
          value.setPurchasePending(false);
          bool validPurchase = await _verifyPurchase(purchaseDetails);
          if (validPurchase) {
            if (value.itemName == "Coins") {
              coins.addCoin(value.currentValue);
              // ignore: use_build_context_synchronously
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return HintAnswerScreen(
                    btnTitle: "Yay!",
                    explanation: "+${value.currentValue} coins added.",
                    title: "Success",
                    onNext: () {
                      Navigator.pop(context);
                    },
                  );
                },
              );
            }
            await _inAppPurchase.completePurchase(purchaseDetails);
          } else {
            showSnackBar('Invalid Purchase');
            await _inAppPurchase.completePurchase(purchaseDetails);
          }
        }
      }
    });
  }

  Future<bool> _verifyPurchase(PurchaseDetails purchaseDetails) async {
    return true;
  }

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(milliseconds: 1500),
      ),
    );
  }

  @override
  void dispose() {
    _subscription.cancel();
    _rewardedAd.dispose();
    super.dispose();
  }

  void loadAd() {
    RewardedAd.load(
      adUnitId: _adUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              setState(() {
                _isRewardedAdLoaded = false;
              });
            },
          );
          setState(() {
            _isRewardedAdLoaded = true;
          });
        },
        onAdFailedToLoad: (err) {
          if (kDebugMode) {
            print(err);
          }
          setState(() {
            _isRewardedAdLoaded = false;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final coinsprovider = Provider.of<CoinProvider>(context, listen: false);
    final musicPlayer = Provider.of<AudioProvider>(context, listen: false);
    final value = Provider.of<PurchaseValueProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        actions: const [
          Center(
              child: Padding(
            padding: EdgeInsets.all(8.0),
            child: CoinIconWithText(
              isPlus: true,
            ),
          ))
        ],
        title: Text(
          'Shop',
          style: GoogleFonts.poppins(),
        ),
        backgroundColor: const Color(0xFF1F1F1F),
        elevation: 0,
      ),
      bottomSheet: value.purchasePending ? const BottomSheet() : null,
      body: SingleChildScrollView(
          child: hasInternet
              ? _products.isNotEmpty
                  ? Container(
                      padding: const EdgeInsets.only(bottom: 30),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.deepPurple,
                            Colors.purple,
                          ],
                        ),
                      ),
                      child: Column(
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(height: 26),
                              const Text(
                                'FREE',
                                style: TextStyle(
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    _BuyItem(
                                      title: "50 coins",
                                      btnText: _isRewardedAdLoaded
                                          ? "Watch Ad"
                                          : "Try Loading Ad",
                                      onClick: () {
                                        if (_isRewardedAdLoaded) {
                                          if (musicPlayer.isMusicTurnedOn) {
                                            musicPlayer.stopMusic();
                                          }
                                          _rewardedAd.show(
                                            onUserEarnedReward: (ad, reward) {
                                              coinsprovider.addCoin(50);

                                              setState(() {
                                                _isRewardedAdLoaded = false;
                                              });

                                              if (musicPlayer.isMusicTurnedOn) {
                                                musicPlayer.playMusic();
                                              }
                                              loadAd();
                                            },
                                          );
                                        } else {
                                          loadAd();
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 26),
                          const Text(
                            'Buy Coins',
                            style: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                _BuyItem(
                                  priceText: _products[1].price,
                                  title: "100 coins",
                                  btnText: "Buy",
                                  onClick: () async {
                                    value.setCurrentValue("Coins", 100);
                                    final PurchaseParam purchaseParam =
                                        PurchaseParam(
                                            productDetails: _products[1]);
                                    _inAppPurchase.buyConsumable(
                                        purchaseParam:
                                            purchaseParam); //buyNonConsumable to buy non-consumable products
                                  },
                                ),
                                _BuyItem(
                                  priceText: _products[4].price,
                                  title: "500 coins",
                                  btnText: "Buy",
                                  onClick: () async {
                                    value.setCurrentValue("Coins", 500);
                                    final PurchaseParam purchaseParam =
                                        PurchaseParam(
                                            productDetails: _products[4]);
                                    _inAppPurchase.buyConsumable(
                                        purchaseParam:
                                            purchaseParam); //buyNonConsumable to buy non-consumable products
                                  },
                                ),
                                _BuyItem(
                                  priceText: _products[0].price,
                                  title: "1000 coins",
                                  btnText: "Buy",
                                  onClick: () async {
                                    value.setCurrentValue("Coins", 500);
                                    final PurchaseParam purchaseParam =
                                        PurchaseParam(
                                            productDetails: _products[0]);
                                    _inAppPurchase.buyConsumable(
                                        purchaseParam:
                                            purchaseParam); //buyNonConsumable to buy non-consumable products
                                  },
                                ),
                                _BuyItem(
                                  priceText: _products[2].price,
                                  title: "2000 coins",
                                  btnText: "Buy",
                                  onClick: () async {
                                    value.setCurrentValue("Coins", 1000);
                                    final PurchaseParam purchaseParam =
                                        PurchaseParam(
                                            productDetails: _products[2]);
                                    _inAppPurchase.buyConsumable(
                                        purchaseParam:
                                            purchaseParam); //buyNonConsumable to buy non-consumable products
                                  },
                                ),
                                _BuyItem(
                                  priceText: _products[3].price,
                                  title: "5000 coins",
                                  btnText: "Buy",
                                  onClick: () async {
                                    value.setCurrentValue("Coins", 3000);
                                    final PurchaseParam purchaseParam =
                                        PurchaseParam(
                                            productDetails: _products[3]);
                                    _inAppPurchase.buyConsumable(
                                        purchaseParam:
                                            purchaseParam); //buyNonConsumable to buy non-consumable products
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                  : Container(
                      height: 800,
                      padding: const EdgeInsets.only(bottom: 30),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.deepPurple,
                            Colors.purple,
                          ],
                        ),
                      ),
                      child: Column(
                        children: [
                          const SizedBox(
                            height: 20,
                          ),
                          const Text(
                            'FREE',
                            style: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: InkWell(
                              onTap: () {
                                initStoreInfo();
                              },
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  _BuyItem(
                                    title: "50 coins",
                                    btnText: _isRewardedAdLoaded
                                        ? "Watch Ad"
                                        : "Try Loading Ad",
                                    onClick: () {
                                      if (_isRewardedAdLoaded) {
                                        if (musicPlayer.isMusicTurnedOn) {
                                          musicPlayer.stopMusic();
                                        }
                                        _rewardedAd.show(
                                          onUserEarnedReward: (ad, reward) {
                                            coinsprovider.addCoin(50);

                                            setState(() {
                                              _isRewardedAdLoaded = false;
                                            });

                                            if (musicPlayer.isMusicTurnedOn) {
                                              musicPlayer.playMusic();
                                            }
                                            loadAd();
                                          },
                                        );
                                      } else {
                                        loadAd();
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
              : const Padding(
                  padding: EdgeInsets.only(top: 200),
                  child: Center(
                      child: Text("Internet connection is required!",
                          style: TextStyle(color: Colors.red))),
                )),
    );
  }
}

class BottomSheet extends StatelessWidget {
  const BottomSheet({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 20),
          const Text(
            'Processing Your Purchase...',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Divider(
            color: Colors.grey[400],
            thickness: 2,
            indent: 50,
            endIndent: 50,
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 100,
            width: 100,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).primaryColor,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.all(22.0),
            child: Text(
              'Please do not close the app or go back while your purchase is being processed.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.red[600],
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BuyItem extends StatelessWidget {
  final String? priceText;
  final String title;
  final String? btnText;
  final VoidCallback onClick;

  const _BuyItem({
    Key? key,
    this.priceText,
    required this.title,
    required this.onClick,
    this.btnText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Image.asset(
              'assets/images/coin_icon.png', // Replace with the path to your coin icon image
              height: 40,
              width: 40,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    (priceText != null ? '$priceText' : "FREE"),
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: onClick,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
              child: Text(btnText != null ? btnText! : "Buy"),
            ),
          ],
        ),
      ),
    );
  }
}
