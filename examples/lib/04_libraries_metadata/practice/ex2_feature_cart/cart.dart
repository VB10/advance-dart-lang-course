/// Public API of the cart feature: consumers import ONLY this file.
@FeatureApi('cart')
library;

import '../../metadata/feature_api.dart';

export 'src/cart_module.dart' show createAddToCart;
export 'src/domain.dart' show AddToCart, CartItem, CartRepository;
