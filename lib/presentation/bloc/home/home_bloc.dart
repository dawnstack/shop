import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shop/domain/entities/data_result.dart';
import 'package:shop/domain/usecase/home_usecase.dart';
import 'package:shop/presentation/bloc/home/home_event.dart';
import 'package:shop/presentation/bloc/home/home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final HomeUsecase _homeUsecase;
  HomeBloc(this._homeUsecase) : super(HomeState.initial()) {
    on<HomeEvent>(_onEvent);
  }

  Future<void> _onEvent(HomeEvent event, Emitter<HomeState> emit) async {
    await event.map(
      loading: (_) async {
        emit(HomeState.initial());
        await _fetchBanners(emit);
        await _fetchCategory(emit);
        await _fetchProduct(emit);
      },
    );
  }

  Future<void> _fetchBanners(Emitter<HomeState> emit) async {
    final result = await _homeUsecase.getBanner();
    switch (result) {
      case Success(data: final bannerList):
        emit(state.copyWith(bannerList: bannerList, isLoadingBanner: false));
        break;
      case Failure(message: final msg):
        emit(state.copyWith(isLoadingBanner: false, errorMessage: msg));
        break;
    }
  }

  Future<void> _fetchCategory(Emitter<HomeState> emit) async {
    final result = await _homeUsecase.getCategory();
    switch (result) {
      case Success(data: final categoryList):
        emit(
          state.copyWith(isLoadingCategory: false, categoryList: categoryList),
        );
        break;
      case Failure(message: final msg):
        emit(state.copyWith(isLoadingCategory: false, errorMessage: msg));
        break;
    }
  }

  Future<void> _fetchProduct(Emitter<HomeState> emit) async {
    final result = await _homeUsecase.getProduct();
    switch (result) {
      case Success(data: final list):
        emit(state.copyWith(productList: list, isLoadingProduct: false));
        break;
      case Failure(message: final msg):
        emit(state.copyWith(errorMessage: msg, isLoadingProduct: false));
        break;
    }
  }
}
