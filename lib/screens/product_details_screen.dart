import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:practical_task/model/product_response_model.dart';

class ProductDetailsScreen extends StatefulWidget {
  final Product product;
  const ProductDetailsScreen({super.key, required this.product});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  Product? product;
  PageController controller=PageController();
  int current=0;

  @override
  void initState() {
    // TODO: implement initState
    product = widget.product;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Detail',style: TextStyle(fontWeight: FontWeight.w500,fontSize: 18)),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(product!.title,style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 21, ),textAlign: TextAlign.center),
              ),
              SizedBox(
                height: height * 0.01,
              ),
              buildImageView(width, height),
              const Divider(),
              const Text("Description",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              SizedBox(
                height: height * 0.01,
              ),
              Text(product!.description),
              SizedBox(
                height: height * 0.02,
              ),
              const Text("Reviews ",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              SizedBox(
                height: height * 0.02,
              ),
              buildExpanded(),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildImageView(double width, double height) {
    return Card(
              child: SizedBox(
                height: 200,
                child: PageView.builder(
                  itemCount: product!.images.length,
                  itemBuilder: (context, index) {
                    return Image.network(
                      product!.images[index],
                      width: width * 0.25,
                      height: height * 0.15,
                    );
                  },
                  scrollDirection: Axis.horizontal,
                  controller: controller,
                  onPageChanged: (int num){
                    setState(() {
                      current=num;
                    });
                  },
                ),
            ),);
  }

  Widget buildExpanded() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: product!.reviews.length,
      itemBuilder: (context, index) {
        final review = product!.reviews[index];
        DateTime date = DateTime.parse(review.date);
        String suffix;
        if (date.day >= 11 && date.day <= 13) {
          suffix = 'th';
        } else {
          switch (date.day % 10) {
            case 1:
              suffix = 'st';
              break;
            case 2:
              suffix = 'nd';
              break;
            case 3:
              suffix = 'rd';
              break;
            default:
              suffix = 'th';
          }
        }
        String formattedMonth = DateFormat('MMM').format(date);
        String formattedYear = DateFormat('yyyy').format(date);
        String finalDate =
            "${date.day}$suffix $formattedMonth $formattedYear";
        return IntrinsicHeight(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(
                  10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(
                    "${review.reviewerName} on $finalDate",
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  Text(
                    '${review.rating} stars',
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  Text(
                    review.comment,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w400),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      separatorBuilder: (BuildContext context, int index) {
        return const SizedBox(
          height: 10,
        );
      },
    );
  }
}
