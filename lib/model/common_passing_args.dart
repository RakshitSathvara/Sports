import 'package:oqdo_mobile_app/model/location_selection_response_model.dart';

class CommonPassingArgs {
  List<DataBean>? selectedCityDetails;
  int? tempRegisterId;
  String? mobileNo;
  String? emilID;
  String? facilityName;
  String? postalCode;
  String? address;
  String? profileImageUploadId = null;
  List<ContactDetails>? FacilityProviderContactDtos;
  String? registrationNumberUEN;
  String? establishmentSince;
  String? coachFirstName;
  String? coachLastName;
  String? coachICNumber;
  String? coachRegistryNumber;
  String? coachEstablishmentYear;
  String? uenNUmber;
  Map? endUserActivitySelection;
  bool? endUserActivitySelected = false;
}

class ContactDetails {
  String? Name;
  String? MobCountryCode;
  String? MobileNumber;
}

class SelectedFilterValues {
  String? activityName;
  int? subActivityId;

  SelectedFilterValues({this.activityName, this.subActivityId});
}

class EmailOTPModel{
  String? email;
  String? otp;

  EmailOTPModel(this.email, this.otp);
}
