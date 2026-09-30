import '../00_architecture/result.dart';
import 'product_domain.dart';

sealed class SearchState {
  const SearchState();
}

final class SearchIdle extends SearchState {
  const SearchIdle();
}

final class SearchLoading extends SearchState {
  const SearchLoading(this.query);
  final String query;
}

final class SearchLoaded extends SearchState {
  const SearchLoaded(this.query, this.products);
  final String query;
  final List<Product> products;
}

final class SearchFailed extends SearchState {
  const SearchFailed(this.failure);
  final Failure failure;
}
