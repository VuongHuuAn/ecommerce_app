import 'package:amazon_shop_on/features/home/screens/category_deals_screen.dart';
import 'package:flutter/material.dart';
import 'package:amazon_shop_on/constants/global_variables.dart';

class TopCategories extends StatelessWidget {
  const TopCategories({super.key});

  String getCategoryValue(String displayTitle) {
  // Chuyển đổi title hiển thị thành giá trị category trong database
  switch (displayTitle) {
    case 'Mobiles':
      return 'Mobiles'; // Sửa lại theo đúng tên trong DB
    case 'Essentials':
      return 'Essentials';
    case 'Appliances':
      return 'Appliances';
    case 'Books':
      return 'Books'; // Sửa từ 'Book' thành 'Books'
    case 'Fashion':
      return 'Fashion';
    default:
      return displayTitle;
  }
}

  void navigateToCategoryPage(BuildContext context, String displayCategory) {
    // Chuyển đổi category trước khi navigate
    String categoryValue = getCategoryValue(displayCategory);
    Navigator.pushNamed(
      context, 
      CategoryDealsScreen.routeName,
      arguments: categoryValue,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: ListView.builder(
        itemCount: GlobalVariables.categoryImages.length,
        scrollDirection: Axis.horizontal,
        itemExtent: 75,
        itemBuilder: (context, index) {
          final displayTitle = GlobalVariables.categoryImages[index]['title']!;
          
          return GestureDetector(
            onTap: () => navigateToCategoryPage(context, displayTitle),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: Image.asset(
                      GlobalVariables.categoryImages[index]['image']!,
                      fit: BoxFit.cover,
                      height: 40,
                      width: 40,
                    ),
                  ),
                ),
                Text(
                  displayTitle,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}