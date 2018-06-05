import 'package:invoiceninja/data/models/models.dart';
import 'package:redux/redux.dart';
import 'package:invoiceninja/redux/product/product_actions.dart';
import 'package:invoiceninja/redux/app/app_state.dart';
import 'package:invoiceninja/data/repositories/product_repository.dart';

List<Middleware<AppState>> createStoreProductsMiddleware([
  ProductsRepository repository = const ProductsRepository(),
]) {
  final loadProducts = _loadProducts(repository);
  final saveProduct = _saveProduct(repository);
  final archiveProduct = _archiveProduct(repository);
  final deleteProduct = _deleteProduct(repository);
  final restoreProduct = _restoreProduct(repository);

  return [
    TypedMiddleware<AppState, LoadProductsAction>(loadProducts),
    TypedMiddleware<AppState, SaveProductRequest>(saveProduct),
    TypedMiddleware<AppState, ArchiveProductRequest>(archiveProduct),
    TypedMiddleware<AppState, DeleteProductRequest>(deleteProduct),
    TypedMiddleware<AppState, RestoreProductRequest>(restoreProduct),
  ];
}

Middleware<AppState> _archiveProduct(ProductsRepository repository) {
  return (Store<AppState> store, action, NextDispatcher next) {
    var origProduct = store.state.productState().map[action.productId];
    repository
        .saveData(store.state.selectedCompany(), store.state.authState,
        origProduct, EntityAction.archive)
        .then((product) {
      store.dispatch(ArchiveProductSuccess(product));
      if (action.completer != null) {
        action.completer.complete(null);
      }
    }).catchError((error) {
      print(error);
      store.dispatch(ArchiveProductFailure(origProduct));
    });

    next(action);
  };
}

Middleware<AppState> _deleteProduct(ProductsRepository repository) {
  return (Store<AppState> store, action, NextDispatcher next) {
    var origProduct = store.state.productState().map[action.productId];
    repository
        .saveData(store.state.selectedCompany(), store.state.authState,
        origProduct, EntityAction.delete)
        .then((product) {
      store.dispatch(DeleteProductSuccess(product));
      if (action.completer != null) {
        action.completer.complete(null);
      }
    }).catchError((error) {
      print(error);
      store.dispatch(DeleteProductFailure(origProduct));
    });

    next(action);
  };
}

Middleware<AppState> _restoreProduct(ProductsRepository repository) {
  return (Store<AppState> store, action, NextDispatcher next) {
    var origProduct = store.state.productState().map[action.productId];
    repository
        .saveData(store.state.selectedCompany(), store.state.authState,
        origProduct, EntityAction.restore)
        .then((product) {
      store.dispatch(RestoreProductSuccess(product));
      if (action.completer != null) {
        action.completer.complete(null);
      }
    }).catchError((error) {
      print(error);
      store.dispatch(RestoreProductFailure(origProduct));
    });

    next(action);
  };
}

Middleware<AppState> _saveProduct(ProductsRepository repository) {
  return (Store<AppState> store, action, NextDispatcher next) {
    repository
        .saveData(store.state.selectedCompany(), store.state.authState,
            action.product)
        .then((product) {
      if (action.product.id == null) {
        store.dispatch(AddProductSuccess(product));
      } else {
        store.dispatch(SaveProductSuccess(product));
      }
      action.completer.complete(null);
    }).catchError((error) {
      print(error);
      store.dispatch(SaveProductFailure(error));
    });

    next(action);
  };
}

Middleware<AppState> _loadProducts(ProductsRepository repository) {
  return (Store<AppState> store, action, NextDispatcher next) {
    
    if (! store.state.productState().isStale() && ! action.force) {
      next(action);
      return;
    }

    if (store.state.isLoading) {
      next(action);
      return;
    }

    store.dispatch(LoadProductsRequest());
    repository
        .loadList(store.state.selectedCompany(), store.state.authState)
        .then((data) {
      store.dispatch(LoadProductsSuccess(data));
      if (action.completer != null) {
        action.completer.complete(null);
      }
    }).catchError((error) => store.dispatch(LoadProductsFailure(error)));

    next(action);
  };
}

