# Sports App

This project demonstrates a layered architecture using **data**, **domain** and **presentation** folders. Each feature exposes:

- **Domain**: entities, use cases and abstract repositories.
- **Data**: DTO models, repository implementations and remote data sources with JSON serialization.
- **Presentation**: `StatelessWidget` screens powered by Bloc.

Navigation is handled by [`go_router`](https://pub.dev/packages/go_router). Routes are defined centrally and blocs are injected through route configuration.

Dependency injection is managed with [`get_it`](https://pub.dev/packages/get_it). Repositories, use cases and blocs are registered in `di/injection.dart` and resolved where needed.

Run `flutter pub get` after fetching the repository to install required packages.
