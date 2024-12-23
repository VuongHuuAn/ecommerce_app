import 'package:amazon_shop_on/common/widgets/loader.dart';
import 'package:amazon_shop_on/constants/global_variables.dart';
import 'package:amazon_shop_on/features/home/widgets/address_box.dart';
import 'package:amazon_shop_on/features/product_details/screens/product_details_screen.dart';
import 'package:amazon_shop_on/features/search/services/search_services.dart';
import 'package:amazon_shop_on/features/search/widget/searched_product.dart';
import 'package:amazon_shop_on/models/product.dart';
import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  static const String routeName = '/search-screen';
  final String searchQuery;
  const SearchScreen({
    Key? key,
    required this.searchQuery,
  }) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List<Product>? products;
  final SearchServices searchServices = SearchServices();
  final TextEditingController searchController = TextEditingController();
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    searchController.text = widget.searchQuery;
    fetchSearchedProduct();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> fetchSearchedProduct() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      products = await searchServices.fetchSearchedProduct(
        context: context,
        searchQuery: widget.searchQuery,
      );
    } catch (e) {
      errorMessage = 'Error searching products: ${e.toString()}';
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void navigateToSearchScreen(String query) {
    if (query.trim().isNotEmpty) {
      Navigator.pushNamed(context, SearchScreen.routeName, arguments: query);
    }
  }

  Widget _buildSearchBar() {
    return Container(
      height: 42,
      margin: const EdgeInsets.symmetric(horizontal: 15),
      child: Material(
        borderRadius: BorderRadius.circular(7),
        elevation: 1,
        child: TextFormField(
          controller: searchController,
          onFieldSubmitted: navigateToSearchScreen,
          decoration: InputDecoration(
            prefixIcon: const Padding(
              padding: EdgeInsets.only(left: 6),
              child: Icon(Icons.search, color: Colors.black, size: 23),
            ),
            suffixIcon: searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      searchController.clear();
                      FocusScope.of(context).unfocus();
                    },
                  )
                : null,
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.only(top: 10),
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(7)),
              borderSide: BorderSide.none,
            ),
            enabledBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(7)),
              borderSide: BorderSide(color: Colors.black38, width: 1),
            ),
            hintText: 'Search Amazon.in',
            hintStyle: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 17,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultsCount() {
    if (products == null || products!.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        '${products!.length} results found',
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(child: Loader());
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              errorMessage!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: fetchSearchedProduct,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (products?.isEmpty ?? true) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.search_off,
              size: 60,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              'No results found for "${widget.searchQuery}"',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: products!.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () => Navigator.pushNamed(
            context,
            ProductDetailScreen.routeName,
            arguments: products![index],
          ),
          child: SearchedProduct(product: products![index]),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: GlobalVariables.appBarGradient,
            ),
          ),
          title: Row(
            children: [
              Expanded(child: _buildSearchBar()),
              Container(
                color: Colors.transparent,
                height: 42,
                margin: const EdgeInsets.symmetric(horizontal: 10),
                child: const Icon(Icons.mic, color: Colors.black, size: 25),
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          const AddressBox(),
          _buildResultsCount(),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }
}
