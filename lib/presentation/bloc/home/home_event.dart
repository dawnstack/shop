sealed class HomeEvent {
  const HomeEvent();

  factory HomeEvent.loading() = HomeLoading;
}

final class HomeLoading extends HomeEvent {
  const HomeLoading();
}
