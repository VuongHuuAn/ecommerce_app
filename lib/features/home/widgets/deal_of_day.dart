import 'package:amazon_shop_on/common/widgets/loader.dart';
import 'package:amazon_shop_on/features/home/services/home_services.dart';
import 'package:amazon_shop_on/features/product_details/screens/product_details_screen.dart';
import 'package:amazon_shop_on/models/product.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class DealOfDay extends StatefulWidget {
  const DealOfDay({Key? key}) : super(key: key);

  @override
  State<DealOfDay> createState() => _DealOfDayState();
}

class _DealOfDayState extends State<DealOfDay> {
  final HomeServices homeServices = HomeServices();
  List<Product> dealProducts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchDealOfDay();
  }

  void fetchDealOfDay() async {
    dealProducts = await homeServices.fetchDealOfDay(context: context);
    // Lọc sản phẩm có giảm giá và sắp xếp theo giảm giá từ cao xuống thấp
    dealProducts = dealProducts
        .where((product) =>
            product.finalPrice != null && product.finalPrice! < product.price)
        .toList()
      ..sort((a, b) {
        double discountA = a.price - a.finalPrice!;
        double discountB = b.price - b.finalPrice!;
        return discountB.compareTo(discountA);
      });
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: Loader());
    }
    if (dealProducts.isEmpty) {
      return const SizedBox();
    }

    final hotestDeal = dealProducts[0];
    final otherDeals = dealProducts.sublist(1);
    final hotestDiscount =
        ((hotestDeal.price - hotestDeal.finalPrice!) / hotestDeal.price * 100)
            .toInt();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          alignment: Alignment.topLeft,
          padding: const EdgeInsets.only(left: 15, top: 15),
          child: const Text(
            'Best Deals',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 15),

        // Sản phẩm hot nhất
        GestureDetector(
          onTap: () {
            Navigator.pushNamed(
              context,
              ProductDetailScreen.routeName,
              arguments: hotestDeal,
            );
          },
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 5,
                ),
              ],
            ),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Badge "Hotest Deal"
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(12),
                          bottomRight: Radius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(
                            Icons.local_fire_department,
                            color: Colors.white,
                            size: 16,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'HOTEST DEAL',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: 200,
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      child: Image.network(
                        hotestDeal.images[0],
                        fit: BoxFit.contain,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            hotestDeal.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Text(
                                '\$${hotestDeal.finalPrice!.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '\$${hotestDeal.price}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  decoration: TextDecoration.lineThrough,
                                  color: Colors.grey,
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '-$hotestDiscount%',
                                  style: TextStyle(
                                    color: Colors.red.shade700,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Carousel các sản phẩm khác có giảm giá
        if (otherDeals.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(left: 15),
            child: Row(
              children: const [
                Text(
                  'More Deals',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 260,
            child: CarouselSlider.builder(
              itemCount: otherDeals.length,
              itemBuilder: (context, index, realIndex) {
                final product = otherDeals[index];
                final discount = ((product.price - product.finalPrice!) /
                        product.price *
                        100)
                    .toInt();

                return GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      ProductDetailScreen.routeName,
                      arguments: product,
                    );
                  },
                  child: Container(
                    width: 220,
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 1,
                          blurRadius: 5,
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 140,
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              child: Image.network(
                                product.images[0],
                                fit: BoxFit.contain,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.name,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Text(
                                        '\$${product.finalPrice!.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.red,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '\$${product.price}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          decoration:
                                              TextDecoration.lineThrough,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        // Hot icon
                        Positioned(
                          top: 8,
                          left: 8,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.local_fire_department,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                        // Discount badge
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '-$discount%',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
              options: CarouselOptions(
                height: 280,
                viewportFraction: 0.6,
                enableInfiniteScroll: otherDeals.length > 2,
                autoPlay: otherDeals.length > 2,
                autoPlayInterval: const Duration(seconds: 3),
                enlargeCenterPage: true,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
