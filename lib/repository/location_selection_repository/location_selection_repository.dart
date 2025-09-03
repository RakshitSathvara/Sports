import '../../model/location_selection_response_model.dart';

abstract class LocationSelectionRepository {
  Future<LocationSelectionResponseModel?> getAllCity();
}
