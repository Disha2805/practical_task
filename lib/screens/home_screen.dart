import 'package:flutter/material.dart';
import 'package:practical_task/screens/product_details_screen.dart';
import 'package:practical_task/screens/provider_controller/product_provider.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    // TODO: implement initState
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductProvider>(context, listen: false).fetchProducts();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);

    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;


    return Scaffold(
      appBar: AppBar(title: const Text('All Products'), actions:  [
        GestureDetector(
          onTap:() async {

            List<String> brands = [];

            if( productProvider.number == 0) {
              for (var element in productProvider.filterData) {
                brands.addAll(element?.brands ?? []);
              }
            } else {
              brands = productProvider.filterData[productProvider.number]?.brands ?? [];
            }



        await  buildDialogBox(
          title: productProvider.filterData[productProvider.number]?.categoryName ?? "",
          brands: brands,
          provider: productProvider,
        );
        },
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Icon(Icons.filter_list_alt),
          ),
        )
      ]),

      body: productProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                SizedBox(
                  height: height * 0.09,
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    itemCount: productProvider.filterData.length,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemBuilder: (context, index) {
                      final product = productProvider.filterData[index];
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: GestureDetector(
                          onTap: () => productProvider.updateIndex(index),
                          child: Card(
                            shape: OutlineInputBorder(
                              borderSide:  BorderSide(color: productProvider.number == index ? Colors.deepPurple : Colors.transparent,),
                              borderRadius: BorderRadius.circular(12),
                            ),
                          
                              child: Center(
                                  child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Text(
                              (product?.categoryName ?? ""),
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 17),
                            ),
                          ),),),
                        ),
                      );
                    },
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),
                    itemCount: productProvider.getProductsData().length,
                    padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 15),
                    itemBuilder: (context, index) {
                      final product = productProvider.getProductsData()[index];

                      if(productProvider.selectedFilter.isNotEmpty){
                        if(!productProvider.selectedFilter.contains(product.brand)){
                          return const SizedBox();
                        }
                      }
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 15),
                        child: GestureDetector(
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ProductDetailsScreen(product: product),)),
                          child : IntrinsicHeight(
                            child: Card(clipBehavior: Clip.antiAlias,
                              child: Stack(
                                clipBehavior: Clip.antiAlias,
                                children: [
                                  Row(
                                    children: [
                                      Image.network(
                                        product.thumbnail,
                                        width: width * 0.25,
                                        height: height * 0.15,
                                      ),
                                      const VerticalDivider(),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.only(left: 8,right: 15),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                                            children: [
                                              Text(
                                                product.title,
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 17),
                                              ),
                                              Row(
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  Expanded(child: Text(product.brand == null ? "No Brand" :'${product.brand}',style: const TextStyle(fontSize: 12),)),
                                                  Expanded(child: Align(alignment: Alignment.centerRight,child: Text('\$${product.price}',style: const TextStyle(fontSize: 14,fontWeight: FontWeight.w700),)),),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                  if(product.discountPercentage > 0.0)
                                  Positioned(
                                    top: 6,
                                    left: -20,
                                    child: Transform.rotate(
                                      angle: -0.7,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 25),
                                        decoration: BoxDecoration(
                                          color: Colors.red.withOpacity(0.1),
                                          border: const Border.symmetric(
                                            horizontal: BorderSide(color: Colors.red)
                                          ),
                                        ),
                                        alignment: Alignment.center,
                                        child: Text(
                                          "${product.discountPercentage}%",
                                          style: const TextStyle(
                                            color: Colors.red,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  buildDialogBox({
    required String title,
    required List<String> brands,
    required ProductProvider provider,
}){
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context,setState1) {
            return AlertDialog(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(title,style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 18)),
                  GestureDetector(onTap: () => Navigator.pop(context),child: const Icon(Icons.close,color: Colors.black,))
                ],
              ),
              content: SizedBox(
                height: 400,
                child: SingleChildScrollView(
                  child: Column(
                    children: List.generate(brands.length, (index) => CheckboxListTile(
                      title: Text(brands[index]),
                      value: provider.selectedFilter.contains(brands[index]),
                      onChanged: (value) {
                      provider.onSelectFilter(brands[index]);
                      setState1(() {

                      });
                      },
                    ),),
                  ),
                ),
              ),
            );
          }
        );
      },
    );


  }


}
