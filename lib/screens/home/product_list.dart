// import '../../models/product.dart';
import '../../models/product.dart';

List<Product> generateProductList() {
  return [
    Product(
      id: '1',
      name: 'Iphone 15',
      price: 699.99,
      description: 'Latest smartphone with high-end features.',
      imageUrl:
          'https://thegreytechnologies.in/cdn/shop/products/mini-smartphone-android-5.jpg?v=1701107217&width=1445',
      quantity: 10,
    ),
    Product(
      id: '2',
      name: 'Macbook Pro',
      price: 1299.99,
      description: 'Powerful laptop for gaming and productivity.',
      imageUrl:
          'https://store.storeimages.cdn-apple.com/8756/as-images.apple.com/is/refurb-mbp13touchbar-performance-space-gallery-2020?wid=1144&hei=1144&fmt=jpeg&qlt=90&.v=1591921674000',
      quantity: 10,
    ),
    Product(
      id: '3',
      name: 'Airpods',
      price: 199.99,
      description: 'Noise-cancelling wireless headphones.',
      imageUrl:
          'https://m.media-amazon.com/images/I/61o8blsHYIL._AC_UF350,350_QL80_.jpg',
      quantity: 10,
    ),
    Product(
      id: '4',
      name: 'Smartwatch ',
      price: 249.99,
      description: 'Smartwatch with fitness tracking features.',
      imageUrl:
          'https://www.bigcmobiles.com/media/catalog/product/cache/e19e56cdd4cf1b4ec073d4305f5db95a/b/o/boat_wave_astra_3_smart_watch.jpg',
      quantity: 10,
    ),
    Product(
      id: '5',
      name: '4K Ultra HD TV',
      price: 899.99,
      description: 'Experience stunning picture quality.',
      imageUrl:
          'https://m.media-amazon.com/images/I/31aDWE4msZL._AC_UF1000,1000_QL80_.jpg',
      quantity: 10,
    ),
    Product(
      id: '6',
      name: 'Bluetooth Speaker',
      price: 149.99,
      description: 'Portable Bluetooth speaker with great sound.',
      imageUrl:
          'https://encrypted-tbn0.gstatic.com/shopping?q=tbn:ANd9GcRzGLQGi8Kd2ZdJd6GQkpa-lJFpavXqgDBy-tTb_sdx1nRObjoOE4oIfVpD-vLWwR6mLuvEAwRIh8PvG1T1JWwo0Px632xSJvjdDMAgSSi9BFL-ZQmHuR9V',
      quantity: 10,
    ),
  ];
}
