

import 'package:amazon_shop_on/constants/global_variables.dart';
import 'package:amazon_shop_on/features/account/services/account_service.dart';
import 'package:amazon_shop_on/features/admin/screens/analytics_screen.dart';
import 'package:amazon_shop_on/features/admin/screens/request_screen.dart';
import 'package:amazon_shop_on/features/admin/screens/seller_management_screen.dart';
import 'package:flutter/material.dart';

class AdminScreen extends StatefulWidget {
  static const String routeName = '/admin-screen';
  const AdminScreen({Key? key}) : super(key: key);

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
    final AccountServices accountServices = AccountServices();
  int _page = 0;
  List<Widget> pages = [
    const AnalyticsScreen(),
    const SellerManagementScreen(),
    const RequestsScreen(),
  ];

  void updatePage(int page) {
    setState(() {
      _page = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50),
        child: AppBar(
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: GlobalVariables.appBarGradient,
            ),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                alignment: Alignment.topLeft,
                child: Image.asset(
                  'assets/images/amazon_in.png',
                  width: 120,
                  height: 45,
                  color: Colors.black,
                ),
              ),
              const Text(
                'Admin Panel',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              )
            ],
          ),
          actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => accountServices.logOut(context),
          ),
        ],
        ),
      ),
      body: pages[_page],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _page,
        selectedItemColor: GlobalVariables.selectedNavBarColor,
        unselectedItemColor: GlobalVariables.unselectedNavBarColor,
        backgroundColor: GlobalVariables.backgroundColor,
        iconSize: 28,
        onTap: updatePage,
        items: [
          // ANALYTICS
          BottomNavigationBarItem(
            icon: Container(
              width: 42,
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: _page == 0
                        ? GlobalVariables.selectedNavBarColor
                        : GlobalVariables.backgroundColor,
                    width: 5,
                  ),
                ),
              ),
              child: const Icon(Icons.analytics_outlined),
            ),
            label: 'Analytics',
          ),
          // SELLER MANAGEMENT
          BottomNavigationBarItem(
            icon: Container(
              width: 42,
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: _page == 1
                        ? GlobalVariables.selectedNavBarColor
                        : GlobalVariables.backgroundColor,
                    width: 5,
                  ),
                ),
              ),
              child: const Icon(Icons.people_outline),
            ),
            label: 'Sellers',
          ),
          // REQUESTS
          BottomNavigationBarItem(
            icon: Container(
              width: 42,
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: _page == 2
                        ? GlobalVariables.selectedNavBarColor
                        : GlobalVariables.backgroundColor,
                    width: 5,
                  ),
                ),
              ),
              child: const Icon(Icons.request_page_outlined),
            ),
            label: 'Requests',
          ),
        ],
      ),
    );
  }
}