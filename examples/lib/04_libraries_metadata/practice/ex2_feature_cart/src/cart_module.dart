import 'data/in_memory_cart_repository.dart';
import 'domain.dart';

AddToCart createAddToCart({Set<String> catalog = const {}}) =>
    AddToCart(InMemoryCartRepository({...catalog}));
