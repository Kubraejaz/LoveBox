import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'product_detail_screen.dart'; // ✅ Add this import

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> products = [
      {
        "name": "Rose Box",
        "price": "\$20",
        "image":
            "https://images.unsplash.com/photo-1509042239860-f550ce710b93?ixlib=rb-4.0.3&auto=format&fit=crop&w=600&q=80",
        "description":
            "A beautiful rose box, perfect for gifting your loved one on special occasions.",
      },
      {
        "name": "Chocolate Box",
        "price": "\$15",
        "image":
            "https://images.unsplash.com/photo-1578985545062-69928b1d9587?ixlib=rb-4.0.3&auto=format&fit=crop&w=600&q=80",
        "description":
            "Delicious assorted chocolates packed in a premium gift box to sweeten every moment.",
      },
      {
        "name": "Gift Hamper",
        "price": "\$30",
        "image":
            "https://media.gettyimages.com/id/182664800/photo/a-gift-basket-of-spa-essentials.jpg?s=612x612&w=0&k=20&c=VTuvVSMdKgMHQL3udvvWlP3fzpev7HkGxvRDS2fv3rE=",
        "description":
            "A luxury gift hamper filled with spa essentials to bring relaxation and joy.",
      },
      {
        "name": "Teddy Combo",
        "price": "\$25",
        "image":
            "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSfrHUtnK3RK9WW6Fn3-HlBVdp2VCp7-X-Okg&s",
        "description":
            "Cute teddy bear combo gift set – a soft and adorable present for loved ones.",
      },
      {
        "name": "Perfume Set",
        "price": "\$40",
        "image":
            "https://media.istockphoto.com/id/628348286/photo/vintage-cosmetic-bottles.jpg?s=612x612&w=0&k=20&c=EDCwnKvpVGpi69WO_A_SRJLYdtpvKBJvnMLvYJ3UhB8=",
        "description":
            "A premium perfume set with elegant fragrances to make every moment refreshing.",
      },
      {
        "name": "Flower Bouquet",
        "price": "\$18",
        "image":
            "https://preview.redd.it/more-bouquet-photos-v0-vdhjk7sto2bc1.jpg?width=1080&crop=smart&auto=webp&s=cb97635a23cd2558d4c1a1cea40b6adc66277723",
        "description":
            "Fresh and vibrant flower bouquet, hand-picked to bring smiles and happiness.",
      },
      {
        "name": "Luxury Watch",
        "price": "\$120",
        "image":
            "https://images.unsplash.com/photo-1523275335684-37898b6baf30?ixlib=rb-4.0.3&auto=format&fit=crop&w=600&q=80",
        "description":
            "A luxury wristwatch crafted with elegance and precision – perfect for gifting.",
      },
      {
        "name": "Couple Mug Set",
        "price": "\$12",
        "image":
            "https://rlv.zcache.com/forever_love_heart_pink_floral_custom_coffee_mug_set-rd31c80541708491fa178f21939c7f9c8_za2dq_1024.jpg?rlvnet=1&max_dim=325",
        "description":
            "Custom couple mug set with romantic design – share your morning coffee with love.",
      },
    ];
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "LoveBox",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFFF83758),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Color(0xFFF83758)),
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (Route<dynamic> route) => false,
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 🔍 Search Bar
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: "Search products...",
                  border: InputBorder.none,
                  icon: Icon(Icons.search, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 🛍️ Product Grid
            Expanded(
              child: GridView.builder(
                itemCount: products.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.8,
                ),
                itemBuilder: (context, index) {
                  final product = products[index];
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProductDetailScreen(product: product),
                        ),
                      );
                    },
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(16),
                              ),
                              child: Image.network(
                                product["image"],
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey[200],
                                    child: const Icon(
                                      Icons.broken_image,
                                      size: 50,
                                      color: Colors.grey,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product["name"],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  product["price"],
                                  style: const TextStyle(
                                    color: Color(0xFFF83758),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
