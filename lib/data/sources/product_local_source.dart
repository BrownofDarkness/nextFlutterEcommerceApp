import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../../core/constants/app_assets.dart';
import '../models/product.dart';

/// Loads products from the bundled JSON asset.
///
/// Kept intentionally thin so the repository can swap it for a remote source
/// without any consumer noticing. The artificial delay makes loading states
/// visible in the UI (a local asset loads in a few ms otherwise).
class ProductLocalSource {
  const ProductLocalSource();

  Future<List<Product>> loadAll() async {
    await Future.delayed(const Duration(milliseconds: 800));

    final raw = await rootBundle.loadString(AppAssets.productsJson);
    final decoded = json.decode(raw) as List<dynamic>;
    return decoded
        .map((e) => Product.fromJson(e as Map<String, dynamic>))
        .toList(growable: false);
  }
}
