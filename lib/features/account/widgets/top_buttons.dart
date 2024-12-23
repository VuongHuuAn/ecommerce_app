import 'package:amazon_shop_on/features/account/screens/seller_request_dialog.dart';
import 'package:amazon_shop_on/features/account/services/account_service.dart';
import 'package:amazon_shop_on/features/account/widgets/account_button.dart';
import 'package:amazon_shop_on/features/seller/screens/seller_screen.dart';

import 'package:amazon_shop_on/features/services/auth_service.dart';
import 'package:amazon_shop_on/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TopButtons extends StatelessWidget {
  const TopButtons({super.key});

  void _handleTurnSeller(BuildContext context) async {
    final AccountServices accountServices = AccountServices();
    final status = await accountServices.checkSellerStatus(context);

    if (!context.mounted) return;

    switch (status) {
      case 'pending':
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Request Pending'),
            content: const Text(
              'Your seller request is still under review. '
              'Please wait for admin approval.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
        break;
      case 'rejected':
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Request Rejected'),
            content: const Text(
              'Your previous seller request was rejected. '
              'Would you like to submit a new request?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  showDialog(
                    context: context,
                    builder: (context) => const SellerRequestDialog(),
                  );
                },
                child: const Text('New Request'),
              ),
            ],
          ),
        );
        break;
      default:
        showDialog(
          context: context,
          builder: (context) => const SellerRequestDialog(),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;
    return Column(
      children: [
        Row(
          children: [
            AccountButton(
              text: 'Your Orders',
              onTap: () {},
            ),
            AccountButton(
              text: (user.type == 'seller') ? 'My shop' : 'Turn Seller',
              onTap: () {                
                if (user.type == 'seller') {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    SellerScreen.routeName,
                    (route) => false,
                  );
                }
                else {
                  _handleTurnSeller(context);
                }
              },
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            AccountButton(
              text: 'Log Out',
              onTap: () => AuthService().signOut(context),
            ),
            AccountButton(
              text: 'Your Wish List',
              onTap: () {},
            ),
          ],
        ),
      ],
    );
  }
}
